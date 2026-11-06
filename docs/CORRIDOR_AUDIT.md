Latest follow-up: [Player journey audit](JOURNEY_AUDIT.md). The following records the earlier River delivery.

# Living River audit — 2026-11-05

This extends the [earlier director delivery](DIRECTOR_DELIVERY.md). The new work supplies a signature home-island chapter with limited flow, two approaches, causal restoration and tactile route planning. All scores are developer judgments; enjoyment remains unmeasured.

| Area | Earlier assessment | Current assessment | Basis / remaining gap |
|---|---:|---:|---|
| Distinctive core mechanic | 6/10 | 8/10 | A linked grove → migration → seedbed puzzle, plus supply/shelter tradeoffs; strategy quality needs player observation |
| Rule clarity | 7/10 | 8/10 | Delivered/demand numbers, soil/growth readings, repair guidance, previews and forecast; novice understanding unobserved |
| Direct control / visual feedback | 7/10 | 8/10 | Real drag/tap previews, saved routes, undo, animated delivery and visible chapter changes; physical comfort untested |
| Attachment / story | 7/10 | 8/10 | Named approaches, actual pollination outcome, Living Heart, local milestone story exports |
| Technical confidence | 8/10 | 8/10 | Repeated full regression/campaign checks and rendered touch route; native device acceptance still open |
| Commercial readiness | 4/10 | 4/10 | Existing capped native monetization remains a test integration; production/provider and audience requirements unchanged |
| Player enjoyment | Unmeasured | Unmeasured | No human playtest or revenue claim |

## Pass 1 — rules and recovery

Focused checks cover complete wetland/woodland restoration, real Meadow evolution, drought allocations, shelter demand, ordinary timer preservation, reward deduplication, save/load, changed terrain/source, compatibility, previews, cancellation, undo, real touch dragging, failed-save rollback and enlarged-text touch bounds. The first complete regression run passed **1,806 assertions across 37 Godot suites**, four campaign routes and startup, plus eight Python audit tests.

All four campaign routes use ordinary paid gameplay transactions and public route authorities. Three reach all twenty discoveries and all five chapters. The shorter primary path finishes five chapters with seven discoveries in 648 accelerated active seconds. These are known-solution simulations, not human playtime estimates.

## Pass 2 — rendered review and clarity fixes

The actual OpenGL game completes the new chapter through screen-touch controls: approach/source selection, two dragged previews, confirmation, allocation, seedbed selection and observed seasons. The fixture constructs a suitable home island before play; it injects no chapter progress. The saved result includes all three stages and an actually evolved Meadow. This is separate from the fresh-start campaign probes.

Inspected captures cover approach choice, planning, confirmation, allocation, restoration stages, completion and story. A second fixture covers a 320×640 portrait display with 120% text and woodland requirements. Review prompted a solid caption background, actual seedbed/endpoint condition readings, clearer source/route repair messages and reduced-motion checks. The scripted rendered harnesses are retained in `validation/river-touch.gd.txt` and `validation/river-mobile.gd.txt`.

The portrait review also caught an early-transition capture. A rendered regression now compares the export byte-for-byte with a settled reference and confirms that both model state and the unfinished on-screen animation are preserved. The harness is `validation/river-portrait.gd.txt`.

A separate Pillow decoder loads every full 180×320 frame of the exported gameplay GIF, including repeated LZW clear blocks, timing and loop metadata. File writing and format signatures are also covered by the Godot control suite. Android sharing validates app-local paths, image signatures, size and PNG/GIF MIME type before opening a chooser.

Selected inspected captures: [approach choice](validation/river-approaches.png), [route planning](validation/river-planning.png), [restored island](validation/river-restored.png), [small portrait / enlarged text](validation/river-mobile.png). These are gameplay screenshots from constructed fixtures.

A controlled rendered clock check changes 29,951 pixels in normal motion and zero pixels in Reduced Motion. This uses the actual scene process callback while keeping the test below an ordinary model tick. A 36-cell/five-visitor-group scene with two delivering routes profiles at 9.780 ms median and 14.682 ms p95 cached refresh over thirty desktop headless samples under shared workspace load. Those figures are logic timing, not phone frame rate or a controlled speedup over earlier measurements.

## Pass 3 — final regression and Android packaging

Final source `54cff0b624e59ccd59b5a98945b5a1f96ab1a519e5a0de090c2960eda3a7dc7e` passed 1,806 assertions across 37 Godot suites, four campaign probes, startup and eight Python audit tests. The final river walkthrough used 26 actual screen-touch actions and completed all three stages; the fresh opening used 28 actions and earned its first restoration through the ordinary clock/resources.

The ARM64 test APK SHA-256 is `2eb222da718b66fa60151b1afc1a0ff3ef3e3f0d21833e01c6a2b41c38336a74`. Its 639 retained files match the universal build; source binding, signature and 16 KB alignment checks pass. The compiled DEX contains the new GIF MIME/magic validation logic. No Android device was attached.

Source-bound counts, checksums, campaign reports, rendered results and package audit results are retained in [CORRIDOR_VALIDATION.json](CORRIDOR_VALIDATION.json). The APK remains a development-signed, test-service preview. No public application release was performed.

## Limits

Desktop OpenGL rendering and scripted touch completion demonstrate functioning controls and a reachable chapter, not physical-phone performance or a guarantee of enjoyment. There is no attached Android device/emulator in this environment. Physical touch, thermal/battery performance, audio listening, Android share chooser acceptance, production advertising/billing/consent and unfamiliar-player observation remain release gates. The changes do not establish retention or revenue. Existing test ad settings/caps are preserved.
