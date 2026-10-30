# Animation inventory — 0.21 preview

The shipping world is now a real3D scene. Cosmetic clocks/state remain separate from WorldModel rewards, ownership and saves.

| Element | Implemented motion | Limits |
|---|---|---|
| Trees, shrubs, reeds, tufts and flowers | Ground-pinned spatial wind deformation; textured foliage | Original modeled forms; final creative approval open |
| Water and pools | Real mesh displacement, animated ripples/caustics and specular response | Stylized surface, not fluid simulation |
| Island edges | Flowing waterfall ribbons on at most two exposed water edges, hanging ivy sway and six drifting mist planes | Fixed mobile effect budgets |
| Windmill | Independently rotating3D sail assembly at its axle | Retained clock freezes when disabled, reduced motion, photo or background |
| Furnace/vents/mist biomes | Up to18 drifting smoke puffs across at most six sources; emissive accents | Enabled/source-state cues; no simulated combustion |
| Wildlife | Three moving butterflies with independently flapping wings | Hidden during photo/reduced motion/background |
| Harvest | Real stump/fragment state, bounded regrowth and yield flight | Cosmetic state derives from actual cooldown; no bonus resources |
| Placement/evolution/fusion | Rise/scale; retained old models converge and retire while the sanctuary grows | Atomic model transaction precedes animation; no selectable duplicate entities |
| Rain/Heat/Frost | Two pooled70-particle3D emitters;3.2-second showers/motes; affected-cell outlines | Reduced motion retains static/fading area feedback |
| Build | Translucent3D structure ghost on an eligible Meadow | Preview never reserves land or spends currency |
| Golem/totem/shrine | Emissive rune accents | Golem body/limbs remain unrigged; no walking-helper claim |
| UI | Press/release, panel transitions, resource highlights and compass orientation | Cards/menus use40 engine-rendered portraits of the runtime models |

Ambient, shader, motor and regrowth animation respects reduced motion, photo/background handling. Background disables the3D viewport. Weather is transient and is not replayed from saved pulse counts after loading. The model has no dependency on rendered-frame rate for rewards.

`artifacts/living-world.gif` and `living-world-render-check.json` document an actual-engine fixed-camera staged island, not a gameplay completion or phone performance result. Human aesthetic, motion comfort, audio and physical-device qualification remain open.
