# Current Android test download

[Download APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk) · [metadata/checksum](https://github.com/TheDarkStrix/pocket-biome/tree/android-test-build)

Current version: `0.21.3-preview`, version code 17. This update repairs the missing-Water opening draft and retains the harvested-land alignment fix. [Opening recovery and touch proof](OPENING_WATER_AUDIT.md) · [exact tests/package evidence](OPENING_WATER_VALIDATION.json).

APK SHA-256: `646a9cc591cb5057d238dc36bea227f7498a1f604377792ac8d376eff6850775`.
Source SHA-256: `aa684487798a5d8bca9745048dd4d0c50848af125d1112fd013dc8b208502c92`.
Package size: 102473290 bytes. Google test ad IDs remain configured.

## Updating without losing the current island

This APK retains package `com.thedarkstrix.pocketbiome` and signing certificate SHA-256 `c624f680df74e7edd9e7a2e83495d5405e1b4cde328f55967bc43c39848029a9` from the recent gameplay/animation and land-alignment downloads. Its version code increases from 16 to 17. Package/signature/version compatibility for an in-place update is verified; no physical device was attached to perform installation/save-preservation acceptance.

Install over that recent build; do not uninstall first. The much older restored-paint test APK had signing-certificate SHA-256 `0aef85d4d7b8721d31b6c671f85e6997ec92c6bad6f7cf5f2f62d8e6d5e6aa89`, so Android cannot update it in place. If Android rejects an update, keep that old app installed if its saved island matters. No in-app export/import path exists for transfer across that old signing change.

## Remaining acceptance

Physical-phone campaign/input/readability/audio/performance and save/restart tests, unfamiliar-player comprehension/pacing/enjoyment, actual native ads/consent/no-fill/purchase flows, safe transfer from the much older signing key and final production signing/store/privacy configuration remain open. Test ads do not earn live revenue. Registered pond-to-cliff falls remain an optional art enhancement.
