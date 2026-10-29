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

`tools/check.sh`: 880 assertions across 15 Godot suites and eight Python audit tests pass, plus startup and two fixed-seed public-action progression simulations reaching all 20 discoveries and five chapters. The collect-ready route takes 5,223 simulated active seconds; adding affordable level-two Windmill upgrades takes 4,810. These probes establish reachability and expose pacing risks, not human enjoyment or device performance. See TEST_REPORT.md and docs/GAMEPLAY_PACING_REVIEW.md.

Current signed debug APK is installed and renders with OpenGL on the API29 software emulator. Native touch progression, save retention across replacement installation and the photo/system-share path have documented evidence. These checks do not certify physical-device performance or store transactions.

## Continuity

Work continues autonomously in tested increments. Decisions and external dependencies are recorded in docs/RELEASE_DEPENDENCIES.md. Post-launch adventures and future content packs remain roadmap scope, as specified in the PRD. No production ad IDs, purchase credentials, telemetry endpoint, or release signing keys have been introduced.

## Current presentation direction

0.14 supersedes the user's rejected0.13 panel-heavy design. Gameplay now uses an original cloud/sky shader, a compact resource row and goal prompt, five small floating tools and transient tile inspection. Detailed conditions, exact power amounts and land capacity are available in the real detail screens. See docs/DESIGN_DIRECTION.md. This is a new visual revision under review, not an assertion of human approval.

Implemented camera fitting uses actual sprite extents, including tall fused biomes. Objectives preserve action captions alongside progress. Title/photo views hide gameplay markers. Native photo/export/system chooser checks passed without choosing a recipient. The earlier native screenshot is artifacts/android-02-restored-world.png; current 0.13 HUD/native evidence is scoped separately.

Store sandbox transactions, publisher/signing/telemetry configuration, physical-device performance/cutouts/audio and human playtesting remain release gates. This is not a certified public release.

## Player feedback fixes

Expansion controls render above canopy art and have nearest-center mobile hit areas. Unfinished drafts can relocate among adjacent clouds with the same offers/quote and no charge. Unaffordable expansion reports the exact price and balance. Fusion guidance detects groups from any selected member, distinguishes Oak from Forest, explains square geometry and active boosts/events, previews the footprint and commits through the unchanged authoritative fusion transaction. Chapter 3 exposes a direct fusion action.

Rain now renders a 3.2-second shower and ripples over every affected biome; reduced motion retains a fading area confirmation. Buttons respond to press/release, menus/panels fade, chapter/ecology values interpolate, and resource changes highlight briefly. These are implemented interaction improvements; full aesthetic/human polish and external release gates remain open.

## Player-facing terminology

Replaced Local DNA with Tile conditions and explicit Moisture/Heat labels. The panel opens an explanation of the selected tile, scores, influences and transformation purpose. Enlarged-text layout measures the actual panel width/height. Tutorial and inspector wording are aligned; saved/internal DNA fields remain unchanged. Latest checks:708 assertions.

## Production engineering pass

Implemented ongoing grounded foliage motion, water ripples and structure activity effects; preserved responsive gameplay/UI animations. Fixed real-frame effect/automation cadence drift. Added in-app privacy/data disclosure, diagnostics deletion/opt-out cancellation, native consent retry/privacy choices and release ad-consent guards. Upgraded/pinned native SDK/compiler/build dependencies and passed the current preview export.

Current evidence:724 Godot assertions, eight Python audit tests, actual OpenGL animation-frame differences, signed preview APK and16KB/package/source-binding checks. Store readiness remains false:development signing, preview/service/test identifiers, missing policy/support configuration and current physical/store/creative acceptance evidence. Full authored rigs are not claimed; remaining art and human polish are documented. See docs/PRODUCTION_READINESS.md.

## Camera and mobile-menu follow-up

Four quarter-turn views, World rotation controls and two-finger twist are implemented with rotation-aware picking/depth/framing. Continuous free-angle 3D orbit remains unimplemented and needs the separately documented renderer/asset phase. Menu touch scrolling now reaches below-fold controls without activating buttons. Native diagnostics capture obeys opt-in, and SDK measurement initialization is delayed. At the 0.11 checkpoint, 750 Godot assertions plus eight Python audit cases pass; release is still blocked as documented.

Latest Android follow-up verified current rotation, menu drag scrolling, privacy disclosure, and real native diagnostics preference On/Off delivery. Stable progression survived replacement and UI testing. Source and evidence are pushed independently of the unfulfilled production signing/store/device/creative gates. Continuous free-angle3D orbit remains unimplemented.

## Gameplay pacing — 0.12 preview

Implemented post-tutorial draft variety with a resource option, local placement/reach descriptions, objective/World next-step suggestions, accessible material trading, affordable automation upgrade guidance, Furnace construction reserves and reserved-quote protection. Existing saves/cards/prices remain compatible. 783 assertions, eight Python audit cases and two fixed-seed public progression routes pass.

This addresses concrete first-session friction and one measured resource-starvation loop. Human enjoyment/retention remains unverified; later costs/collection pressure need further playtesting and balancing. The detailed audit is docs/GAMEPLAY_PACING_REVIEW.md. Production and continuous 3D-camera gates remain open.

## 0.13 mobile HUD redesign

Reviewed current public Google Play listings and screenshots for SimCity BuildIt, Pocket City 2, Township, Pocket City and Pocket Build. Source details and screenshot scope are in docs/UI_RESEARCH.md and artifacts/mobile-ui-references.json. The HUD now separates currencies/materials from the quest/conditions row, gives Build a distinct primary treatment, illustrates selected terrain and its real cooldown, and displays Pulse energy through an original ring/emblem with an exact count. World actions have explanatory cards; modal/dock styling is consistent. No third-party reference artwork ships.

The small-screen/large-text visual pass caught cramped high resource counts; the layout was corrected and regression coverage added. Optional footer actions now trigger relayout before camera/input bounds settle. Actual OpenGL fixtures27–29 document the interface; human design acceptance remains open. This is a preview revision, not production certification.

## 0.14 atmospheric world and compact HUD

Implemented day/dusk/night atmosphere with controlled cloud drift, context-only conditions and selection details, a five-second inspect callout, smaller visible controls with retained touch targets, a direct Pulse icon and lighter World action styling. Exact economy/save behavior is unchanged. The current mobile fixtures verify world-height allocation, high resource counts, goal progress, selection reveal/expiry and inspector access. New shader/vector art is original; actual rendered evidence and scoped Android results are recorded separately.

## 0.15 gameplay-sheet revision

Implemented illustrated draft cards, categorized build catalogue and actual job shelf, current-island miniatures in World, Pulse footprint previews, input/output fusion art, item/Codex diorama stages, bound Settings switches, and illustrated trade/help/store layouts. Shared sheet styling is independent of the compact gameplay HUD. No gameplay recipe or backend service was replaced by a mock; all18 configured crafting recipes remain reachable through All/categories. Exact resource transactions and saved quotes are retained. Visual acceptance remains open; current-source automated and native evidence is recorded separately.

## Cohesive UI proposal — in progress

The user still finds0.15 sheet-like and requests the original logo/asset-sheet identity across the entire game. docs/design/COHESIVE_UI_PROPOSAL.md and its generated four-screen board define a new whole-game direction informed by an actual fresh Play Store screenshot review. This is design work, not an implemented APK or delivered runtime asset pack. The0.15 client and its verification remain unchanged.

## 0.16 — selected draft direction implemented

The user selected the final (Draft) panel of the concept board. Implemented that interaction and material direction in the real draft: three simultaneously visible fanned terrain cards, a raised luminous selection, named saved Coin quote, one green framed Place action, optional detailed information and Later. Selection animates briefly, with an immediate reduced-motion alternative. The island is framed above the hand and the previous camera is restored on dismissal. Affordability and placement still use the real model; offers/prices/saves remain compatible.

Integrated two independent generated blank frame/button assets and the licensed Marcellus typeface. The presentation board is not sliced into runtime UI. Actual rendered fixtures40–42 and new interaction/layout tests cover this specific screen. The rest of the whole-game proposal (title, grouped resource rail, Pack/Build/Pulse tools, contextual Build tray and remaining menus) is still in progress; this update does not claim the entire concept is implemented or production-qualified.

## 0.17 — surrounding composition corrected

The user correctly identified that0.16's background, text and surrounding UI still did not resemble the selected concept. Implemented a separate painted cloud-world plate, illustrated title logo, named Wood/Stone/Coins material rail, journal goal plaque, functional Settings gear, painted navigation/power tools, Cinzel/Lato typography and shared dark slate/bronze surfaces. The actual draft island is larger behind the cards; inactive markers/rings no longer compete with modal content. Corrected nine-patch border density and material-icon atlas bounds. All materials remain accessible in Workshop/trading; conditions help is connected through Settings and tile inspection. No simulation/save/economy/provider configuration changes.

Actual rendered fixtures43–50 show this pass. The lower Build tray, three-tool navigation reorganization and continuous deep-sided island art remain unfinished; see docs/design/REFERENCE_COMPARISON.md. Human visual/physical-device approval and production gates remain open.
