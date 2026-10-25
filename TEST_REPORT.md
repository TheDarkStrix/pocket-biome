# Test report

Updated 2026-10-25. Engine: Godot 4.6.3 official. Runner: `./tools/check.sh`. Fresh machine-readable results, timestamp and tested source digest are written to artifacts/test-results.json; individual logs remain ignored under artifacts/test-logs/. The runner rejects missing/zero-assertion suites, timeouts, script errors, nonzero exits and source changes during a run.

| Suite | Assertions passed | Coverage |
|---|---:|---|
| run | 44 | Harvest, draft, DNA, reactions, rewards, pulses and model invariants |
| campaign | 54 | Chapters, recipes, crafting, automation, migrations, Dusk and upgrades |
| save_validation | 319 | Nested invalid state rejection, occupancy/references, schema, restoration and corruption handling |
| save_io_failures | 11 | Injected backup/rename errors preserve committed save and permit retry |
| fusion_edges | 10 | Footprint neighbors, shared cooldown, modifiers and tier protection |
| input_gestures | 11 | Tap/hold/drag/pinch/cancel/UI-origin classification |
| layout | 17 | Portrait geometries, safe-area transforms, scroll bounds and fallback |
| presentation | 29 | Cosmetic isolation, terminating animation, alpha picking and no replay |
| gameplay_pacing | 28 | Seeded offer diversity/eligibility, tutorial stability, local placement descriptions, actionable advice, reserves, upgrade quote protection and save continuity |
| services | 29 | Provider unavailable behavior, callback deduplication, receipt persistence, save-failure retry, reroll/hint contexts, entitlements and diagnostics opt-out/bounds |
| screens | 83 | Menu, Codex/workshop/settings/world/services/photo and complete draft pools |
| scene_smoke | 41 | Launch-to-first-evolution, real card callback path, targeting, lifecycle and persistence |
| touch_ui | 35 | Actual ScreenTouch→Godot Control launch/welcome path; one harvest despite mouse emulation; mixed UI/world two-finger safety |
| mobile_layout | 72 | Three portrait dimensions × normal/enlarged text; HUD/world separation, caption fitting and viewport bounds |
| **Total** | **783** | Assertions; separate simulation and startup checks also run |

## Progression and graphics

Public-action simulation: all 20 discoveries, all five chapters, 35 cells, 119 tracked progression operations, plus earning-loop harvests, 5199 simulated active seconds, 1293 final coins; save/restore included. Accelerated simulation is not a human pacing result.

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
