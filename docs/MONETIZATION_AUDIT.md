# Monetization audit — 2026-11-06

The goal of this change is a credible automatic-ad revenue path with a playable game. [AD_MONETIZATION.md](AD_MONETIZATION.md) documents the implemented placements, cadence, failure handling, measurements and owner setup. Exact evidence is retained in [MONETIZATION_VALIDATION.json](MONETIZATION_VALIDATION.json).

## Implementation findings and corrections

The earlier policy waited eight active minutes and capped automatic dispatches at two per app session. It supported a small set of original completion breaks, had no monetization for fresh replay/mastery attempts, and could offer an ad through generic menu closure after a historical milestone. The current code uses explicit newly saved result placements with consistent Continue/Close/Android Back behavior.

The new cadence is configurable, records actual exposure rather than attempted dispatch, survives world/app restarts, covers spacing after rewarded ads and permits long-session slots to recover. Engine active time is independent of world age. No-fill/show failure never waits over gameplay or resurrects a missed result later. Game simulation stops during fullscreen presentation. Failed persistence protects progress and suppresses additional forced exposure where cadence cannot be recorded safely.

A home lesson previously suppressed every placement while its active flag remained set. Protection now follows the teaching context: completed side activities remain eligible, so leaving an unfinished home lesson in the HUD cannot turn all expeditions permanently ad-free. Home teaching itself stays protected.

AdMob configuration was hard-coded in native source. Validated resource generation now connects app/unit IDs and audience settings to the manifest/SDK. Debug exports use test units. A separate billing switch supports an ads-only release; tests and package audits reject an enabled sandbox store in production. The preflight reports missing live configuration instead of fabricating it.

## Evidence and scope

Focused policy tests cover first/returning guards, all-format spacing before automatic ads, rolling caps, duplicate callbacks, restarts/world changes, no-fill/late loads, failure backoff, overlapping rewards, active teaching/side activities, storage failure, remove-ads and earned receipts during weather. Scene integration covers durable completion, all six placement routes, Continue/Close/Android Back, unchanged rewards, fullscreen time freeze and ad-free ordinary menus.

The rendered review uses real screen-touch controls on a constructed island with controlled eligibility clocks and a fake native provider. It shows chapter and habitat result dispatch, completed side-expedition dispatch while a home lesson remains active, unchanged earned progress, correct mobile touch bounds and no repeat monetization when a historical result is reopened. It does not show a real SDK video or prove real fill/revenue. Separate rendered opening and advanced lesson walkthroughs verify that the game journey still works.

Synthetic five-/thirty-minute schedules exercise the real policy with assumed 100% fill. They measure eligible exposure coverage only. The comparison with the earlier cap is illustrative and is not a revenue, retention or human-timing result.

Full game/save/UI checks, all four campaign routes, native compilation and APK source/signature/alignment/configuration checks are repeated after the focused fixes. An earlier complete audit is retained separately with its own source digest. The current preview remains development-signed and uses test advertising/products.

## External qualification still open

No AdMob owner identifiers or audience choice have been supplied. No authorized Android device/emulator is attached. Actual SDK video presentation, fill/no-fill behavior, consent/privacy flows, paid-value accuracy, billing (if enabled), phone performance and player response remain unqualified. Production signing, actual privacy/support URLs and owner app approval remain open. The account/setup questions were requested while implementation continued; unanswered fields remain explicitly unset.

Real income is not live. No bank/account credentials, production ad traffic, public application release or paid campaign was created. Increasing measured revenue per player while maintaining completion/return behavior requires production data after those prerequisites are fulfilled.

## Final candidate

Source `334670b1b2e5e2455a2bd0127df1d2af93d524a6e88e76144ae24ee05d157701` passed **1,960 assertions in 41 Godot suites**, four campaign probes, startup and **22 Python checks**. The focused suites contain 47 policy/recovery checks, 21 scene/placement checks and 15 synthetic-exposure checks. The rendered result walkthrough uses six real screen-touch actions with a fake provider, and separate ordinary-clock opening / guided-River walkthroughs use 27 / 44 actions. All three rendered reports name this exact source and have no script/runtime errors.

The ARM64 test APK SHA-256 is `3117cfbb1107185437d48a8a7253b1731c0a008c1048f4ef6cb8beac7ff35ad8`. Source binding, all 651 retained files, signature, 16 KB alignment, embedded ad configuration, native resource binding and QA exclusion pass. DEX inspection confirms the context-aware dispatch, audience and resource-loading implementation.

Inspected captures: [chapter result](validation/monetization-chapter.png), [expedition result](validation/monetization-expedition.png), [small-screen result](validation/monetization-mobile.png). They are game screens from controlled fixtures, not real ad creatives.
