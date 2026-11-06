"""Capture a source-bound Android startup smoke check; never claim full device acceptance."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import re
import subprocess
import zipfile
from run_checks import source_digest

ROOT = Path(__file__).resolve().parents[1]
ADB = Path('/workspace/runtime/android-sdk/platform-tools/adb')
PACKAGE = 'com.thedarkstrix.pocketbiome'

def authorized_devices(output):
    return [parts[0] for line in output.splitlines() if len(parts := line.split()) == 2 and parts[1] == 'device']

def embedded_source(apk):
    with zipfile.ZipFile(apk) as archive:
        return json.loads(archive.read('assets/data/build_info.json'))['source_sha256']

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apk', type=Path, default=ROOT/'builds/PocketBiome-Android-test.apk')
    parser.add_argument('--serial', help='Explicitly install/update and launch on this authorized device.')
    parser.add_argument('--output', type=Path, default=ROOT/'artifacts/device-smoke.json')
    args = parser.parse_args()
    report = {'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'source_sha256': source_digest(),
              'passed': False, 'startup_smoke_passed': False, 'physical_device_qualified': False,
              'scope': 'Startup/log/screenshot smoke only. Full touch, save/resume, performance, audio, consent and provider acceptance require the device playthrough checklist.',
              'remaining': ['first launch and full tutorial', 'all advanced lessons', 'complete campaign', 'save/background/process-death recovery',
                            'touch/readability/accessibility', 'thermal/battery/audio', 'no-fill and consent on real SDK', 'sandbox purchase/restore and Android sharing']}
    try:
        inventory = subprocess.check_output([str(ADB), 'devices'], text=True, stderr=subprocess.STDOUT, timeout=15)
        devices = authorized_devices(inventory)
        report['authorized_device_count'] = len(devices)
        if not devices:
            report['blocked'] = 'No authorized Android device or emulator is attached.'
        elif args.serial is None:
            report['blocked'] = 'Choose --serial to explicitly install/update and launch the test APK.'
        elif args.serial not in devices:
            report['blocked'] = 'Requested serial is not an authorized attached device.'
        elif embedded_source(args.apk) != report['source_sha256']:
            report['blocked'] = 'APK source differs from the current tested checkout; rebuild first.'
        else:
            def adb(*parts, binary=False):
                return subprocess.check_output([str(ADB), '-s', args.serial, *parts], text=not binary, stderr=subprocess.STDOUT, timeout=45)
            report['apk_sha256'] = hashlib.sha256(args.apk.read_bytes()).hexdigest()
            report['serial_sha256'] = hashlib.sha256(args.serial.encode()).hexdigest()
            report['install_output'] = adb('install', '-r', str(args.apk)).strip()
            adb('shell', 'am', 'force-stop', PACKAGE)
            launch = adb('shell', 'am', 'start', '-W', '-n', PACKAGE+'/com.godot.game.GodotApp')
            report['launch_output'] = launch.strip()
            pid = adb('shell', 'pidof', '-s', PACKAGE).strip()
            if not re.fullmatch(r'\d+', pid):
                raise RuntimeError('App process did not remain running after launch.')
            logs = adb('logcat', '-d', '--pid='+pid, '-t', '400')
            screenshot = adb('exec-out', 'screencap', '-p', binary=True)
            if not screenshot.startswith(b'\x89PNG\r\n\x1a\n'):
                raise RuntimeError('Device did not return a PNG screenshot.')
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.with_suffix('.png').write_bytes(screenshot)
            args.output.with_suffix('.log').write_text(logs)
            report['startup_smoke_passed'] = 'Status: ok' in launch and not re.search(r'FATAL EXCEPTION|SCRIPT ERROR:|^ERROR:', logs, re.MULTILINE)
    except (OSError, ValueError, KeyError, zipfile.BadZipFile, RuntimeError, subprocess.SubprocessError) as error:
        report['blocked'] = str(error)[:500]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))
    return 0 if report['startup_smoke_passed'] else 2

if __name__ == '__main__':
    raise SystemExit(main())
