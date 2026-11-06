# Current Android test download

[Download APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk) · [metadata/checksum](https://github.com/TheDarkStrix/pocket-biome/tree/android-test-build)

Current version: `0.21.2-preview`, version code 16. This update fixes the land dropping when resource artwork switches after harvesting. [Before/after and implementation](LAND_ALIGNMENT_AUDIT.md) · [exact test/package evidence](LAND_ALIGNMENT_VALIDATION.json).

APK SHA-256: `9ed02da304cf20b605233a33ccd2c608aa96b695952e9983c5b8f63cd0511a33`.
Source SHA-256: `68a4fc0d4a90508d0ce684a54df4cfa36ffc927103fa51e2e28319fa239473dd`.
Package size: 102469035 bytes. Google test ad IDs remain configured.

## Updating without losing the current island

This APK retains package `com.thedarkstrix.pocketbiome` and signing certificate SHA-256 `c624f680df74e7edd9e7a2e83495d5405e1b4cde328f55967bc43c39848029a9` from the immediately preceding gameplay/animation download (APK SHA-256 `c5336560796648a8acbff7955bd9a68555d5e9b1b19bfcd7f5b79e6d57d2889f`). Its version code increases from 15 to 16. Package/signature/version compatibility for an in-place update is verified; no physical device was attached to perform installation/save-preservation acceptance.

Install over that recent build; do not uninstall first. The much older restored-paint test APK had signing-certificate SHA-256 `0aef85d4d7b8721d31b6c671f85e6997ec92c6bad6f7cf5f2f62d8e6d5e6aa89`, so Android cannot update it in place. If Android rejects an update, keep that old app installed if its saved island matters. No in-app export/import path exists for transfer across that old signing change.

## Remaining acceptance

Physical-phone campaign/input/readability/audio/performance and save/restart tests, unfamiliar-player comprehension/pacing/enjoyment, actual native ads/consent/no-fill/purchase flows, safe transfer from the much older signing key and final production signing/store/privacy configuration remain open. Test ads do not earn live revenue. Registered pond-to-cliff falls remain an optional art enhancement.
