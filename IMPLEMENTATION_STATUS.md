# Implementation status

Updated 2026-10-25. Authoritative scope: [Master PRD v4.0](docs/MASTER_PRD_v4.md). This is an implemented game under validation, not a certified commercial release.

| Phase | Implemented | Remaining acceptance work |
|---|---|---|
| 0 — audit | Empty-repository audit, Godot 4.6.3, modular architecture, data schema, dependency setup, test plan | Complete |
| 1 — playable slice | Four starting cells; isometric picking; drag/pinch; resources/cooldowns; expansion; illustrated three-card inspection/confirmation; DNA; environmental reactions; five initial evolutions; fusion; Rain/Heat; objectives; atomic saves; portrait HUD | Native touch harvest/draft/evolution and replacement-install save checks passed on documented builds; physical-device lifecycle/cutouts/usability remain |
| 2 — retention | All 20 discoveries; categorized Codex with progressive free hints; five chapters; crafting with quantity/queues; blueprint placement; automation/upgrades; Frost; optional Dusk Tide; persistent progression | Human pacing/retention validation |
| 3 — commercial systems | Native Android Google test ads, UMP consent path, Play Billing query/purchase/acknowledge/restore, durable rewarded receipts, caps/reroll/hints, permanent entitlements, opt-in bounded telemetry and crash collection | Actual provider sandbox transactions; publisher consent configuration; receiver configuration; production signing/store accounts |
| 4 — presentation | Distinct generated artwork for 20 discoveries, terrain/nodes/structures, depleted states, resource/UI icons, illustrated cards, DNA bars, reveals, crossfades/fusion/weather feedback, original synthesized cues/ambient loop, photo/share, accessibility/audio controls | Further graphical/device review; listening and human polish review; texture-edge refinement where needed |
| 5 — Android release | Toolchain and native plugin compile; signed debug APK built and installed on API29 emulator | Current OpenGL debug APK installed/resumed/rendered; remaining: device matrix/performance, live sandbox ad/purchase/restore, release signing/AAB/store policy review |

## Current verified milestone

`tools/check.sh`: 679 assertions across 13 suites pass, plus a public-action progression simulation completing 20 discoveries and 5 chapters in 119 tracked progression operations (plus earning-loop harvests), using 35 cells. These results establish system reachability, not player enjoyment or hardware performance. See TEST_REPORT.md for the tested source stage and remaining gates.

Current signed debug APK is installed and renders with OpenGL on the API29 software emulator. Native touch progression, save retention across replacement installation and the photo/system-share path have documented evidence. These checks do not certify physical-device performance or store transactions.

## Continuity

Work continues autonomously in tested increments. Decisions and external dependencies are recorded in docs/RELEASE_DEPENDENCIES.md. Post-launch adventures and future content packs remain roadmap scope, as specified in the PRD. No production ad IDs, purchase credentials, telemetry endpoint, or release signing keys have been introduced.

## Current presentation direction

The user requested Terra Nil's style and gameplay information hierarchy, with Pocket Biome's own colors. The current interface uses graphite/pearl/muted violet, neutral licensed typography, flat thin-bordered panels and original line icons. Chapter/resources sit upper-left, selected-tile ecology upper-right, and contextual actions/tool navigation at the bottom. The earlier parchment/brass and slate/rust passes are superseded.

Implemented camera fitting uses actual sprite extents, including tall fused biomes. Objectives preserve action captions alongside progress. Title/photo views hide gameplay markers. Native photo/export/system chooser checks passed without choosing a recipient. The actual current native screenshot is artifacts/android-02-restored-world.png.

Store sandbox transactions, publisher/signing/telemetry configuration, physical-device performance/cutouts/audio and human playtesting remain release gates. This is not a certified public release.
