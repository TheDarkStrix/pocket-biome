# Animation inventory

| Element | Implemented motion | Limits |
|---|---|---|
| Oak/Forest/Fiber and supported leafy sanctuaries | Texture-mapped canopy sways; lower terrain stays fixed | Procedural two-part deformation, not a full skeletal rig; depleted stumps remain still |
| Water and watery discoveries | Continuous expanding/fading surface ripples | Existing illustrated water texture is not a frame-by-frame fluid simulation |
| Furnace/vents | Drifting smoke and warm flicker/embers | Raster body remains fixed |
| Windmill | Work dust while enabled | Painted rotor remains static; separate rotor/body art is still needed for authored blade rotation |
| Golem/totem/shrine | Moving activity lights when enabled | No body/limb rig; helper production is a stationary tile system |
| Placement/evolution/fusion | Scale/rise, crossfade, particles and four-part fusion pull | Bounded effects; simulation commits independently |
| Rain/Heat/Frost | 3.2-second area effects; falling rain/ripples, heat motes and frost flakes | Reduced motion uses a fading area confirmation |
| Harvest | Resource flight and floating yield | Cosmetic only; capped concurrent effects |
| HUD/menus | Press/release, panel fades, chapter/condition interpolation, resource highlights | Motion responds to state and interaction; controls do not continually drift |
| Photo mode | Stable still rendering | Ambient motion suppressed; no camera alteration to gameplay |

The world is not a fully rigged 3D scene. Remaining authored animation work is recorded explicitly rather than claiming every sprite is animated. Physical-device comfort/performance and final human creative review are still required.

Suggested remaining layered-art specification: Windmill body with no blades at the existing 418×445 atlas proportions, separate transparent rotor 256×256 with centered hub/pivot, 2:1 isometric alignment matching the source; Golem body/arms separated on transparent 418×390 canvases with identical registration and ground pivot. These are not claimed to exist yet.

0.18/0.19 add attached root sway, controlled water-ribbon shader flow and local mist around the actual boundary. The three painted tool medallions retain press/release feedback and the live Pulse ring; selected shelf/draft cards show gold focus/selection. The Build placement ghost is a static preview; it is not claimed as an additional simulation or completed construction. Runtime ground clipping preserves the existing canopy's moving upper mesh and fixed lower surface.
