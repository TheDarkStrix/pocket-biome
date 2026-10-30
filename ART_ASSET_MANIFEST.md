# Art and audio asset manifest

Current0.21.1 default:restore the original painted terrain, resources, structures, discoveries and menu/card art. Full tile surfaces/earth edges are rendered; added shared grass/cliff foundations and procedural3D models/portraits are disabled. The user explicitly rejected the3D visual replacement. Keep original source images and do not change the art style to implement animation. Disconnected decorative waterfalls are suppressed until an actual registered pond-to-lip source is supplied. Individual Golem/workbench rigs are still missing.

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

## Rejected3D experiment assets — internal only

| Asset | Specification | Status |
|---|---|---|
| scripts/DioramaGeometry.gd / DioramaProps.gd | Original authored miniature geometry, one unit per cell, Y-up; fused props span2×2 cells; material-merged meshes | Implemented; creative/device approval open |
| data/diorama.json | Explicit palettes/features for all20 discoveries | Implemented and catalog-tested |
| assets/terrain/foliage-material.png | Unchanged generated opaque leaf-material source;512px mipmapped lossy import | Integrated on swaying3D foliage; not a generated mesh |
| assets/diorama_previews/*.png | Forty256×256 transparent engine captures of runtime props/materials | Integrated in cards/menu thumbnails; regenerate after visual changes |
| assets/shaders/diorama-*.gdshader | Spatial surface wind/glow, water displacement/caustics, ivy and falls | Rendered in-engine |
| Existing grass/cliff/roots/waterfall art | Materials on actual connected3D foundation and edge meshes | Reused without pixel editing |

The catalog above is disabled in the normal game. The original painted atlas entries are the current presentation. Generated foliage is an image material; no external GLB pack or completed artist-approved model collection is claimed. Golem limbs remain unrigged. The reference design board continues to guide visual review; geometric coverage is not final aesthetic acceptance. See docs/ANIMATION_STATUS.md.

## Historical2D specifications and delivery rules

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

0.16 draft assets integrated and rendered:

| Path | Source / dimensions | Status |
| --- | --- | --- |
| assets/ui/draft/card-frame.png | Independently generated blank slate/bronze frame,1024×1536 RGBA | Used by all three real terrain cards; original retained intact; runtime region excludes external padding |
| assets/ui/draft/place-button.png | Independently generated blank green/bronze button,1774×887 RGBA | Region rendered with a scalable StyleBoxTexture; live localized text, pressed/hover/disabled modulation and keyboard focus |
| assets/fonts/Marcellus-Regular.ttf | Google Fonts Marcellus, SIL Open Font License1.1 | Used for draft names, heading and placement text; license in LICENSE_Marcellus.txt |
| assets/shaders/draft-scrim.gdshader | Original single-pass vertical alpha gradient | Lower-screen contrast; no screen capture or blur dependency |

Card title, cost, trait, selected glow and terrain are live game elements. The presentation board is never shipped as a background or cut into controls. Actual render evidence40–42 uses constructed world states. Independent title/tool/rail assets and the remaining menus are still outstanding; final human creative and physical-device reviews remain open.

## 0.17 integrated setting and interface assets

| Path | Source dimensions / preparation | Status |
| --- | --- | --- |
| assets/backgrounds/sky-realm.png |1024×1536 opaque independently generated painted cloud world | Runtime decorative background; cover scaling, small drift and palette grading; no playable land baked into center |
| assets/ui/material/logo.png |1536×1024 independently generated transparent title | Actual title-screen branding; original full image retained |
| assets/ui/material/slate-plaque.png |2172×724 independently generated blank frame | Shared rail/badge/panel/button material; cached virtual density avoids stretched rim bands |
| assets/ui/material/tool-icons.png |1774×887 independently generated4×2 object atlas | Painted journal, hammer, rain totem, gear, compass, leaf and coin integrated; backpack prepared for the remaining navigation pass |
| assets/fonts/Cinzel.ttf and Title.tres | SIL OFL licensed variable display font,650 weight plus subtle emboldening | Headings/card names/actions; LICENSE_Cinzel.txt included by export filter |
| assets/fonts/Lato-Regular.ttf | SIL OFL readable body font | Body/counts/legal text; LICENSE_Lato.txt included by export filter |

New background/UI images use lossy0.82 mobile imports; background maximum1536px, logo/plaque/tools maximum1024px. High-resolution original PNGs remain available. MaterialUI's virtual texture dimensions change runtime border metrics without modifying pixels. Existing raw-material atlas regions now exclude transparent gutters and a neighboring-row fringe; gameplay terrain art is unchanged. Actual fixtures43–50 show the combined art and live controls. This does not complete the contextual Build tray, three-tool layout, connected deep terrain, layered structure motion or final human creative/device acceptance.

## 0.18 island-edge artwork integrated

| Path | Source dimensions / use | Status |
| --- | --- | --- |
| assets/environment/cliff-rock.png |1254×1254 independently generated natural rock/moss material | UV-mapped to occupied-cell cliff geometry; shape comes from runtime topology, not a painted whole island |
| assets/environment/hanging-roots.png |1774×887 independently generated two-cluster RGBA atlas | Metadata regions isolate each root cluster; fixed attachments with slight tip sway |
| assets/environment/waterfall.png |724×2172 independently generated transparent water ribbon/spray | Separate Sprite2D over exposed water-edge cliffs; downward streak lighting shader; no stream on frozen/interior water |
| assets/shaders/island-waterfall.gdshader | Original two-sample stream shader | Shared controlled clock; reduced-motion/photo alternatives remain static |

Sources remain intact. Rock/roots maximum1024px and waterfall maximum1536px use lossy0.82 imports. The connecting surface samples the existing painted grass atlas. Island-bound mist is lightweight procedural soft geometry; no resource/reward is implied by decorative roots, mist or water. Actual fixtures51–59 show integrated land and its foundation, outlets, turns, title/photo and sanctuary. The raised surface-pad soil artwork remains; removing all interior pad seams requires a later surface-art pass. Final human creative and physical-device performance approval remains open.

## 0.19 concept-wide runtime pass

| Path / component | Source extent | Status |
| --- | --- | --- |
| assets/ui/material/tool-medallion.png |1254×1254 transparent PNG | Independent generated slate/bronze tool socket, integrated under Pack/Build/Pulse; lossy0.82 import capped512px |
| assets/ui/line/moisture.svg |48×48 | Original two-tone droplet, integrated alongside painted Growth/Magic/resource traits |
| ToolMedallion / ShelfCard | Responsive runtime controls | Live object icons, selected shelf glow, energy/focus/press feedback; no embedded text or values |
| TileArtwork.joined_mesh | Original terrain atlases retained | Runtime front-plane clipping removes baked extrusion above shared caps; no generated single-picture island substitution |

Actual Godot fixtures60–64 show Play, lower Build (selected Windmill preview), Pack, Draft and title. These scenes are deliberately constructed to review composition, not claimed earned progression. The surface still uses the existing atlas; the concept's exact contours/props/coloring and layered windmill rotor are not falsely marked delivered. Whole-screen boards remain documentation, excluded from Android resources.

## 0.20 reference correction

Independent runtime sources: reference-tools.png (2172×724, three complete medallions), reference-resources.png (2172×724, Log/Stone/Coin), reference-panel.png (2172×724, thin slate/bronze), reference-action.png (1983×793, green/bronze). All reside under assets/ui/material, imported at max1024/lossy0.85 with measured regions. They replace unrelated noisy icons/heavy gold framing rather than flattening a concept screenshot.

assets/terrain/continuous-grass.png is an opaque1254×1254 source, max512/mipmaps/lossy0.85. Soft front-edge meshes blend atlas skirts over it. assets/structures/windmill-layers.png is a1774×887 independent body/rotor sheet, max1024 with normalized registrations. assets/ui/line/gear.svg is an original48px light-gray cog. Original sources are retained.

Actual fixtures70–75 show the result. windmill-motion.json measures changed world pixels separately from the first frame's resource-highlight tween. docs/store includes a staged engine-rendered1024×500 feature graphic and review copy; no store submission or creative sign-off is claimed.
