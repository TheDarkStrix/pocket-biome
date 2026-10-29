# Economy and progression

Authority: data/game.json; transaction/objective rules in WorldModel and CampaignSystem. Numerical choices remain tuning hypotheses pending player validation.

- Start: 25 coins, four cells, no earned inventory. Expansion: rounded `12 × 1.24^N`, capped at 36 occupied cells.
- Harvest: initial Oak 8s, Stone 12s, Fiber 6s. Manual taps accelerate cooldown 0.5s at most every 0.25s; a tap cannot extend a nearly-ready timer. Harvesting grants repeatable coin income, preventing reliance on ads.
- Active play only: no offline production or clock-based income. Automated sources consume real recipe inputs and honor shared fused cooldowns.
- Draft: three saved offers, guaranteed accessible tutorial sources; chapter pools expand. Confirmation alone charges. Moving an unfinished draft keeps its existing three offers and quote; it is not a free reroll. Optional rewarded reroll once per expansion never changes its quote.
- DNA: five attributes bounded 0–100, buffered neighbor updates at 1Hz and monotonic tiers. Pulse costs 100 from a 200 cap, with 12s temporary effects. Rewards deduplicate after save/load.
- Twenty discoveries: 6 common, 7 uncommon, 5 rare, 2 legendary. All are available through gameplay without purchases or advertisements.
- Crafting: three concurrent slots, batch quantities 1–3; blueprints deploy explicitly. Essential source tiles are craftable, and retirement permits rearrangement at the land cap. Protected initial wood/stone/fiber sources preserve a recovery path.
- Structures: levels 1–3, explicit upgrades and pause/resume. Higher yield/emission/production changes are real model effects. Scarce Star Dew is not sold as repeated ad progression currency.
- Five chapters: deterministic goals/rewards and persistent completion IDs. Optional Dusk Tide cannot destroy progress; players may ignore it.
- Ads: optional rewards capped at three per UTC day; interstitials require eight active minutes, ten-minute spacing and at most two per session, only at eligible breaks. Entitlements remove forced ads; no banners in primary gameplay.

## Verified progression simulation

`tests/progression_simulation.gd` uses public gameplay transactions and advances active time; it does not inject inventory or discoveries. Latest run: all 20 discoveries, all five chapters, 35 occupied cells, 119 tracked progression operations, plus earning-loop harvests, 5199 active seconds, ending with 1293 coins. It includes save/restore. This establishes reachability, not an expected human completion time or optimal strategy. The script deliberately accelerates waiting and knows recipe conditions.

First normal path: harvest Oak, open adjacent cloud, inspect Water and confirm placement; moisture crosses the Rainforest threshold in a few active seconds. Scene smoke exercises this launch-to-evolution route with real UI callbacks.

## Remaining tuning

Measure comprehension, early decision quality, harvest fatigue, energy cadence, saturation, scarcity and time between discoveries with people. Validate PRD retention targets through actual playtests and analytics before calling the economy commercially proven. Store prices come from localized Billing queries, not hardcoded mock checkout prices.

Timer hardening: environmental and automation cycles now retain anchored deadlines. Slightly late frames no longer stretch a cycle by a whole scheduler tick. Stalled slots are skipped rather than granting a backlog burst. This fixes timing accuracy without changing authored yields, prices or intervals; production-paced frame-jitter regression tests cover it.

## 0.12 gameplay pacing pass

Post-tutorial drafts now provide a rotating resource-producing option and two varied seeded choices; the initial Forest/Water/Crystal tutorial is unchanged. Saved offers and quotes are preserved. Placement descriptions are local to the chosen plot. Advice and trade shortcuts expose already implemented alternatives rather than granting resources.

Automatic Furnaces reserve 4 Wood/5 Stone; explicit manual crafting can spend that stock. This prevents the demonstrated early Iron-building starvation loop. Upgrade transactions cannot spend coins reserved for an unfinished plot.

With fixed seed 90210, the public collect-ready route now reaches all 20 discoveries/five chapters/35 cells in 5,223 simulated active seconds with 117 tracked progression operations and 10,939 successful manual collections. A second route purchasing affordable level-two Windmill upgrades takes 4,810 seconds and 10,057 collections. These are not human-session/optimal-strategy benchmarks. Earlier 5199-second figures used the old dealer; comparisons across differing policies/seeds are not retention evidence. docs/GAMEPLAY_PACING_REVIEW.md records the controlled Furnace observation, remaining late-game pressure and human playtest plan. No economy formula or saved quote was changed.

0.13 is a presentation pass: currency/material quantities, cooldowns, chapter rewards, prices, drafts and saved-state rules are unchanged. The energy ring displays stored Pulse energy and does not imply timed regeneration.

0.14 changes presentation and information exposure, not resource yields, prices, cooldowns or progression. Detailed conditions and exact energy remain accessible; the default HUD is reduced.

0.15 changes modal presentation, categories and navigation only. Recipe prices/prerequisites, three job slots, durations, batch quantities, saved draft quotes, reward limits and trade exchange rates are unchanged. UI ingredient badges read actual owned/required values; previews do not perform transactions.
# 0.16 draft presentation note

The three-offer hand changes presentation and confirmation only. Draft pools, deterministic dealing, saved offers, exact Coin quote, adjacency effects, tutorial rewards and all crafting/automation costs are unchanged. Selection, Info and Later charge nothing. First expansion still grants its separate10-Coin objective reward after the quoted placement cost; interaction coverage explicitly distinguishes that reward from the charge. No new retention/economy claim is made.

0.17 presentation-only: no costs, pools, progression, crafting/automation timing or provider rewards change. The header prioritizes Wood/Stone/Coins, while the complete seven-material stock remains in Workshop/trading. Harvest flights target the actual corresponding header value or Build for other crafting materials; these effects do not grant or spend stock.

0.18 environment presentation adds no resources, cooldowns, adjacency emissions, rewards or saved fields. Waterfalls are cosmetic, read existing exposed/unfrozen water surfaces and are limited to two visible outlet candidates for overdraw. A frozen or surrounded pond does not create a flowing outlet. Rock sides and roots are not gatherable nodes. Expansion/fusion still use existing validated transactions and stored prices.

##0.19 interface/economy integrity

The concept-wide UI pass changes no economy or game-definition values. Recipe tabs cover every configured recipe, the lower tray displays required quantities for the retained batch selection, and CampaignSystem alone charges/queues/deploys. Focused real-touch checks verify one4 Wood/2 Stone Workbench debit, normal active-time completion, no second placement charge, retained blueprint on cancellation, and save restoration after deployment. Cosmetic ghosts/ground clipping/tool navigation never mutate inventory, occupancy or progression. Both full progression probes retain4,810/5,223 active-second outcomes; they do not establish enjoyment or human completion time.
