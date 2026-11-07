# Menus after the tutorial — 0.21.8

Pack previously mixed stock, collection, four navigation tools, goals, lessons, habitat projects and expeditions. World combined inspection, arranging, upgrades, camera controls, restoration, visitors, decoration, weather and challenges in one long list. Projects opened the entire recipe catalogue as well as the queue. These were concrete sources of competing choices and inconsistent names after the guided start.

## Changed navigation

Pack now offers **Continue my current goal** and four destinations:

| Entry | What it opens |
|---|---|
| Materials & trade | Actual stock, ready-resource collection and explicit spare-material trades |
| Discoveries | The existing discovery records and free clues |
| Crafting queue | Working timers, finished items and placement help; full catalogue/batch controls remain secondary |
| Island tools | Four purpose groups, rather than the previous all-tools list |

Island tools groups **Plants & wildlife**, **Arrange island**, **Camera & photos** and **Other islands**. Existing habitat/river/care/visitor functions, selected-plot movement/upgrades/pause/restoration, fusion, decoration, camera/photo controls, expeditions and the optional Dusk challenge remain available within these groups. Each group explains its purpose and names its way back. Inventory, trading, discoveries, queue and the secondary catalogue also provide explicit parent links. Close/Back-to-island remains an explicit exit.

The Crafting queue shows what is being made and what can be placed, without requiring the player to browse every recipe. Placement remains disabled when a saved land choice or missing empty grass blocks it, with a route to the corresponding recovery. Finished items are not charged again. Timers update without rebuilding every queue action on each tick; semantic queue/ready-item changes refresh the screen. The static Pack landing no longer rebuilds its controls whenever inventory changes behind it.

Build uses named actions such as **Make Workbench** and **Place Workbench**, and its materials tab says **Materials** rather than Craft. The existing ingredient costs, timers, batch quantities and placement authority remain. **Weather tools · Pulse** explains what Pulse means, how the preview/confirmation works and what Cancel preserves. Visible navigation paths and discovery names were aligned with the new entries. Selected-plot tools also show why moving, replacing or upgrading is unavailable. Upgrade/toggle/replacement saves commit atomically; rejection or persistence failure restores the previous plot, stock and Coins and explains the problem inside the visible menu. Upgrade callbacks reject a stale level instead of spending a later quote. No new currencies, purchases or automatic-ad placements were added.

## Verification and scope

Ninety-six new assertions exercise all Pack routes and island categories, explicit back links, read-only browsing, narrow/enlarged-text layouts, real inventory collection, named Build actions, weather access and ready-item space guards. Existing native-touch, construction, screen and menu-layout suites now follow the actual new categories instead of assuming every action is on the World landing.

Fresh rendered touch walkthroughs earn the opening normally, pay for and finish the Workbench, open the focused queue and place the real finished item. After the first habitat they visit stock/trade/discoveries/queue, camera controls and the expedition map, cancel a real Rain preview without spending energy, and continue through the actual river lesson to a flowing channel and grove maturity. No stock, habitat or river-completion progress is injected in those walkthroughs. Preparing constructed states for separate layout tests is distinguished from this earned route.

The complete packaged source passes **2,270 assertions in 47 Godot suites**, 22 Python checks, startup and four campaign probes. Package/source/signature/16 KB alignment and all 669 retained ARM64-package files pass. Version code increases 21 → 22 with the recent download's package/certificate. These are engineering and rendered-input results, not physical-phone installation, independent newcomer understanding or enjoyment/revenue evidence.

[Exact reports](MENU_CLARITY_VALIDATION.json) · [Fresh input walkthrough](validation/menu-clarity-fresh.gd.txt) · [Pack](validation/menu-clarity-mobile-pack.png) · [Island groups](validation/menu-clarity-mobile-island-tools.png) · [Real finished Workbench](validation/menu-clarity-mobile-queue-ready.png) · [Weather explanation](validation/menu-clarity-mobile-weather.png).

This delivers the planned menu-navigation increment. It does not establish a continuous rendered playthrough through the ending, review every later feature/detail/error screen, qualify an Android phone or close the broader [conversation request review](USER_REQUEST_REVIEW.md). Current Google test ad IDs are retained.
