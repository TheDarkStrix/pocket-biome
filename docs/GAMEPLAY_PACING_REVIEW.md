# Gameplay pacing review — 0.12 preview

The aim is a satisfying sequence of choices: choose a neighbor, watch a reaction, discover a possibility, build or reshape, and improve the island. Animation supports that loop. More clicks or more compulsory tasks are not evidence of enjoyment.

## Friction found and changes implemented

| Observation | Change | Intended player benefit |
|---|---|---|
| Every old draft repeated Forest and Water | Keep the first Water tutorial; later hands contain one rotating resource option plus two seeded eligible choices | Compare several viable directions instead of repeatedly accepting the same tiles |
| Card descriptions ignored the chosen plot | Show the actual neighboring influence count/rate, or Golem collection reach | Placement becomes a deliberate experiment; avoid buying a helper with no useful neighbors |
| A broad chapter objective offered little help choosing the next action | Tap the objective or World's Find something to try for up to three relevant options | Resume a draft, place a completed blueprint, find a fusion, trade, build automation or investigate discoveries |
| Trading was buried below every crafting recipe | Direct Workshop trade entry; illustrated five/twenty-material batches | Turn surplus stock into a plot without another cycle of waiting and harvesting |
| Useful automation upgrades were easy to overlook | Offer an affordable Windmill upgrade as an optional next direction, focused on the actual machine | Invest in passive income as an alternative to buying more land immediately |
| Automatic Furnace jobs consumed Stone needed for the next building | Keep 4 Wood/5 Stone for construction; manual crafting can spend the reserve | Prevent a default production loop from starving early progression |
| Upgrade spending could invalidate an unfinished plot's saved quote | Protect those reserved coins | Preserve the saved decision and avoid failed saves/lost progress |

No new daily chores, reward faucet, mandatory ad, energy farm or price increase was introduced. Existing plot quotes/cards stay stored; only newly opened hands use the new dealer. The economy formula and saved-state format are unchanged.

## Measured engineering evidence

783 Godot assertions, eight Python audit tests and two public-transaction progression routes pass. Both routes use seed 90210 and accelerate waiting; they know all recipes, use a fixed layout and collect ready resources aggressively. They are stress/reachability probes, not human playtests or optimal strategies.

Before the Furnace reserve, the fixed route began its Iron blueprint at 661 active seconds, after 534 seconds without a recorded progression event. With the reserve it begins at 181 seconds, 54 seconds after that checkpoint. The other changes do not grant materials or alter that recipe. This exposes and fixes one specific early starvation loop; it is not an eight-minute speed guarantee for every player.

Current full-catalog routes (20 discoveries, five chapters, 35 cells):

| Policy | Active seconds | Successful manual collections | Longest gap between recorded progression events |
|---|---:|---:|---:|
| Collect-ready/stockpile route | 5,223 | 10,939 | 791s |
| Also purchase affordable level-two Windmill upgrades | 4,810 | 10,057 | 744s |

Both still manually collect ready nodes; this preempts work the Golem could do and is not the minimum tapping required. The solver also buys 35 cells and rebuilds a known reaction area; players may use other layouts and parallel discoveries. Still, the large collection counts/late gaps are a pacing warning. This pass does not establish that the whole economy is balanced or entertaining. See artifacts/pacing-simulation.json, pacing-automation.json and draft-variety.json.

## Human playtest acceptance — not executed yet

Observe a fresh ten-minute session without debug assistance. Record whether the player understands the first reaction, compares card locations, finds two useful directions, can explain their chosen goal, and discovers crafting/trading/automation when relevant. Record confusion, repeated unproductive taps, perceived waiting and moments they want to experiment or stop. Use actual five-to-fifteen-minute sessions as the PRD requests.

The next balancing decision should use those observations and a less greedy layout strategy. In particular, test later expansion costs and resource demand before certifying retention. Any price-curve change needs explicit legacy-quote migration tests; prices were deliberately kept intact in this pass. Continuous 3D orbit and production signing/provider/device/creative gates remain separate open work.
