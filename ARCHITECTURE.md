# Architecture and original audit

The original repository was empty with no working functionality or commits to preserve. Godot 4.6.3 stable official is the pinned engine. The supplied specification is docs/MASTER_PRD_v4.md. Android uses OpenGL Compatibility explicitly, minimum API24, target36, ARM64 and x86_64 debug validation.

## Living3D presentation — 0.21

The shipping view is now `OrbitWorld.gd`, a CanvasLayer between the painted sky and the2D feedback/HUD. It owns an isolated transparent3D SubViewport, orthographic Camera3D, shared materials, sunlight, one connected foundation, integer-keyed visual entities and bounded effects. Yaw/pitch, projection/ray-AABB picking, mobile viewport density,3D fitting and cosmetic retirement are separate from the model. The earlier2D atlas view remains only as an internal regression option.

`DioramaGeometry` merges authored miniature forms by material; `DioramaProps` builds the complete base/structure/discovery catalog using `data/diorama.json`. Material shaders animate grounded foliage, water, ivy and flowing falls. The Windmill has a separate rotor. Depleted models derive from actual cooldown state, and old fusion constituents converge while the replacement grows. These visual nodes never own occupancy or rewards.

`DioramaLife` pools six mist planes,18 smoke planes, three winged butterflies and two70-particle weather systems. Cosmetic clocks respect accessibility/lifecycle/photo states; background disables the offscreen renderer. `OrbitPad` handles drag/keyboard camera movement without gameplay transactions. `InputController` emits continuous twist angles after a7° threshold while preserving native pinch and suppression of tap-on-release.

`DioramaPortraits`/`DioramaPreview` use40 transparent engine-rendered cache images of the actual props; world previews sample the live viewport. Regenerate the cache with `tools/capture_diorama_previews.gd` after geometry/material changes, then reimport before testing/export. No3D asset generation service or external mesh pack is implied.

The3D regression suite exercises actual default-mode gameplay and camera behavior. Legacy atlas-specific suites explicitly select the old view; passing them alone is insufficient evidence for3D readiness. Physical GPU/thermal/frame-time and human creative acceptance remain open.

## Runtime composition

`scenes/Main.tscn` instantiates Main, the presentation/input/UI coordinator. It delegates authoritative transactions to WorldModel and CampaignSystem. All game definitions live in data/game.json; provider configuration lives in data/services.json.

| Component | Responsibility |
|---|---|
| WorldModel | Occupancy, harvest/coins, saved drafts, DNA, reactions, recipes, fusion, pulses, objectives |
| CampaignSystem | Chapters, crafting queues/quantities, production/automation/upgrades, blueprint deployment, retirement, Dusk Tide |
| SaveStore / CampaignSchema | Atomic validated primary/backup persistence; version 1/2 migration to schema 3; numeric canonicalization |
| InputController | Tap/long-press/drag/pinch/cancel classification; Main excludes UI-origin and mixed UI/world touch sequences |
| SafeLayout | Physical safe area and DPI conversion into 540×960 logical portrait layout; responsive modal bounds |
| CampaignUI | Pack/Journal/World/stock-project/settings routes; retained Build category and selection |
| BuildTray / ShelfCard | Lower workbench, illustrated horizontal recipe shelf, live costs/prerequisites, job-to-Place transition; CampaignSystem alone commits transactions |
| ToolMedallion | Independent painted circular tool backplate with live icons; enclosing Button owns touch/focus |
| TileArtwork / TileThumbnail / UIIcons | Stable atlas regions, pivots, shared appearance selection and alpha picking; illustrated previews/icons |
| WorldAmbience | Grounded canopy deformation and bounded water/machine activity, with separate cosmetic clock and reduced-motion support |
| WorldPresentation | Bounded cosmetic diffs, rise/crossfade/fusion/weather/harvest animations; never owns rewards |
| FusionGuide | Read-only candidate discovery/ranking and blocker explanations; WorldModel owns fusion commits |
| UIMotion | Interruptible, node-bound press/fade/highlight tweens; respects reduced motion |
| GameTheme | Licensed Cinzel/Lato fonts, slate/bronze/cream materials, shared UI palette independent of world skins |
| AudioFeedback | Pooled cue voices and ambient loop; independent volume/mute and lifecycle handling |
| ServiceHub / Telemetry | Optional provider bridge, durable reward ledger/caps, purchase entitlement handling, opt-in diagnostics/HTTPS delivery |
| PocketServices.kt | Native test Ads/UMP, Billing, rewarded receipts, Android crash diagnostics and user-initiated photo content-URI sharing |

## State and invariants

Coordinates are stable `x,y` keys independent of projection. Maximum gameplay occupancy is 36 cells; storage validates up to 64. Fused entities have one origin and three reservations; all cooldown, DNA, influence and picking queries resolve that origin. Fusion commits atomically before animation and never grants duplicate discovery rewards.

Simulation uses monotonic active seconds, per-frame cooldown advancement and 1Hz environmental updates. Neighbor sums are buffered and clamped after all sources; recipe tiers increase monotonically. DNA is bounded 0–100. Offline time grants no production. Harvest writes debounce for 350ms and flush immediately on backgrounding. Background saves and resume delta suppression prevent elapsed-time windfalls.

Expansion stores target, frozen three offers and quoted cost; payment occurs only on successful placement. One optional ad reroll per expansion preserves the price and target. Essential source tiles are also craftable, protecting progression at the land cap. Initial wood/stone/fiber nodes remain productive and cannot be retired.

Schema 3 includes world, IDs, inventory, timers, pulse modifiers, discoveries, pending draft, chapters/rewards, crafting, blueprints, event state, cosmetics/entitlements, rewarded requests/receipts, accessibility and audio settings. Nested validation precedes load/write. Unknown schemas are rejected. Writes use a temporary file and validated backup before rename; copy/rename failures preserve committed state. This is not a physical power-loss durability guarantee.

## Native build and isolation

`tools/prepare_native.py` generates ignored android/build from the pinned Godot template and copies maintained Kotlin/resources. It adds Google Ads25.5.0, UMP4.0.0 and Play Billing8.3.0. `tools/build_android.sh` imports, runs checks, exports a staging APK, verifies its signature and promotes it only on success. APKs/toolchains/caches are not source-controlled.

Tests instantiate the model without a scene tree; scene suites exercise real UI callbacks with isolated save paths. Graphical captures use Xorg/Mesa through tools/visual_review.sh. Native emulator evidence and remaining release gates are tracked separately from model coverage.

## Builder interface revision

The latest user instruction selects Terra Nil as a reference and supersedes both earlier navy/green and parchment assumptions. Compact HUD and a four-icon dock leave more room for the island. A single Pulse control opens the real power selector; the World hub retains center/fusion/photo actions. Global DNA detail lives in the inspector, production uses illustrated ingredient counts, and a transient notice layer does not resize the world. GameTheme centralizes interface colors/fonts. Modal close controls and a scrim handle dismissal; launch-menu spacing responds to viewport height. See docs/UI_RESEARCH.md for actually reviewed sources and access limitations.

Current GameTheme uses renamed static Inter derivatives and original SVG line controls. Header/type does not use decorative outlines, panel borders are thin, corners are small and shadows are removed. Official Terra Nil screenshot analysis is recorded in docs/UI_RESEARCH.md; no reference-game assets are distributed.

ChapterDial reads real campaign metrics into a bounded chapter fraction. EcologyReadout renders selected-tile moisture/heat without owning simulation. Main positions their corner groups independently while reserving a full-width world. Initial gameplay camera framing waits for settled HUD geometry; pulse-number width follows font metrics.

Expansion marker picking precedes terrain alpha picking only during ordinary collection/expansion mode; pulse/deployment mode hides these controls. Nearest visible marker wins overlapping mobile target areas. Moving a pending draft changes only its destination, keeping serialized offers and price. Rain presentation stores the actual authoritative affected keys and a bounded cosmetic lifetime.

EcologyReadout exposes a tap/keyboard explanation signal and explicitly labelled conditions. Main opens plain-language help; its responsive header reserves the measured conditions-panel dimensions, including enlarged text. WorldModel retains DNA as an internal data term; no save migration is required for this wording change.

Production tooling: tools/write_build_stamp.py embeds a generated source fingerprint, deliberately excluded from its own digest. tools/audit_android.py checks the actual APK and refuses stale/unbound test evidence; --production also requires real release configuration and current external QA declarations. tools/check.sh runs eight native-audit unit cases plus Godot suites. Native dependency/compiler versions are pinned in native/android JSON manifests.

Neighbor effects and automated production retain anchored cycle deadlines; frame jitter cannot shift each future interval. Stalled intervals are skipped rather than replayed in a reward burst.

Camera view_turn rotates projected grid coordinates in 90° steps. Inverse picking applies the inverse turn; depth sorting uses rotated entity centers. Fused reservations retain the same logical origin. Two-finger twist uses a60° threshold with90° residual subtraction to avoid pinch jitter. This is a 2.5D four-view camera, not a 3D model renderer.

Menu buttons pass GUI events to ScrollContainer so native touch drags can scroll; panels still contain modal input. Regression tests check below-fold reachability, no unintended button activation and no leaked world pointers. Native crash capture receives the actual diagnostics consent; opting in does not import Android exit records from an opt-out period.

JNI interface note:the wrapped Godot Android singleton dispatches plugin methods dynamically. Generic Object.has_method introspection skipped the new privacy helpers on the tested device. Own-package helper calls now use the known compiled interface after checking the singleton exists. Native SharedPreferences on/off verification confirms delivery.

DraftDealer supplies deterministic eligible hands from data/game.json rules. WorldModel persists the result once, preserving legacy pending offers and quotes. GameplayAdvisor is read-only and returns transient suggestions and placement descriptions; it owns no timers, rewards or saved state. Main/CampaignUI dispatch explicit player actions to existing validated transactions. Furnace automation reads construction reserves from tile data; manual crafting remains unrestricted by those reserves.

GameHUD.gd builds the gameplay HUD separately from Main and reads model state without spending or rewarding. AbilityMedallion.gd animates the current energy fraction; the numeric amount remains visible. Shared GameTheme supplies capsule/floating/quiet styles. Header resources span the available width, quest/conditions share the next row, and HUD minimum-size changes update layout/camera bounds. World hub cards dispatch the existing real actions.

0.14: SkyBackdrop is a negative CanvasLayer behind Main's world, so the sky shader never affects tile textures or UI. Main supplies its existing controlled ambient clock, including reduced-motion/background/photo freeze. GameHUD's selection callout is an overlay anchored inside the world bounds; its visibility does not change camera layout. The default HUD has no live statistical panels. EcologyReadout is now a compact leaf action retaining the current selection context; the existing inspector owns detailed readings. Numerical Pulse energy remains in its actual picker.

0.15: GameSheets builds reusable item stages, chips, primary actions, tabs, switch rows and illustrated power cards. DioramaPreview fits the existing atlas metadata and can render the real island via Main's projection/bounds/order; it does not own gameplay state. PulseDiagram is an explicitly illustrative cross footprint, and FusionDiagram shows four inputs/the sanctuary result. ToggleMark reflects the bound setting; the real button callback persists it. Main applies sheet colors only to modal descendants and caps content-sized sheets at the existing safe rectangle. Workshop filters and carousel positions are transient presentation state; existing validated public transactions remain authoritative.

0.16 supersedes the draft carousel only. DraftHand reads the saved three-offer transaction, owns transient card selection, and invokes WorldModel.place exactly once through the explicit confirmation. DraftCard is a native Button with ignored decorative children, existing terrain art, an independent generated frame and a procedural selection outline. Main temporarily frames the real island above the hand and restores the prior camera on dismissal or opening Info; no camera transform enters the save. A single gradient scrim darkens the lower world without reading screen textures. Other modal routes restore their existing sheet style. Optional rewarded redraw remains reachable in Info; the hand shows its shortcut only when the provider is ready. No provider or save-schema change.

0.17: SkyBackdrop uses an independent painted sky-realm texture plus one subtle haze sample, cover scaling on viewport resize and the existing controlled ambient clock. Day/dusk/night grades remain data-independent; photo/background/reduced-motion freeze behavior is preserved. MaterialUI caches two runtime ImageTextures with a virtual logical size for correct nine-patch density; original artwork pixels are unchanged. Cinzel/Lato resources and framed named HUD groups replace the loose counters/old sheet palette. UIIcons caches a generated object atlas and tight metadata regions for raw material sprites. The legacy EcologyReadout instance still retains selected DNA for inspector context but runs in settings_mode, visibly a gear opening actual Settings. A connected Settings action opens condition help. These presentation routes cannot spend resources or mutate saves.

0.18: IslandTopology is a pure occupied-cell builder including fusion-owned cells. It rotates occupancy into view space, builds only exposed front faces, joins shared lower corners, bounds horizontal taper and adds irregular cliff tips. Bounds include roots, mist and outlet spray. IslandEnvironment caches geometry by occupancy/type/evolution/view, pools IslandWall children in depth order behind Main's land, draws the common surface/mist and updates controlled30Hz cosmetic time. IslandWall draws painted cliff/roots; its Sprite2D child uses a shared waterfall shader, so nearer wall nodes correctly cover farther outlets. Main retains expansion clouds/markers above the foundation and all existing picking authority. Photo/title bounds merge the environment. DioramaPreview uses the same wall/cap painter for static World miniatures. No environmental presentation state is serialized.

## 0.19 concept composition and shared ground

Pack consolidates the prior five-tool navigation into three physical tools without removing destinations. The goal-book still opens GameplayAdvisor; Pack→Journal supplies Codex, Pack→World supplies fusion/rotation/photo, Pack→Projects supplies the complete queues/batch/catalogue, and the header gear supplies Settings/About/New World. All eight stock types stay visible in Pack.

BuildTray uses Main's existing modal/scroll lifecycle but a lower safe-area layout with maximum57% height. The modal input boundary is retained. Main stores/restores the prior gameplay zoom/pan when switching or closing Build, as it does for Draft. Tabs and horizontal shelf preserve recipe selection; a selected object is revealed on reopening. Current jobs/stock/blueprints/prerequisites refresh the selected quote; completion changes Build to Place. Normal CampaignSystem craft/deploy, atomic saves and cancel behavior are unchanged. Pending land drafts and absent eligible Meadows disable placement with actionable explanations. The preview chooses only an unreserved Grass plot outside Dusk targets, owns no occupancy and does not change saved data. Valid placement plots receive a gold surface outline.

TileArtwork.joined_mesh clips atlas soil skirts against two front-facing shared-ground half-planes and derives source UVs from the original pivots/normalization. Original PNGs remain untouched. Main/WorldAmbience use the clipped base in gameplay, including previous/fused animation parts; canopy deformation retains its original upper mesh. Static World miniatures use the same clipping. Cards/standalone item thumbnails retain their isolated tile bases. Alpha picking excludes the removed skirt before the existing grid fallback; photo/title bounds conservatively include the original sprite envelope. Foundation topology, fusion aliases and four quarter-turn projections remain authoritative for attached scenery.

## 0.20 terrain joins, tool materials, motors and pricing

IslandEnvironment uses an opaque world-aligned grass carpet across occupied caps, with tiny edge overlap for raster seams. TileArtwork partitions clipped sprites into an opaque interior and two linear front-alpha bands. This removes baked soil channels while preserving props/canopies; unoccupied coordinates stay empty. ToolMedallion paints complete reference-matched objects; the Pulse child adds live energy. A single framed resource rail uses ResourceCell separators and dedicated icons. Build structures use clipped ground without circular backplates.

Registered Windmill body/rotor regions share previews, alpha picking and complete-revolution bounds. WorldPresentation retains a bounded clock per machine, advances only enabled motors and freezes for photo/reduced/background. Building/ground geometry stays fixed.

ExpansionPricing revision2 preserves counters0–12, then uses a12-Coin linear tail capped360. New drafts store pricing_revision2. Missing revision means1 and validates against the original exact formula. SaveStore canonicalizes the optional field without repricing old drafts. Moving/confirming retains the saved quote; only future purchases use the new policy. Schema3/owned land remain unchanged.

0.20.1: WorldModel.cost is the active price readout: a pending draft returns its actual saved cost. Only absence of a draft evaluates the current curve. Save validation continues to use independent policy calculations, preventing a self-validating quote.
