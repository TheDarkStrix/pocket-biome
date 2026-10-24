from pathlib import Path
import shutil, zipfile
root=Path(__file__).resolve().parents[1]
build=root/'android/build'
if not build.exists():
 build.mkdir(parents=True)
 with zipfile.ZipFile('/workspace/runtime/data/godot/export_templates/4.6.3.stable/android_source.zip') as archive: archive.extractall(build)
(build/'gradlew').chmod(0o755)
(build/'.gdignore').touch()
(root/'android/.build_version').write_text('4.6.3.stable\n')
for source in (root/'native/android/src').rglob('*.kt'):
 target=build/'src/main/java'/source.relative_to(root/'native/android/src');target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,target)
for source in (root/'native/android/res').rglob('*.xml'):
 target=build/'res'/source.relative_to(root/'native/android/res');target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,target)
p=build/'build.gradle';s=p.read_text()
if 'play-services-ads:23.6.0' not in s:
 s=s.replace('dependencies {','dependencies {\n    implementation "com.google.android.gms:play-services-ads:23.6.0"\n    implementation "com.google.android.ump:user-messaging-platform:3.1.0"\n    implementation "com.android.billingclient:billing:8.0.0"',1)
# Same Google artifacts and TLS verification; use the official host available in the sandbox.
s=s.replace('google()', 'maven { url "https://dl.google.com/dl/android/maven2/" }')
p.write_text(s)
p=build/'settings.gradle';p.write_text(p.read_text().replace('google()', 'maven { url "https://dl.google.com/dl/android/maven2/" }'))
p=build/'src/main/AndroidManifest.xml';s=p.read_text().replace('android:name="androidx.core.content.FileProvider"','android:name="com.pocketbiome.PocketShareProvider"')
metadata='''
        <meta-data android:name="org.godotengine.plugin.v2.PocketServices" android:value="com.pocketbiome.PocketServices" />
        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-3940256099942544~3347511713" />
        <provider android:name="com.pocketbiome.PocketShareProvider" android:authorities="${applicationId}.pocket.share" android:exported="false" android:grantUriPermissions="true">
            <meta-data android:name="android.support.FILE_PROVIDER_PATHS" android:resource="@xml/pocket_share_paths" />
        </provider>
'''
if 'plugin.v2.PocketServices' not in s:s=s.replace('</application>',metadata+'\n</application>')
p.write_text(s)
(build/'local.properties').write_text('sdk.dir=/workspace/runtime/android-sdk\n')
# Bound Gradle parallelism and heap to reduce contention during emulator validation.
p=build/'gradle.properties';s=p.read_text();s="\n".join(line for line in s.splitlines() if not line.startswith(("org.gradle.workers.max=","org.gradle.jvmargs=")))+'\norg.gradle.workers.max=4\norg.gradle.jvmargs=-Xmx3072m -Dfile.encoding=UTF-8\n';p.write_text(s)

# Use the checksum-pinned local distribution prepared by bootstrap_android.py.
p=build/'gradle/wrapper/gradle-wrapper.properties'
s="\n".join(line for line in p.read_text().splitlines() if not line.startswith(("distributionUrl=","distributionSha256Sum=")))
s+='\ndistributionSha256Sum=f397b287023acdba1e9f6fc5ea72d22dd63669d59ed4a289a29b1a76eee151c6\ndistributionUrl=file\\:/workspace/runtime/downloads/gradle-8.11.1-bin.zip\n'
p.write_text(s)
