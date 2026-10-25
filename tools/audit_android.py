"""Audit an actual APK. Preview success does not imply store readiness."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import struct
import subprocess
import sys
import zipfile
from run_checks import source_digest

ROOT = Path(__file__).resolve().parents[1]
BUILD_TOOLS = Path('/workspace/runtime/android-sdk/build-tools/36.1.0')

def elf_load_alignments(data):
    if len(data) < 64 or data[:4] != b'\x7fELF' or data[4] not in (1,2) or data[5] not in (1,2):
        raise ValueError('Invalid or truncated ELF header')
    endian = '<' if data[5] == 1 else '>'
    wide = data[4] == 2
    offset = struct.unpack_from(endian+('Q' if wide else 'I'),data,32 if wide else 28)[0]
    size, count = struct.unpack_from(endian+'HH',data,54 if wide else 42)
    required = 56 if wide else 32
    if count == 0 or size < required or offset+size*count > len(data):
        raise ValueError('Invalid or truncated ELF program table')
    values=[]
    for index in range(count):
        at=offset+index*size
        if struct.unpack_from(endian+'I',data,at)[0] == 1:
            values.append(struct.unpack_from(endian+('Q' if wide else 'I'),data,at+(48 if wide else 28))[0])
    if not values: raise ValueError('ELF has no loadable segments')
    return values

def production_blockers(facts):
    blockers=[]
    for key,description in [
        ('debuggable','APK is debuggable'),('debug_certificate','APK uses a development signing certificate'),
        ('preview_version','Application version is marked preview/test'),('sandbox_services','Services still use sandbox mode'),
        ('test_provider_ids','Native providers still contain test advertising/product IDs')]:
        if facts[key]: blockers.append(description)
    for field in ('privacy_policy_url','support_url'):
        value=facts['release'].get(field,'')
        if not re.fullmatch(r'https://[^\s/]+(?:/[^\s]*)?',value): blockers.append(field+' is not configured with an HTTPS URL')
    for field in ('physical_device_report','play_sandbox_report','creative_review_report'):
        report=facts['evidence'].get(field,{})
        if not isinstance(report,dict) or report.get('passed') is not True or report.get('source_sha256') != facts['source_sha256']:
            blockers.append(field+' has no passing evidence for the current source')
    return blockers

def inspect(apk):
    def command(name,*args):
        return subprocess.check_output([str(BUILD_TOOLS/name),*map(str,args)],stderr=subprocess.STDOUT,text=True)
    badging=command('aapt','dump','badging',apk)
    cert=command('apksigner','verify','--print-certs',apk)
    command('zipalign','-c','-P','16','4',apk)
    report=json.loads((ROOT/'artifacts/test-results.json').read_text())
    digest=source_digest()
    checks={
        'matching_passing_tests':report.get('passed') is True and report.get('source_sha256')==digest,
        'package_identity':"package: name='com.thedarkstrix.pocketbiome'" in badging,
        'min_sdk_24':"sdkVersion:'24'" in badging,
        'target_sdk_36':"targetSdkVersion:'36'" in badging,
        'portrait':"portrait" in badging,
        'no_sensitive_capture_permissions':not any(p in badging for p in ('android.permission.RECORD_AUDIO','android.permission.CAMERA','android.permission.ACCESS_FINE_LOCATION')),
        'signature_verified':True,'zip_16k_alignment':True}
    libraries={}
    with zipfile.ZipFile(apk) as archive:
        names=archive.namelist()
        try: stamp=json.loads(archive.read('assets/data/build_info.json'))
        except (KeyError,ValueError): stamp={}
        checks['embedded_source_matches_tests']=stamp.get('source_sha256')==digest
        checks['arm64_present']=any(n.startswith('lib/arm64-v8a/') for n in names)
        checks['qa_files_excluded']=not any(n.startswith(('assets/tests/','assets/tools/','assets/docs/','assets/native/')) for n in names)
        for name in names:
            if name.startswith('lib/') and name.endswith('.so'):
                libraries[name]=elf_load_alignments(archive.read(name))
    checks['elf_16k_load_alignment']=bool(libraries) and all(a>=16384 for values in libraries.values() for a in values)
    release=json.loads((ROOT/'data/release.json').read_text())
    evidence={}
    for field in ('physical_device_report','play_sandbox_report','creative_review_report'):
        location=release.get(field,'')
        if location:
            try: evidence[field]=json.loads((ROOT/location).read_text())
            except (OSError,ValueError): evidence[field]={}
    native=(ROOT/'native/android/src/com/pocketbiome/PocketServices.kt').read_text()
    version=re.search(r"versionName='([^']*)'",badging)
    facts={'source_sha256':digest,'debuggable':'application-debuggable' in badging,
        'debug_certificate':'CN=Android Debug' in cert,
        'preview_version':not version or bool(re.search('preview|test|debug',version[1],re.I)),
        'sandbox_services':json.loads((ROOT/'data/services.json').read_text()).get('mode')!='production',
        'test_provider_ids':'ca-app-pub-3940256099942544' in native or '_test"' in native,
        'release':release,'evidence':evidence}
    blockers=production_blockers(facts)
    return {'apk':str(apk.relative_to(ROOT) if apk.is_relative_to(ROOT) else apk),
        'apk_sha256':hashlib.sha256(apk.read_bytes()).hexdigest(),'source_sha256':digest,
        'checks':checks,'elf_load_alignments':libraries,'preview_checks_passed':all(checks.values()),
        'production_blockers':blockers,'store_release_ready':all(checks.values()) and not blockers,
        'note':'Static artifact/configuration audit. Evidence declarations require human review; this is not store approval or a device benchmark.'}

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--apk',type=Path,required=True)
    parser.add_argument('--production',action='store_true');parser.add_argument('--output',type=Path,default=ROOT/'artifacts/android-package-audit.json')
    args=parser.parse_args()
    try: result=inspect(args.apk.resolve())
    except (OSError,ValueError,subprocess.CalledProcessError) as error:
        result={'preview_checks_passed':False,'store_release_ready':False,'error':str(error)}
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
    return 0 if result.get('store_release_ready' if args.production else 'preview_checks_passed') else 2

if __name__=='__main__':sys.exit(main())
