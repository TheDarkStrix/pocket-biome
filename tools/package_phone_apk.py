"""Produce an ARM64 download from the verified universal debug APK, preserving files."""
from pathlib import Path
import hashlib
import json
import os
import subprocess
import tempfile
import zipfile
from run_checks import source_digest

ROOT = Path(__file__).resolve().parents[1]
SDK_TOOLS = Path('/workspace/runtime/android-sdk/build-tools/36.1.0')
SOURCE = ROOT / 'builds/PocketBiome-debug.apk'
OUTPUT = ROOT / 'builds/PocketBiome-Android-test.apk'

def run(*args):
    subprocess.run([str(a) for a in args], check=True)

def retained(name):
    if name.startswith('lib/x86_64/'):
        return False
    upper = name.upper()
    # Preserve service-loader entries and dependency metadata; discard only old signatures.
    return not (upper == 'META-INF/MANIFEST.MF' or
                (upper.startswith('META-INF/') and upper.count('/') == 1 and
                 upper.endswith(('.SF', '.RSA', '.DSA', '.EC'))))

def main():
    report = json.loads((ROOT / 'artifacts/test-results.json').read_text())
    if not report['passed'] or report['source_sha256'] != source_digest():
        raise RuntimeError('Refusing to package with a failing test report')
    with tempfile.TemporaryDirectory(dir=ROOT / 'builds') as scratch:
        scratch = Path(scratch)
        unsigned, aligned, signed = (scratch / n for n in ('unsigned.apk','aligned.apk','signed.apk'))
        with zipfile.ZipFile(SOURCE) as old, zipfile.ZipFile(unsigned, 'w') as new:
            for entry in old.infolist():
                if retained(entry.filename):
                    new.writestr(entry, old.read(entry))
        run(SDK_TOOLS / 'zipalign', '-P', '16', '-f', '4', unsigned, aligned)
        run(SDK_TOOLS / 'apksigner', 'sign', '--ks', '/workspace/runtime/android-user/debug.keystore',
            '--ks-key-alias', 'androiddebugkey', '--ks-pass', 'pass:android', '--out', signed, aligned)
        run(SDK_TOOLS / 'apksigner', 'verify', signed)
        run(SDK_TOOLS / 'zipalign', '-c', '-P', '16', '4', signed)
        with zipfile.ZipFile(SOURCE) as old, zipfile.ZipFile(signed) as new:
            names = [n for n in old.namelist() if retained(n)]
            assert all(old.read(n) == new.read(n) for n in names), 'Retained APK contents changed'
            assert not any(n.startswith('lib/x86_64/') for n in new.namelist())
        os.replace(signed, OUTPUT)
    digest = hashlib.sha256(OUTPUT.read_bytes()).hexdigest()
    OUTPUT.with_suffix('.apk.sha256').write_text(digest + '  ' + OUTPUT.name + '\n')
    (ROOT / 'artifacts/android-phone-build.json').write_text(json.dumps({
        'source_sha256': report['source_sha256'], 'assertions': report['assertions'],
        'apk_sha256': digest, 'bytes': OUTPUT.stat().st_size, 'abi': 'arm64-v8a',
        'retained_files_verified': len(names), 'signature_and_alignment_verified': True,
        'physical_device_tested': False,
        'note': 'Debug test build; identical retained game/native files to universal APK. Not store certification.'
    }, indent=2) + '\n')
    print(OUTPUT)

if __name__ == '__main__':
    main()
