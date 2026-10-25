# Pocket Biome 0.12.0 Android preview

[Download the updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android phones, Android 7.0+ (API 24). Signed development preview, not a certified production release. Install over the existing game to retain your island; do not uninstall.

## Camera and world motion

- World → Rotate left/right or a two-finger twist gives four 90° isometric views. Drag and pinch still pan/zoom. Continuous free-angle 3D orbit and newly rendered back faces are not implemented.
- Canopies sway with fixed ground; water ripples; enabled structures show smoke, embers, work dust or activity lights. Some painted parts, including Windmill blades, remain static. Reduced-motion mode freezes idle effects.
- Placement, evolution, fusion, Rain/Heat/Frost, harvest flights and responsive UI animations are included.

## Gameplay pacing update

- Post-tutorial drafts offer a rotating resource option plus two varied seeded choices. Saved offers and quotes remain intact.
- Card descriptions explain effects at the selected plot, including nearby influence or Golem reach.
- Tap the chapter objective for up to three useful directions: pending cards, discoveries, fusion, crafting, trading or automation.
- Workshop has a direct illustrated trade screen with five/twenty-material batches.
- Automatic Furnaces keep 4 Wood/5 Stone for construction; manual crafting can spend that reserve. Structure upgrades protect coins reserved by a saved draft.
- Existing fusion guidance, readable Tile conditions, expansion picking, scrolling, privacy controls and animated feedback remain included.

Source: 3b2774cbe14b9b356c66766ceebd35f7baed620f. 783 Godot assertions, eight Python audit tests and two public-action full-progression simulations pass. APK signature, ARM64 files, 16 KB ZIP/ELF alignment and embedded source provenance are checked. The exact universal export installed over the existing emulator save; objective suggestions and direct Workshop trade navigation were verified. Save cards, quotes and stable progression fields were retained. Native trade execution was not exercised with the low-stock save; a real 20-material transaction/save passes the automated touch fixture.

These checks do not establish enjoyment or physical performance. The early Furnace starvation loop is fixed; significant late progression gaps remain an open balancing concern. See docs/GAMEPLAY_PACING_REVIEW.md on main. No human retention result or real Google consent/ad/purchase certification is claimed.

Production is still blocked by development signing/test configuration, hosted publisher policy/support details and device/store/creative acceptance evidence. See docs/PRODUCTION_READINESS.md and docs/CAMERA_ORBIT_PLAN.md on main. No store upload/publication was performed.

Checksum is provided alongside the APK. Development continues on main; this branch contains download artifacts.
