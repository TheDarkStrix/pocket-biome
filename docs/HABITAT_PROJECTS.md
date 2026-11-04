# Home-island habitat projects

Current implementation: [Restoration campaign](RESTORATION_CAMPAIGN.md). The original three saved IDs now have campaign names and reusable tool rewards; two additional projects provide climate shelter and habitat connection. Later chapters require specific restorations, and projects offer alternative designs. The remaining sections describe earlier checkpoints.

Pack → Habitat projects and World → Habitat projects provide three optional layout objectives after the first discovery. Ready projects also appear in next-action suggestions. These use the actual home island, not a separate constructed board.

| Project | Requirements | Once-only reward | Visitor |
|---|---|---|---|
| Shaded Pond | Water sharing an edge with Oak/Forest at moisture ≥60 and heat ≤65 | 40 Coins | Frog |
| Pollinator Patch | Fiber sharing edges with both Water and a healthy Oak/Forest (moisture ≥60, heat ≤65) | 60 Coins | Butterflies |
| Living Workshop | Workbench sharing edges with an enabled Windmill and Oak/Forest at fertility ≥60 and heat ≤65 | 80 Coins | Bird |

The project screen explains missing starting tiles, checks current conditions, highlights a candidate habitat on the island and enables completion only when eligible. Checks update when the relevant relationships change. Matching uses existing neighbor/footprint logic, including sanctuary ownership, rather than diagonal proximity. Several layouts can satisfy each project; no fixed coordinate is required.

## Rewards, saves and visitors

Completion is explicit. The three IDs are saved in the optional `habitat_projects` array. Old saves remain valid, and malformed/unknown/duplicate records are rejected. Claiming rechecks the current island, prevents duplicates and adds the configured reward once. The UI commits record and Coins in the same atomic save; failure restores the previous state and explains that the claim can be retried. Claims do not register additional interstitial milestones.

These bonuses add up to 180 Coins per profile/world. They are new one-time rewards; per-node yields, prices and chapter requirements are unchanged. Automated baseline campaign routes do not claim them, so their existing results are not evidence of the new rewards' effect on novice pacing.

Wildlife is cosmetic and bounded to three visitor groups. A completed project's visitor is shown only while a matching habitat exists. Removing a neighbor, changing conditions or pausing the relevant Windmill can remove visitors; restoring suitable habitat brings them back without another payment. Earned Coins and the completion record are retained. Visitor matching is cached on scene refresh rather than rescanning every draw. Reduced motion, photo mode and suspension freeze motion; the animal remains visible.

## Coverage

27 focused checks cover each layout, heat/pause exclusions, read-only inspection, claims/duplicates, all rewards/visitors, JSON save/load, habitat loss, validation, first-discovery unlock, failed-save rollback, real UI claims and live action availability. OpenGL fixtures at `/workspace/runtime/habitat-review` show goals, completed cards, wildlife, changed habitat and small-screen scrolling. They are constructed review states, not independently earned player sessions.

This adds layout goals, one-time rewards and visible ecological feedback to the home loop. It does not establish improved retention, human enjoyment or live revenue. First-time player observation and phone qualification remain outstanding.

Final private build: eight Python audit tests, 1,410 assertions across 26 Godot suites, both original campaign completion routes and startup passed. Universal preview and ARM64 package signatures/alignment/content checks passed. No public distribution was performed.

## Actionable guidance

Unfinished or currently unsuitable projects now show a context-specific next step. Guidance follows Workbench prerequisites, existing queues, ready blueprints, lack of empty Grass, saved drafts, paused Windmills, insufficient moisture, excess heat and low fertility. Shortcuts open the selected Build recipe, current queue, saved hand, inspector or World tools; blueprint guidance enters the normal placement preview. No shortcut pays for crafting, places land, restores a plot, changes conditions, resumes automation or spends Pulse energy.

Advice is recalculated at activation, so changed conditions or a finished project cannot execute a stale suggestion. The project screen's live signature includes the advice, allowing timer/condition changes to update the explanation. 18 focused tests cover read-only behavior, prerequisite routing, ready/queued work, saved quotes, thermal/moisture deficits, paused automation, real UI navigation, no-cost placement preview and stale-action safety. Rendered standard/small-screen examples are retained under `/workspace/runtime/habitat-guidance-review`.

Guidance follow-up private build: all eight Python audit tests, 1,428 assertions across 27 Godot suites, both campaign completion probes and startup passed. Universal preview and ARM64 package checks passed.
