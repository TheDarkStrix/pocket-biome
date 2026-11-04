# Restoration campaign and player journey

Implemented 2026-11-04. This connects the existing discovery/building game to authored home-island restoration goals. Four expedition puzzles remain complementary activities. The painted art direction, saved discoveries, ordinary gathering and existing commercial caps are retained.

## What a player does

1. Harvest the thirsty Oak, compare Water beside it, and observe live moisture and the first transformation.
2. Craft and place a Workbench. Restore the returning spring and welcome frogs.
3. Arrange a pollinator garden, learn sanctuary fusion and brick crafting, and earn shade.
4. Shelter a working workshop, establish a climate refuge, and use helpers to sustain production.
5. Connect the suitable restorations through natural land, complete the discovery collection and celebrate the island. Continue redesigning or replaying expeditions afterward.

The opening goal helper follows actual harvest, placement, discovery, observation, queue, blueprint and building state. It highlights the Oak and illustrates Water's edge-sharing influence on the island; the inspector displays live conditions. Comparing Water and observing the Oak record optional learning flags. It does not manufacture resources or completion. Completing the building and first habitat permanently finishes guidance, even if the Workbench is later retired. Guidance remains dismissible, and broader ideas remain accessible. Automatic provider/consent preparation and transition ads wait while guidance is active; explicit Store access remains available.

## Restoration goals and earned capabilities

| Restoration | Chapter connection | Once-only Coins | Permanent capability |
|---|---|---:|---|
| The Returning Spring (`shaded_pond`) | Required in Chapter 2 | 40 | Water channel: carry moisture across up to two natural-land steps from Water |
| Wings over the Garden (`pollinator_patch`) | Required in Chapter 3 | 60 | Shade canopy: cool a selected natural plot |
| The Sheltered Workshop (`living_workshop`) | Required in Chapter 4 | 80 | Move unprotected single-cell natural land while retaining identity, evolution and conditions |
| A Refuge from the Weather (`thermal_refuge`) | Required in Chapter 4 | 90 | Warmth lantern: warm a selected natural plot |
| The Living Sanctuary (`sanctuary_network`) | Required in Chapter 5 | 120 | Two slots for each care tool, increased from one |

Chapter 1 still teaches recovery through the first living biome. Later chapters retain their discovery, building and production requirements alongside specific restoration accomplishments. Project claims re-evaluate chapter completion. Earned records are durable; subsequent habitat changes do not remove chapter rewards or unlocks. Existing completed chapters never reopen.

These capabilities are earned through play and require no ad or purchase. The five project bonuses total 390 Coins. Original three-project saves retain their IDs and automatically gain the corresponding capabilities; a separate unlock ledger is unnecessary.

## Alternative solutions and wildlife preferences

Healthy trees are Oak/Forest with at least 60 moisture and at most 65 heat. A fertile workshop tree instead needs at least 60 fertility and at most 65 heat. All distances use edge-sharing home-neighbor topology, including sanctuary footprints.

- **Spring:** a compact Water/tree edge qualifies. A broader woodland pond supports two healthy trees within two steps through natural land, even without a directly touching tree.
- **Garden:** Fiber or a Wildflower Meadow touching Water and a healthy tree qualifies. Alternatively, two healthy tree neighbors shelter flowers with at least 50 moisture and 70 fertility; adjacent Water is unnecessary in this design.
- **Workshop:** a Workbench touching an enabled Windmill and a fertile tree qualifies. A larger woodland design supports two fertile trees within two natural-land steps, with an enabled Windmill reachable within two steps. Machines cannot serve as intermediate green terrain.
- **Climate refuge:** a tree beside Glacier with at least 60 moisture and at most 35 heat provides a cool retreat. A tree beside an enabled Rain Totem with at least 80 moisture and 35–65 heat provides a mild rain shelter.
- **Connected sanctuary:** the four prior restorations must be claimed and currently suitable in the same connected region. Natural terrain and Workbenches carry paths; other machines block them. Both compact clusters and longer green corridors work. Matching searches connected alternatives so an attractive disconnected habitat cannot hide a valid solution elsewhere.

Frogs, butterflies, woodland birds, shelter birds and fireflies visibly respond to those preferences. Larger woodland/garden designs and the mild rain shelter produce a larger visitor group. Cards expose the rules and current design, and arrival/departure messages explain suitability changes. Returning visitors grant no repeated reward. This is a bounded habitat-preference system, without hunger, breeding or a food-chain simulation.

## Using care tools

Select land, then open **World → Earned care tools**, or **Care for this habitat** from its inspector. Review the tool's effect, select a slot, and confirm placement. Reassignment and removal are free. Water channels add 12 moisture, shade removes 12 heat, and warmth adds 12 heat every four active seconds. There is one shared persisted cadence; repeated callbacks, loading or reassigning cannot generate an instant extra cycle. A stalled frame applies one cycle rather than a catch-up burst.

Water must remain within two edge-sharing steps through natural land for a channel to work. A disconnected channel becomes dormant, and the screen explains how to restore it. Other tools apply only to natural land. New placements reject saved drafts and active effects on the target. Outlines, a water-connection line, a canopy arc and a warm light identify cared-for plots. Reduced motion freezes cosmetic motion.

Tools deliberately change conditions, so cooling or warming a formerly suitable habitat can move its visitors elsewhere. Removing a tool stops future changes; it does not undo previously changed conditions. Normal influences and other tools provide recovery.

## Save and transaction behavior

`habitat_projects` remains optional, accepts the original IDs, and now admits the two new IDs. `learning` and `restoration_care` are also optional and strictly bounded. Care records validate their cadence, owned unlocks, capacity, coordinate existence and duplicate assignments. New-format records roundtrip through the existing atomic save.

Tool assignments and project claims restore the prior state if saving fails. Move previews preserve evolved artwork, and movement carries the complete entity and its care markers. Original protected resource nodes remain immovable. Sanctuary dismantling still guarantees spatial recovery at the land limit.

## Validation and limits

Final build evidence: eight Python audit tests, 1,573 assertions across 31 Godot suites, both complete campaign probes and startup passed. Universal preview and ARM64 package signature/alignment/content checks passed. See [Restoration validation](RESTORATION_VALIDATION.json).

The 85-check focused restoration suite covers alternate layouts, connectivity, paused/unsuitable habitats, visitors leaving/returning, earned tools, cadence and load replay, dormant water connections, slot limits, save compatibility and rollback, landscape movement, actual teaching callbacks, confirmation/cancel, guided-opening ad guards and mobile touch bounds. Both complete campaign probes use ordinary paid crafting, harvesting and placement to earn the new project records and complete all 20 discoveries within the 36-cell limit.

OpenGL fixtures under `/workspace/runtime/living-review` cover the opening, live conditions, building lesson, layout options, earned rewards, cared-for island, tools and enlarged-text small-phone sheets. These are scripted walkthroughs and constructed review states. Automated solutions and rendered captures do not establish novice understanding, enjoyment, retention, real-phone performance or income. Physical-device, publisher/consent/billing, production signing and commercial acceptance remain separate release work.
