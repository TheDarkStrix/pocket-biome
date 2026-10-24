# Economy and progression

Authority: data/game.json; transaction/objective rules in WorldModel and CampaignSystem. Numerical choices remain tuning hypotheses pending player validation.

- Start: 25 coins, four cells, no earned inventory. Expansion: rounded `12 × 1.24^N`, capped at 36 occupied cells.
- Harvest: initial Oak 8s, Stone 12s, Fiber 6s. Manual taps accelerate cooldown 0.5s at most every 0.25s; a tap cannot extend a nearly-ready timer. Harvesting grants repeatable coin income, preventing reliance on ads.
- Active play only: no offline production or clock-based income. Automated sources consume real recipe inputs and honor shared fused cooldowns.
- Draft: three saved offers, guaranteed accessible tutorial sources; chapter pools expand. Confirmation alone charges. Optional rewarded reroll once per expansion never changes its quote.
- DNA: five attributes bounded 0–100, buffered neighbor updates at 1Hz and monotonic tiers. Pulse costs 100 from a 200 cap, with 12s temporary effects. Rewards deduplicate after save/load.
- Twenty discoveries: 6 common, 7 uncommon, 5 rare, 2 legendary. All are available through gameplay without purchases or advertisements.
- Crafting: three concurrent slots, batch quantities 1–3; blueprints deploy explicitly. Essential source tiles are craftable, and retirement permits rearrangement at the land cap. Protected initial wood/stone/fiber sources preserve a recovery path.
- Structures: levels 1–3, explicit upgrades and pause/resume. Higher yield/emission/production changes are real model effects. Scarce Star Dew is not sold as repeated ad progression currency.
- Five chapters: deterministic goals/rewards and persistent completion IDs. Optional Dusk Tide cannot destroy progress; players may ignore it.
- Ads: optional rewards capped at three per UTC day; interstitials require eight active minutes, ten-minute spacing and at most two per session, only at eligible breaks. Entitlements remove forced ads; no banners in primary gameplay.

## Verified progression simulation

`tests/progression_simulation.gd` uses public gameplay transactions and advances active time; it does not inject inventory or discoveries. Latest run: all 20 discoveries, all five chapters, 35 occupied cells, 119 gameplay transactions, 5199 active seconds, ending with 1293 coins. It includes save/restore. This establishes reachability, not an expected human completion time or optimal strategy. The script deliberately accelerates waiting and knows recipe conditions.

First normal path: harvest Oak, open adjacent cloud, inspect Water and confirm placement; moisture crosses the Rainforest threshold in a few active seconds. Scene smoke exercises this launch-to-evolution route with real UI callbacks.

## Remaining tuning

Measure comprehension, early decision quality, harvest fatigue, energy cadence, saturation, scarcity and time between discoveries with people. Validate PRD retention targets through actual playtests and analytics before calling the economy commercially proven. Store prices come from localized Billing queries, not hardcoded mock checkout prices.
