# Painted tile joins — 0.21.4 preview

The previous harvest-height fix aligned the painted soil contact across ready/depleted sprites. It did not make neighboring caps fit: grid pitch still included transparent atlas gutters, and baked soil walls were drawn even between occupied neighbors. That explains why the reported Fiber/Oak join could still read as separate blocks.

`PaintedGrid` now uses one fitted 116×58 cap pitch for projection, inverse mapping, goal/placement outlines and fusion previews. Source artwork stays at its original scale. `PaintedJoins` draws narrow original-grass texture strips only inside actual shared edges, and hides forward-facing soil walls when the whole adjacent face is occupied. Outer walls stay painted; partially exposed fused edges retain their outer wall. Fusion-owned cells do not get a seam through the sanctuary. This does not enable the older rejected shared grass floor, replacement cliffs or 3D world.

Static sprites, moving foliage, Golem/Workbench/Totem rigs, Windmill bodies, alpha picking and world miniatures use the same shared-edge rules. Tile ownership, adjacency, production, saved objectives and inventory are unchanged. Foreground tree canopies still win alpha selection when they visibly cover a rear tile; logical floor mapping remains independent.

## Verification

Thirty-nine seam regressions cover ready/depleted painted cap sides, shared geometry, inverse mapping, four-view floor/cloud interaction, foreground canopy selection, outer-wall preservation, partial/full fused faces, owner-cell seam suppression and hidden-wall hit testing. Comparing actual source-side probes finds 16 uncovered probes out of 24 at the old pitch and zero at the fitted pitch. These are footprint probes, not an aesthetic score.

Actual OpenGL transparent-viewport sampling checks 210 shared-edge points for each of four views and both ready/harvested states. Minimum sampled alpha rises from 0.878 at the old layout to at least 0.988 with the fitted/clipped joins. The loose 0.7 “gap” threshold reports zero for both, so that metric alone is not claimed as proof of the visible join correction. The before/after game renders are the relevant visual evidence.

The final unchanged source passes **2,074 assertions in 44 Godot suites**, 22 Python checks, startup and four campaign probes. Rendered reviews cover the five-tile opening and harvesting in every camera direction, seven touch actions through saved Water-hand recovery, ordinary-clock discovery, 320×640/120%-text controls, a 36-cell island with five visitor groups, photos and result portraits. Source binding, Android export, signatures, 16 KB alignment and all 663 retained ARM64-package files pass. The app increments version code 17 → 18 with the current download's signer/package.

[Exact reports and hashes](PAINTED_SEAMS_VALIDATION.json) · [opening renderer harness](validation/seams-visual.gd.txt) · [pixel sampling harness](validation/seams-mask.gd.txt)

[Before](validation/seams-before.png) · [After harvesting](validation/seams-after.png) · [Ready tiles](validation/seams-ready.png) · [Rotated](validation/seams-rotated.png) · [Water joined to Oak after settling](validation/seams-water-and-oak.png) · [Full island](validation/seams-full-island.png)

These are actual desktop engine renders, not edited user screenshots. The Water placement's brief arrival animation is allowed to settle before assessing its join. No authorized Android phone is attached; physical installation/save preservation, audio/comfort/performance, unfamiliar-player approval and native/provider/store acceptance remain unqualified. The preview keeps Google test ad IDs.
