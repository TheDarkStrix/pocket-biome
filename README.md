# Pocket Biome 0.11.0 Android preview

[Download the updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android phones, Android 7.0+ (API 24). Signed development preview, not a certified production release. Install over the existing game to retain your island; do not uninstall.

## Camera and world motion

- World → Rotate left/right or a two-finger twist gives four 90° isometric views. Drag and pinch still pan/zoom. Continuous free-angle 3D orbit and newly rendered back faces are not implemented.
- Canopies sway with fixed ground; water ripples; enabled structures show smoke, embers, work dust or activity lights. Some painted parts, including Windmill blades, remain static. Reduced-motion mode freezes idle effects.
- Placement, evolution, fusion, Rain/Heat/Frost, harvest flights and responsive UI animations are included.

## Gameplay and mobile fixes

- Expansion markers receive input above tree art. Closed drafts relocate without rerolling or charging.
- Fusion detects matching 2×2 groups and explains blockers; Chapter 3 exposes a direct shortcut.
- Tile conditions names Moisture/Heat and opens a player explanation of 0–100 scores and transformations.
- Dragging across menu buttons scrolls to actions below the fold without triggering buttons.
- Frame jitter no longer stretches environment/automation intervals.
- Privacy disclosure, local diagnostic deletion, native opt-in/out and required ad-privacy-choice entry points are implemented. Own telemetry endpoint remains empty; test IDs remain in use.

Source: 319ae30ac8faf561edf95656eaec1f05b9d5c45d . 750 Godot assertions plus eight Python audit tests pass; complete progression simulation passes. APK signature, ARM64 files, 16 KB ZIP/ELF alignment and embedded source provenance are checked. Native software-emulator checks cover installation, restored progress, rotation buttons, menu scrolling, privacy UI and actual Android diagnostics preference On/Off. This does not certify physical performance, real Google consent/ads/purchases or public release readiness.

Production is still blocked by development signing/test configuration, hosted publisher policy/support details and device/store/creative acceptance evidence. See docs/PRODUCTION_READINESS.md and docs/CAMERA_ORBIT_PLAN.md on main. No store upload/publication was performed.

Checksum is provided alongside the APK. Development continues on main; this branch contains download artifacts.
