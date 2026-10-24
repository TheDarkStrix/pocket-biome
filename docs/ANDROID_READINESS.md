# Android build and validation

## Installed and verified

- Godot 4.6.3 official; matching export templates verified with official SHA512 checksums.
- Temurin JDK17.0.16+8 under /workspace/runtime/jdk/jdk-17.0.16+8, official SHA256 verified.
- Android SDK under /workspace/runtime/android-sdk: command-line tools19, platform36, build-tools36.1.0, NDK29.0.14206865, platform-tools. Versions follow the actual Godot4.6.3 template.
- Gradle8.11.1 distribution verified against official SHA256, cached under runtime/downloads; proxy host/port only, system CA trust preserved.
- Android native plugin with Ads23.6.0, UMP3.1.0 and Billing8.0.0 builds through maintained sources in native/android.

Build: `./tools/build_android.sh`. It imports, runs the full test suite, exports a staged debug APK, verifies apksigner and promotes only on success. Output builds/PocketBiome-debug.apk is ignored by Git; hash is stored beside it. Both regular and mobile rendering explicitly select OpenGL Compatibility. Minimum API24, target36, ARM64+x86_64. Debug signing is development-only; never use that key for publication.

## Current QA environment

API29 AOSP x86_64 AVD `pocket-qa29`, software SwiftShader/no KVM. adb connect 127.0.0.1:5557 after editor/export (Godot may stop adb). API35 under software acceleration was unstable at the operating-system level; that is not attributed to gameplay code. This emulator has no Play Store, so successful purchase flows require a separate configured Play tester device.

First test APK installed and registered PocketServices. Vulkan mobile override corrected; OpenGL selection confirmed. A legacy SwiftShader shader-uniform limit is being addressed before native gameplay is signed off. See TEST_REPORT.md for current evidence; installation alone is insufficient.

## Release matrix

Cold launch offline → harvest/draft/first evolution → menu/input/pinch → force-stop/relaunch restoration → background during reveal/fusion → photo chooser → safe areas/cutouts → real test ad/reward/failure → sandbox purchase/restore → physical-device performance/audio. Release AAB, signing and store policy review follow these checks. Production IDs and credentials are never silently substituted.
