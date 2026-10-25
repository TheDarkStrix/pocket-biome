# Pocket Biome 0.15.0 Android preview

[Download the updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android 7.0+ (API24). Signed development preview. Install over the existing game to retain your island; do not uninstall.

## Illustrated gameplay sheets

- Three illustrated draft cards with real touch swiping, arrow alternatives and stored-price confirmation.
- Two-column building catalogue, All/Land/Structures/Materials categories, owned/required ingredient art and the actual three-job shelf/countdowns.
- Real island miniatures and selected-biome/sanctuary art in World.
- Rain/Heat/Frost cards with five-cell footprint illustrations and small illustrative effects; selecting still opens the actual world-targeting flow.
- Fusion input/result diagrams, Codex/inspector diorama stages, illustrated trade/help/reward layouts and bound setting switches.
- Mineral-ivory/teal modal styling, shorter content-sized sheets and safe scrolling. The compact sky-backed gameplay HUD remains intact.

Every crafting recipe is retained. Artwork is the existing integrated atlas, original runtime diagrams and original vector controls; no reference-game asset is shipped and no new hand-painted frame is claimed. This is an original revision under review, not a claim of reproducing another game's interface.

Source: b247e7d3b90998a1909fab4444730f9d19ebac9e. 880 Godot assertions across 15 suites, eight Python audit tests, startup and two complete public-action progression routes pass. Real-touch cases verify swipe-without-payment, third-card inspection and the 20-material trade. Category tests retain every recipe; 30 sheet-layout cases cover three portrait sizes/two text scales. Actual rendered fixtures33–39 use constructed presentation states, not earned progression or human approval. Current-source native observations are scoped in artifacts/android-sheets-check.json.

Signature, ARM64 files, 16 KB ZIP/ELF alignment and embedded source provenance are verified. Physical-device performance, real Google provider transactions and human creative acceptance remain unqualified. Economy, saves, quotes and provider test IDs are unchanged. Camera quarter turns remain; continuous 3D orbit is not implemented. Some painted parts still lack authored motion, as documented in docs/ANIMATION_STATUS.md.

Production signing/configuration, hosted publisher details and device/store/creative evidence remain release gates. No store publication was performed. See docs/PRODUCTION_READINESS.md. Checksum is alongside the APK; source development continues on main.
