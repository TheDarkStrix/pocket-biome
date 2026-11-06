# Pocket Biome — 0.21.3 Android test update

[Download the current APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

Android 7.0+ / ARM64. About 98 MiB. Development preview with Google test ad IDs.

## Fixed: Water missing while the tutorial asks for it

Opening Water is guaranteed until the first-discovery guidance no longer needs it. Old saved hands without Water repair automatically when opened, including Resume draft. The quote, wallet, existing pond and two other offers are kept; repair needs no ad or redraw. Placing a new plot still charges its normal saved quote.

The valid Oak-adjacent clouds are highlighted. Water is selected in the hand; remote plots explain that they cannot reach the Oak and offer a route back to the highlighted plots. A Water neighbor immediately advances the objective. The 0.21.2 harvested-land alignment fix and all prior gameplay/animation features remain included.

Version code increases 16 → 17 with the same package and signing key as the recent gameplay/animation and land-alignment downloads. Install over those recent builds; do not uninstall first. Compatibility is verified statically; physical installation/save-preservation acceptance is still pending.

The much older restored-paint test APK used a different signing key. If Android rejects an update, keep that old app installed if its saved island matters. Uninstalling removes local progress; safe transfer across that old signing change remains pending.

Runtime commit: `406c364cbca3f7f85a3aab79dbc4b58b9ede7b29`.
Tested source SHA-256: `aa684487798a5d8bca9745048dd4d0c50848af125d1112fd013dc8b208502c92`.
APK SHA-256: `646a9cc591cb5057d238dc36bea227f7498a1f604377792ac8d376eff6850775`.

The unchanged source passes 2,035 assertions in 43 Godot suites, 22 Python checks, startup and four automated campaign routes. Seven rendered touch actions verify old-hand repair, correct placement, normal price, retained pond, objective advancement, ordinary-clock discovery and small-screen recovery. Package/source/signature/16 KB alignment checks pass; all 659 retained ARM64-package files match the universal export.

Exact reports/screenshots are in the source branch's `docs/OPENING_WATER_AUDIT.md` and `docs/OPENING_WATER_VALIDATION.json`. These are automated/rendered checks, not a physical-phone or unfamiliar-player acceptance study. Test ads earn no live revenue; production/store setup remains open.
