# Current game audit

Original audit snapshot: gameplay branch at `1a5940c` (guidance checkpoint). The findings below describe that snapshot. The follow-up status here records subsequent implementation; earlier chronological review notes remain historical.

## Current director delivery

Three subsequent build/audit passes are recorded in [Audit scorecard](DIRECTOR_ITERATIONS.md), with the full feature/status mapping in [Director delivery](DIRECTOR_DELIVERY.md) and source-bound [validation](DIRECTOR_VALIDATION.json). Those documents supersede the feature status and final-goal assumptions in the older snapshots below.

## Previous restoration implementation

The five subsequent gameplay priorities are now implemented. See [Restoration campaign](RESTORATION_CAMPAIGN.md) for the exact rules and player journey:

1. Distinct chapter restorations: spring, pollinator garden, working woodland workshop, climate refuge and connected sanctuary.
2. Earned capabilities: water channels, shade, warmth, landscape movement and expanded care capacity.
3. Alternative viable layouts for spring, garden, workshop and climate shelter; compact and extended sanctuary connections.
4. Live wildlife preferences, larger visitor groups for selected designs, and arrival/departure feedback.
5. Playable guidance through comparison, observation, crafting, placement and the first habitat; dismissible and durably completed, with automatic provider/consent preparation and interstitials deferred during guidance.

The project screen prioritizes the next unfinished chapter restoration and exposes layout alternatives and useful unlocks. Old saves and earned chapters remain accepted. The existing completion recovery, expeditions and painted presentation remain.

Validation: eight Python audit tests, 1,573 assertions across 31 Godot suites, two full campaign probes and startup passed. Both campaign probes finish all 20 discoveries and five chapters within 36 cells, taking 1,116/1,142 simulated active seconds using known solutions. Android preview and ARM64 package checks pass for source `80f6f5fc202b9175b22620508e8cef303f0a8ff5560b670ac6ac5f74368d70fc`. Full evidence is recorded in [Restoration validation](RESTORATION_VALIDATION.json). Enjoyment, novice understanding, retention, physical-device performance and commercial income remain unverified. The bounded visitor-preference implementation does not claim animal breeding or a simulated food chain. No public app release was performed.

## Previous follow-up implementation

- **Completion trap fixed:** confirmed sanctuary dismantling recovers the four plots, preserves discoveries and restores protected resource nodes. The exact 36-cell adverse layout is now a regression test.
- **Structure movement implemented:** legal destination outlines, preview, confirmation and cancel; identity, upgrades and production timing retained; failed saves roll back. See [Layout recovery](LAYOUT_RECOVERY.md).
- **Restoration integrated into Chapter 2:** completing one existing habitat project is now an explicit chapter requirement. Claims reevaluate campaign progress. Existing completed chapters and earned rewards are preserved. This is one integration, not a rewrite of all five chapters or a new unlock system.
- **Fourth expedition and replay implemented:** River Link adds a continuous cardinal water route between fixed endpoints. Independent replay attempts preserve original restoration records and cannot repeat completion ad milestones. See [Expeditions](EXPEDITIONS.md).
- **Opening goal helper narrowed:** harvest, expand and inspect now appear one relevant action at a time, with broader ideas available. A full interactive teaching sequence through crafting and a novice observation study remain outstanding.

Previous checkpoint validation: eight Python audit tests, 1,488 assertions across 30 Godot suites, two successful full-campaign solver probes and startup. Both probes complete all 20 discoveries and five chapters in 1,067/1,087 simulated active seconds; these are known-solution probes, not human completion estimates. Android preview and ARM64 signature/alignment/content checks pass for source digest `f94467f7d372ca194c38fff432db15c94feb51c5d1d6a758876ef8edff007fc6`. Scripted OpenGL captures cover the new recovery and river screens, including 320×640 enlarged text.

The broader presentation pass, richer wildlife decisions, full campaign narrative, physical-device qualification, production publisher configuration and player enjoyment/revenue evidence remain unfinished. No public app release or live advertising qualification was performed.

## Original audit

## Verdict

Pocket Biome is a playable, small discovery/building game with environmental puzzles. It has goals, choices, progression, rewards and an ending. The outstanding issue is the depth, coherence and safety of that experience, not whether enough feature names exist. Commercial readiness and enjoyment remain unproven. Do not describe it as a finished long-term restoration/management game.

## What actually exists

| System | Implemented player activity | Limit |
|---|---|---|
| Home island | Expand from four starting plots up to 36 cells; choose among three saved terrain offers; inspect neighbor influences | No general move/undo tool. Making room can require replacing a biome; retiring a structure returns a level-one blueprint and loses upgrades |
| Discovery | 16 environmental discoveries and four sanctuary discoveries, tracked in Journal | Many goals remain threshold/collection checks; knowing solutions removes much of the mystery |
| Main campaign | Five chapters introducing expansion, discovery, Pulse, fusion, crafting and automation; final chapter requires all 20 discoveries and 25 cells | Progress is mainly counters, not five distinct restoration scenarios |
| Crafting | 18 recipes, prerequisites, material prices, three job slots, batches and placement of completed blueprints | Benefits/owned-required guidance is improved, but planning an island still lacks reversible editing |
| Automation | Windmill income, Golem collection, Furnace processing, Totem effects and upgrades/pause | Supports acquisition and progression; not a deep production/logistics simulation |
| Gathering | Per-tile harvesting and manual Gather ready, with ordinary payouts, storage checks and cooldowns | Reduces inputs; does not itself create a strategic decision |
| Pulse | Rain, Heat and Frost with targeting, confirmation, energy costs and cancellations | A tool for influencing conditions; not a standalone activity |
| Sanctuary fusion | Combine matching 2×2 groups into four sanctuary types | Permanent footprint. See confirmed completion trap below |
| Expeditions | Dry Springs, Frost Hollow and Ember Shore: separate saved 3×3 puzzles, sequential unlocks, different water/heat rules | All ultimately require two groves and two flower habitats. Small authored puzzles; completed boards are locked and only revisitable |
| Home habitat projects | Shaded Pond, Pollinator Patch and Living Workshop; live spatial/condition checks, contextual advice, three once-only payouts totaling 180 Coins | Optional side objectives; no recurring project generator or broad project campaign |
| Wildlife | Frog, butterfly and bird effects at suitable completed home habitats; visitors leave/return as conditions change | Cosmetic feedback. No population, animal-care, food-chain, breeding or migration simulation |
| Dusk Tide | Optional chapter-3+ timed frost challenge on two non-resource plots; recovery by Heat/Totem; success reward | Narrow fixed challenge pattern. Timeout restores the island safely rather than causing permanent damage |
| Finale | Actual-island recap, completion acknowledgement, continued play/photo/expedition routes; replay from Journal | A ceremony, not a new final sanctuary construction/transformation |
| Creative presentation | Painted terrain, foliage/water/machine animation, collection feedback, camera controls, photo/share path | No broad decoration catalogue or free landscaping editor; native photo sharing still needs release-device qualification |
| Commercial systems | Native test rewarded/interstitial ads, consent path, purchase/restore, Remove Ads, durable reward receipts and caps | Test configuration only; no verified live revenue, publisher setup or operating analytics backend |

## Current player loops

Home: collect → fund/craft terrain → choose neighbors → influence conditions → discover/fuse → complete chapters.

Expeditions: read an environmental problem → rearrange bounded terrain → advance a season → check conditions → restore habitat → unlock the next board.

Habitat projects: arrange suitable neighbors at home → review live requirements → explicitly claim a reward → retain the habitat for visible visitors.

These are real activities. Their connections are weak: expeditions mainly unlock the next puzzle and record completion; they do not currently provide a new home-island capability. Wildlife confirms success but adds no new decisions. After collection, three expedition completions and three habitat claims, continued play relies largely on personal interest in the layout.

## Findings in priority order

### P1 — Confirmed valid-state campaign completion trap

Reproduction used the real model's fusion and retirement methods on a constructed 6×6 island preserving the four starting plots. Filled the remaining 32 plots with Forest, fused eight distinct 2×2 groups, and tested recovery. Result:

- SaveStore accepts the resulting state.
- 36 cells; expansion frontier is empty because the configured land limit is reached.
- Eight Forest sanctuaries; only `grove` discovered in the constructed state.
- No plots can be retired. The original Meadow remains available for one blueprint, but the other three original nodes are protected.
- No remaining sanctuary fusion is possible. Other sanctuary types required for the 20-discovery ending cannot be made.

Evidence: `/workspace/runtime/game-audit/fusion_capacity.gd`, executed during this audit. Output: `valid_save=true`, `forest_sanctuaries=8`, `frontier=0`, `restorable=[]`, `ready_fusions=[]`.

This is a constructed legal state, not an earned human playthrough. It demonstrates a recovery gap in the rules, beyond the successful solver routes. Relevant code: WorldModel.fuse/fusion_recipe, CampaignSystem.retire, economy.max_cells=36.

Required fix: provide safe sanctuary dismantling/unfusion or another guaranteed spatial recovery path, with explicit confirmation. Preserve collected discoveries, prevent reward replay, retain valid ownership/footprints, keep the world connected, and verify existing saves. Add an adverse-layout regression test. Do not solve it by wiping progress or merely raising the cap.

### P1 — Home creativity is harder to revise than the game suggests

Placement choices matter, but correcting them is costly in navigation and can lose structure upgrades. There is no general move or undo system. This discourages the experimentation that the design wants to reward.

Add deliberate layout editing: preview a legal destination, show affected neighbors, confirm/cancel, preserve structure level and cooldowns, and support fused footprints safely. Start with moving existing structures; use the recovery fix above for sanctuaries. Avoid duplicated entities, free yield resets, changed saved draft quotes or surprise habitat loss.

### P1 — Campaign goals need distinct ecological accomplishments

Five chapters teach functionality, but later progress is primarily numerical. Adding independent menus has increased breadth without fully changing the reason to play.

Build on existing home projects: make selected restoration accomplishments part of chapter progression, show an environmental result, and unlock a useful capability. Preserve completion and rewards for old saves. A habitat corridor, managed thermal garden, or restored spring should require a decision, not only a cumulative harvest total. Prototype one complete chapter rework before rewriting all five.

### P2 — Expeditions have limited variety and replay value

Three heat/water rule sets are useful, but all share the same compact board and final habitat pattern. After completion, `place`/`advance` reject further edits; revisiting is viewing, not replaying. These are not yet a substantial expedition campaign.

Add a second objective family before adding many more boards: connecting separated habitats, allocating scarce shade, or routing water to multiple destinations. Then add optional replay attempts with a recorded best result or constraints. Keep original restoration records and one-time rewards separate from replay state. Require every challenge to have a verified solution and a reversible recovery path.

### P2 — First-session teaching still relies on reading

The opening, action-led goals, card hints and habitat shortcuts are implemented improvements. However, unfamiliar-player understanding remains unobserved. The welcome is a sheet, and later tools are distributed across Pack, World, Build and Journal.

Create a short playable teaching sequence: select Oak → harvest → compare Water placement → observe the actual moisture change → understand the first evolution → craft/place one useful structure. Explain only the current step and let players revisit help. Keep the free exploration route and avoid forced ad prompts during teaching.

### P2 — More feedback is not the same as deeper ecology

Existing wildlife is a visible response to a qualified layout, and animations help the island feel alive. They do not create management decisions. Do not advertise a simulated animal ecosystem yet.

If wildlife is the differentiator, first add one lightweight, understandable behavior: visitor preferences with two viable habitat designs, or a migration/restoration request. Avoid breeding, hunger meters and many new currencies until the core relationship is fun.

### P2 — Presentation still competes with the island

Earlier and follow-up rendered screen passes covered primary menus, shortages, queues, details, privacy/reset, Pulse targeting, reveals, expeditions and the finale. Several defects were fixed, including title modal layering, Conditions heading wrapping and World-menu camera reachability. That is not exhaustive native usability coverage.

Remaining design work: quieter secondary surfaces, consistent selected/locked/ready states, better prominence for the island, and fewer nested routes for common tasks. Actual-phone readability, touch comfort, long sessions and audio need validation. Do not replace the painted art style to avoid solving hierarchy.

### P1 release gate — Monetization and device readiness are unfinished

Interstitials are prepared at a quiet moment after the first discovery and qualify at chapter/restoration breaks, with the existing first-eight-minute delay, ten-minute spacing and two-per-session cap. Rewarded benefits are optional; Remove Ads is respected. Local guards/receipt behavior are tested.

The build still uses test ads/products. Privacy/support URLs and physical-device, Play sandbox and creative-acceptance reports are empty. Live consent, fill, confirmed impressions, revenue, billing and lifecycle behavior are not certified. `interstitial_shown` is recorded at dispatch and is not an impression/revenue report. Diagnostics have no configured network receiver.

Complete publisher/audience configuration, secure signing, hosted policy/support, native qualification and measurement before release. Retention and actual revenue must be measured; neither follows from installing more ad placements. No earnings projection is justified yet.

## What to build next

1. **Progression recovery:** safe fusion reversal/dismantling with the confirmed 36-cell trap as a regression fixture.
2. **Layout editing:** move structures without losing upgrades or resetting production, with a useful preview and cancel.
3. **One integrated restoration chapter:** connect the home project loop, a visible result and a meaningful unlock.
4. **One new expedition objective type and replay support:** reuse existing environmental rules without merely recoloring boards.
5. **Playable onboarding and UI consistency:** test the full first session privately, including novice mistakes and adverse layouts.
6. **Release qualification:** physical Android, publisher/consent/billing, confirmed ad measurement and release artifacts.

Defer multiplayer, broad breeding systems, many additional resources, a large decoration store and a mass of daily chores. None solves the recovery or progression issues above. A small coherent game is a better release target than a longer checklist.

## Technical evidence and limits

The working tree was clean at audit start. The latest full report still matches the current source digest: 1,428 assertions across 27 suites, two campaign completion probes and startup, plus the recorded Python/package audits. This audit did not rerun that unchanged suite. It added the separate adverse-layout reproduction above.

The two completion solvers take approximately 1,076/1,097 simulated active seconds using known solutions. Those are not human completion estimates. The historical manual-collection counts predate the Gather-ready UI and cannot be quoted as current required player tap counts.

No full manual campaign playthrough, unfamiliar-player session, native-device performance pass or live-income measurement was performed for this audit. No application logic, economy values, APK or public release was changed. The confirmed recovery defect prevents a readiness recommendation even though ordinary progression tests pass.
