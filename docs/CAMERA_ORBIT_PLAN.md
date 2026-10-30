# Continuous camera — 0.21 preview

The default playable world now uses a real isolated `SubViewport`/`Camera3D` in `OrbitWorld.gd`. Orthographic yaw is continuous through360°, pitch is limited to22–68° and the horizon remains upright. Dragging land pans; pinching zooms; twisting two fingers orbits after a7° dead zone. The small compass supports orbit/tilt dragging and keyboard arrows. Desktop right-drag also orbits/tilts. World retains convenient quarter-turn shortcuts.

Coordinates and saved model state are independent of the camera. Ground-plane inverse projection resolves grid cells, nearest model AABB intersections handle raised props, and frontier controls retain mobile hit areas. Fusion reservations resolve to their original owner. Models have actual back/side geometry; this is not the earlier four-view upright-sprite rotation. Photo mode retains/restores yaw, pitch, pan and zoom. Orientation remains session-only.

Whole-world fitting uses projected3D bounds, including cliffs, tall props, fused scale and Build ghosts. Safe areas and lower draft/build trays retain space for the island. An offscreen viewport scales from logical portrait size to at most1.5× density, with2× MSAA. Android continues using OpenGL Compatibility; this change does not silently select Vulkan.

The prior2D view remains available internally (`orbit_enabled=false`) for legacy atlas regression fixtures. Those suites do not establish3D rendering acceptance. `tests/orbit_world.gd` separately exercises the shipping renderer,72 non-cardinal yaw/pitch combinations, public first-evolution transactions, every discovery profile/portrait, fused picking/transitions, compass/native twist, three mobile dimensions, reduced motion, background suspension and Rain emission.

Meshes are original procedural miniature forms authored in GDScript, merged by material. They are implemented visuals, not a claim that a production GLB collection or artist-approved model pack was delivered. `data/diorama.json` defines discovery palettes/features. The generated foliage texture is raster material art, not generated3D geometry.

Remaining acceptance: human comparison against the supplied art board, physical Android GPU/frame-time/thermal/memory sampling, cutout/input ergonomics and sustained playtesting. Software-emulator and Mesa captures cannot certify phone performance. Golem limbs are not independently rigged.
