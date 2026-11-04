# Pocket Biome: implementation and release plan

Restoration delivery: the five proposed gameplay priorities now have an integrated implementation. See [Restoration campaign](RESTORATION_CAMPAIGN.md) for chapter requirements, capability rewards, alternatives, wildlife preferences and first-building teaching. This completes that feature scope; player observation, broader creative polish and native/commercial qualification remain required.

Previous implementation checkpoint: [Current game audit](CURRENT_GAME_AUDIT.md). The legal full-island fusion trap now has safe dismantling; single-cell structures can move with upgrades/timing preserved. Chapter 2 requires a living habitat, River Link adds a connectivity objective, completed expeditions offer independent replays, and the opening goal helper focuses on one action. This delivers core recovery and progression improvements. The full teaching sequence, broader presentation/creative work and release qualification below remain active requirements.

## Release objective

Ship an understandable, enjoyable Android discovery/building game that can earn through optional rewarded ads and restrained chapter-break interstitials. Treat playability, enjoyment, retention, ad reliability and commercial performance as separate claims requiring separate evidence. A successful build is not a release decision.

Scope for v1: existing painted island, environmental discovery, five chapters, crafting/automation, fusion, Pulse, saves, and continued creative play. Improve this loop rather than adding unrelated modes or more content to hide pacing problems. No claim of guaranteed earnings. Preserve the user's existing progress, quoted drafts, receipts and purchased entitlements throughout implementation.

Related evidence: [product review](PRODUCT_REVIEW.md), [animation inventory](ANIMATION_STATUS.md), [production blockers](PRODUCTION_READINESS.md), [Android workflow](ANDROID_READINESS.md). This plan is the forward delivery sequence; historical revision plans are not current release approval.

## Screen inventory and coverage

28 fresh 540×960 OpenGL captures are retained at `/workspace/runtime/release-screen-review`. These use constructed states and invoke actual scene methods; they are not evidence that every button, scroll position, gesture, lifecycle or native provider state was manually tested. Contact sheets `index-0.png` through `index-3.png` support composition review. The final capture pass uses the real Rain button signal to enter targeting, waits for the discovery reveal to settle, and includes the corrected Conditions headings. It still does not establish native touch, device or provider behavior.

| Screen/flow | Rendered state | Required implementation/release coverage |
|---|---|---|
| Title / Continue | Initial title | Existing save, fresh launch, return from modal, no title input through overlay |
| Title Settings | Modal over title | Overlap fixed; Android back/close and independent audio preferences |
| Island HUD | Initial island | Early/mid/final islands, all resources, pending actions, safe areas, readable current goal |
| Welcome | Purpose and first action | First-time user can harvest/expand without verbal help; revisit instructions |
| How to play | Scrollable explanation | Remove outdated terminology; practical shortcuts to the thing being explained |
| Conditions help | Water/Oak example | Broken vertical heading wrapping found in this pass and fixed; all text scales and lower scroll content |
| Next-action guide | Early suggestions | Accurate, affordable, state-aware actions; no circular navigation or impossible advice |
| Pack | Inventory/navigation hub | Clarify hub scope, large inventory values and empty states |
| Journal | Unknown entries | Consistent unknown/hinted/discovered/mastered states; filters and scroll restoration |
| Discovery detail | Unknown and known | Free clue progression, exact known conditions, optional ad unavailable/declined/capped states |
| Tile inspector | Oak | Every resource/structure/fused tile, live cooldowns, influence explanation, upgrade/pause |
| Build tray | Materials missing | Explain benefit, owned/required cost, named action, locked/affordable/blueprint-ready states |
| Projects | Empty and active queue | All three slots full, batch changes, completion, already-crafted placement and cancellation |
| Trade | Materials available | Zero stock, insufficient stock, 5/20 batches, reserved quote protection and atomic payment |
| World tools | Ordinary island | Restore confirmation, selected structure upgrade/pause, protected land, Dusk availability |
| Fusion | Incomplete group | Eligible 2×2, wrong group, stale preview, cost/footprint, success and save restoration |
| Pulse | Empty energy picker | Sufficient energy, locked Frost, target preview, confirm/cancel, affordable/insufficient after state change |
| Draft | Three saved offers | Neighbor explanation/highlights, relocation, Later, insufficient Coins, rewarded redraw, one debit only |
| Draft Info | Selected Water | Same saved quote/selection; return to hand; no secret outcome promise |
| Store | Provider unavailable | Ready/no-fill/offline/declined consent, daily cap, interrupted ad, reward/save failure, purchase/restore |
| Privacy | Local disclosure | Hosted final policy, consent choices, deletion, network opt-out and target audience declarations |
| About | Preview text | Accurate release version, credits/licenses, support route and final product claims |
| New world | Confirmation only | Cancel, archive failure, successful reset, recoverable prior world, preserved purchases |
| Photo | Mode controls | Save denied/failure/success, native chooser cancel, return framing and no unintended rewards |
| Discovery reveal | Rainforest fade | Settled title, actual payout, close/share, reduced motion and queued multiple reveals |
| Dusk challenge | Not rendered this pass | Start/unlock, active threats, timeout/success, decline, restored state and no ads during event |
| Chapter rewards / finale | Completion logic, no dedicated finale | Milestone ceremony, once-only rewards, final sanctuary presentation and continue building |
| Error/lifecycle states | Automated coverage only | Save failure, damaged save recovery, background/kill/relaunch, network changes and interrupted purchases |

## Work packages, dependencies and definition of done

### R1 — Screen clarity and reliable navigation

Status: purpose/action-led goals/local placement guidance/title modal/camera copy implemented; Conditions layout corrected. Remainder pending.

- R1.1: Normalize sheet headers, close/back behavior, input blocking, spacing and scroll affordances across the inventory above. Files: Main.gd, CampaignUI.gd, GameSheets.gd, MaterialUI.gd.
- R1.2: Make Build explain each structure's benefit, owned/required ingredients, craft duration and blueprint placement state. Use named actions instead of generic Build. Files: BuildTray.gd, CampaignUI.gd.
- R1.3: Clarify Pack/Projects/World navigation; preserve direct access to existing functions. Unify Journal states/cards and practical clues. Files: CampaignUI.gd, GameplayAdvisor.gd.
- R1.4: Reduce visual competition around the island and unify typography/surfaces without replacing painted art. Check initial and large islands before changing camera scale globally.
- Acceptance: a first-time player can state the purpose, follow one goal, compare a placement, find a clue, craft/place a structure and find Back without coaching. No unreadable/clipped text at supported sizes/120% scale; no obscured or unreachable actions. Capture all primary and error states, not only attractive fixtures.

### R2 — Enjoyable loop and economy

Depends on R1 being usable enough for observation.

- R2.1: Run a developer end-to-end UI walkthrough with no direct state grants; separately observe at least five unfamiliar players for qualitative comprehension. Record prompts, wrong turns, active play, idle periods and repeated tapping. Do not call scripted solver completion a human playtest.
- R2.2: Investigate harvesting fatigue: existing expert solver routes report roughly 1,500–1,600 collections. Compare a collect-ready interaction, earlier useful automation, or input/output adjustments only after locating actual bottlenecks. Preserve feedback and meaningful choices.
- R2.3: Review each building and each chapter for a new decision or capability, not just a larger counter. Give free next-step advice when stuck. Test adverse draft luck and a player who spends materials inefficiently.
- R2.4: Tune economy using both a novice route and an experienced route. Retain all required content without purchases or ad views. Migrate any changed pricing policy without rewriting saved quotes or erasing earned progress.
- Acceptance: representative players can discover why their first transformation happened and describe a next experiment; repeated confusion and involuntary waits have recorded fixes. Set quantitative pacing targets after the baseline rather than inventing success numbers.

### R3 — Campaign payoff and continued play

Depends on R2 pacing results.

- R3.1: Give each chapter a named accomplishment and visible, restrained milestone response. Rewards must remain exactly once across reloads.
- R3.2: Implement a dedicated celestial-sanctuary finale, recap/island portrait and explicit Continue creating route. Reuse the actual island, not a promotional image disconnected from earned progress.
- R3.3: Evaluate whether all 20 discoveries should remain mandatory for the ending or become a mastery goal. Current rules remain five chapters/all 20/25 cells until this is deliberately resolved from playtest evidence. If changed, keep existing completion awards and saves valid and update goals/tests together.
- R3.4: Make optional collection, layout refinement and Dusk challenges legible after completion. Do not add daily chores or more chapters before the existing loop works.
- Acceptance: players recognize that the campaign ended, see their accomplishment, can continue playing and can distinguish optional mastery. Finale never repeats rewards or blocks an old completed save.

### R4 — Monetization that players understand

Local request/receipt/cap logic exists; live readiness remains pending. May proceed in parallel with R2 after publisher prerequisites are available.

- R4.1: Show exact optional reward, availability and a clear continue-without-ad route. Preserve free clues and ad-free campaign completion. Qualify redraw against changed/moved pending hands.
- R4.2: Exercise native rewarded ads for availability, no-fill, cancellation, app suspension/process loss, delayed duplicate callback, earned reward with failed save, and cap boundaries. A reward requires provider confirmation and durable receipt.
- R4.3: Keep conservative existing chapter-break interstitial limits during validation. Test Remove Ads, no interrupting targeting/placement/reveals/challenges, and return from ad. Do not optimize frequency based on dispatch counts.
- R4.4: Add provider-confirmed impression and paid-event reporting if a privacy-reviewed measurement backend is selected. Existing `interstitial_shown` is dispatch-time, not revenue proof. Preserve opt-out and data minimization. Track grant failures separately from impressions.
- R4.5: Validate consent, production ad unit configuration, purchase/restore and licensed Play testers. Actual audience and publisher account are prerequisites; do not invent them or substitute production IDs silently.
- Acceptance: normal progression works offline; declined/unavailable ads do not trap the player; earned rewards survive lifecycle failures exactly once; reported revenue reconciles with provider evidence. Compare return play and complaints alongside revenue. No earnings promise is justified before live data.

### R5 — Android quality and content acceptance

Depends on code stabilization from R1–R4.

- R5.1: Run existing full checks plus targeted new regression tests; rebuild APK from the tested source and retain provenance/signature/alignment audits.
- R5.2: Exercise install/update/save retention, background/kill/relaunch, interrupted actions, low-storage/save failures, offline/resume and supported orientation on real Android hardware.
- R5.3: Measure sustained frame time, memory, heat/battery, startup, motion/audio comfort and input accuracy on at least a representative mid-range device, plus small-phone/cutout/tablet layouts. Desktop Mesa is not device evidence.
- R5.4: Finish art/audio/animation consistency review, reduced motion, enlarged text, readable contrast, touch/gesture alternatives and privacy text.
- Acceptance: no unresolved progression-loss, duplicate-payment/reward, inaccessible-primary-action or critical stability defects. Device reports identify hardware/build/source and limitations; no stale screenshots used as current evidence.

### R6 — Release candidate and measured launch

Depends on R5 and external publisher prerequisites.

- R6.1: Finalize secure upload signing/Play App Signing, production service configuration, hosted privacy/support URLs, audience/content rating, Data Safety, licenses and store listing that matches actual gameplay. No secrets in source or chat.
- R6.2: Produce release AAB, run production artifact audit, distribute to authorized internal testers, resolve regressions and verify update installation. Publishing/submission is a separate user-authorized step.
- R6.3: Run a limited release/test cohort before a broad launch. Measure comprehension, first-session completion/drop-off, voluntary return, crashes/ANRs, ad fill/completion/grant errors and actual revenue. Define the cohort and windows before comparing results.
- R6.4: Decide expand/fix/hold from the evidence. Correct poor comprehension/retention before increasing ad load or paying for acquisition. Track operating/acquisition costs before calling revenue profit.
- Acceptance: all release-critical tasks have evidence, not merely a checked box; actual provider reports exist; no claims of profitability or broad release made on the basis of a debug APK.

## Responsibility and external prerequisites

The agent can implement client changes, preserve compatibility, write/run tests, build artifacts, render/review screens and prepare release materials. The publisher must supply secure production credentials/configuration, audience/business identity, hosted policy/support and authorized account access. Unfamiliar players and physical Android device testing supply evidence the cloud cannot manufacture. Use secure environment settings for credentials, never chat.

## Working rules and current release decision

Work in the existing checkout. Preserve prior animation/guidance changes. Keep completed/implemented, tested, human-accepted and released statuses distinct. For each package record implementation files, screenshot/build evidence, tests, known limits and acceptance outcome. Test changed behavior; do not rerun unrelated work merely to inflate counts. Use a feature freeze after the candidate is stable and retest only affected flows after subsequent fixes.

**Current decision: development preview; not approved for commercial release.** Existing APK/signature/full-campaign checks establish a working implementation. Remaining R1–R6 items establish whether it is understandable, enjoyable and commercially viable. The intended next coding package is R1's screen consistency and building decision support, followed by the R2 observed walkthrough; production monetization and publication remain separate milestones.

## Verification of the screen-pass correction

The Conditions heading correction passed all 156 mobile-layout assertions across three viewport configurations at normal and 120% text. Fresh OpenGL capture confirms the headings and lower actions are readable. This narrow correction was not followed by a new Android package; the previously delivered APK predates it. The earlier full-check result remains 1,259 assertions for the preceding guidance build, not a fresh full-suite result for this correction.
