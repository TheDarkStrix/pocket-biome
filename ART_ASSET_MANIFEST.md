# Art and audio asset manifest

Generated raster candidates are integrated and rendered in the actual engine. Source sheets are retained unchanged; scripts address atlas regions/pivots, rather than editing pixels. The earlier navy/green layout is superseded by the user's request for a complete game interface; docs/references/user_art_direction.jpg guides materials and proportions.

| Asset | Size/format | Use | Status |
|---|---|---|---|
| assets/terrain/biome_candidates.png | 1254×1254 PNG | Nine base terrain/node types | Integrated; rendered review |
| assets/biomes/evolved_candidates.png | 1254×1254 PNG | First five evolutions + Ancient Grove | Integrated; rendered review |
| assets/biomes/biomes_a.png | 1254×1254 PNG | Meadow, mossrock, reeds, sunstone, mistforest, crystalforest, oasis, ironwood, moonflower | Integrated |
| assets/biomes/biomes_b.png | 1254×1254 PNG | Obsidian, celestial, lagoon, quarry, verdant, dirt, growth shrine, founder lantern, cloud | Integrated |
| assets/structures/structures.png | 1254×1254 PNG | Workbench, furnace, windmill, golem, rain totem, compost, clay, iron | Integrated |
| assets/nodes/harvest_states.png | 1254×1254 PNG | Five depleted node states and material icons | Integrated |
| assets/ui/icons.png | 1254×1254 PNG | Coins, Dew, clay, iron, Rain, Heat, Frost, Codex, options | Integrated; HUD and flight feedback |
| assets/app_icon.png | 1254×1254 PNG | Launcher/splash identity | Integrated in Android export |
| assets/audio/*.wav | PCM 22050Hz | Eleven original synthesized feedback cues and 32s ambient loop | Integrated; headless encoding verified; human listening open |

## Specifications and delivery rules

Use 2:1 isometric ground planes, consistent light from upper left, warm earthy sides, soft painted contours, readable silhouettes and generous transparent margins. Atlas cells are nominally 418px wide, with measured row bounds and pivots in TileArtwork.gd. Base rendered ground width is 132 logical pixels; fused footprints span four grid cells. UI uses custom graphite surfaces, amber Build emphasis, violet Pulse controls, pearl text, rarity borders and illustrated textures. No engine-default button styling is intended as final UI.

Future standalone delivery: transparent RGBA PNG, terrain 512×384 with ground anchor (256,256); tall nodes/structures 512×640 with ground anchor (256,480); fused sanctuaries 1024×768 with ground anchor (512,512); UI/resource icons 256×256 with 24px inset. Maintain atlas manifests and source files. Do not crop by visual guess: verify shared ground anchors in engine and matching alpha hit testing.

## Remaining review

Inspect high-zoom alpha fringes, transitions and consistent ground dimensions on Android. Perform human visual/audio review and device sampling. These integrated generated assets are not a claim of final creative sign-off. Rare reveals, silhouettes, depletion, fusion choreography and photo mode use real asset references; additional hand-painted animation frames may improve quality but are not falsely marked delivered.

## Current interface assets

assets/fonts/BiomeInterface.ttf and BiomeDisplay.ttf are static500/350-weight neutral interface/display derivatives of Google Fonts Inter. The modified font families are renamed and the original SIL OFL notice is retained as LICENSE_Inter.txt and included in Android exports. Source: https://github.com/google/fonts/tree/main/ofl/inter . Static instances avoid a variable-font importer instability encountered during the prior pass. Nunito/Fredoka have been retired from this interface after the user's rejection of the playful style.

assets/ui/line/*.svg are original32px monochrome navigation/power icons, authored for this interface. They are independent of Terra Nil artwork. Official reference screenshots are analysis material only and are not packaged.

Current direction is recorded in docs/DESIGN_DIRECTION.md; the parchment/brass pass is superseded. Existing generated terrain/biome/resource illustrations remain integrated and require the same perspective/alpha/device review described above.

Player-feedback revision reuses existing sanctuary art for the fusion chooser. Expansion target rings, area highlights, rain streaks/ripples, heat motes and frost flakes are original runtime vector effects rather than missing raster artwork. UI response uses original motion code; no new external art dependency was added.

Current ambient motion uses original procedural canopy deformation and water/structure effects over existing art. It does not supply separated Windmill rotor or Golem body/limb art; exact remaining layered-art specifications are in docs/ANIMATION_STATUS.md. Final human art/audio review remains open.

0.13 interface pass: original procedural Pulse wave emblem/ring and circular navigation medallions reuse the licensed fonts, original line icons and existing resource/terrain illustrations. Floating surfaces and progress gauges are native styled/vector controls. No Play Store reference image is shipped, and no new raster-art delivery is claimed.

0.14 supersedes the persistent 0.13 HUD. assets/shaders/sky.gdshader and scripts/SkyBackdrop.gd provide original procedural atmosphere using a generated256×256 seamless noise texture, three texture samples and analytic soft cloud shapes. Day/dusk/night variants and reduced-motion freezing are integrated. assets/ui/line/ecology.svg and camera.svg are original32px vector icons. The small controls reuse existing terrain/material art; no reference-game art is shipped. Human creative approval and physical GPU sampling remain open.

0.15 adds original runtime diorama staging, Pulse footprint illustrations and fusion input/output diagrams using the existing integrated game atlas. It adds original32px sound/music/motion/shield/challenge SVGs and an actual bound vector switch indicator. No new hand-painted raster frame or reference-game asset is claimed. Cards/sheets use custom ivory/teal native styling; actual rendered fixtures33–39 document the result and large-text variants. Human creative approval and physical-device sampling remain open.

Design-stage only: docs/design/cohesive-ui-concept.png is an original generated four-screen presentation using the supplied reference. It is not a shipping atlas, rendered game screen or approved final asset pack. Independent logo/tool/frame state assets and in-engine layout work are still required; see docs/design/COHESIVE_UI_PROPOSAL.md.
