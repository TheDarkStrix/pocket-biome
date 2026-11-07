# Pocket Biome: Tiny Expansion

Godot **4.6.3**, portrait Android-first, offline environmental discovery game. Twenty discoveries, five progression chapters, crafting, automation, World Pulse, Codex, saves and optional native store integrations are implemented. Commercial release validation is ongoing; see IMPLEMENTATION_STATUS.md.

## Android test download

[Download the current ARM64 test APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk). Android 7.0+; about 98 MiB, development preview with Google test ad IDs. [Download details and checksum](https://github.com/TheDarkStrix/pocket-biome/tree/android-test-build).

Current update: **0.21.7-preview** centers “Choose your next biome” across the entire card hand, separates its Close target and keeps the island preview clear of the heading. Version code increases to 21 with the current signing key. [Rendered layout and input proof](docs/DRAFT_TITLE_AUDIT.md). The [0.21.6 tutorial, simpler river guidance and numbered labels](docs/PLAYER_CLARITY_AUDIT.md), saved-card recovery and painted-land fixes remain included.

[Full conversation request review](docs/USER_REQUEST_REVIEW.md) maps gameplay, teaching, visual, testing, monetization and release requests to implemented work and unfinished acceptance. The complete screen-clarity pass, continuous UI playthrough to the ending and physical/newcomer/live-provider qualification remain open.

**Much older installation:** the original restored-paint test APK used a different signing key. If Android rejects an update, keep that old app installed if its saved island matters; uninstalling removes local progress. See [download and update compatibility](docs/APK_DOWNLOAD.md).

The verified cloud package is at `builds/PocketBiome-Android-test.apk`. Generate it with `python3 tools/package_phone_apk.py` after a successful universal debug build.

## Develop

- Play: `./tools/godot.sh` (graphical display required).
- Editor: `./tools/godot.sh --editor`.
- Automated gameplay/save/UI checks: `./tools/check.sh`.
- Actual OpenGL screenshots: `./tools/visual_review.sh` (Xorg dummy and Mesa required).
- Production artifact check (expected to fail for previews): `python3 tools/audit_android.py --apk builds/PocketBiome-debug.apk --production`.
- Debug Android build: `./tools/build_android.sh` with the documented runtime SDK/JDK/templates installed.

The launcher sets writable cloud XDG locations. Android dependencies and setup are described in docs/ANDROID_READINESS.md. Use the existing checkout; no additional worktree is needed.

## Play

Latest visual feedback pass: [animation inventory](docs/ANIMATION_STATUS.md) and [verified polish audit](docs/GAME_JUICE_AUDIT.md). Painted Golem/tool rigs, rooted growth, reactive wildlife, finite milestone celebrations and sound mixing are integrated. The preview keeps Google test ad IDs.

Latest monetization delivery: [Automatic ads and live setup](docs/AD_MONETIZATION.md) and [audit/evidence](docs/MONETIZATION_AUDIT.md). Six saved-result placements include completed replay/mastery attempts, with configurable timing, persistent frequency controls and placement-level SDK measurements. The current preview still uses test units and earns no live revenue.

Gameplay delivery: [Advanced lessons and chapter guidance](docs/PLAYER_JOURNEY.md), [audit/evidence](docs/JOURNEY_AUDIT.md), and [Android acceptance](docs/ANDROID_ACCEPTANCE.md). Tap the goal for a live checklist, learn four advanced systems on your island, and use material help to find the next real action. Lessons can be skipped and revisited from Pack.

Earlier signature chapter: [The Living River](docs/LIVING_CORRIDORS.md) and [its repeated audit](docs/CORRIDOR_AUDIT.md). After the first spring, route limited Water to a remote grove, guide pollinators to a garden and restore a dormant corner. Choose wetland or woodland, preview/confirm routes on the island, respond to a dry spell and earn the Living Heart. Optional local portraits export as a PNG strip or animated GIF.

Earlier foundation: [Three director passes](docs/DIRECTOR_DELIVERY.md) and [audit scorecard](docs/DIRECTOR_ITERATIONS.md). New islands use Living climate; existing saves can switch in Settings → Climate growth rules. Select land for direct Inspect/Tend/Move/Goal actions. The ending requires a currently thriving connected sanctuary; collecting all twenty discoveries is optional mastery. Earn decorations, welcome optional visitor requests, compare your starting/current portraits and try eight expedition mastery challenges with personal bests.

**Pack → Habitat projects** offers five restorations: a returning spring, pollinator garden, sheltered workshop, climate refuge and connected sanctuary. Restore them to earn reusable water channels, shade, warmth control, landscape movement and increased care capacity. Wildlife responds to current habitat suitability. Each project explains alternative designs. See [Restoration campaign](docs/RESTORATION_CAMPAIGN.md).

The five chapters now connect discovery and building to distinct restoration accomplishments. During the opening, tap the objective for one relevant action: harvest, compare Water, observe growth, craft and place a Workbench, then welcome wildlife. Guidance can be dismissed; automatic ad/consent preparation and interstitials wait while it is active.

Select a structure, then open **World → Move selected structure** to preview an empty Meadow and confirm a free move that keeps upgrades and production timing. Restoring the Sheltered Workshop also unlocks movement of unprotected single-cell natural tiles. Select a sanctuary for **World → Dismantle sanctuary** to recover its four plots while keeping discoveries. See [Layout recovery](docs/LAYOUT_RECOVERY.md).

During the tutorial, follow the pointed resource tiles or **Collect ready materials**. After finishing or leaving guidance, **Gather ready** collects available resources together. Cooldowns, storage limits and per-node rewards still apply; individual tile harvesting remains available.

Completing all five chapters now celebrates your living sanctuary with an island recap and routes to continued building, photo mode and expeditions. Replay it from the Journal after completion.

After your first discovery, open **Pack → Expeditions** to visit **Dry Springs**. Restore a separate wetland by placing water beside thirsty trees, advancing seasons and creating flowering habitats. Terrain can be rearranged for free and progress saves with your home. Continue through Frost Hollow, Ember Shore and **River Link**, where a continuous river must connect a spring and outlet. Completed islands offer fresh replay attempts, saved separately from the original restoration without repeat rewards or ad milestones. See [Expeditions](docs/EXPEDITIONS.md).

Harvest the Oak, tap an adjacent cloud and choose Water to discover the first evolution. Inspect a draft card before confirming it. Hold tiles to inspect their conditions. Tap the current objective for relevant things to try. Later drafts vary their choices and explain the selected plot’s effects; Workshop → Trade offers five- or twenty-material batches. Automatic Furnaces preserve construction stock; manual crafting can spend it. Original painted land is restored. Drag to pan, pinch/wheel to zoom, and use two-finger twist or World → Rotate left/right for90° views. The rejected procedural3D view is disabled. For sanctuary fusion, use the Chapter 3 shortcut or World → Fuse sanctuary. The chooser detects matching 2×2 groups, offers a footprint preview and explains blockers. Closing a draft keeps its offers; tapping another cloud moves those same offers without charging. Use the Journal for free discovery clues; Craft and World expose progression, automation, upgrades and photo mode. Rewarded extras and purchases are optional; capped interstitials can appear at natural breaks. Services use development configurations.

See ARCHITECTURE.md, ART_ASSET_MANIFEST.md, BALANCING.md, TEST_REPORT.md and docs/RELEASE_DEPENDENCIES.md. The authoritative specification is docs/MASTER_PRD_v4.md. The shared visual reference is preserved under docs/references/.

Current visual direction is world-first: atmospheric sky/clouds, compact resources and goals, small floating tool icons and contextual tile details. This supersedes the user's rejected gray, panel-heavy0.13 HUD. See docs/DESIGN_DIRECTION.md and docs/UI_RESEARCH.md. This revision remains under human review.

Production status and external gates: docs/PRODUCTION_READINESS.md. Ongoing foliage/water/structure effects are implemented; the exact animation inventory and device-review scope are in docs/ANIMATION_STATUS.md. Preview artifact validation is distinct from commercial release certification.

Gameplay sheets now use illustrated draft cards, a categorized crafting catalogue and job shelf, current-island World previews, Pulse footprint diagrams and bound setting switches. The gameplay HUD and economy remain unchanged. See fixtures33–39 and current TEST_REPORT.md; human visual approval remains open.
