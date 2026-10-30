# Implementation status

Updated 2026-10-30. Authoritative scope: [Master PRD v4.0](docs/MASTER_PRD_v4.md). This is an implemented game under validation, not a certified commercial release.

| Phase | Implemented | Remaining acceptance work |
|---|---|---|
| 0 — audit | Empty-repository audit, Godot 4.6.3, modular architecture, data schema, dependency setup, test plan | Complete |
| 1 — playable slice | Four starting cells; isometric picking; drag/pinch; resources/cooldowns; expansion; illustrated three-card inspection/confirmation; DNA; environmental reactions; five initial evolutions; fusion; Rain/Heat; objectives; atomic saves; portrait HUD | Native touch harvest/draft/evolution and replacement-install save checks passed on documented builds; physical-device lifecycle/cutouts/usability remain |
| 2 — retention | All 20 discoveries; categorized Codex with progressive free hints; five chapters; crafting with quantity/queues; blueprint placement; automation/upgrades; Frost; optional Dusk Tide; persistent progression | Human pacing/retention validation |
| 3 — commercial systems | Native Android Google test ads, UMP consent path, Play Billing query/purchase/acknowledge/restore, durable rewarded receipts, caps/reroll/hints, permanent entitlements, opt-in bounded telemetry and crash collection | Actual provider sandbox transactions; publisher consent configuration; receiver configuration; production signing/store accounts |
| 4 — presentation | Distinct generated artwork for 20 discoveries, terrain/nodes/structures, depleted states, resource/UI icons, illustrated cards, DNA bars, reveals, crossfades/fusion/weather feedback, original synthesized cues/ambient loop, photo/share, accessibility/audio controls | Further graphical/device review; listening and human polish review; texture-edge refinement where needed |
| 5 — Android release | Toolchain and native plugin compile; signed debug APK built and installed on API29 emulator | Current OpenGL debug APK installed/resumed/rendered; remaining: device matrix/performance, live sandbox ad/purchase/restore, release signing/AAB/store policy review |

## Current verified milestone — original painted land restored

**Session paused at the user’s request.** Read SESSION_HANDOFF.md before resuming. Runtime sourcefa96a28;0.21.1-preview/code15; tested source digest `e7813bf2a0989e8a521e2238cd5f7044d674cd6eea24b2afb2986113fdce2de2`. Android export/phone packaging and replacement installation pass; the save stayed byte-identical. Native UI/interaction/photo checks for the restored build remain pending. The rejected3D package is superseded by the restored painted build on the download branch.

0.21.1 restores the earlier painted land from before the added cliff-base/shared-grass pass. Main defaults to `orbit_enabled=false` and `connected_land=false`: original painted terrain/nodes/structures retain their complete surfaces and warm earth edges. No new meshes, flat grass carpet or generated3D portraits appear in the normal game. Drafts, Workshop, Journal and world miniatures again use the original painted source artwork. Current HUD/menu controls and gameplay/save/economy remain.

The0.21 procedural3D presentation was a rejected visual change. Its code remains isolated for technical regression only, with explicit opt-in in experimental tests/capture tools; it is not the player-facing default or approved art direction. The restored painted camera supports pan/pinch and four90° views, not continuous3D orbit. Automatic art-style replacement is prohibited by this recorded user preference.

Disconnected decorative edge waterfalls are suppressed: an exposed pond does not establish a visible pond-to-cliff outlet. Proper connected waterfall artwork and additional individual-object animation remain unfinished. Existing painted canopy movement, water ripples, layered Windmill sails, resource/fusion/pulse feedback and source effects are retained. Golem limbs and workbench tools are not claimed animated.

All1,241 assertions across21 Godot suites, eight Python audit cases, startup and both full campaign probes pass. The new12-case painted-art regression tests default rendering, original menu/card assets, four-view picking, state isolation and absence of disconnected falls. Actual-engine captures90–92 show the restored default land/Workshop/draft. Android package/native evidence follows in TEST_REPORT.md; final creative/physical-device/provider/signing qualification remains open.

## Continuity

Work continues autonomously in tested increments. Decisions and external dependencies are recorded in docs/RELEASE_DEPENDENCIES.md. Post-launch adventures and future content packs remain roadmap scope, as specified in the PRD. No production ad IDs, purchase credentials, telemetry endpoint, or release signing keys have been introduced.

## Current presentation direction

The selected Pocket Biome concept board supersedes the earlier graphite/violet, parchment and five-tool directions. The current design uses painted sky/foliage and tool objects, narrow slate/bronze materials, cream Cinzel/Lato lettering, a connected floating island and a green primary action. Older revision notes below are historical.

Surface silhouettes and hand-shaped contours still differ from the concept. Windmill blades now have a separately animated3D assembly. Physical-device performance/cutouts/audio, human playtesting, live provider sandbox checks and publisher/release configuration remain open. This is a test preview, not a certified commercial release.

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

## 0.18 — environment attached to the actual island

The user correctly distinguished the distant sky plate from missing scenery on/under the playable land. Implemented an occupied-cell foundation with painted rock faces, irregular tapered cliff tips, surface joins, hanging roots/ivy, local mist and shader-animated waterfalls on exposed unfrozen water edges. It follows real expansion, fused ownership, negative/irregular layouts and all four camera turns. Neighboring cells share corner positions and do not receive interior cliff walls. Photo/title framing and World miniatures include the new geometry. Expansion clouds/markers retain visible priority and hit behavior.

The three new artwork sources are integrated as separate runtime assets; no complete island picture replaces gameplay. Geometry is cached independently of cooldown/DNA clocks, decoration freezes with reduced motion/photo mode, and liquid outlets are capped at two. Gameplay/economy/save/provider configuration is unchanged. Actual rendered fixtures51–59 and current native observations are scoped in TEST_REPORT.md. Existing raised terrain-pad artwork is still visible above the new connected foundation; this is not a claim of fully retopologized/approved final terrain art or completed production polish.
