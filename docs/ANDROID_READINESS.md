# Android build and validation

## Reproducible toolchain

Godot 4.6.3 official and matching SHA512-verified export templates; checksum-verified Temurin JDK17.0.16+8; SDK platform36/build-tools36.1.0/NDK29.0.14206865 under /workspace/runtime/android-sdk; checksum-pinned Gradle8.11.1. Reproduce base dependencies with `python3 tools/bootstrap_android.py --install-sdk`.

Maintained native pins: native/android/dependencies.json (Ads25.5.0, UMP4.0.0, Billing8.3.0) and native/android/toolchain.json (Kotlin2.3.21, AGP8.10.1). tools/prepare_native.py applies these to the matching Godot template. Kotlin was upgraded to read current Ads metadata; no compatibility checks were suppressed. Official artifact availability is recorded in artifacts/sdk-update-check.json.

`./tools/build_android.sh` prepares/imports, embeds source provenance, runs eight Python audit tests plus all Godot suites, exports a staged APK, checks export errors/signing and audits actual package/SDK/ABI/portrait/16KB ZIP+ELF alignment/source binding. Only passing output replaces builds/PocketBiome-debug.apk. `python3 tools/package_phone_apk.py` produces the ARM64 download while verifying every retained file and preserving service-loader metadata; it refuses stale test evidence. Debug signing is development-only.

Both regular and mobile rendering explicitly select OpenGL Compatibility. Minimum API24, target36, ARM64+x86_64 universal preview; ARM64 phone download. Version0.11.0-preview/code3. Production credentials/IDs are not substituted automatically.

## Native evidence and limits

Current cloud AVD: API29 AOSP x86_64, no Play Store/GMS and no KVM. Host Mesa software backend via Xorg:95; adb endpoint127.0.0.1:5555 (editor/export may stop adb). Earlier SwiftShader/API35 attempts had Android operating-system stalls. These are not attributed to the game.

Previous native checkpoints exercised launch/harvest/draft/evolution, replacement-install save retention, photo/system chooser without a recipient, and cloud relocation without changes to cards/quote/balance/land. Each artifact is scoped to its source/build. Current animation/SDK revision must have its own installation/rendering evidence before claiming native validation; see TEST_REPORT.md and Android JSON reports. Emulator behavior does not establish physical-device FPS, audio comfort or store success.

## Production gate

`python3 tools/audit_android.py --apk builds/PocketBiome-debug.apk --production --output artifacts/production-readiness.json` must fail for the preview configuration. Use docs/PRODUCTION_READINESS.md for missing signing, hosted policy/support details, physical-device evidence and live sandbox reward/purchase/restore/consent qualification. No release AAB/internal-test upload or public store submission is claimed.
