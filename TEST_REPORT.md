# Test report

Updated 2026-10-30. Engine: Godot 4.6.3 official. Runner: `./tools/check.sh`. Fresh machine-readable results, timestamp and tested source digest are written to artifacts/test-results.json; individual logs remain ignored under artifacts/test-logs/. The runner rejects missing/zero-assertion suites, timeouts, script errors, nonzero exits and source changes during a run.

| Suite | Assertions passed | Coverage |
|---|---:|---|
| run | 44 | Harvest, draft, DNA, reactions, rewards, pulses and model invariants |
| campaign | 54 | Chapters, recipes, crafting, automation, migrations, Dusk and upgrades |
| save_validation | 319 | Nested invalid state rejection, occupancy/references, schema, restoration and corruption handling |
| save_io_failures | 11 | Injected backup/rename errors preserve committed save and permit retry |
| fusion_edges | 10 | Footprint neighbors, shared cooldown, modifiers and tier protection |
| input_gestures | 11 | Tap/hold/drag/pinch/cancel/UI-origin classification |
| layout | 17 | Portrait geometries, safe-area transforms, scroll bounds and fallback |
| presentation | 39 | Cosmetic isolation, terminating animation, alpha picking and no replay |
| gameplay_pacing | 28 | Seeded offer diversity/eligibility, tutorial stability, local placement descriptions, actionable advice, reserves, upgrade quote protection and save continuity |
| services | 29 | Provider unavailable behavior, callback deduplication, receipt persistence, save-failure retry, reroll/hint contexts, entitlements and diagnostics opt-out/bounds |
| screens | 85 | Menu, Codex/workshop/settings/world/services/photo and complete draft pools |
| scene_smoke | 42 | Launch-to-first-evolution, real card callback path, targeting, lifecycle and persistence |
| touch_ui | 47 | Actual ScreenTouch→Godot Control launch/welcome path; one harvest despite mouse emulation; mixed UI/world two-finger safety |
| mobile_layout | 150 | Three portrait dimensions × normal/enlarged text; HUD/world separation, caption fitting and viewport bounds |
| sheet_layout | 36 | Draft hand/actions, catalogue, World cards, power controls and setting switches at three portrait sizes/two text scales |
| draft_flow | 22 | Saved offers/quote, retained selection, Info/redraw safety, affordability, one placement and camera restoration |
| island_environment | 42 | Four-turn cliff topology/triangulation, fused owners, roots/outlets/cache and photo framing |
| build_flow | 77 | Six mobile/text cases; complete recipe reachability, focus/scroll/controls/camera; real touch craft/completion/place/cancel/save; blocked placement and cosmetic ground mesh/preview |
| expansion_pricing | 26 | Early-price parity, late budget, strict legacy/current quotes, relocation/payment/save and malformed revision rejection |
| orbit_world | 140 | Shipping3D camera,72 yaw/pitch poses, first evolution/save, complete profiles/portraits, fusion, ghost, native twist/compass, mobile fit, weather and lifecycle |
| **Total** | **1,229** | Assertions; separate simulation and startup checks also run |

## 0.21 living-world verification

All20 suites, eight Python audit cases, startup and both complete public campaign routes pass for the source digest in artifacts/test-results.json. New3D tests run separately from explicitly retained legacy2D atlas fixtures. Actual OpenGL/Mesa captures80–86 cover start, mixed island, non-cardinal orbit, moving parts, Build, draft and Rain. Forty menu portraits were captured from the runtime geometry/materials. The shader/render logs report no script/shader errors after corrections.

`artifacts/living-world.gif` captures24 actual-engine frames at a fixed camera. The staged model stays byte-identical;30,543 pixels change beyond an8-value RGB threshold. The nine-cell fixture uses42,416 triangles and72 MeshInstances including pooled ambient effects. This verifies visible motion and bounded scene composition, not physical Android FPS or creative approval. Golem limbs remain unrigged; final art-direction/human playtesting stays open.

The current Android package/native results are appended below after exact-source export and installation checks. Production release gates remain unchanged.

## Progression and graphics

Public-action simulations: both collect-ready and automation-first routes reach all20 discoveries, five chapters and35 cells, with117 tracked progression operations plus earning loops. Their simulated active times are1,097 and1,076 seconds; final Coins1,114 and1,155. Save/restore is included. These are deterministic reachability probes, not a human pacing result.

`tools/visual_review.sh` renders through actual Godot OpenGL with Xorg dummy/Mesa. Current captures 01–04 show the gameplay/draft/evolution/inspector route; 07–10 show Codex/detail/workshop/settings. Captures 05–06 deliberately construct visual fixtures and are not progression evidence. No cloud audio listening claim is made.

## Android evidence and limitations

The native plugin compiled and the signed debug package installed on an API29 AOSP x86_64 software emulator. Current APK resumes and renders through explicitly selected OpenGL Compatibility. Bounded current-process log review found no errors; see artifacts/android-runtime-check.json. The software emulator also raised Android System UI/launcher ANRs while booting; these are not attributed to the game.

The earlier native touch route exercised launch, Oak harvest, Water draft inspection/confirmation and evolution without debug state injection. Saved state contained five cells, chapter 2, three discoveries and one harvest. A replacement-install check compared ten persisted fields successfully (artifacts/android-restore-check.json). The current APK also installed and resumed that world. These observations are scoped to documented builds, not every device/lifecycle scenario.

Native photo mode hid gameplay HUD/expansion markers, exported a 320×640 PNG and opened the real Android ChooserActivity. No destination was selected and no photo/message was sent. See artifacts/android-photo-check.json and native captures. Sharing was checked on the preceding corner-HUD build; subsequent camera/goal-caption changes have automated coverage and current native rendering evidence.

Remaining: physical touch/cutout/lifecycle matrix, real GPU FPS/memory/thermal/audio, actual test-ad reward and Play Billing sandbox purchase/restore, configured consent/telemetry, human first-session comprehension and store signing. Provider callback tests exercise the service boundary, not real Google transactions. Local crash collection does not establish delivery to a configured backend or a crash-free percentage.

## Current presentation verification

The user requested Terra Nil's style/structure rather than its colors. Current UI uses an original graphite/pearl/violet palette, chapter/resources upper-left, local ecology upper-right and contextual bottom tools. Actual OpenGL captures 01–12 and native captures show the revision. Earlier playful/parchment and slate/rust skins are superseded.

Mobile fixtures cover three portrait dimensions at normal/enlarged text. They check settled HUD framing, Pulse-number width, separated corner panels, title hero and photo-toolbar bounds. Actual sprite extents drive camera fitting. A tall 32-cell visual fixture derives Ancient Grove bounds independently from renderer atlas metadata; it is not earned-progression evidence. Real-event tests cover navigation, modal replacement and quantity rebuilding. Objective captions retain the action instruction and progress.

## First player feedback regression pass

701 assertions pass across 13 suites, plus progression/startup. Added cases cover pending-draft relocation without debit/reroll; every visible frontier center through real ScreenTouch events on a 16-cell fixture; any-corner fusion detection; four-in-a-row rejection; pulse-blocker explanation; actual dialog confirmation; full-cross rain state surviving refresh/reduced-motion; bounded weather lifetime; and HUD press/release settling. The ecology readout assertion now waits for the real interpolation to finish.

Actual OpenGL fixtures 13–16 show raised expansion controls, an illustrated fusion chooser, and two distinct frames of the rain shower. These use a constructed layout and are presentation evidence, not earned progression or native-device proof. Current package/native evidence is separately recorded in android JSON artifacts; prior native screenshots remain historical until refreshed.

Current native feedback checks: replacement installation succeeded, title and resumed-world screens rendered, and a top-left canopy-adjacent cloud opened a real draft. Closing it and touching a different cloud changed the saved destination from -2,0 to 2,0 with identical cards, quote, balance and tile set. Stable progress fields survived installation; the old app stayed active for 39 seconds between the first snapshot and installation, so its effect clocks advanced. A shader-cache recompile warning appeared; bounded app logs contained no script/runtime errors. See android-feedback-check.json and captures 05–07. Native phone GPU/performance and rain appearance still require physical-device feedback; native emulator checks do not replace that.

## Tile-conditions clarity update

708 assertions pass. The HUD now names Moisture and Heat under Tile conditions. A real touchscreen tap opens the player explanation, which identifies the selected tile, defines the 0–100 scores, distinguishes warmth from Celsius, and explains neighbor/Pulse influences and transformation requirements. Tutorial copy uses conditions; inspector scores include /100. Internal DNA data and schema are unchanged.

The six mobile size/text fixtures now verify named-reading separation and the full panel above the world. Enlarged text exposed both a height issue and a width overlap; layout now measures the conditions panel when reserving header space. Real-touch help navigation passes. Current native device recheck is separate; previous native captures show the prior HUD wording.

## Animation and production hardening

724 Godot assertions across 13 suites pass, plus complete progression/startup. Eight separate Python audit-policy/ELF-parser tests pass. Added cases cover grounded canopy deformation, UV bounds, bounded displacement, reduced-motion invariance, no activity from paused machines, cosmetic isolation, frame-jitter-safe environment/automation cadence, no stalled reward bursts, diagnostic deletion/cancellation and offline privacy navigation.

Current preview export compiled with Ads25.5.0/UMP4.0.0/Billing8.3.0, Kotlin2.3.21 and AGP8.10.1. Signature, package/minAPI24/target36, portrait, no capture/location permissions, QA-source exclusion, ARM64, 16KB ZIP alignment and every native ELF load segment pass. The embedded source hash matches the passing source report. Source provenance deliberately excludes its generated stamp from its own digest. The production audit exits2 as expected and enumerates ten unmet configuration/acceptance gates; preview package success is not production approval.

Actual OpenGL frame comparison uses a constructed six-cell visual fixture at two fixed cosmetic times:3,904 canopy pixels and605 water-region pixels changed; the sampled Oak ground patch stayed identical. This demonstrates visible ambient motion and grounded art, not player progression, physical GPU FPS or complete sprite rigs. See artifacts/ambient-frame-check.json, frames17–18 and docs/ANIMATION_STATUS.md. Native lifecycle evidence for this revision is separately scoped in its JSON report.

## Native scrolling, consent and cardinal-camera follow-up

Latest 750 Godot assertions and eight Python audit tests pass. A touch-drag regression first failed with menu buttons consuming input, then passed after buttons allowed propagation to ScrollContainer. It also verifies no button toggles and no leaked world pointers. The headless fixture enables touch capability for this native ScrollContainer path; the test sends real ScreenTouch/ScreenDrag events rather than setting a scrollbar value.

Camera tests cover all four expected projected directions, inverse cell picking, every frontier center, full-circle state invariance, fused origin/reservation/cooldown preservation, pinch jitter rejection and a World rotation button through touch. Views are 0/90/180/270° billboard-style isometric projections; continuous 3D yaw/back faces are not implemented. Four OpenGL fixture views are captured separately.

Native crash capture now follows the actual diagnostics preference and ignores historical process exits from opt-out periods. The manifest delays Ads app-measurement initialization. These controls compile with the current native dependencies; actual regional UMP and Google transactions remain uncertified. Current native observations are scoped in artifacts/android-production-check.json; earlier captures/reports are historical.

Latest native750-source follow-up:current APK installed and rendered, World rotation reached90°, dragging menu controls scrolled to below-fold privacy actions, and privacy disclosure opened. Reading actual native preferences confirmed diagnostics enabled=true after the On control and=false after Off. Stable save/progression fields remained unchanged; bounded current-process logs had no script/runtime error lines. The JNI privacy dispatch bug was reproduced as missing preference writes before the fix and corrected via the known compiled interface. These are software-emulator checks, not physical-device gesture/performance or provider certification.

## 0.12 gameplay pass

783 assertions across 14 Godot suites pass, plus eight Python audit cases, startup and two public progression policies. Real-touch tests open objective suggestions, return to the island without auto-harvesting, and execute/persist an illustrated 20-material trade. Dealer tests sample multiple seeds/chapters, verify unique eligible stable hands and unchanged saved drafts. Model cases cover the reported surplus-Wood/cash-short fixture, local effect/reach descriptions, nonmutating advice, useful automation guidance, reserved plot coins and automatic/manual Furnace input behavior.

Both fixed-seed public routes finish the full 20-discovery/five-chapter campaign and restore the resulting save. The new event/collection traces expose substantial late progression gaps; tests do not prove enjoyment. docs/GAMEPLAY_PACING_REVIEW.md gives the measured results and unexecuted human-session acceptance. Actual OpenGL fixtures24–26 show suggestions, material trade and local card consequences; they use constructed states, not earned-progression evidence. Native 0.12 observations are recorded separately in artifacts/android-gameplay-check.json; earlier provider/rotation/privacy reports retain their original scope.

Native 0.12: the exact final universal APK installed over the existing save; every ZIP member matched the exported package. The title/restored world, objective suggestions and direct Workshop trade screen rendered and accepted touch navigation. Legacy pending cards/quote and stable progress fields were retained; active clocks advanced. Insufficient stock correctly disabled the trade controls; no native sale was executed. The real 20-material transaction/save is covered separately by the automated touch fixture. Bounded current-process logs contained no script/runtime error lines; a cached shader was recompiled. See android-gameplay-check.json and captures17–18.

## 0.13 HUD verification

The current source adds high-count layout checks at three portrait sizes and two text scales, selected-name/inspect separation, ability ring/count containment, mobile inspect/Build target sizes and an actual touch path from the selected-biome inspect control. The existing touch route also caught a newly visible fusion shortcut temporarily reshaping its footer; reserving action width and listening for minimum-size changes fixed the stale world-input bounds.

Mobile layout: 108 checks pass. Touch UI: 36 checks pass. Actual OpenGL captures27–29 show the new HUD, World hub and small-screen/120% text/high-count fixture. The first small-screen candidate visibly wrapped currency amounts despite older layout checks passing; the header structure and coverage were corrected before packaging. Human visual acceptance, physical devices and real store providers remain separate gates. Final automated/native package evidence is recorded in the current Android JSON reports.

Current 0.13 automated total: 820 assertions across 14 Godot suites, plus eight Python audit tests, startup and both public progression simulations. Harvest feedback now flies to its matching material counter; materials absent from the compact HUD finish at the selected-biome illustration. The revised presentation does not alter the underlying award transaction.

Native visual review of the first 0.13 candidate exposed a hidden chapter count when the instruction wrapped. Quest progress now has its own label beneath the full instruction; all six mobile size/text fixtures explicitly require the visible 4/8 count. The current final-source/native evidence is recorded in android-hud-check.json.

Final 0.13 native check: replacement installation succeeded; the final-source HUD showed the restored world and separate5/8 goal count. Touching the selected-biome arrow opened Mistwood Refuge inspection, the Pulse medallion opened actual powers without spending energy, and World opened the action-card hub. Stable save fields and tile data were retained except active environmental clocks. Bounded current-process logs contain no script/runtime errors; cached shader recompilation is recorded. See android-hud-check.json and native captures19–22.

## 0.14 world-first presentation checks

Mobile layout now has132 checks, including a world-height floor of55% at all six portrait size/text fixtures, high counts, full quest progress, retained targets, actual land-touch callout reveal and expiry. The prior persistent-meter tests now check correct selection context and live numerical readings in the real inspector. Touch tests wait for a post-modal frame before interacting with the returning transient callout. Scene smoke adds reduced-motion freezing of the cloud animation clock. Actual OpenGL captures27/29/30/31 show the compact HUD, large-text layout, temporary callout and dusk variant. These are constructed visual fixtures, not human approval or earned progression. Current package/native evidence is separately scoped.

Current 0.14 automated total:845 assertions across14 Godot suites, eight Python audit tests, startup and both complete public-action progression simulations pass. Native shader/input/save observations are scoped in android-atmosphere-check.json. No physical GPU frame-rate or human visual approval is asserted.

Final 0.14 native: the shader renders the sky/clouds on the software-emulator OpenGL backend. The restored HUD is compact; Pulse/World/leaf controls open actual screens, land interaction reveals a Grass callout, and tapping it opens the full inspector. Stable save fields and tile data were retained except active clocks. Current-process bounded logs have no script/runtime errors; cached shader recompilation is recorded. A host-driven750ms stationary swipe produced the callout rather than direct inspection, so native hold timing is not certified by this run. The callout-to-inspector route passed. See android-atmosphere-check.json and captures23–28.

## 0.15 sheet interaction and layout verification

880 assertions across 15 Godot suites pass, plus eight Python audit cases, startup and both public-action campaign simulations. New real-touch cases swipe across draft artwork, verify unchanged saved offers/balance, and open the third card's actual confirmation. Catalogue category controls expose the complete structure subset and return every configured recipe without changing model state. The 20-material trade still executes/persists the actual transaction. The new 30-case sheet-layout suite covers three portrait sizes/two text scales: card actions, catalogue width, World art/title/description containment, power targets and setting switches.

Existing queue tests verify actual quantity/countdown/completion and blueprint results. Actual rendered fixtures33–39 are constructed presentation states, not earned progression or human approval. Long legal/privacy text and all existing service callbacks remain present. Final Android/source provenance and native observations are separately scoped in current artifacts.

The first 0.15 native candidate exposed an unsupported full-width plus in empty project slots and save-dependent dictionary order in the inventory ribbon. The glyph was changed to ASCII and the ribbon now uses a fixed resource order. Sound Off/On persistence and draft swiping passed on that candidate; final-source observations are recorded separately.

Final-source0.15 native: replacement installation retained all stable save/progression fields and tile data except active clocks. The original Forest/Water/Iron offers and15-Coin quote render correctly; a real swipe moves the gallery without charging/redealing. Catalogue slot markers and resource order are corrected. Reading the actual save confirms Sound Off=false and then On=true. Bounded current-process logs have no script/runtime error lines; cached shader recompilation is recorded. See android-sheets-check.json and native captures29–33.

## 0.16 card-hand verification

913 assertions across16 Godot suites pass, plus eight Python audit cases, startup and both complete public-action campaign simulations. The new22-case draft suite checks saved-quote display, one active selection, reduced-motion behavior, no selection/Info debit, real SaveStore round-trip, insufficient-funds rejection, restored camera/dock, one chosen placement and duplicate-confirmation rejection. Native-style screen-touch coverage now selects the third visible card directly, opens its actual Info and confirms the exact terrain/quote plus the separate first-expansion objective reward. The36-case sheet-layout suite checks all three rotated card bounds, mobile target sizes, names/traits and confirmation containment across three portrait sizes/two text scales, alongside the existing catalogue/powers/settings cases.

Actual OpenGL fixtures40–42 show the implemented hand, changed selection and small-phone/120% text. The island in these fixtures is deliberately constructed for presentation review; it is not naturally earned progression or a render of the concept-board world. Remaining screens retain their prior UI. No physical-device performance or human creative approval is inferred from these checks.

0.16.0-preview/code8 Android export succeeds. Source/test/embedded provenance matches7b9e5c8696b013c7bfbebe0cbabc463c1bd57a6ee2505cd6aa8709f1ed4c9850. The ARM64 preview is99,181,922 bytes with SHA256 5dd33c60575ded69f6046472ce129e212e07aca465ffe0b80f7578f71855cddb; retained files, signature and16KB alignment pass. Production audit exits2 with the same10 real release blockers; this is not a production release.

Final-source0.16 native: replacement install succeeds as code8 and preserves the exact saved world before launch. Continue opens the existing Forest/Water/Iron offers and15-Coin quote. Real180ms stationary touch selects Iron, moves the glowing frame and changes the action to Place Iron. Later returns to the island/dock; all saved fields and tile data remain unchanged except active time/next-effect clocks. Native QA deliberately leaves the pending plot unplaced; actual placement, reward, affordability and duplicate-confirmation transactions are automated-test evidence. Bounded current-process logs have no script/fatal errors. The software emulator showed an Android System UI ANR during cold startup, unsupported translator query messages and a cached-shader recompilation warning; none establishes physical-device performance or app crash rate. See android-card-hand-check.json and native captures34–36.

## 0.17 setting, typography and shared-material verification

927 assertions across16 Godot suites pass, plus eight Python audit cases, startup and both complete public-action progression simulations. Mobile coverage now includes visible names on all three framed resource groups across three portrait sizes/two text scales and the Settings destination of the top-right gear. Real screen-touch coverage opens the gear, scrolls its actual Tile conditions action into view and opens help through the connected button. Existing draft selection/Info/affordability/placement/reward/save tests remain passing.

Actual OpenGL fixtures43–50 cover draft, changed selection, gameplay, illustrated title, Workshop, Settings, powers and a small-phone/120% text case. The first rendered material candidate exposed stretched gold bands; virtual texture density now preserves border proportions on badges and tall panels. The actual island in these fixtures is constructed for presentation review. The existing Build catalogue, five-route dock and ground-art spacing remain different from the concept; see docs/design/REFERENCE_COMPARISON.md.

0.17.0-preview/code9 export succeeds with source/test/embedded digest 86b2f563cad2a1316f9c9dce68e20e338db9a39fe680c054e9979e1000b1157c. ARM64 APK SHA256 3fe53b5df18a258ec076b148e1b4a1992b52f7da33fa287c1a8a3b314f1d61a0, 100,289,639 bytes; signature,435 retained files and16KB ZIP/ELF alignment pass. Production audit exits2 with the same10 release blockers. No physical-device/provider/creative qualification is implied.

Final-source0.17 native: replacement installation succeeds as code9 and preserves the exact saved world before launch. The illustrated logo/cloud plate/green action render on the actual title. Continue restores Forest/Water/Iron and the15-Coin quote with the named resource rail. Real180ms touch selects Iron and changes the actual confirmation to Place Iron. Later keeps the pending transaction; the gear opens actual Settings with the new frames/type/indicators. Stable root fields and tile data remain unchanged except time/next-effect clocks. Bounded current-process logs contain no script/fatal errors. Native QA deliberately leaves the pending plot unplaced; actual placement and other transactions remain automated-test evidence. This software emulator does not qualify physical performance, audio comfort, provider transactions or human creative acceptance. See android-material-ui-check.json and native captures37–40.

## 0.18 attached-island environment verification

975 assertions across17 Godot suites pass, plus eight Python audit tests, startup and both complete public-action progression simulations. The42-case island suite covers empty/starting/expanded/hollow/large negative-coordinate footprints, shared corner continuity, fused owners, exposed versus enclosed/frozen water, a two-outlet budget, geometry caching, photo bounds and reduced motion. It validates every cliff mesh in long staircases and rings through all four turns. An early global taper inverted some long-island faces; the corrected taper is horizontally bounded and every bottom corner remains below its ground corner. Existing real-touch expansion/placement/fusion/pulse/save tests continue to pass. Mobile layout now150 checks, including root/cliff/outlet photo bounds across three sizes/two text scales.

Actual OpenGL fixtures51–59 cover initial four-cell land, larger attached scenery, waterfall motion, quarter turns, draft/title/photo, a fused sanctuary and the shared World preview. Constructed art states are labelled; these are not earned progression or human visual approval. Clock-only rendered frames52/53 differ in6,198 pixels above a two-channel-level threshold while the simulation is held fixed, documenting cosmetic movement. Physical FPS is not inferred. The existing surface-pad soil bands remain above the new foundation; this pass does not claim a complete surface-art replacement.

0.18.0-preview/code10 export succeeds, source/test/embedded digest f02463374599904bdad50f4740c6c1539232aec476940035bfb9328466e850fd. ARM64 APK 100,942,129 bytes, SHA256 7917fa83fb7846a244fa52dd671116538998c15ac5a96780f9439a59f0499d15;448 retained members, signature and16KB alignment pass. Production audit exits2 with the same10 real release blockers.

Final-source0.18 native: replacement installation succeeds as code10 and preserves the exact saved world before launch. Title and restored draft show the real five-cell island's cliff foundation/roots. World miniatures include the same foundation. Real touch activates Rotate right; the cliff/root geometry follows and an exposed water ribbon renders at the new visible edge. Real touch opens Photo mode, which includes the full base/roots/spray, and Done restores the previous quarter-turn gameplay view. Stable root fields and all tile data remain unchanged except time/next-effect clocks; the original pending Forest/Water/Iron offers and15-Coin quote remain. Bounded current-process logs contain no script/fatal errors. Native QA tests one actual turn, not all four native views; all-four-turn mesh validity and placement/fusion are automated evidence. No physical-device performance, provider or human creative qualification is claimed. See android-environment-check.json and native captures41–45.

## 0.19 concept-wide composition verification

All 1,053 assertions/18 Godot suites pass, plus eight Python audit tests, startup and both complete campaign probes. New 77-case Build flow uses actual ScreenTouch events to open the primary tool, pay the selected Workbench4 Wood/2 Stone once, wait normal model time, observe Place without reopening, cancel while retaining the blueprint, and deploy/save on an empty Grass tile. Six small-phone/portrait/text cases verify all categories/Close/selected actions fit, retained selection is revealed, all18 configured recipes remain available with no browsing debit, and closing restores the prior exact camera/dock. Horizontal drag does not select/build. Pending drafts/full islands explain placement conflicts. Every atlas/structure/discovery/fused/depleted shared-ground mesh triangulates with valid UVs; cosmetic previews do not mutate gameplay.

Existing screen/catalogue tests now explicitly target the retained detailed Projects screen; new Build-flow tests exercise the actual lower tray. The real-touch route opens Pack and then Journal, preserving old destinations after the three-tool consolidation. Whole-suite output is rejected on script errors even when assertion totals pass; a typed empty-array optimization error was caught during final build checks and fixed before packaging.

Actual OpenGL fixtures60–64 show current Play, lower Build and ghost, Pack, Draft trait symbols, and title. They use a constructed10-cell art fixture with an existing Windmill/Workbench and supplied review stock, not earned progression. The conceptual board is excluded from packaged resources. Captures are actual Godot output, not generated full-screen mockups.

Android0.19 export, payload/signature/alignment/source proof and installed-emulator evidence are recorded below. Physical-device performance, continuous3D orbit, layered windmill rotor animation, human creative/pacing qualification and real provider sandbox/release gates remain open.

Initial0.19 source/test/export digest `479f87f0318cf09b30791f07f649d6e4455544ce96a18c1581bc878efb69b7b1`. ARM64 download 101,045,424 bytes, SHA256 `1c526ba4e60b16bc38ee150fd1cdb1fc1e49f7d8911b5f798dbdcaee7d85237e`; all458 retained members are byte-identical to the universal APK, signatures and16KB ZIP/ELF alignment pass. Production audit still exits2 with10 real release blockers. A nonfatal ObjectDB shutdown warning appeared under the Xorg94 fixture runner; a final-source verbose OpenGL render under Xorg95 exited without it. No runtime script/render error appeared; no long-duration leak-free claim is made.

The installed0.19 preview exposed fractional formatting of JSON recipe costs (4.0/2.0) and an unnecessary idle project row. Final code formats resource quantities as integers and hides the idle summary while keeping Pack→Projects. Starting a job reveals the live queue summary; completion still exposes Place. These branches add two focused checks, bringing the final total to1,053. Final-source screenshots/native evidence supersede the initial0.19 captures.

Final export after the installed-UI fixes: source/test/export digest `c330f85c1bf183bd887776f22514f128618d3c97e64b95514cb06dcb81e2d901`; ARM64 101,045,424 bytes, SHA256 `6e1a686a8e39bd35417229b1d357bc6971f82c9b7d35dce21ba680ef699a794f`, 458 retained payload members verified, all 1,053 assertions and source/signature/16KB ZIP+ELF alignment pass.

Final-source0.19 native: replacement install preserves a byte-identical save before launch. Real touches exercise Continue→restored Draft→Later→Play→Build, Android Back→Pack→World. The original Forest/Water/Iron offers,15-Coin quote,150 Coins, all stock, five-cell footprint, types/evolutions, discoveries, objectives and other stable fields remain unchanged; only active time/next-effect clocks advance. Actual Build shows integer4 Wood/2 Stone, missing3 Wood/2 Stone, disabled confirmation and an eligible Meadow ghost. The idle project row is absent; the island is visibly larger above the tray. Pack shows all eight stocks and four destination tools; its World action reaches fusion/photo/rotation. Current-PID logs contain no script/fatal lines. See android-cohesive-ui-check.json and captures46–51. The immutable ARM64 download responds HTTP200 with the exact101,045,424-byte length. Native payment/turns were not repeated in this UI pass; real touch craft/deploy/save is automated evidence, prior native rotation is separately documented. The final OpenGL fixture runner exits without the earlier ObjectDB shutdown warning.

## 0.20 connected/reference correction and pacing verification

All1,087 assertions/19 suites, eight Python audit tests, startup and both full campaign probes pass. New motor tests cover a registered fixed hub, actual sail mesh movement, full-revolution bounds, alpha picking, paused/reduced/photo freeze, resumed phase, unchanged model state and retired-entry cleanup. Every supported terrain/depletion/discovery skirt blend triangulates with bounded UVs/alpha. Sampled ground material including its edges is opaque. Existing touch/mobile checks qualify the continuous resource rail, larger clean medallions and Workshop; no functional route is removed.

Pricing tests preserve the first13 quotes, cap/budget later prices, and exercise revision1 and2 through real save/load/relocation/confirmation. Unsupported revisions and mutated prices are rejected. Both full public-transaction routes still reach all20 discoveries/five chapters/35 cells:1,097/1,076 active seconds,1,662/1,509 manual collections,68-second maximum logged gaps. These are expert reachability probes, not enjoyment or retention proof.

Actual OpenGL fixtures70–75 use a constructed10-cell review world. Motor-only world changes cover1,400 pixels in[166,399,225,453];119 other pixels are the first frame's still-settling HUD highlight and are explicitly excluded from motion evidence. No FPS claim is made. Reference art is packaged as separate real assets, not a board screenshot. Documentation-only store art is1024×500 and staged; publisher/store review remains open.

Final0.20 export digest `489a4b3d13763da89de63350992befc1ab879dc2ad87079298c0f58d6acf0116`; ARM64 101,579,779 bytes, SHA256 `cb68e1d97abb8a95371fe84525b8476f68d9a03fc822082bccd46f82ac9b9312`. All476 retained members are byte-identical to the universal APK; signatures, source binding and16KB ZIP/ELF alignment pass. Production audit still exits2 with10 real blockers.

Final installed0.20 update retains a byte-identical0.19 save before launch. Actual Continue/Draft/Later/Play/Build/Back/Pack/World/Rotate right inputs render the cleaner rail/tools/workbench and continuous floor. One native quarter turn preserves joins and attached waterfall scenery. All27 stable root fields and tile state remain unchanged except active time/next-effect clocks; original Forest/Water/Iron offers and15-Coin quote remain. No script/fatal lines appear in the bounded current-PID log. See android-reference-correction-check.json and captures52–57. Native rotating-sail playback/payment/provider/physical performance are not inferred; rotor motion and transactions are tested separately. Current OpenGL render exits without script/render errors.

## 0.20.1 saved-price readout compatibility

A new late-world legacy quote regression first fails because WorldModel.cost returned the new curve although payment retained the saved old quote. WorldModel.cost now returns the actual frozen pending quote whenever present; new draft creation still uses revision2 when no quote exists. Validation remains independent in ExpansionPricing and still rejects arbitrary/mutated prices. Both legacy/current readout cases pass; pricing coverage is26 and total1,089 assertions/19 suites, with all eight Python audits, startup and both full campaign probes passing. No visual, reward, stored-price or owned-land change is included in this patch.

Final0.20.1 source/test/export digest `dccc0c279837dbe293b6020fefb788607e5c7ed15232c9635d1c6f858fa3b339`; ARM64 101,579,779 bytes, SHA256 `26615c91e83aa125f2205da63060e649d4cdda63a058f96a305965a953f2c9b0`, all476 retained payload members verified, signatures and16KB alignment pass.

Final exact0.20.1/code13 installed-native check: Android package manager confirms version13/0.20.1. Update preserves a byte-identical save before launch. Actual Continue→Draft→Later restores original Forest/Water/Iron offers and15-Coin quote, current rail/tools and connected floor. All27 stable root fields/tile data survive backgrounding; only time/next-effect clocks change. Bounded current-process logs have no script/fatal errors. See android-quote-patch-check.json and captures58–60. The late high-price legacy case is automated evidence; this native save has one expansion and is not represented as that scenario. The earlier0.20 native Build/Pack/quarter-turn evidence covers unchanged presentation.

## First0.21 package checkpoint — superseded by framing follow-up

Runtime source commit:c11772a. Tested/exported source digest:2a6216f329dfa7872611cc8372110015b478d8200262d85a910d974aed143405. Version0.21.0-preview, code14. Universal APK SHA256:9b7010f59f4a045947018809a95eeb6f6dde85eba82b61e31f126bf73920707e. Phone ARM64 APK SHA256:2d42ade52e7d0da78f43b05fe7e2e17e01b78f2ffe602c93daee82f0313987fa,102,159,210 bytes. All575 retained members are byte-identical to the universal export. Source binding, signature, portrait/package/SDK and16KB ZIP/ELF checks pass. The production audit still returns the ten documented release blockers; it is not a store-readiness pass.
