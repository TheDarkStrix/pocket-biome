# The Living River

This chapter turns the home island into a small restoration puzzle: carry limited Water to a distant grove, guide Sola through its shelter to flowers, then wake a dormant corner. It joins the existing five-chapter campaign after the first spring restoration. It preserves the painted island and existing land models.

## How to play

1. Restore the returning spring. Open **Goal → Restore the Living River**, **Tend → Living Corridors**, or **World → Living Corridors**.
2. Choose Clover's wetland or Juniper's woodland. Spring selection opens automatically: tap a blue Water plot and confirm it. The selected spring stays marked on the island.
3. Tap a highlighted distant Oak or Forest to preview a connected channel, or draw it across edge-sharing natural plots. The grove must be at least two edges from the spring. If none is reachable, the setup screen explains the missing land and can select a Forest from your actual saved cards. Preview and save the route; confirmation states the starting flow. New channels request available flow up to the grove's demand (two, or one with woodland shelter), or one for flowers. Adjust it with **+ / −**. Editing an existing route preserves its requested allocation, including zero.
4. Observe two qualifying seasons to mature the grove. The forecast dry spell reduces spring supply by one. Under Living climate it also warms routed land; woodland shelter buffers that warmth.
5. Trace a flower route through the mature grove to Fiber or soil. The wetland garden needs neighboring Water; the woodland garden needs two healthy tree neighbors. Keep it watered and fertile.
6. Choose bare Meadow or Ploughed Soil within three natural-land steps of the garden. Sola carries moisture and fertility there. Two qualifying seedbed observations earn the flowering corner and Living Heart. The actual tile evolves through the ordinary discovery rules.
7. Continue the existing restoration/building campaign. Later, try another seedbed or the other approach, pursue the twenty discoveries, four expeditions/eight mastery challenges, visitors and decoration.

The live sheet shows delivered versus needed flow, requested allocation, growth counters and actual soil readings. Dry-spell allocation gives the grove priority. In the woodland approach a healthy neighboring tree reduces grove demand from two to one, making it possible to redirect scarce flow to the flowers.

## Rules and recovery

- Wetland supply is four, or three during the dry spell. Woodland supply is three, or two during the dry spell. Requested total cannot exceed the original supply; actual delivery follows current supply.
- Paths contain 2–12 unique owned physical cells, sharing edges. Meadow, soil, Fiber, Oak, Forest and Water carry routes. Stone, machinery and extreme terrain block them.
- Grove growth needs its required delivery, 60 moisture and at most 65 heat. The garden needs one delivered flow, a mature grove on its route, 50 moisture, 70 fertility and at most 65 heat, plus the chosen approach's neighbors.
- A healthy garden adds moisture/fertility to its seedbed. Seedbed growth needs 50 moisture, 80 fertility and at most 65 heat. A repurposed or fused seedbed cannot earn restoration as bare soil.
- Observing a season does not advance harvest, crafting or machine timers. Normal active time still runs normally. Classic climate retains its original heat behavior and receives periodic routed moisture.
- Planning costs no Coins or materials. Drafting is temporary until confirmation. Cancel discards only the preview. Undo restores the last saved configuration before another season; it does not rewind chemistry, clocks, earned stages or discoveries.
- Saved land cards, destination and price coexist with river planning and observations. Buying or crafting missing terrain still uses its ordinary price; the river does not grant free land. Setup errors appear in the visible panel or planning caption.
- Source/route replacement resets affected current growth. Changing approach clears the routes and current growth. Earned field-note moments and chapter rewards remain permanent, and cannot be farmed repeatedly.
- Terrain editing can interrupt a route. It remains a valid save and can be repaired. Placement previews warn when delivery would stop. Failed route/season saves roll back their entire transaction.
- Old saves need no new fields. Previously completed chapter rewards/endings stay completed. An unfinished third chapter receives the new restoration objective.

## Appearance and story

Delivered flow produces animated channel droplets; blocked channels pause and change appearance. Grove buds, Sola's travel along the flower route, seeded flowers and nine Living Heart buds follow actual chapter state. Reduced motion freezes the cosmetic clock; it does not stop ordinary progression.

**River story & portraits** offers optional session-only recording. Up to four small actual island images per island stay locally. Recording is off by default. A player can export a PNG strip or looping four-frame GIF and explicitly open the Android share chooser. Nothing uploads automatically. The GIF is an animated sequence of recorded milestones, rather than continuous video. Source images can be deleted from the story screen.

Implementation: `LivingCorridors.gd` owns rules and optional save validation; `CorridorUI.gd` owns ephemeral planning/atomic commits; `CorridorArtwork.gd` presents state; `RiverStory.gd` and `StoryGif.gd` provide local opt-in exports. See [audit and remaining limits](CORRIDOR_AUDIT.md).
