# Implementation status

Updated 2026-10-25. Authoritative scope: [Master PRD v4.0](docs/MASTER_PRD_v4.md). This is an implemented game under validation, not a certified commercial release.

| Phase | Implemented | Remaining acceptance work |
|---|---|---|
| 0 — audit | Empty-repository audit, Godot 4.6.3, modular architecture, data schema, dependency setup, test plan | Complete |
| 1 — playable slice | Four starting cells; isometric picking; drag/pinch; resources/cooldowns; expansion; illustrated three-card inspection/confirmation; DNA; environmental reactions; five initial evolutions; fusion; Rain/Heat; objectives; atomic saves; portrait HUD | Rebuilt OpenGL Android gameplay/input/lifecycle verification; physical-device cutouts and usability |
| 2 — retention | All 20 discoveries; categorized Codex with progressive free hints; five chapters; crafting with quantity/queues; blueprint placement; automation/upgrades; Frost; optional Dusk Tide; persistent progression | Human pacing/retention validation |
| 3 — commercial systems | Native Android Google test ads, UMP consent path, Play Billing query/purchase/acknowledge/restore, durable rewarded receipts, caps/reroll/hints, permanent entitlements, opt-in bounded telemetry and crash collection | Actual provider sandbox transactions; publisher consent configuration; receiver configuration; production signing/store accounts |
| 4 — presentation | Distinct generated artwork for 20 discoveries, terrain/nodes/structures, depleted states, resource/UI icons, illustrated cards, DNA bars, reveals, crossfades/fusion/weather feedback, original synthesized cues/ambient loop, photo/share, accessibility/audio controls | Further graphical/device review; listening and human polish review; texture-edge refinement where needed |
| 5 — Android release | Toolchain and native plugin compile; signed debug APK built and installed on API29 emulator | Latest OpenGL APK validation, device matrix/performance, live sandbox ad/purchase/restore, release signing/AAB/store policy review |

## Current verified milestone

`tools/check.sh`: 631 assertions across 13 suites pass, plus a public-action progression simulation completing 20 discoveries and 5 chapters in 119 transactions, using 35 cells. These results establish system reachability, not player enjoyment or hardware performance. See TEST_REPORT.md for the tested source stage and remaining gates.

The previous installed Android package selected Vulkan because of the engine mobile override. Both desktop and mobile renderer settings now explicitly select Compatibility/OpenGL; the rebuilt signed debug APK passes all automated checks; native interaction verification is in progress. Do not use the earlier black-screen capture as a current gameplay screenshot.

## Continuity

Work continues autonomously in tested increments. Decisions and external dependencies are recorded in docs/RELEASE_DEPENDENCIES.md. Post-launch adventures and future content packs remain roadmap scope, as specified in the PRD. No production ad IDs, purchase credentials, telemetry endpoint, or release signing keys have been introduced.

## Builder UI redesign

User correction: navy/green is not a fixed direction. docs/DESIGN_DIRECTION.md supersedes the earlier assumption. Implemented parchment/brass/ink styling, licensed display/body typography, compact global HUD, four illustrated dock actions, selected-tile context, one Pulse selector, transient notices, modal scrim/close controls, responsive live-island title screen, illustrated craft cards with owned/required material counts, and a World action hub retaining fusion/photo/center. SimCity BuildIt and Dorfromantik archived screenshots were actually reviewed; current official pages remain network-blocked. See docs/UI_RESEARCH.md. Six mobile size/text combinations pass 24 layout checks; real touch tests pass 12 checks. Latest signed debug APK rebuilt after all631 assertions; its new UI still requires native verification.

Native gameplay evidence from the previous touch-enabled build: harvested Oak, purchased Water from the saved draft and reached three discoveries through Android touch input. Saved world had five cells, chapter2 and three discoveries. This is functional emulator evidence, not physical-device FPS or purchase certification.
