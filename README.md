# Pocket Biome: Tiny Expansion

Godot **4.6.3**, portrait Android-first, offline environmental discovery game. Twenty discoveries, five progression chapters, crafting, automation, World Pulse, Codex, saves and optional native store integrations are implemented. Commercial release validation is ongoing; see IMPLEMENTATION_STATUS.md.

## Android test download

[Download the latest signed ARM64 test APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk). Android 7.0+; debug preview, not a store release. Install over the existing build to retain its world; do not uninstall. Source and checksums are listed on the download branch. Build the phone package with `python3 tools/package_phone_apk.py` after a successful universal debug build.

## Develop

- Play: `./tools/godot.sh` (graphical display required).
- Editor: `./tools/godot.sh --editor`.
- Automated gameplay/save/UI checks: `./tools/check.sh`.
- Actual OpenGL screenshots: `./tools/visual_review.sh` (Xorg dummy and Mesa required).
- Production artifact check (expected to fail for previews): `python3 tools/audit_android.py --apk builds/PocketBiome-debug.apk --production`.
- Debug Android build: `./tools/build_android.sh` with the documented runtime SDK/JDK/templates installed.

The launcher sets writable cloud XDG locations. Android dependencies and setup are described in docs/ANDROID_READINESS.md. Use the existing checkout; no additional worktree is needed.

## Play

Harvest the Oak, tap an adjacent cloud and choose Water to discover the first evolution. Inspect a draft card before confirming it. Hold tiles to inspect their conditions. Tap the current objective for relevant things to try. Later drafts vary their choices and explain the selected plot’s effects; Workshop → Trade offers five- or twenty-material batches. Automatic Furnaces preserve construction stock; manual crafting can spend it. Drag to pan, pinch/wheel to zoom, and twist two fingers for continuous3D orbit. Drag the small compass to orbit/tilt, or right-drag on desktop. World → Rotate left/right retains convenient quarter-turn shortcuts. For sanctuary fusion, use the Chapter 3 shortcut or World → Fuse sanctuary. The chooser detects matching 2×2 groups, offers a footprint preview and explains blockers. Closing a draft keeps its offers; tapping another cloud moves those same offers without charging. Use the Journal for free discovery clues; Craft and World expose progression, automation, upgrades and photo mode. Purchases and ads are optional and use development configurations.

See ARCHITECTURE.md, ART_ASSET_MANIFEST.md, BALANCING.md, TEST_REPORT.md and docs/RELEASE_DEPENDENCIES.md. The authoritative specification is docs/MASTER_PRD_v4.md. The shared visual reference is preserved under docs/references/.

Current visual direction is world-first: atmospheric sky/clouds, compact resources and goals, small floating tool icons and contextual tile details. This supersedes the user's rejected gray, panel-heavy0.13 HUD. See docs/DESIGN_DIRECTION.md and docs/UI_RESEARCH.md. This revision remains under human review.

Production status and external gates: docs/PRODUCTION_READINESS.md. Ongoing foliage/water/structure effects are implemented; the exact animation inventory and remaining authored rigs are in docs/ANIMATION_STATUS.md. Preview artifact validation is distinct from commercial release certification.

Gameplay sheets now use illustrated draft cards, a categorized crafting catalogue and job shelf, current-island World previews, Pulse footprint diagrams and bound setting switches. The gameplay HUD and economy remain unchanged. See fixtures33–39 and current TEST_REPORT.md; human visual approval remains open.
