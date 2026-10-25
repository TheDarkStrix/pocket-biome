# Camera capability and continuous-orbit requirement

## Implemented now

The existing painted isometric renderer supports four upright cardinal views: 0°,90°,180°,270°. World has Rotate left/right controls, and a two-finger twist turns the view in 90° steps with hysteresis to avoid accidental turns while pinching. Drag/pinch continue to pan/zoom. Projection, inverse picking, depth sorting, frontier markers, fused origins and whole-island framing use the selected view. Rotating changes presentation only; it does not rearrange saved cells or spend resources. Current camera orientation is session-only.

This is stepped full-circle viewing, not continuous 3D orbit. The raster props remain upright and face the viewer; there are no newly rendered back faces. The user requested360° camera movement, so this distinction is explicit rather than reporting a free-angle orbit as complete.

## Required next rendering phase for true free-angle orbit

Preserve WorldModel/CampaignSystem/SaveStore and integer coordinates. Introduce a separately testable Node3D presentation scene with Camera 3D yaw/pitch rig, ground-plane/raycast cell picking, instance-based terrain/props, shared fusion ownership and world-to-screen HUD anchors. Replace the 2D art-bound camera fit with3D bounds. Keep the current working view until visual and gameplay parity is verified.

Final assets required:registered terrain meshes and directional props for the full biome catalog; fused2×2 variants; separate Windmill rotor/hub; helper body/limb rig; matching materials, thumbnails and effects. Painted sprites alone cannot reveal their back sides. Image generation available in this environment produces raster art, not a verified set of production3D models.

Proposed asset contract:GLB, one unit per cell, origin at ground center, Y-up, consistent cell-edge registration; one-cell footprint1×1, fused footprint2×2 centered on the footprint; low-poly beveled terrain with separate top/side material slots; shared roughness/vertex-color palette; documented per-prop bounds/attachment points. Start with a four-cell look-development island and validate free yaw, touch selection, expansion and shadows before porting all 20 discoveries. Treat triangle/texture/lighting budgets as targets to be measured on physical Android hardware, not as achieved performance.

Acceptance:continuous yaw through 360°, stable upright horizon, correct picking/occlusion/placement in all angles, no seams at tile/fusion edges, save parity, photo framing, reduced-motion comfort and measured mobile performance. No such3D migration or asset set is claimed complete in this preview.
