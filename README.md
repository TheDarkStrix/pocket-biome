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

**Pack → Habitat projects** offers Shaded Pond, Pollinator Patch and Living Workshop: home-island layout goals with one-time rewards and wildlife that visits suitable habitats. See [Habitat projects](docs/HABITAT_PROJECTS.md).

Chapter 2 now asks you to complete a living habitat. During the opening, tap the objective for one relevant next action: harvest, expand, then inspect how neighbors change the Oak. Broader ideas remain available.

Select a structure, then open **World → Move selected structure** to preview an empty Meadow and confirm a free move that keeps upgrades and production timing. Select a sanctuary for **World → Dismantle sanctuary** to recover its four plots while keeping discoveries. See [Layout recovery](docs/LAYOUT_RECOVERY.md).

After your first harvest, use **Gather ready** to collect available resources together. Cooldowns, storage limits and per-node rewards still apply; individual tile harvesting remains available.

Completing all five chapters now celebrates your living sanctuary with an island recap and routes to continued building, photo mode and expeditions. Replay it from the Journal after completion.

After your first discovery, open **Pack → Expeditions** to visit **Dry Springs**. Restore a separate wetland by placing water beside thirsty trees, advancing seasons and creating flowering habitats. Terrain can be rearranged for free and progress saves with your home. Continue through Frost Hollow, Ember Shore and **River Link**, where a continuous river must connect a spring and outlet. Completed islands offer fresh replay attempts, saved separately from the original restoration without repeat rewards or ad milestones. See [Expeditions](docs/EXPEDITIONS.md).

Harvest the Oak, tap an adjacent cloud and choose Water to discover the first evolution. Inspect a draft card before confirming it. Hold tiles to inspect their conditions. Tap the current objective for relevant things to try. Later drafts vary their choices and explain the selected plot’s effects; Workshop → Trade offers five- or twenty-material batches. Automatic Furnaces preserve construction stock; manual crafting can spend it. Original painted land is restored. Drag to pan, pinch/wheel to zoom, and use two-finger twist or World → Rotate left/right for90° views. The rejected procedural3D view is disabled. For sanctuary fusion, use the Chapter 3 shortcut or World → Fuse sanctuary. The chooser detects matching 2×2 groups, offers a footprint preview and explains blockers. Closing a draft keeps its offers; tapping another cloud moves those same offers without charging. Use the Journal for free discovery clues; Craft and World expose progression, automation, upgrades and photo mode. Purchases and ads are optional and use development configurations.

See ARCHITECTURE.md, ART_ASSET_MANIFEST.md, BALANCING.md, TEST_REPORT.md and docs/RELEASE_DEPENDENCIES.md. The authoritative specification is docs/MASTER_PRD_v4.md. The shared visual reference is preserved under docs/references/.

Current visual direction is world-first: atmospheric sky/clouds, compact resources and goals, small floating tool icons and contextual tile details. This supersedes the user's rejected gray, panel-heavy0.13 HUD. See docs/DESIGN_DIRECTION.md and docs/UI_RESEARCH.md. This revision remains under human review.

Production status and external gates: docs/PRODUCTION_READINESS.md. Ongoing foliage/water/structure effects are implemented; the exact animation inventory and remaining authored rigs are in docs/ANIMATION_STATUS.md. Preview artifact validation is distinct from commercial release certification.

Gameplay sheets now use illustrated draft cards, a categorized crafting catalogue and job shelf, current-island World previews, Pulse footprint diagrams and bound setting switches. The gameplay HUD and economy remain unchanged. See fixtures33–39 and current TEST_REPORT.md; human visual approval remains open.
