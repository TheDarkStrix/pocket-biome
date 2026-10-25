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
