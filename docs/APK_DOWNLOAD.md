# Current Android test download

[Download APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk) · [metadata/checksum](https://github.com/TheDarkStrix/pocket-biome/tree/android-test-build)

Current version: `0.21.7-preview`, version code 21. “Choose your next biome” is centered across all three cards with a separate close target, and the island preview stays above the heading. Earlier tutorial, river, Water-offer and painted-land fixes remain. [Rendered proof and scope](DRAFT_TITLE_AUDIT.md) · [exact results](DRAFT_TITLE_VALIDATION.json).

APK SHA-256: `283c8c2ff171428545c9a23606cbd1cf8d16bda6d8610ae9303d9ca0585fb0d4`.
Source SHA-256: `0628e63b0afc1d6b0ed0a3c792b5e4a7f03ae55e17bfbea321b2548ae0186139`.
Package size: 102498659 bytes. Google test ad IDs remain configured.

## Updating without losing the current island

This APK retains package `com.thedarkstrix.pocketbiome` and signing certificate SHA-256 `c624f680df74e7edd9e7a2e83495d5405e1b4cde328f55967bc43c39848029a9` from the recent gameplay/animation, land-alignment and Water-recovery downloads. Its version code increases from 20 to 21. Package/signature/version compatibility for an in-place update is verified; no physical device was attached to perform installation/save-preservation acceptance.

Install over that recent build; do not uninstall first. The much older restored-paint test APK had signing-certificate SHA-256 `0aef85d4d7b8721d31b6c671f85e6997ec92c6bad6f7cf5f2f62d8e6d5e6aa89`, so Android cannot update it in place. If Android rejects an update, keep that old app installed if its saved island matters. No in-app export/import path exists for transfer across that old signing change.

## Remaining acceptance

Physical-phone campaign/input/readability/audio/performance and save/restart tests, unfamiliar-player comprehension/pacing/enjoyment, actual native ads/consent/no-fill/purchase flows, safe transfer from the much older signing key and final production signing/store/privacy configuration remain open. Test ads do not earn live revenue. Registered pond-to-cliff falls remain an optional art enhancement.
