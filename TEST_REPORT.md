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
| services | 29 | Provider unavailable behavior, callback deduplication, receipt persistence, save-failure retry, reroll/hint contexts, entitlements and diagnostics opt-out/bounds |
| screens | 83 | Menu, Codex/workshop/settings/world/services/photo and complete draft pools |
| scene_smoke | 41 | Launch-to-first-evolution, real card callback path, targeting, lifecycle and persistence |
| touch_ui | 30 | Actual ScreenTouch→Godot Control launch/welcome path; one harvest despite mouse emulation; mixed UI/world two-finger safety |
| mobile_layout | 72 | Three portrait dimensions × normal/enlarged text; HUD/world separation, caption fitting and viewport bounds |
| **Total** | **750** | Assertions; separate simulation and startup checks also run |

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
