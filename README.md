# Pocket Biome 0.14.0 Android preview

[Download the updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android 7.0+ (API24). Signed development preview. Install over the existing game to retain your island; do not uninstall.

## World-first presentation

This revision supersedes the rejected gray background and large 0.13 HUD cards.

- Original sky/cloud shader with controlled drift and day/dusk/night variants. Reduced motion freezes its clock.
- Small resource row and a readable chapter prompt directly over the scene.
- Five compact floating tools instead of an enclosing bottom tray and permanent stats panels.
- Touch land for a brief nearby inspect callout; hold it for the complete inspector.
- Conditions are behind the leaf/inspector controls; exact energy remains in the real Pulse picker; land capacity is in World.
- Small contextual saved-card, cancellation and fusion actions; lighter World tools and original leaf/camera icons.

The existing economy, saved offers/quotes, progression and provider test configuration are unchanged. The sky does not alter tile art or isometric geometry. World pans/pinches/quarter-turns remain available; continuous 3D orbit is not implemented. Some painted parts, including Windmill blades, remain static. See docs/ANIMATION_STATUS.md.

Source: bf34cebdd0b506a871c37661ab96f7b3fb6766b3. 845 Godot assertions, eight Python audit tests, startup and two full public-action campaign routes pass. Mobile fixtures require at least 55% of screen height for the world, readable large counts/progress, retained touch targets and working callout reveal/expiry. The APK signature, ARM64 files, 16 KB ZIP/ELF alignment and embedded source provenance are verified.

Actual rendered fixtures32/29/30/31 show the new HUD, large text, callout and dusk variant; these are constructed presentation states, not human approval or earned-progression claims. Current-source emulator observations are scoped in artifacts/android-atmosphere-check.json. Physical GPU performance, human creative approval and real Google provider transactions remain unqualified.

Production signing/test IDs, hosted publisher details and device/store/creative acceptance remain open release gates. No store publication was performed. See docs/PRODUCTION_READINESS.md. Checksum is provided alongside the APK; source development continues on main.
