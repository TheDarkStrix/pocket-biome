# Player journey and release-candidate audit — 2026-11-06

This pass addresses advanced teaching, actionable objectives, pacing guidance, feedback and native ad recovery on top of [Living Corridors](LIVING_CORRIDORS.md). The implementation and limits are described in [Player journey](PLAYER_JOURNEY.md). Exact source/package/campaign results are retained in [JOURNEY_VALIDATION.json](JOURNEY_VALIDATION.json).

## What changed and why

- Four optional lessons derive their steps from actual land, allocations, growth, production and habitat suitability. They persist skip/completion state, resume from the HUD and retain full reference instructions after completion. Reviewing completed help is read-only.
- A live checklist explains every campaign requirement, its current/required count, purpose, blocker and next action. Completed checks use explicit text as well as a checkmark. New recipe/project/resource routes open the relevant tool or actual plot.
- Material help distinguishes a missing prerequisite from a missing resource, a running job, a finished blueprint and a full queue. It uses real costs/timers and preserves ordinary production. Guided recipe links select a single quantity, avoiding a stale three-item quote from a previous batch.
- Lesson step/completion feedback follows observed state. Completion is synchronized before the HUD reads it, so the goal does not continue advertising a finished lesson. Layout review includes small portrait screens with enlarged text.
- Interstitial gating now lives in the service authority as well as UI callers. Historical chapters are baselined; lessons, drafts, weather, pending rewards and fullscreen presentation are protected. No-fill recovery retries quietly with a one-minute throttle and native duplicate-load/consent guards. Earned receipts remain valid if weather begins during presentation.
- A source-bound Android smoke tool and explicit phone/provider acceptance procedure are ready. The tool never promotes startup success to full device qualification.

## Verification and findings

Focused tests exercise all lesson completions through the actual rule authorities, every chapter requirement's executable action, read-only help/review, skip/revisit, legacy/corrupt saves, failed lesson saves, real crafting/production and native-provider policy through a fake bridge. Policy tests distinguish dispatch from actual impression/value callbacks and cover earned-reward recovery. Early full audits exposed outdated ad-test assumptions; the tests now explicitly distinguish unfinished guidance from a safe post-guidance expedition break.

The final repair review also checks a natural flower path that bypasses its mature grove and an old seedbed outside the new garden reach. Both remain safe saved configurations; the lesson now offers the specific repair/reselection action instead of leaving the player observing a stalled habitat.

The actual rendered advanced walkthrough completes the River lesson through 44 screen-touch actions, earns the real flowering corner and saved lesson receipt, skips/revisits fusion, reviews completed instructions, and follows missing-material help to the real Wood source without spending. Its home island is constructed before the walkthrough; it is not a fresh campaign or human usability study. A separate rendered opening uses actual controls, ordinary time and earned materials from a fresh island. Screens include chapter objectives, lesson actions/reference, material help and 320×640 / 120% text.

Full regression, four campaign probes, native compilation and package integrity are repeated after the focused/visual fixes. Pacing evidence retains all routes' simulated duration, progression events and node-collection counts. No human timing or enjoyment score is inferred from those known-solution probes. Economy prices/cooldowns remain unchanged pending observed player evidence; this pass reduces navigation and information friction.

## Remaining gates

No authorized Android device/emulator is attached in the current environment; the device report is explicitly blocked. Physical touch, sustained performance, battery, audio, Android share chooser, real SDK consent/no-fill behavior and Play sandbox purchases remain unverified. Production provider accounts/configuration, URLs and signing are not supplied. The preview does not earn qualified production revenue or constitute a store release. The [acceptance procedure](ANDROID_ACCEPTANCE.md) makes each remaining check concrete without declaring it passed.

Human comprehension, enjoyment and retention remain unmeasured. The implementation supports a complete playable candidate; it does not establish that unfamiliar players understand or enjoy it.

Inspected screenshots: [chapter checklist](validation/journey-objectives.png), [advanced lesson](validation/journey-lesson.png), [material help](validation/journey-material-help.png), [small-screen objectives](validation/journey-mobile-objectives.png), and [route repair](validation/journey-repair-route.png). Reproducible external harnesses are stored as `validation/journey-*.gd.txt` to keep QA scripts out of the APK.

## Final candidate evidence

Source `f0d6bab13af3adb94a294c42f36bdf7bd7449673127b72afce5d44fc241408b1` passed **1,901 assertions across 39 Godot suites**, all four campaign routes, startup and **12 Python checks**. The 70-check journey suite covers all lesson outcomes and the two specific repair conditions; the 25-case fake-provider suite covers break eligibility, retry throttling, overlap prevention, failure recovery and earned receipts. A preceding full pass also succeeded before the final two repair conditions were added; its separate source digest is retained.

ARM64 preview APK SHA-256: `513b9632be3bbe6cc45ca3be10692c9e0cd7b36419bb1c4c92c013e9c54b239e`. All 647 retained files match the universal package; embedded source, signature, 16 KB alignment and QA exclusion pass. The APK DEX contains the native retry/load-guard implementation. Physical-device and production-provider acceptance remain false.

The 36-cell/five-visitor-group desktop scene with two live routes and an active lesson/checklist measured 21.892 ms median and 27.196 ms p95 cached refresh across thirty headless samples under shared workspace load. This is logic timing at a periodic refresh, not phone frame rate or a controlled comparison.

| Known-solution route | Active seconds | Progression operations | Largest recorded progress-event gap |
|---|---:|---:|---:|
| pacing-simulation | 1174 | 128 | 68.0 s |
| pacing-automation | 1146 | 128 | 68.0 s |
| pacing-balanced | 1244 | 146 | 68.0 s |
| pacing-primary | 648 | 61 | 68.0 s |

These timings do not measure a new player. Ordinary timers and economy values remain unchanged; the delivered pacing improvements concern finding materials, using available projects/blueprints, batching collection and understanding useful next actions.
