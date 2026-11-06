# Pocket Biome — current Android test build

[Download the current APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

Android 7.0+ / ARM64. About 98 MiB. Development-signed preview with Google test ad IDs; not a store release and not earning live ad revenue.

## Existing installations

This APK uses a different debug signing certificate from the older APK previously hosted here. Android will reject an in-place update from that older version. **Do not uninstall the old app if you need its saved island.** Uninstalling removes local progress. A safe save-transfer path for this signing change is pending. Fresh installations can use the APK normally.

## Included

Five chapters and twenty discoveries, guided opening and advanced lessons, habitat restoration, Living River choices, crafting/automation, expeditions/mastery and the sanctuary ending. The latest painted-world polish adds Golem/Workbench/Totem rigs, rooted growth, reactive wildlife, finite milestone celebrations and improved sound mixing. Original painted art remains the default.

Runtime commit: `d716c8edde5c7c894b19e37e172e505f7fc1a1d5`.
Tested source SHA-256: `5748bcd27fe04b88d0d3658d30df1053d357cba92ddbd1ec21e9e9fdd7b89560`.
APK SHA-256: `c5336560796648a8acbff7955bd9a68555d5e9b1b19bfcd7f5b79e6d57d2889f`.

The unchanged source passes 2,000 assertions in 42 Godot suites, 22 Python checks, startup and four automated campaign routes. Rendered touch walkthroughs and Android package/signature/alignment/source checks pass. This is not a physical-phone playthrough or a human enjoyment study. Full results are in the source branch's `docs/GAME_JUICE_VALIDATION.json`; package metadata is also retained in `build-info.json` here.

Phone controls/audio/vibration/performance, save/update acceptance, real SDK consent/ad behaviour, human pacing/retention and production signing/store setup remain pending.
