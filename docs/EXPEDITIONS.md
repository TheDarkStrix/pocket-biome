# Expedition islands

Latest additions: first restorations now grant derived home capabilities, and every island offers two authored mastery challenges with independent personal bests. See [Director delivery](DIRECTOR_DELIVERY.md). The relaxed replay rules and original restoration records below remain supported.

The expedition map contains a four-island restoration route. Each is a separate reversible 3×3 puzzle with its own saved layout, environmental state and completion record. Completed islands offer independently saved replay attempts.

| Island | Environmental problem | Supplies and success |
|---|---|---|
| Dry Springs | Thirsty Oaks | Three Water tiles; two moist groves and two flowering habitats |
| Frost Hollow | Frozen Oaks at different positions | One movable Vent, two Water tiles; two groves at 60–85 heat, plus flowering habitats |
| Ember Shore | Hot air and a fixed volcanic rock | Three Water tiles; balance 35–65 heat and at least 70 moisture, then support two flowering habitats |
| River Link | Separated spring and outlet | Connect the fixed Water endpoints with a continuous edge-sharing route using five Water tiles total, then restore two groves and two flowering habitats |

Discover a home biome to unlock Dry Springs. Restoring each island unlocks the next. Completed islands can be revisited. Required completion and unlocking never require an ad or purchase.

## Dry Springs flow


After the first home-island discovery, open Pack → Expeditions (also available in World and next-action suggestions). Dry Springs is a separate 3×3 ecology puzzle. Three water supplies can be rearranged freely; rooted Oaks cannot be removed. Nothing is charged to home Coins or inventory.

1. Put edge-sharing Water beside both Oaks.
2. Advance seasons to grow two groves. Each adjacent Water adds 15 moisture per season; an unwatered Oak loses 10. Groves need 70. Seasons advance only when the player chooses, with no real-time wait.
3. Place two flower patches, each touching both Water and a grove.
4. Complete restoration to record the island and welcome frogs. Return home or revisit the restored layout.

Multiple layouts work. There is no irreversible failure: change Water to Meadow to reclaim it, move supplies and try another season. The completion record is the reward for this first expedition; it does not award home currency or claim a new home discovery. The two thermal islands extend this restoration loop with different heat rules, and River Link adds a connectivity constraint. These are four short authored challenges, not a large expedition campaign.

## River Link and replay

Restore Ember Shore to unlock River Link. Its fixed spring and outlet are at internal indices 2 and 6; the Oaks are at 0 and 8. Diagonal contact does not connect water. Two legal routes add Water at 1/4/7 or 5/4/3, with flowers in the remaining two cells. Both support the surrounding habitats after three seasons. Endpoint outlines and the staged objective show the extra connection requirement. The water supply counts the two fixed endpoints.

On a restored island's map card, **Replay challenge…** confirms replacement of the previous replay attempt. **Continue replay** resumes an unfinished attempt; completed replay cards show its season count. Original restorations remain read-only and retain their own layouts. Replays use the same rules, award no home resources and register no new completion ad milestone. This is free retry/practice with a last-result record, not a ranked or procedural mode.

Optional `expedition_attempts` records use the same strict validation as original `expeditions`; both canonicalize JSON moisture, heat and season numbers. River records add island identity but no heat array. Legacy Dry Springs and thermal records remain accepted.

Current follow-up validation: all eight Python audit tests, 1,488 assertions across 30 Godot suites, two full campaign completion probes and startup pass. The 16 new replay checks verify independent records, no repeat completion milestone, endpoint protection, route topology, alternate solutions and validation. Android preview and ARM64 package checks pass. Later sections retain historical validation counts from their original checkpoints.

## Implementation and compatibility

- `Expedition.gd`: bounded rules, staged objective, neighbor topology, reversible edits, save validation.
- `ExpeditionBoard.gd`: painted isometric island, mouse/touch plot selection, keyboard selection, ambient animation and simple frog visitors. Reduced motion freezes cosmetic clock motion.
- `ExpeditionUI.gd`: map/entry, board, terrain controls, objective/progress, completion and return flow.
- `CampaignSchema.gd` / `SaveStore.gd`: optional `expeditions` record in the existing atomic home save, strict per-island content/budget/bounds validation and JSON integer canonicalization for moisture and heat. Existing saves without this field remain accepted.
- Main/CampaignUI/GameplayAdvisor: entry routes and discovery-based unlock. Home state continues normally; this puzzle does not swap or overwrite the home island, currency, entitlements or reward ledger.

Completion saves successfully before registering any ad opportunity. A failed save leaves completion retryable and creates no ad milestone. Repeated completion cannot replay the milestone. Leaving an unfinished expedition saves the layout; closing its sheet also retains the already-saved edits.

## Advertising behavior

The native ad/store connection is prepared at a quiet gameplay moment after the first discovery, once per session. Explicit retry remains available in Store. Release native code still gates requests through UMP; no production ad IDs or consent/account configuration were invented. Debug builds continue to use test units.

Each newly completed expedition can add a natural interstitial opportunity when returning to home. Existing first-eight-minute delay, ten-minute spacing, two-per-session cap, Remove Ads, pending-draft and active-challenge exclusions remain. An unavailable/ineligible ad does not undo completion or block return. The one-time milestone need not show an ad: it is eligibility, not a guaranteed impression. Rewarded offers remain voluntary.

## Validation scope

`tests/expedition.gd` exercises two complete solutions, budget and topology, reversible edits, home-state isolation, JSON save/resume, malformed records, actual board selection, save-failure completion, duplicate completion, offline return, automatic ad preparation and natural-break frequency guards. The full runner includes this suite.

OpenGL fixtures under `/workspace/runtime/expedition-review` show entry, dry board, water, groves, habitat-ready, recorded completion, return map and 320×640 enlarged-text layout. These are scripted walkthroughs, not proof of novice enjoyment or native touch performance. Live consent/ad fill, real-device lifecycle/performance and a first-time player study remain release gates.

Final debug build validation: all eight Python audit tests, 1,314 assertions across 22 Godot suites (including 49 expedition checks), both full original campaign simulations and startup passed. Universal preview audit and ARM64 package signature/alignment/content checks passed. Live ad delivery and commercial release remain unverified.

## Thermal challenge rules and compatibility

Frost Hollow begins with Oaks at plots 1 and 3 (internal indices 0 and 2), moisture 80 and heat 20. One Vent warms each adjacent tree by 15 per season. Adjacent Water cools by 10; groves require heat 60–85. Heat above the upper bound is not a successful habitat. Vent placement can be reversed and water moved to recover.

Ember Shore keeps the opposite-corner Oaks, initially at heat 95 and moisture 25. Its rock at internal index 2 is protected. Air warms trees by 5 per season, while each adjacent Water removes 20 heat and adds 15 moisture. Groves require heat 35–65 and moisture at least 70. Continuing to cool can invalidate a grove; removing/rearranging supplies permits recovery. Conditions update only on player-controlled seasons. Completed layouts are retained as restoration records.

Dry Springs retains its original four-field save format and rules. Thermal records add identity and a nine-value heat array; all three records can coexist in one home save. Invalid identities, heat arrays, budgets and protected plots are rejected. The season display saturates at 10,000 while environmental turns remain usable, avoiding a counter-based soft lock.

25 new focused thermal checks verify distinct solutions/rules, heat bounds, recovery, unlock order, persisted independent records, validation, entry routing and restoration ad eligibility. Original expedition checks remain in place. Standard and small-phone fixtures are retained at `/workspace/runtime/thermal-review`. Neither those constructed captures nor automated solutions establish human enjoyment or completion time.

Expanded private Android build validation: all eight Python audit tests, 1,357 assertions across 24 Godot suites, both original campaign completion probes and startup passed. Universal preview and ARM64 package signature/alignment/content audits passed. Production ad delivery and human enjoyment remain unverified; nothing was publicly distributed.
