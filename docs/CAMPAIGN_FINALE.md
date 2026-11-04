# Living sanctuary finale

Completing Chapter 5 now opens a dedicated celebration at the next safe gameplay moment, after discovery reveals and tile transitions. It waits for open sheets, saved drafts, targeting, blueprint placement and photo mode to finish. It does not replace the title screen.

The celebration contains a miniature of the player's actual current island, chapter completion text, discoveries/land totals, fusion/crafting/automation recap, and three routes:

- Keep creating: return to the island and frame it normally.
- Frame an island portrait: enter the real photo mode; saving or sharing remains an explicit player action.
- Explore expeditions: open the existing expedition map.

Completed players can revisit it from Journal → Celebrate your sanctuary. This is a campaign ceremony/recap, not a new biome, resource payout or automatic photo upload. Completion requirements remain unchanged.

`FinaleUI.gd` owns presentation. CampaignSystem remains the only owner of chapter rewards. The optional `finale_seen` marker is accepted on old saves only as a boolean, and true requires Chapter 5's earned reward record. JSON numeric canonicalization is accounted for during validation. Saves without the marker remain valid. The marker is persisted on presentation; failed writes roll it back and retain a session guard so failure cannot cause a repeated modal loop. A future launch can retry the acknowledgement. Replaying never awards chapter rewards again.

17 focused checks cover compatibility, malformed marker rejection, persisted acknowledgement, safe scheduling, replay, reward isolation, continued play, Journal entry, actual portrait mode, small-phone/enlarged-text actions, and failed-save retry behavior. Standard and small-screen OpenGL fixtures are retained at `/workspace/runtime/finale-review`. These are constructed completed-world fixtures rather than a manual campaign playthrough.

This is an incremental improvement to the campaign payoff. A bespoke final world transformation, human pacing/creative acceptance, device QA and live monetization qualification remain separate work.

Final private Android build: eight Python audit tests, 1,332 assertions across 23 Godot suites, both full original progression routes and startup passed. Universal and ARM64 package audits/signatures/alignment passed. No public upload or store submission was performed.
