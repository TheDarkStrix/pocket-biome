# Harvested tile alignment fix — 0.21.2 preview

The reported low tile was reproducible when Fiber switched from growing to harvested artwork. The ready and harvested atlas entries used different ground anchors: the old harvested Fiber pivot put its painted front soil contact 32 source pixels below the ready tile. Oak and Stone shifted 31 pixels, Forest 17 pixels, and Clay/Iron shifted in the opposite direction.

`TileArtwork` now registers each harvested sprite to its ready artwork's painted ground contact. Every renderer and alpha picker uses the same appearance metadata. Tile coordinates, depth order, original painted images, simulation, inventory and saves are unchanged. Plants/resources can change on harvest while the land stays anchored.

Twelve added regressions read the actual atlas pixels to compare ready/harvested soil baselines for all six resource types and check selection at the corrected visible contact edge. Existing painted-art checks still cover the four camera views, original assets, state isolation and disabled replacement scenery. The external rendered fixture reproduces the opening with Water beyond the Meadow, records before/after harvest states, and checks all four camera views without changing saved state.

[Before](validation/alignment-before-fiber.png) · [After](validation/alignment-after-fiber.png) · [All harvested](validation/alignment-all-harvested.png) · [Retained rendering harness](validation/alignment-visual.gd.txt)

[Exact validation and Android package metadata](LAND_ALIGNMENT_VALIDATION.json) name the tested source. The release increments the app to version code 16 / `0.21.2-preview` and retains the signing identity of the immediately preceding gameplay/animation download, so this update does not require uninstalling that build. The much older restored-paint test APK used a different key; its save-transfer limitation remains documented separately.

The screenshots are actual desktop Godot renders of a constructed island, not edited user photos or a physical-phone acceptance run. Per-art contact registration fixes the harvest/regrowth jump; the painted sprites retain their original silhouettes and soil textures.
