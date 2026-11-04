# Gameplay, comprehension and monetization review

Forward delivery and release gates: [Release implementation plan](RELEASE_IMPLEMENTATION_PLAN.md). This covers the full screen inventory, work packages, dependencies and acceptance evidence.

## Scope and evidence

This review uses current source/configuration, existing full-campaign simulations, fresh OpenGL opening/placement/Settings captures, and automated gameplay/save/service/UI checks. It is not a manual campaign completion, external player study, current competitor-market survey, real-device benchmark or revenue validation. Existing animation work is preserved.

## Product direction

Grow a tiny island into a self-sustaining sanctuary. The primary loop is observe → choose a neighbor → watch environmental conditions change → discover → use resources/automation to make another meaningful choice. The island should make progress visible, and the player should always be able to identify a useful next action. Discovery and personal expression are the reasons to return; advertisements are an optional service around that experience.

## Review of the whole player journey

| Aspect | Observed state | Action / acceptance target |
|---|---|---|
| Purpose and first action | Opening previously explained controls but not the overall purpose | Implemented: opening and Journal state the purpose; HUD explains the first action, with supporting guidance |
| Immediate goals | Raw progress metrics and generic discovery requests | Implemented: action-led goals, readable progress labels, and a next-action line in the Journal; chapter thresholds and existing saves unchanged |
| Placement decisions | Detailed adjacency explanation existed behind Info; default hand gave generic traits | Implemented: neighbor-specific plain-language summary, gold destination and teal adjacent-plot outlines; no hidden recipe names or guaranteed outcomes |
| Navigation reliability | Title controls could cover Settings; camera help promised disabled continuous orbit | Fixed: title hides while modal is visible and restores on close; help matches painted camera controls |
| Harvesting fatigue | Recorded expert routes use 1,509/1,662 manual collections over 1,076/1,097 active simulation seconds | High-priority playtest risk. These are solver statistics, not human tap requirements. Observe repetition before altering costs/rewards; assess an accessible collect-ready action or earlier useful automation if needed |
| Early economy | Full campaign is reachable without ads; crafting and material trading provide alternatives | Preserve the ad-free completion path. Measure human time to first evolution, first Workbench and first useful automation; inspect shortages and confusing reservations |
| Building decisions | Costs/blueprints/queues work, but structure benefits are not prominent enough in the main Build tray | Pending: benefit line, owned/required ingredients, named action, explicit craft-versus-place status. Validate that a new player can build and place without instruction |
| Discovery comprehension | Journal offers free clues and optional detailed hints | Keep a free route to every required discovery. Pending: clearer unknown/hinted/discovered states and help forming an experiment rather than revealing every recipe |
| Main campaign | Five chapters culminating in all 20 discoveries and 25 cells | Mechanically validated. Pending: test whether exhaustive collection makes a satisfying main ending or is better as optional mastery; do not silently change completion criteria or existing earned rewards |
| Ending and continued play | Completion reward/message followed by free building | Pending: a distinct final sanctuary reveal and recap/portrait. Preserve creative play and completed saves afterward |
| Visual life and feedback | Painted foliage/water/machine effects and new harvest/placement/evolution polish | Rendered sequence and tests available. Human review of readability, motion comfort and satisfaction still needed |
| UI hierarchy | Background/frame/navigation weight can compete with island; secondary sheets vary | Pending composition pass and cohesive surface/state system. Retain painted style; avoid replacing art before validating hierarchy |
| Accessibility | Text scaling, reduced motion, vibration/audio settings, gesture alternatives and small-layout tests exist | Tests cover supported layouts. Physical phone review must check readability, screen cutouts, gestures, focus/scroll, audio comfort and motor accessibility |
| Saves and lifecycle | Real save/restore and failure tests; rewards and quotes are persisted | Retest on Android background/kill/relaunch and network loss. Existing tests do not replace physical-device lifecycle evidence |
| Performance | Desktop Mesa rendering verified | Mid-range device frame time, thermal/battery/memory and longer sessions remain unmeasured |
| Repeat play | Collection, building and optional Dusk challenges exist | Do not claim retention. First validate a satisfying completed session; then test whether players want to return to new experiments or improve their layout |

## Advertising audit and recommendation

### Existing implementation

- `data/services.json` is sandbox-only and uses Google's public test ad IDs. No live income is established.
- Rewarded choices include +25 Coins, +100 Pulse energy, one saved-hand redraw and a detailed discovery hint. Requests require a ready provider; daily cap is three successful optional rewards. First-action and event guards exist.
- Earned callbacks have persisted request IDs and idempotent receipts; save failures roll back/retry rather than duplicating currency. Redraw preserves the stored quote. Existing service tests cover these paths.
- Interstitials require a ready native bridge, a chapter milestone, at least eight active minutes into a session, ten active minutes since the previous interstitial, and at most two per session. They are blocked during events and pending drafts; Remove Ads is honored. UI transition guards also protect targeting/placement/reveals.
- Consent/native provider code exists; current live regional consent, fill, store purchase and reward behavior are not certified by local tests.

### Recommended launch approach

Prioritize explicit rewarded offers at useful moments, with exact rewards and a clear way to continue without watching. Do not insert an interstitial during harvest, a reveal, selection or construction. Keep existing conservative limits until human comprehension and retention evidence exists. Do not increase prices, reduce normal rewards, hide free hints, or block the finale to manufacture ad demand. No production IDs or frequency increases were introduced by this review.

Before release, verify cancellation/unavailable/no-fill, loss of connectivity, app background/return, callback replay, successful viewing with a failed save, daily-limit boundaries, consent decline and Remove Ads behavior through real native sandbox flows. Ad-unavailable messages should leave a visible playable alternative. Intended audience/age classification must be settled before configuring production ad and consent settings.

### Revenue and measurement

The game cannot yet be described as commercially validated. Measure tutorial start/completion, time to first evolution, chapter/drop-off, sessions and return visits, plus offer visibility, reward acceptance, provider-confirmed impressions, completion, grants, failures and consent state. Collect only with the disclosed privacy/consent arrangements. The telemetry endpoint is currently empty; events are not an operating analytics backend. `interstitial_shown` is currently logged on dispatch, so it must not be treated as an impression or revenue event. Add verified provider impression/revenue callbacks before making revenue reports.

A rough rewarded-revenue model is active players × rewarded opportunities/player × voluntary acceptance × fill rate × realized eCPM / 1,000. Every term needs actual data; no earnings projection is justified yet. Evaluate retention and player complaints alongside revenue, not only ad views.

## Prioritized delivery sequence

1. **This pass:** purpose, actionable chapter guidance, local placement explanation/highlights, title modal fix, truthful camera help, focused regression tests and updated debug APK.
2. **Next gameplay pass:** observe first-time play; improve build decision support, blueprint placement and harvest fatigue according to observed blockers. Record actual decisions and idle time, not only task completion.
3. **Campaign payoff:** test chapter pacing, distinguish main completion from mastery if warranted, implement a meaningful finale and continued creative play.
4. **Presentation pass:** unify secondary screens and prioritize the playable island; verify small screens, enlarged text and reduced motion.
5. **Native/monetization qualification:** production audience/publisher configuration, live consent/reward/purchase tests, privacy/support URLs, real-device performance/lifecycle and privacy-respecting measurement. Then tune offers using observed results.

## First-time player evaluation

Use at least five people unfamiliar with the game for an initial qualitative pass (not statistical proof of retention). Give no verbal instructions during the opening. Ask them to describe the purpose, harvest, expand with Water, explain the neighbor effect after seeing it, find a clue, craft/place a structure and locate the next goal. Record hesitation, wrong taps, backtracking, repetitive collections, unplanned waits and requests for help. Ask what they wanted to do next and whether the optional reward was understandable. Never require an ad to finish the session. Repeat with an offline run and larger text.

A developer walkthrough and automated solver are useful technical checks; neither substitutes for this player evidence. Stronger retention or revenue claims require a properly instrumented external test after these comprehension blockers are resolved.

## Validation for this pass

All eight Python audit tests and 1,259 Godot assertions passed, including two complete progression probes, startup, small-phone/enlarged-text layouts, preview non-mutation/no-recipe-spoiler checks and title modal navigation. OpenGL captures exercise the real harvest → cloud → card selection callbacks and separately capture the purpose sheet and title Settings route. This is a scripted opening walkthrough, not an independent human playtest.

## First expedition implementation

Dry Springs now provides an authored restoration puzzle beyond the home discovery collection: reversible spatial choices, player-controlled seasons, grove/habitat goals, frog visitors, persistent completion and return home. See [Expeditions](EXPEDITIONS.md). The ad flow now prepares services automatically at a quiet moment after the first discovery, with native release consent checks; a saved expedition completion can qualify for a capped interstitial break. Actual live ads/revenue and player enjoyment remain unvalidated.

## Construction clarity pass

The lower Build tray now explains building benefits, shows owned/required material quantities, labels the transaction as crafting, and explains the later Meadow-placement step. Shelf height was adjusted to retain the island view and mobile action reachability. Build flow has 78 assertions across supported phone sizes/text scales and real crafting/cancel/placement/save callbacks. Full Android build validation passed 1,315 assertions plus Python audits, both original campaign routes and startup. Package and ARM64 signature/alignment checks passed. The preview remains private; this is not player acceptance or commercial release evidence.

## Campaign payoff pass

A dedicated [living sanctuary finale](CAMPAIGN_FINALE.md) now celebrates completed campaigns with the actual current island and progress recap. It can be replayed from Journal, continues into building/photo/expeditions, and does not grant rewards again. Existing completed saves are supported. This implements a ceremony and continuation flow; a bespoke final world transformation and player acceptance remain outstanding.

## Expedition variety pass

The map now has three sequential authored islands. Frost Hollow introduces one shared heat source and upper/lower temperature bounds; Ember Shore combines ongoing volcanic warmth with water cooling and moisture. Each has an independent saved layout and restoration record. Unlocks follow successful restoration, not ad views. This adds short spatial/environmental challenges beyond home collection; it does not establish a long campaign or player retention. See [Expeditions](EXPEDITIONS.md).

## Harvesting input pass

A read-only ready-node preview and player-triggered batch gathering now reduce repeated collection inputs while preserving existing harvest transactions, cooldowns, rewards and storage limits. The action is accessible in ordinary home play and Pack, with touch/layout/save coverage. See [Gathering](GATHERING.md). Human pacing and enjoyment effects are not yet measured.

## Home habitat projects

Three optional projects now connect home tile layout and conditions to explicit goals: Shaded Pond, Pollinator Patch and Living Workshop. Players can review requirements, highlight a candidate layout and claim a once-only Coin reward. Frogs, butterflies and a bird visit suitable completed habitats; visitors leave/return with live suitability while earned rewards remain. See [Habitat projects](HABITAT_PROJECTS.md). This implements additional home goals; player enjoyment and economic pacing effects still need observation.

## Guided habitat completion

Habitat project cards now connect missing requirements to specific, read-only next actions. Players can inspect a thirsty/overheated tree, review paused automation, open prerequisite or terrain recipes, use an existing blueprint, review a queue or resolve a saved draft. The shortcuts retain the existing transaction/confirmation authorities. This improves task discoverability; independent player comprehension remains unmeasured.
