# Architecture and original audit

The original repository was empty with no working functionality or commits to preserve. Godot 4.6.3 stable official is the pinned engine. The supplied specification is docs/MASTER_PRD_v4.md. Android uses OpenGL Compatibility explicitly, minimum API24, target36, ARM64 and x86_64 debug validation.

## Runtime composition

`scenes/Main.tscn` instantiates Main, the presentation/input/UI coordinator. It delegates authoritative transactions to WorldModel and CampaignSystem. All game definitions live in data/game.json; provider configuration lives in data/services.json.

| Component | Responsibility |
|---|---|
| WorldModel | Occupancy, harvest/coins, saved drafts, DNA, reactions, recipes, fusion, pulses, objectives |
| CampaignSystem | Chapters, crafting queues/quantities, production/automation/upgrades, blueprint deployment, retirement, Dusk Tide |
| SaveStore / CampaignSchema | Atomic validated primary/backup persistence; version 1/2 migration to schema 3; numeric canonicalization |
| InputController | Tap/long-press/drag/pinch/cancel classification; Main excludes UI-origin and mixed UI/world touch sequences |
| SafeLayout | Physical safe area and DPI conversion into 540×960 logical portrait layout; responsive modal bounds |
| CampaignUI | Codex, workshop, world management, settings/tutorial; styled scrollable controls |
| TileArtwork / TileThumbnail / UIIcons | Stable atlas regions, pivots, shared appearance selection and alpha picking; illustrated previews/icons |
| WorldAmbience | Grounded canopy deformation and bounded water/machine activity, with separate cosmetic clock and reduced-motion support |
| WorldPresentation | Bounded cosmetic diffs, rise/crossfade/fusion/weather/harvest animations; never owns rewards |
| FusionGuide | Read-only candidate discovery/ranking and blocker explanations; WorldModel owns fusion commits |
| UIMotion | Interruptible, node-bound press/fade/highlight tweens; respects reduced motion |
| GameTheme | Licensed fonts, graphite/pearl/muted-violet styles, shared UI palette independent of world skins |
| AudioFeedback | Pooled cue voices and ambient loop; independent volume/mute and lifecycle handling |
| ServiceHub / Telemetry | Optional provider bridge, durable reward ledger/caps, purchase entitlement handling, opt-in diagnostics/HTTPS delivery |
| PocketServices.kt | Native test Ads/UMP, Billing, rewarded receipts, Android crash diagnostics and user-initiated photo content-URI sharing |

## State and invariants

Coordinates are stable `x,y` keys independent of projection. Maximum gameplay occupancy is 36 cells; storage validates up to 64. Fused entities have one origin and three reservations; all cooldown, DNA, influence and picking queries resolve that origin. Fusion commits atomically before animation and never grants duplicate discovery rewards.

Simulation uses monotonic active seconds, per-frame cooldown advancement and 1Hz environmental updates. Neighbor sums are buffered and clamped after all sources; recipe tiers increase monotonically. DNA is bounded 0–100. Offline time grants no production. Harvest writes debounce for 350ms and flush immediately on backgrounding. Background saves and resume delta suppression prevent elapsed-time windfalls.

Expansion stores target, frozen three offers and quoted cost; payment occurs only on successful placement. One optional ad reroll per expansion preserves the price and target. Essential source tiles are also craftable, protecting progression at the land cap. Initial wood/stone/fiber nodes remain productive and cannot be retired.

Schema 3 includes world, IDs, inventory, timers, pulse modifiers, discoveries, pending draft, chapters/rewards, crafting, blueprints, event state, cosmetics/entitlements, rewarded requests/receipts, accessibility and audio settings. Nested validation precedes load/write. Unknown schemas are rejected. Writes use a temporary file and validated backup before rename; copy/rename failures preserve committed state. This is not a physical power-loss durability guarantee.

## Native build and isolation

`tools/prepare_native.py` generates ignored android/build from the pinned Godot template and copies maintained Kotlin/resources. It adds Google Ads 23.6.0, UMP 3.1.0 and Play Billing 8.0.0. `tools/build_android.sh` imports, runs checks, exports a staging APK, verifies its signature and promotes it only on success. APKs/toolchains/caches are not source-controlled.

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
