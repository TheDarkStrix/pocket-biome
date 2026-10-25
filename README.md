# Pocket Biome Android test build

[Download updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

Android 7.0+ (API 24), ARM64 phones. Signed debug preview, not a public release candidate. Install over the existing test build to retain your world; do not uninstall.

## Player-feedback update

- Visible expansion controls receive touch before overlapping canopy artwork.
- A closed draft can move to another cloud with the same cards/price, without spending coins.
- Chapter 3 has a direct fusion shortcut. The illustrated chooser finds 2×2 groups, previews them and explains missing tiles/pulse blockers.
- Rain showers/ripples cover the full affected area for 3.2 seconds; reduced motion retains confirmation.
- Press/release responses, panel/menu fades, resource highlights and interpolated chapter/ecology stats.

Source: a80f58f1d4c80df56ef78b8e20bce43a062b8ebf. 701 automated assertions pass, plus complete progression/startup checks. The equivalent universal runtime payload installed and rendered on an Android emulator, retained progress and passed native cloud/draft-relocation checks. Phone APK signature/alignment and identical retained files verified. Physical ARM64-device/performance validation remains open. Ads use test IDs; real purchase/restore and release qualification remain unverified.

For fusion, use **Find a sanctuary fusion** or **World → Fuse sanctuary**. Four matching tiles must make a square in grid space (a diamond on screen), rather than a row. Oak differs from Forest; evolved Forest tiles still count. The chooser shows readiness and temporary blockers.

Checksum is alongside the APK. This branch contains download artifacts; development continues on main.
