# Pocket Biome — 0.21.5 Living River entry

[Download the current APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

Android 7.0+ / ARM64. About 98 MiB. Development preview with Google test ad IDs.

## Fixed: approach and spring controls appearing inactive

Saved land cards no longer silently block Living River actions. Choosing an approach opens highlighted Water selection; confirming the spring opens grove planning. When no distant grove can receive Water, the setup screen explains the missing land and can select a Forest from the actual saved hand at its ordinary price. No free terrain or completion is granted.

Tap a highlighted reachable tree to preview its natural-land channel, or draw it. Preview states the starting flow before Save. A new channel starts with the confirmed available allocation; existing allocations, including zero, remain unchanged when rerouting. The saved river stays visible with a source marker and flowing droplets. Setup/invalid/save errors appear in the visible panel, and planning controls have reserved room without overlapping toast messages. Cards, quote and progress stay saved. Earlier painted-seam, opening Water and harvest-height fixes remain included.

Version code increases 18 → 19 with the previous download's package and signing key. Install over that recent build; do not uninstall first. Static update compatibility is verified; physical installation/save acceptance remains pending. The much older restored-paint APK used a different key: keep it installed if its saved island matters and Android rejects the update, because uninstalling removes local progress.

Runtime commit: `c727db52d9ec9c2eea599698ce884842efac885c`.
Tested source SHA-256: `d68efd10827253d220f34c6192cf0f1beffdcccc4331afa23631bafab6bcca81`.
APK SHA-256: `a4676b6c4e987ef114c5ffbdba1c3a1cdd0aeecb2e52cc810694443b13795e99`.

The unchanged source passes 2,102 assertions in 45 Godot suites, 22 Python tests, startup and four campaign probes. Two fresh-save rendered touch runs (540×960 and 320×640, 53 touches each) earn the first restoration normally, buy the real offered Forest, save a flowing channel and mature its grove while retaining a pending hand. These fresh walkthroughs stop at grove maturity; separate model/control suites cover later stages and both approaches. Source binding, signatures, 16 KB alignment and all 663 retained ARM64-package files pass.

Screenshots and exact scoped evidence: source branch `docs/RIVER_ENTRY_AUDIT.md` and `docs/RIVER_ENTRY_VALIDATION.json`. No physical Android phone or unfamiliar player was tested. Provider/store acceptance remains open. Test ads do not earn live revenue.
