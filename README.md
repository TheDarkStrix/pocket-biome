# Pocket Biome 0.16.0 Android preview

[Download the updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android 7.0+ (API24). Signed development preview. Install over the existing game to retain your island; do not uninstall.

## The selected biome-card direction, implemented

- All three saved terrain offers appear together as illustrated, slightly fanned slate/bronze cards.
- Selecting raises and highlights one offer; one green framed Place button names the selected biome.
- The exact saved Coin quote remains visible. Selection, Info and Later spend nothing; insufficient funds are explained and placement is disabled.
- The actual island remains framed above the hand. Closing the hand restores the previous camera and dock.
- Detailed biome/environment information and the optional test-ad redraw remain reachable through Info. Asynchronous redraw replaces stale details with the real new offers.
- Short selection motion respects reduced-motion settings; names, traits and controls fit the tested small-phone and larger-text layouts.

This implements the final Draft panel's direction, using two independent generated blank frame/button assets, existing terrain art and the licensed Marcellus font. The presentation-board image is not cut into game controls. The title, gameplay HUD, contextual Build tray and other menus have not yet been converted to the entire concept. No claim of finished whole-game visual polish is made.

Source: 73c4854 (main). Source digest: 7b9e5c8696b013c7bfbebe0cbabc463c1bd57a6ee2505cd6aa8709f1ed4c9850. 913 Godot assertions across16 suites, eight Python audit tests, startup and two complete public-action progression routes pass. Tests cover actual touch selection/Info/placement, exact quote and separate objective reward, persisted offers, insufficient-funds rejection, camera restoration and duplicate-confirmation rejection. Rendered fixtures40–42 are constructed presentation states, not earned progression or human approval.

Signature,417 retained files, ARM64 packaging,16KB ZIP/ELF alignment and embedded source provenance are verified. SHA256: 5dd33c60575ded69f6046472ce129e212e07aca465ffe0b80f7578f71855cddb. Size:99,181,922 bytes.

Physical-device performance, real Google provider transactions and human creative acceptance remain unqualified. Economy, saves, quoted prices and provider test IDs are unchanged. The four-view camera remains; continuous3D orbit is not implemented. Some painted parts still lack authored motion; see docs/ANIMATION_STATUS.md on main. Production signing/configuration, hosted publisher details and device/store/creative evidence remain release gates. No store publication was performed. See main's TEST_REPORT.md and docs/PRODUCTION_READINESS.md for scoped evidence.
