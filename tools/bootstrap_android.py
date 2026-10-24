"""Reproduce the verified Linux cloud toolchain without weakening TLS/checksums.
Run with --install-sdk to install the requested Android packages/licenses.
Toolchain files stay outside the checkout. Godot 4.6.3 must already be on PATH.
"""
from pathlib import Path
import argparse
import hashlib
import os
import subprocess
import tarfile
import urllib.parse
import urllib.request
import zipfile

RUNTIME = Path('/workspace/runtime')
DOWNLOADS = RUNTIME / 'downloads'
ROOT = Path(__file__).resolve().parents[1]

def verified(url, name, checksum, algorithm='sha256'):
    path = DOWNLOADS / name
    if not path.exists():
        partial = path.with_suffix(path.suffix + '.part')
        urllib.request.urlretrieve(url, partial)
        partial.rename(path)
    digest = hashlib.new(algorithm)
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    if digest.hexdigest() != checksum:
        raise RuntimeError('Checksum mismatch: ' + name)
    print('Verified ' + name, flush=True)
    return path

def remote_text(url):
    with urllib.request.urlopen(url, timeout=60) as response:
        return response.read().decode()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--install-sdk', action='store_true')
    args = parser.parse_args()
    DOWNLOADS.mkdir(parents=True, exist_ok=True)
    version = subprocess.check_output(['godot', '--version'], text=True)
    if not version.startswith('4.6.3.stable'):
        raise RuntimeError('Install official Godot 4.6.3 before this Android bootstrap')
    jdk_base = 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/'
    name = 'OpenJDK17U-jdk_x64_linux_hotspot_17.0.16_8.tar.gz'
    archive = verified(jdk_base + name, name, remote_text(jdk_base + name + '.sha256.txt').split()[0])
    java = RUNTIME / 'jdk/jdk-17.0.16+8'
    if not (java / 'bin/javac').exists():
        java.parent.mkdir(parents=True, exist_ok=True)
        with tarfile.open(archive) as source:
            source.extractall(java.parent, filter='data')
    name = 'gradle-8.11.1-bin.zip'
    verified('https://services.gradle.org/distributions/' + name, name,
             'f397b287023acdba1e9f6fc5ea72d22dd63669d59ed4a289a29b1a76eee151c6')
    base = 'https://github.com/godotengine/godot-builds/releases/download/4.6.3-stable/'
    name = 'Godot_v4.6.3-stable_export_templates.tpz'
    sums = {line.split()[1]: line.split()[0] for line in remote_text(base + 'SHA512-SUMS.txt').splitlines() if len(line.split()) == 2}
    archive = verified(base + name, name, sums[name], 'sha512')
    output = RUNTIME / 'data/godot/export_templates/4.6.3.stable'
    output.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as source:
        for member in source.namelist():
            leaf = member.rsplit('/', 1)[-1]
            if leaf in ['android_debug.apk', 'android_release.apk', 'android_source.zip', 'linux_debug.x86_64', 'linux_release.x86_64']:
                target = output / leaf
                if not target.exists():
                    target.write_bytes(source.read(member))
                    target.chmod(0o755)
    # Google's repository metadata pins this stable command-line-tools 19 archive.
    name = 'commandlinetools-linux-13114758_latest.zip'
    archive = verified('https://dl.google.com/android/repository/' + name, name,
                       '5fdcc763663eefb86a5b8879697aa6088b041e70', 'sha1')
    sdk = RUNTIME / 'android-sdk'
    manager = sdk / 'cmdline-tools/19.0/bin/sdkmanager'
    if not manager.exists():
        temporary = sdk / 'pinned-bootstrap'
        temporary.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(archive) as source:
            source.extractall(temporary)
        manager.parent.parent.parent.mkdir(parents=True, exist_ok=True)
        (temporary / 'cmdline-tools').rename(manager.parent.parent)
        for path in manager.parent.iterdir():
            path.chmod(0o755)
    env = os.environ.copy()
    env.update(JAVA_HOME=str(java), ANDROID_HOME=str(sdk), ANDROID_SDK_ROOT=str(sdk),
               ANDROID_USER_HOME=str(RUNTIME / 'android-user'), GRADLE_USER_HOME=str(RUNTIME / 'gradle'))
    trust = '/etc/ssl/certs/java/cacerts'
    if Path(trust).exists():
        env['JAVA_TOOL_OPTIONS'] = '-Djavax.net.ssl.trustStore=' + trust
    proxy = urllib.parse.urlsplit(os.environ.get('HTTPS_PROXY', ''))
    options = []
    properties = []
    if proxy.hostname:
        options = ['--proxy=http', '--proxy_host=' + proxy.hostname, '--proxy_port=' + str(proxy.port or 80)]
        for scheme in ['http', 'https']:
            properties += [f'systemProp.{scheme}.proxyHost={proxy.hostname}', f'systemProp.{scheme}.proxyPort={proxy.port or 80}']
    if Path(trust).exists():
        properties.append('systemProp.javax.net.ssl.trustStore=' + trust)
    gradle_settings = RUNTIME / 'gradle/gradle.properties'
    gradle_settings.parent.mkdir(parents=True, exist_ok=True)
    # This file is managed solely by this bootstrap, never copy proxy credentials.
    gradle_settings.write_text('\n'.join(properties) + '\n')
    if args.install_sdk:
        subprocess.run([str(manager), '--sdk_root=' + str(sdk), *options, 'platform-tools',
                        'platforms;android-36', 'build-tools;36.1.0', 'ndk;29.0.14206865'],
                       env=env, input='y\n' * 20, text=True, check=True)
    key = RUNTIME / 'android-user/debug.keystore'
    key.parent.mkdir(parents=True, exist_ok=True)
    if not key.exists():
        subprocess.run([str(java / 'bin/keytool'), '-genkeypair', '-keystore', str(key), '-storepass', 'android',
                        '-alias', 'androiddebugkey', '-keypass', 'android', '-keyalg', 'RSA', '-keysize', '2048',
                        '-validity', '10000', '-dname', 'CN=Android Debug,O=Android,C=US'], check=True)
    # Preserve unrelated editor settings; replace only managed Android path fields.
    config = RUNTIME / 'config/godot/editor_settings-4.6.tres'
    config.parent.mkdir(parents=True, exist_ok=True)
    text = config.read_text() if config.exists() else '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
    keys = {'export/android/java_sdk_path': str(java), 'export/android/android_sdk_path': str(sdk),
            'export/android/debug_keystore': str(key), 'export/android/debug_keystore_user': 'androiddebugkey',
            'export/android/debug_keystore_pass': 'android'}
    text = '\n'.join(line for line in text.splitlines() if not any(line.startswith(k + ' =') for k in keys)) + '\n'
    for key, value in keys.items():
        text += key + ' = "' + value + '"\n'
    config.write_text(text)
    subprocess.run(['python3', str(ROOT / 'tools/prepare_native.py')], check=True)
    subprocess.run([str(java / 'bin/javac'), '-version'], check=True)
    print('Verified toolchain prepared. Run tools/build_android.sh for import, tests and export.')

if __name__ == '__main__':
    main()
