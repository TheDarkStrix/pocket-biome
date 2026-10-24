# Test report

Updated 2026-10-24. Engine: Godot 4.6.3 official. Runner: `./tools/check.sh`. Fresh machine-readable results, timestamp and tested source digest are written to artifacts/test-results.json; individual logs remain ignored under artifacts/test-logs/. The runner rejects missing/zero-assertion suites, timeouts, script errors, nonzero exits and source changes during a run.

| Suite | Assertions passed | Coverage |
|---|---:|---|
| run | 37 | Harvest, draft, DNA, reactions, rewards, pulses and model invariants |
| campaign | 51 | Chapters, recipes, crafting, automation, migrations, Dusk and upgrades |
| save_validation | 319 | Nested invalid state rejection, occupancy/references, schema, restoration and corruption handling |
| save_io_failures | 11 | Injected backup/rename errors preserve committed save and permit retry |
| fusion_edges | 10 | Footprint neighbors, shared cooldown, modifiers and tier protection |
| input_gestures | 8 | Tap/hold/drag/pinch/cancel/UI-origin classification |
| layout | 17 | Portrait geometries, safe-area transforms, scroll bounds and fallback |
| presentation | 12 | Cosmetic isolation, terminating animation, alpha picking and no replay |
| services | 25 | Provider unavailable behavior, callback deduplication, receipt persistence, save-failure retry, reroll/hint contexts, entitlements and diagnostics opt-out/bounds |
| screens | 65 | Menu, Codex/workshop/settings/world/services/photo and complete draft pools |
| scene_smoke | 20 | Launch-to-first-evolution, real card callback path, targeting, lifecycle and persistence |
| **Total** | **575** | Assertions; separate simulation and startup checks also run |

## Progression and graphics

Public-action simulation: all 20 discoveries, all five chapters, 35 cells, 119 gameplay transactions, 5199 simulated active seconds, 1293 final coins; save/restore included. Accelerated simulation is not a human pacing result.

`tools/visual_review.sh` renders through actual Godot OpenGL with Xorg dummy/Mesa. Current captures 01–04 show the gameplay/draft/evolution/inspector route; 07–10 show Codex/detail/workshop/settings. Captures 05–06 deliberately construct visual fixtures and are not progression evidence. No cloud audio listening claim is made.

## Android evidence and limitations

The native plugin compiled and the signed debug package installed on an API29 AOSP x86_64 software emulator. The original export incorrectly selected Vulkan; explicit mobile Compatibility now selects OpenGL, confirmed in native launch logs. The old emulator then reported a 3D shader uniform limit during startup. A reduced unused 3D light limit is under rebuild/validation. No successful native gameplay claim is made until a game screen is captured and exercised.

Open: physical touch/cutout matrix, background/kill restoration on latest APK, native photo chooser, actual test ad reward, Play Billing sandbox purchase/restore, real GPU FPS/memory/thermal/audio, human first-session comprehension, and store release signing. Provider callback tests call the service boundary and do not pretend to execute Google transactions. Local crash handling is not evidence of a configured reporting backend. These gates remain explicit in docs/RELEASE_DEPENDENCIES.md.
