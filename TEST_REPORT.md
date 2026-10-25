# Test report

Updated 2026-10-25. Engine: Godot 4.6.3 official. Runner: `./tools/check.sh`. Fresh machine-readable results, timestamp and tested source digest are written to artifacts/test-results.json; individual logs remain ignored under artifacts/test-logs/. The runner rejects missing/zero-assertion suites, timeouts, script errors, nonzero exits and source changes during a run.

| Suite | Assertions passed | Coverage |
|---|---:|---|
| run | 37 | Harvest, draft, DNA, reactions, rewards, pulses and model invariants |
| campaign | 54 | Chapters, recipes, crafting, automation, migrations, Dusk and upgrades |
| save_validation | 319 | Nested invalid state rejection, occupancy/references, schema, restoration and corruption handling |
| save_io_failures | 11 | Injected backup/rename errors preserve committed save and permit retry |
| fusion_edges | 10 | Footprint neighbors, shared cooldown, modifiers and tier protection |
| input_gestures | 8 | Tap/hold/drag/pinch/cancel/UI-origin classification |
| layout | 17 | Portrait geometries, safe-area transforms, scroll bounds and fallback |
| presentation | 13 | Cosmetic isolation, terminating animation, alpha picking and no replay |
| services | 25 | Provider unavailable behavior, callback deduplication, receipt persistence, save-failure retry, reroll/hint contexts, entitlements and diagnostics opt-out/bounds |
| screens | 80 | Menu, Codex/workshop/settings/world/services/photo and complete draft pools |
| scene_smoke | 22 | Launch-to-first-evolution, real card callback path, targeting, lifecycle and persistence |
| touch_ui | 13 | Actual ScreenTouch→Godot Control launch/welcome path; one harvest despite mouse emulation; mixed UI/world two-finger safety |
| mobile_layout | 36 | Three portrait dimensions × normal/enlarged text; HUD/world separation, caption fitting and viewport bounds |
| **Total** | **645** | Assertions; separate simulation and startup checks also run |

## Progression and graphics

Public-action simulation: all 20 discoveries, all five chapters, 35 cells, 119 gameplay transactions, 5199 simulated active seconds, 1293 final coins; save/restore included. Accelerated simulation is not a human pacing result.

`tools/visual_review.sh` renders through actual Godot OpenGL with Xorg dummy/Mesa. Current captures 01–04 show the gameplay/draft/evolution/inspector route; 07–10 show Codex/detail/workshop/settings. Captures 05–06 deliberately construct visual fixtures and are not progression evidence. No cloud audio listening claim is made.

## Android evidence and limitations

The native plugin compiled and the signed debug package installed on an API29 AOSP x86_64 software emulator. The original export incorrectly selected Vulkan; explicit mobile Compatibility now selects OpenGL, confirmed in native launch logs. The old emulator then reported a 3D shader uniform limit during startup. The unused 3D light limit was reduced, and OpenGL initialization subsequently succeeded with ANGLE/SwiftShader. The software-emulated Android System UI itself stalled/raised ANRs, preventing reliable interaction; a host Mesa backend is now under test. No successful native gameplay claim is made until a game screen is captured and exercised.

Open: physical touch/cutout matrix, background/kill restoration on latest APK, native photo chooser, actual test ad reward, Play Billing sandbox purchase/restore, real GPU FPS/memory/thermal/audio, human first-session comprehension, and store release signing. Provider callback tests call the service boundary and do not pretend to execute Google transactions. Local crash handling is not evidence of a configured reporting backend. These gates remain explicit in docs/RELEASE_DEPENDENCIES.md.

Native touch testing exposed disabled mouse emulation preventing Godot Control buttons from receiving presses. The setting is now enabled, while InputController ignores only emulated mouse events for world gestures. A new real-event regression suite passes. Its headless root explicitly uses 540×960 so OS event coordinates match the GUI; calling button signals alone would miss this bug. Rebuilt native touch-path validation is in progress.

## Latest builder UI verification

645 assertions across13 suites pass, plus full progression simulation and headless startup. The real-event suite now exercises dock→Journal, close/scrim dismissal and Pulse selection as well as welcome/harvest/mixed gestures. Mobile metrics fixtures cover320×640,360×780 and540×960 at100%/120% text. Warm-paper style/rounded typography, compact HUD/dock, illustrated production ingredients and title hierarchy render through actual OpenGL in refreshed artifacts01–12. Final native validation of this redesign is separate and in progress.

The earlier touch-enabled native build was exercised through launch, harvest, Water draft inspection/confirmation and evolution. A saved-state read after that route contained five cells, chapter2, discoveries rainforest/mistforest/reedwater and one harvest, with no debug state injection. The emulator also produced System UI/launcher ANRs while booting; these are not attributed to an app crash. Do not claim physical FPS, reliable Play Billing transactions or finished store readiness from this evidence.

Latest hardening: independent title-island framing after Android viewport resize, deferred modal control deletion during pointer callbacks, photo camera restoration, hidden expansion/selection markers in photos, and short safe photo-toolbar captions. Real-touch workshop quantity rebuild and six title/photo layout fixtures are included in the645 assertions.
