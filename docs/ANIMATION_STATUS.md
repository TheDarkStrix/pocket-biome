# Animation inventory — restored painted game0.21.1

The original painted graphics are the default. The rejected procedural3D view is disabled; technical3D animation evidence from0.21 is historical and does not describe the player-facing game.

| Element | Current implementation | Remaining work |
|---|---|---|
| Oak/Forest/Fiber/leafy discoveries | Ground-pinned upper-canopy deformation with compound seeded sway, expanded leafy-discovery coverage and bounded local harvest impulse | Separate branch/leaf layers for richer individual motion |
| Grass/flowers | Five small anchored blade/flower clusters per eligible tile; independently phased tips | Authored plant layers for more varied silhouettes |
| Water | Three expanding, fading elliptical ripples over original painted pond | Registered animated pond-to-lip outlets |
| Windmill | Separate painted body and rotating sail layer with retained clock | Further authored work feedback |
| Furnace/vent | Source smoke, stronger fire glow and rising embers over painted structure | Separate bellows/fire layers |
| Golem/workbench | Existing rune/activity feedback; original graphics | Independent limbs and tool rigs are not implemented |
| Harvest/evolution/fusion | Flying resource icons, harvest leaf scatter, depletion/regrowth, settling cloud puffs and grounded evolution crossfades; existing four-part fusion pull | Human motion review |
| Rain/Heat/Frost | Timed area particles/streaks/ripples over the affected painted tiles | Physical-device comfort/performance review |
| Island edge | Original painted earth edges | Decorative detached falls removed; no fabricated water source |
| UI | Press/release, highlights, fades and selection feedback | Human creative review |

Reduced motion and photo/background clocks retain their prior behavior. No rewards or save fields are owned by visual effects. The immediate correction restores the user's earlier land graphics; it does not claim the outstanding individual-object animation request is complete.

## Living-land polish validation

The painted renderer was exercised in a 48-frame OpenGL sequence with tree, forest, grass, fiber, water, windmill and furnace fixtures. Five new presentation assertions cover rooted plant geometry, bounded harvest displacement, local/expiring harvest response and stationary evolution ground. Full checks pass 1,246 assertions, both progression simulations and startup. The pre-existing split windmill asset and resource-to-HUD flight are reused, not newly authored. Reduced motion suppresses new meadow/particle motion and harvest icon flight; placement/evolution motion is cleared by the existing reduced-motion path. No new 3D models or sprite assets were needed. Human review on a physical phone remains outstanding.
