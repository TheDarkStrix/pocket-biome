# POCKET BIOME: TINY EXPANSION
## Final Master Product Requirements Document
### Version 4.0 — Living Worlds Edition

**Document Status:** Design baseline, internally audited — implementation and market validation pending  
**Engine:** Godot 4.x (GDScript)  
**Platform:** Android first, iOS-compatible architecture  
**Genre:** Cozy Strategy / Environmental Discovery / Hybrid-Casual  
**Business Model:** Free-to-play + rewarded advertisements + optional in-app purchases  
**Game Mode:** Single-player, offline-first  
**Orientation:** Portrait  
**Reference Resolution:** 1080 × 1920  
**Primary Development Approach:** Solo development with AI-assisted programming and asset creation

---

# PART I — PRODUCT STRATEGY

## 1. Executive Summary

Pocket Biome is a miniature living-world game in which players begin with four floating land tiles surrounded by clouds.

Players expand their island, arrange environments, discover unexpected ecological reactions, evolve biomes, and create increasingly elaborate miniature worlds.

The island is not simply a collection of static tiles.

Each tile has environmental characteristics that interact with its surroundings. Water increases moisture, volcanic structures produce heat, trees encourage fertility, and unusual combinations unlock hidden transformations.

Different players can evolve the same starting island into dramatically different worlds.

### Primary Player Fantasy

**"I created this tiny world, and I want to see what it becomes."**

### Primary Business Objective

Develop a game that sustainably generates advertising and optional purchase revenue by earning recurring player engagement.

### Secondary Objectives

- Establish a visually recognizable game identity.
- Encourage organic sharing of interesting discoveries.
- Build a content architecture that supports future biome packs.
- Minimize recurring backend and infrastructure costs.
- Support international audiences.
- Maintain acceptable performance on mid-range Android devices.

## 2. Product Differentiation

Pocket Biome must not rely on tile merging alone.

Its differentiating proposition is the combination of four interconnected mechanics:

### Pillar A — Biome DNA

Every environmental tile has characteristics that change through neighboring conditions and player actions.

The same original tile can evolve into multiple different forms.

### Pillar B — Environmental Chain Reactions

An environmental change can influence surrounding tiles, causing visible secondary changes or unlocking new opportunities.

Reactions are deterministic, understandable, and visually clear.

### Pillar C — Secret Discovery

Players experiment with combinations to uncover new environmental forms, structures, and rare transformations.

Discoveries are documented in a persistent Codex.

### Pillar D — World Pulse

Players periodically gain control of an environmental power that can deliberately change conditions across a selected region.

These four pillars form the game's identity.

Tile drafting, resource harvesting, fusion, crafting, and automation support them.

## 3. Design Principles

1. Easy to understand, strategically interesting to master.
2. Short sessions should produce meaningful progress.
3. Visual transformations should be more exciting than increasing numbers.
4. Discovery is rewarding even without advertisements.
5. Every session should contain useful decisions.
6. Waiting should never be the player's only available action.
7. Monetization should enhance the experience, not manufacture frustration.
8. Rare discoveries should be obtainable through normal gameplay.
9. The island should feel personal and worth showing.
10. New content should primarily be data-driven rather than requiring new engine architecture.

---

# PART II — CORE GAMEPLAY

## 4. Primary Gameplay Loop

**Harvest → Expand → Draft → Place → Influence → Discover → Evolve → Optimize → Repeat**

### Harvest

Collect Wood, Stone, Fiber, Clay, and Ore from resource nodes.

### Expand

Use earned Coins to purchase land hidden under surrounding clouds.

### Draft

Choose one of three new biome or structure cards.

### Place

Place the chosen card in the expansion plot or, when an explicit relocation ability is available, reposition eligible existing tiles.

### Influence

Adjacent structures, natural environments, and World Pulse abilities modify local conditions.

### Discover

Environmental conditions fulfill recipes, producing new evolutions or special reactions.

### Evolve

Create multi-cell sanctuaries or unlock higher-tier biome forms.

### Optimize

Arrange structures and environmental effects to support production and achieve new objectives.

### Repeat

Unlock fresh regions, discoveries, upgrades, and cosmetic possibilities.

## 5. Three Engagement Loops

### Micro Loop — 30 to 90 Seconds

- Harvest resource nodes.
- Activate a synergy.
- Select a card.
- Modify environmental conditions.
- Advance one objective.

### Session Loop — 5 to 15 Minutes

- Complete a quest.
- Unlock several tiles.
- Experiment with combinations.
- Discover or fuse a biome.
- Upgrade an automation structure.

### Long-Term Loop — Multiple Days

- Complete Discovery Codex collections.
- Unlock biome families.
- Create higher-tier sanctuaries.
- Master environmental puzzles.
- Build a personalized showcase island.

Progress must be saved automatically.

---

# PART III — THE LIVING WORLD

## 6. World Structure

### Initial Island

Four logical cells occupy:

- (0,0)
- (1,0)
- (0,1)
- (1,1)

The starting arrangement contains:

- One Oak resource tile.
- One Stone resource tile.
- One Fiber resource tile.
- One Grass tile.

The island visually appears as one connected floating landmass.

### Expansion Rules

- Expansion plots must touch existing land cardinally.
- A purchased plot produces a three-card draft.
- Exactly one selected card is installed at the purchased coordinate.
- Existing occupied coordinates cannot be overwritten.
- Expansion coordinates are independent of world-screen positions.
- Expansion cost is charged only after the transaction is successfully completed.
- Canceling a pending draft preserves the paid expansion decision and resumes that draft.

### Launch Boundaries

For the MVP, support an occupied world of approximately 25–36 cells.

The architecture must support at least 64 cells without rewriting grid logic.

Large future worlds may require camera improvements, scene culling, and rendering optimization.

## 7. Biome DNA System

Each standard environmental cell has five primary attributes.

| Attribute | Range | Meaning |
|---|---|---|
| Moisture | 0–100 | Water and hydration |
| Heat | 0–100 | Thermal activity |
| Fertility | 0–100 | Growth potential |
| Stability | 0–100 | Geological resilience |
| Magic | 0–100 | Supernatural energy |

Attributes are integer values.

### Example Base Attributes

| Biome | Moisture | Heat | Fertility | Stability | Magic |
|---|---:|---:|---:|---:|---:|
| Grassland | 35 | 30 | 55 | 60 | 5 |
| Forest | 50 | 25 | 75 | 55 | 10 |
| Pond | 95 | 20 | 40 | 45 | 15 |
| Rocky Ground | 10 | 45 | 10 | 95 | 5 |
| Volcanic Ground | 5 | 95 | 5 | 65 | 25 |
| Crystal Field | 20 | 20 | 15 | 85 | 85 |

These are initial tuning values, not production-balanced numbers.

### Environmental Updates

Environmental conditions change when:

- A new tile is placed.
- An adjacent tile changes type.
- A structure emits its periodic effect.
- A World Pulse is activated.
- A special event begins or ends.
- A biome evolves.

### Simulation Model

Use discrete, event-driven updates instead of a continuous environmental simulation.

Normal environment updates occur only when triggered by gameplay events or a low-frequency simulation tick.

Default environmental simulation tick: 1 second while actively playing.

Environmental effects are processed in deterministic order.

Each update:

1. Reads the current world state.
2. Calculates changes into a separate buffer.
3. Clamps attributes to 0–100.
4. Applies the changes simultaneously.
5. Evaluates newly satisfied discovery conditions.
6. Refreshes affected visuals and synergies.

This prevents update-order bugs and uncontrolled chain reactions.

### Reaction Limits

- Environmental effects are bounded.
- One reaction cannot recursively trigger itself indefinitely.
- The reaction engine has a configurable maximum chain depth.
- Each discrete effect has a source ID and cooldown where necessary.
- Duplicate rewards from repeated state evaluation are prevented.

### Visual Behavior

Environmental changes are reflected through:

- Terrain palette changes.
- Plant growth variations.
- Water coloration.
- Particle effects.
- Environmental glow.
- Small ambient animations.
- Distinct evolved biome artwork.

Avoid requiring unique artwork for every possible combination of the five attributes.

Instead, use a manageable set of authored visual states with shader overlays and effects.

## 8. Environmental Interactions

Initial examples:

| Source | Effect | Target |
|---|---|---|
| Water | +8 Moisture per pulse | Cardinal neighboring natural tiles |
| Forest | +4 Fertility per pulse | Neighboring soil and grass |
| Thermal Vent | +10 Heat per pulse | Cardinal neighbors |
| Rain Totem | +6 Moisture and cooldown reduction | Cardinal neighbors |
| Crystal | +5 Magic per pulse | Compatible neighboring tiles |
| Compost Bed | +6 Fertility | Adjacent plant tiles |

Pulse intervals must be configured per effect.

The numerical changes above are design defaults pending balancing.

### Conflicting Environmental Effects

Conflicting effects should produce interesting outcomes instead of silently canceling out.

For example:

- Heat + Water may create Steam.
- High Moisture + High Fertility may unlock Rainforest.
- High Magic + High Stability may unlock Crystal formations.
- Extreme Heat + Low Moisture may convert Grass to Barren Ground.

### Player Clarity

When selecting a tile, show:

- Its current environmental attributes.
- Influencing neighboring tiles.
- Positive and negative effects.
- Nearby available discoveries.
- A short explanation of why a transformation is or is not possible.

Players should not need to guess invisible thresholds indefinitely.

---

# PART IV — DISCOVERY & EVOLUTION

## 9. Discovery System

The Discovery Codex is a major retention feature.

### Launch Target

20 authored discoveries.

Initial distribution:

- 6 Common
- 7 Uncommon
- 5 Rare
- 2 Legendary

Rarity describes discovery complexity and presentation, not paywalled exclusivity.

### Sample Discoveries

| Discovery | Conditions | Result |
|---|---|---|
| Rainforest Sanctuary | Forest, Moisture ≥70, Fertility ≥70 | Enhanced forest |
| Ember Bloom | Plant tile, Heat ≥70, Magic ≥35 | Glowing fire-resistant plants |
| Crystal Lake | Water, Magic ≥65, Stability ≥60 | Magical water production |
| Steam Jungle | Forest, Moisture ≥65, Heat ≥65 | Hybrid thermal forest |
| Frozen Garden | Plant tile, Heat ≤15, Moisture ≥60 | Frost vegetation |
| Ancient Grove | Four Forest cells in 2×2 | Large sacred forest |
| Moonlit Lagoon | Four Water cells in 2×2 | Magical lagoon |
| Crystal Quarry | Four Stone cells in 2×2 | Advanced mineral site |

The complete production recipe catalog must be stored in structured game data rather than hardcoded conditionals.

### Discovery Evaluation

For each recipe define:

- Unique recipe ID.
- Required cell types.
- Required footprint.
- Environmental attribute thresholds.
- Required structures.
- Optional World Pulse requirements.
- Resulting biome.
- Reward.
- Discovery rarity.
- Presentation animation.
- Repeat behavior.

### First-Time Rewards

First discovery rewards can include:

- Coins.
- Star Dew.
- New card unlocks.
- Environmental powers.
- Decorative items.
- Progression milestone advancement.

Rewards are granted once per profile per unique discovery ID.

### Codex Hints

Unknown entries display silhouettes and hints.

Example:

"When ancient roots drink from heated waters, an impossible forest may emerge."

Hints become progressively clearer through normal gameplay.

Ads may optionally grant an additional hint, but required recipe information must always remain obtainable without ads.

## 10. Tile Fusion

### Basic Fusion

Four compatible cells in a 2×2 footprint may fuse into one evolved entity.

Examples:

- Four Forest → Ancient Grove.
- Four Water → Moonlit Lagoon.
- Four Stone → Crystal Quarry.
- Four Grass → Verdant Sanctuary.

### Fusion Representation

The evolved entity has:

- One authoritative entity ID.
- One origin coordinate.
- Width and height in logical cells.
- Four reserved grid coordinates.
- Shared environment and production state.
- One selectable collision target.

Do not render or harvest the evolved entity as four independent objects.

### Fusion Requirements

- Player explicitly confirms the fusion.
- All cells meet recipe conditions.
- No locked or incompatible structure occupies the footprint.
- Environmental requirements remain satisfied.
- Required resources, if any, are available.

### Fusion Animation

1. Highlight valid cells.
2. Briefly pull energy toward the center.
3. Compress constituent visuals.
4. Play a burst of particles.
5. Reveal the new biome using a scale-and-rise animation.
6. Display its name.
7. Award the discovery.
8. Return control immediately after the animation.

### Fusion Safety

If a fusion fails or the game closes during the animation, the authoritative game state must remain valid.

Commit the logical fusion atomically before playing the cosmetic animation.

---

# PART V — WORLD PULSE

## 11. World Pulse System

World Pulse gives players a powerful, deliberate way to influence their island.

### Energy Meter

World Pulse energy is earned through:

- First-time discoveries.
- Completing objectives.
- Performing fusions.
- Selected strategic actions.

Ordinary resource taps grant little or no World Pulse energy to avoid encouraging repetitive tapping.

### Energy Rules

- Meter capacity: 100.
- Pulse cost: 100.
- No automatic energy decay.
- Energy persists across sessions.
- Initial maximum stored charges: 2.

### Launch Powers

**Rain Burst**

Applies a temporary Moisture increase and faster plant growth to a selected area.

**Heat Wave**

Raises Heat, enables thermal reactions, and clears compatible frost effects.

**Frost Bloom**

Reduces Heat and creates temporary frost conditions that can enable frozen biome discoveries.

### Targeting

- Player selects the power.
- A preview displays affected cells.
- Player taps to confirm.
- Power is consumed only after a valid target is confirmed.
- Invalid targets do not consume energy.

### Monetization Restriction

The game must not require advertisements to use World Pulse.

An optional rewarded recharge can be tested after core retention is established, with strict daily limits and no exclusive discoveries locked behind viewing ads.

---

# PART VI — RESOURCES, CRAFTING & AUTOMATION

## 12. Resource System

### Primary Resources

- Wood
- Stone
- Fiber
- Clay
- Iron

### Currencies

**Coins**

Earned primarily through normal gameplay. Used for expansions and upgrades.

**Star Dew**

Rare earnable currency used for selected advanced upgrades and decorative unlocks.

Star Dew must not become the sole gate to mandatory progression.

### Starting Inventory

- Wood: 0
- Stone: 0
- Fiber: 0
- Clay: 0
- Iron: 0
- Coins: 25
- Star Dew: 0

### Harvest Values

| Node | Yield | Base Cooldown |
|---|---:|---:|
| Oak | 1 Wood | 8s |
| Boulder | 1 Stone | 12s |
| Fiber Shrub | 1 Fiber | 6s |
| Clay Deposit | 1 Clay | 15s |
| Iron Vein | 1 Iron | 20s |

### Cooldown Acceleration

A cooling-down node can receive manual taps reducing the remaining cooldown by 0.5 seconds.

Apply a rate limit and minimum cooldown of 1 second.

### Economy Formula

Initial expansion formula:

`ExpansionCost(N) = round(12 × 1.24^N)`

Where N is the number of completed paid expansion purchases.

The cost must be tuned against production, objective rewards, and intended session pacing.

### Anti-Softlock Rule

The player must always have a free, attainable path to the next required resource or expansion.

## 13. Automation Structures

### Stone Golem

Harvests adjacent ready Stone or Ore nodes on a configurable interval.

### Rain Totem

Emits a pulse every 4 seconds that reduces adjacent cooldown timers and increases Moisture.

### Mini Windmill

Generates Coins periodically.

Default: 1 Coin every 5 seconds.

### Stone Furnace

Processes materials and produces thermal influence.

Initial recipe:

2 Stone + 1 Wood → 1 Brick.

Additional recipes unlock later.

### Ancient Workbench

Provides the crafting interface.

### Automation Restrictions

- Automation must respect inventory limits.
- Automated harvesting should use the same authoritative resource logic as manual harvesting.
- Automation must not produce duplicate transactions.
- Structures should remain useful but not trivialize all strategic decisions.
- Any offline production must be calculated from persisted time differences and capped to prevent exploits.

---

# PART VII — OBJECTIVES & RETENTION

## 14. Objective System

Always show one primary objective.

Optional side objectives may appear as players progress.

### Example Objectives

- Collect 5 Wood.
- Unlock your fifth tile.
- Place a Water Tile beside a Forest.
- Raise a biome's Moisture above 70.
- Discover your first rare evolution.
- Create an Ancient Grove.
- Use World Pulse to unlock a reaction.
- Generate 30 Coins using automation.

### Objective Requirements

- Objectives must be deterministic.
- Progress persists across sessions.
- Rewards can only be claimed once.
- A player must never receive an impossible main objective.
- Objectives can adapt to the cards and biomes already available.
- Optional goals should encourage experimentation.

## 15. Progression Chapters

### Chapter 1 — The First Seed

Learn harvesting, expansion, drafting, and the first environmental synergy.

### Chapter 2 — Living Neighbors

Introduce adjacency effects, environmental attributes, and the first World Pulse.

### Chapter 3 — Strange Transformations

Introduce special discoveries and fusion.

### Chapter 4 — The Tiny Civilization

Unlock automation and more advanced production.

### Chapter 5 — Celestial Biomes

Introduce rare transformations, Star Dew, and Dusk Tide.

Each chapter has a clear completion objective, a visual celebration, and a new gameplay possibility.

## 16. Dusk Tide

Retain the original Dusk Tide concept, but introduce it only after players understand normal gameplay.

### Behavior

- An optional environmental challenge becomes available approximately every five minutes of active gameplay.
- Dusk lasts up to 60 seconds.
- Two eligible cells receive temporary frost or mist.
- Players may respond with World Pulse or an appropriate structure.
- Successful intervention provides a modest reward.

### Important Restrictions

- Critical early-game resource access cannot be completely frozen.
- Ignoring the event must not destroy player progress.
- The same tile should not repeatedly receive disruptive effects.
- The event pauses when the app is suspended.
- No advertisements during the active event.
- The player can disable nonessential visual effects in settings.

Dusk Tide is a secondary engagement mechanic, not a mandatory repeating chore.

## 17. Return Incentives

Implement:

- New achievable objectives.
- Collection milestones.
- Previously unlocked automation rewards.
- New chapters.
- Cosmetic unlocks.
- Future optional challenges.

Do not implement loss-of-progress penalties for missing daily sessions.

No mandatory streak system at launch.

---

# PART VIII — VISUAL ART DIRECTION

## 18. Art Direction: "Pocket Diorama"

Pocket Biome must have a recognizable visual identity.

### Selected Style

**Premium, stylized 2.5D isometric miniature diorama.**

The game should resemble a beautifully crafted miniature world, with soft rounded terrain, detailed natural objects, and whimsical environmental effects.

### Visual Characteristics

- Fixed isometric projection.
- Rich but controlled colors.
- Handcrafted miniature proportions.
- Soft ambient lighting.
- Rounded terrain edges.
- Layered terrain depth.
- Clean silhouettes.
- Gentle gradients and painterly texture detail.
- High-quality environmental effects.
- Readable sprites at small mobile sizes.

### Avoid

- Generic flat vector art.
- Excessive photorealism.
- Inconsistent AI-generated perspectives.
- Pixel-art sprites mixed with painterly assets.
- Overly complex environments.
- Excessive glow.
- Small unreadable details.
- Generic fantasy UI ornamentation.

### Art Personality

Calm, magical, collectible, and slightly mysterious.

The game should feel welcoming in normal play and spectacular when a rare transformation occurs.

## 19. World Color Palette

### Primary UI Palette

| Role | Hex |
|---|---|
| Deep Navy | #17243A |
| Forest Green | #2E785D |
| Mint Highlight | #78D4A2 |
| Warm Cream | #FFF4DC |
| Golden Reward | #F2C46D |
| Sky Blue | #8DBFE8 |
| Magic Violet | #A58BE8 |
| Warning Coral | #E97C6D |

### Biome Palettes

**Grassland:** fresh greens, golden soil.

**Forest:** deep emerald, warm wood, moss.

**Water:** turquoise, teal, reflected sky blue.

**Volcanic:** charcoal, ember orange, copper.

**Frozen:** icy cyan, blue-white, indigo.

**Crystal:** violet, pale cyan, silver.

**Celestial:** midnight blue, lavender, golden particles.

## 20. Isometric Sprite Standards

### Logical Tile Layout

Recommended initial projected tile top-face size:

- Width: 256 px.
- Height: 128 px.
- Projection ratio: 2:1.

Sprites may have a larger transparent canvas to accommodate terrain depth and taller objects.

### Asset Design Requirements

- All tiles share the same projection and camera angle.
- All cells use a consistent top-face footprint.
- Terrain profiles align without visible cracks.
- Objects share a consistent visual scale.
- Tall objects can overlap visually without expanding their logical grid footprint.
- Sprite pivots and ground anchors must be explicitly defined.
- Terrain, objects, and foreground effects use consistent render ordering.

### Render Layers

1. Cloud background.
2. Distant decorative islands.
3. Active terrain.
4. Resource nodes and structures.
5. Foreground vegetation.
6. Environmental effects.
7. Selection overlays.
8. Floating world-space labels.
9. Screen-space interface.

### Production Asset Strategy

Use a master art-direction reference sheet for visual consistency.

Do not require all game artwork to be embedded into one enormous atlas texture.

Generate or illustrate assets by category, normalize scale and perspective, clean transparency, and pack them into multiple logical texture atlases.

Recommended atlas groups:

- Terrain
- Resource nodes
- Structures
- Evolved biomes
- Environment effects
- UI icons
- Decorative objects

Use lossless source artwork for editing and optimized runtime textures for production.

## 21. Required Art Inventory

### Environment Assets

- Grass terrain
- Dirt terrain
- Forest terrain
- Stone terrain
- Water terrain
- Volcanic terrain
- Frozen terrain
- Crystal terrain
- Locked cloud plot
- Cloud edge variations
- Floating island dirt profiles
- Decorative rocks and foliage

### Resource Nodes

Ready and depleted versions of:

- Oak Tree
- Stone Boulder
- Fiber Shrub
- Clay Deposit
- Iron Vein

### Structures

- Rain Totem
- Thermal Vent
- Stone Furnace
- Mini Windmill
- Stone Golem
- Compost Bed
- Ancient Workbench
- Growth Shrine

### Fusion Art

Create unique visual treatments for each of the 20 authored discoveries.

Recoloring alone is not sufficient for every rare or legendary biome.

Rare discoveries should have identifiable silhouettes, decorations, or environmental effects.

### Environmental VFX

- Harvest pop.
- Resource flight.
- Floating reward text.
- Placement rise.
- Tile fusion.
- Discovery burst.
- Moisture pulse.
- Heat wave.
- Frost bloom.
- Crystal sparkle.
- Dusk mist.
- Legendary transformation.

### UI Art

- Resource icons.
- Coins and Star Dew icons.
- Card frames.
- Rarity borders.
- Buttons.
- Modal panels.
- Progress bars.
- Quest icons.
- Codex silhouettes.
- Settings icons.
- World Pulse indicators.
- Store item previews.

---

# PART IX — UI/UX DESIGN

## 22. Visual UI Concept

Use a premium fantasy interface with modern mobile usability.

The UI should feel like a glass-and-wood miniature explorer's journal.

### UI Style

- Soft translucent panels.
- Dark navy typography.
- Warm cream surfaces.
- Green primary actions.
- Golden rewards.
- Rounded corners.
- Gentle shadows.
- Clear iconography.
- Compact controls.
- Minimal decoration during active gameplay.

The interface must not obscure the island.

## 23. Main Gameplay Screen

### Screen Structure

**Top Safe Area**

System status bar and device cutout spacing.

**Top Resource Bar**

Compact displays for Coins, Wood, Stone, and contextual resources.

Additional resources available through a detailed inventory screen.

**Top-Right Controls**

- Settings
- Recenter camera
- Optional camera/photo mode

**Upper Objective Panel**

Shows the current primary objective.

Example:

"Discover your first Rainforest"

Progress: 2/3 conditions satisfied.

**Center Gameplay Area**

The floating island occupies the majority of the screen.

Touching a tile opens its contextual information.

**World Pulse Button**

Floating action button near the lower-right edge of the gameplay area.

Displays available energy.

**Bottom Navigation**

- Island
- Codex
- Craft
- Shop

Use four clearly labeled navigation targets.

### UI Priorities

The island is always the visual focus.

Nonessential UI may collapse or fade while the player drags or zooms.

All important interactive elements must be reachable and large enough for touch.

## 24. Card Draft Screen

Triggered after purchasing an expansion plot.

### Layout

- Dimmed island background.
- Title: "Choose Your Next Biome."
- Three vertically arranged cards on compact screens.
- Card illustration.
- Card name.
- Card category and rarity.
- Primary ability.
- Adjacent synergy indicator.
- Tap to inspect details.
- Confirm selection button.
- Optional rewarded reroll.

Do not use three small horizontal cards if text becomes unreadable on narrow phones.

### Card Rarity Treatment

- Common: subdued natural border.
- Uncommon: green accent.
- Rare: blue/violet accent.
- Legendary: warm gold accent with subtle animation.

Rarity must also be indicated by text or symbols for accessibility.

## 25. Tile Inspection Panel

When a tile is selected, show a bottom sheet.

Contents:

- Tile name.
- Preview artwork.
- Current production.
- Cooldown status.
- DNA attribute bars.
- Active synergies.
- Discovery opportunities.
- Available actions.

The panel must allow quick dismissal by tapping outside or swiping downward.

## 26. Discovery Codex Screen

### Layout

- Header with collection progress.
- Biome category tabs.
- Scrollable discovery grid.
- Unlocked entries show artwork.
- Locked entries show silhouettes.
- Selected entries display recipes, hints, lore, and benefits.

### Rare Discovery Reveal

A rare first-time discovery receives:

- Fullscreen artwork emphasis.
- Name reveal.
- Short animation.
- Reward summary.
- Share button.

Do not automatically open the operating system share sheet.

## 27. World Pulse UI

### States

- Unavailable
- Charging
- Ready
- Selecting power
- Targeting
- Activating

### Layout

Selecting the ability opens a compact radial or bottom-sheet power selector.

Targeting displays a clear effect preview on the island.

The player can cancel without spending energy.

## 28. Crafting Screen

Use a clear recipe list.

Each recipe displays:

- Output item.
- Required ingredients.
- Available resources.
- Quantity selector.
- Craft button.
- Craft duration if applicable.

Unavailable recipes should explain the missing requirement.

## 29. Shop Screen

Separate store items into:

- Decorative Themes
- Special Cosmetic Bundles
- Optional Adventures
- Remove Ads

Show prices in the platform-provided local currency.

Purchases must display exactly what the player receives.

## 30. UI Animations

Recommended timings:

| Interaction | Target Duration |
|---|---:|
| Button response | 80–120ms |
| Harvest animation | 180–280ms |
| Resource flight | 250–450ms |
| Tile placement | 400–650ms |
| Card reveal | 300–500ms |
| Standard fusion | 1.2–2.0s |
| Rare discovery reveal | 2.0–3.0s |

These are tuning targets, not hard engine requirements.

Animations must not block save operations or cause input-state inconsistencies.

Include reduced-motion settings.

## 31. Accessibility

- Minimum practical touch targets: approximately 48 dp.
- Safe-area-aware layouts.
- Text scaling where feasible.
- High-contrast information indicators.
- No reliance on color alone.
- Sound and vibration controls.
- Reduced-motion mode.
- Readable fonts on smaller devices.
- Portrait device aspect-ratio testing.

---

# PART X — AUDIO & FEEDBACK

## 32. Sound Design

Music style:

- Cozy ambient.
- Soft marimba or plucked tones.
- Gentle strings.
- Natural ambience.
- Subtle magical textures.

### Sound Effects

- Soft wooden harvest.
- Stone break.
- Water ripple.
- Resource collection.
- Card selection.
- Tile placement.
- Small discovery chime.
- Legendary discovery swell.
- World Pulse activation.
- Environmental reactions.

### Audio Requirements

- Separate music and effects sliders.
- Proper interruption handling.
- Pause or duck sound on app backgrounding.
- Respect device audio settings where appropriate.
- Avoid repetitive high-frequency reward sounds.

---

# PART XI — MONETIZATION

## 33. Monetization Strategy

Monetization must support retention.

Primary revenue sources:

1. Rewarded advertisements.
2. Limited interstitial advertisements.
3. Cosmetic in-app purchases.
4. Permanent ad removal.
5. Optional premium content packs.

## 34. Rewarded Advertisements

Initial placements:

### Draft Reroll

Watch an advertisement to receive one additional card draft.

Maximum one ad reroll per expansion.

### Optional Bonus Reward

After completing selected objectives, the player can choose to watch an ad for a bonus reward.

This must not multiply scarce progression-critical resources excessively.

### Additional Discovery Hint

A rewarded advertisement may reveal an extra hint for an unknown discovery.

All discoveries remain obtainable without advertisements.

### Rules

- Ads are always opt-in.
- Clearly display the reward before the ad.
- Credit the reward only after verified completion.
- Ensure failure leaves the original game state intact.
- Prevent duplicate rewards.
- Apply server/provider callbacks safely.
- Use frequency caps and event analytics.

## 35. Interstitial Advertisements

Do not show interstitials during:

- Tutorial.
- Resource harvesting.
- Tile dragging.
- Card selection.
- World Pulse targeting.
- Fusion animations.
- Rare discovery reveals.
- Dusk events.
- App startup or return from background.

### Initial Experimental Policy

- No forced interstitial during the first session's onboarding.
- Minimum 8 minutes of active play before eligibility.
- Maximum one interstitial per 10 minutes of active play.
- Maximum two interstitials per session.
- Only at appropriate chapter transitions or clear stopping points.

These are conservative internal limits, not guarantees that an interstitial is appropriate. If a suitable break does not occur, do not show an ad.

Interstitials should be disabled or reduced if retention or session completion worsens.

## 36. Banner Advertisements

No banner advertisements on the primary island screen at launch.

The interface needs available space for gameplay.

Optional banner experiments may be considered on noninteractive secondary screens only after collecting engagement data.

## 37. In-App Purchases

### Remove Ads

Example test price: ₹149–₹299.

Permanently removes forced interstitial and banner advertisements.

Clarify whether rewarded ads remain available as optional reward sources.

### Cosmetic Island Themes

Example test price: ₹99–₹199.

Potential themes:

- Sakura Kingdom.
- Celestial Garden.
- Moonlit Forest.
- Ancient Ruins.
- Crystal Dreamscape.

### Founder's Collection

Example test price: ₹299–₹499.

Includes:

- Ad removal.
- A unique cosmetic theme.
- Decorative buildings.
- Exclusive visual effects.

### Premium Adventures — Post-Launch

Optional authored challenge regions with specialized discoveries and cosmetics.

These are not needed for the initial release.

### Purchase Rules

- No hidden subscriptions.
- No gambling-style paid loot boxes.
- No mandatory purchases to complete the core game.
- No paid-only exclusive functional advantage in the competitive sense.
- Permanent entitlements must survive reinstall through supported restore mechanisms.
- Store and payment handling must comply with applicable platform requirements.

All prices are hypotheses to test, not validated market prices.

---

# PART XII — PLAYER SHARING & GROWTH

## 38. Shareable Island Mode

Implement a dedicated photo mode.

### Features

- Hide gameplay HUD.
- Automatically frame the entire island.
- Allow limited pan and zoom.
- Choose Day or Dusk preview when unlocked.
- Capture clean screenshots.
- Display subtle game branding outside important artwork.
- Use the native Android sharing interface.

### Share Trigger Moments

- First rare discovery.
- First legendary biome.
- Chapter completion.
- Major island transformation.
- Optional manual photo mode.

Sharing must always be initiated by the user.

## 39. Island Seeds

Each new world receives a seed.

Seed sharing is a later enhancement.

A seed may reproduce the initial conditions and deterministic generation rules.

Player actions and card choices still produce different final islands.

Do not promise identical completed worlds from a seed alone.

## 40. Acquisition Strategy

Potential marketing themes:

- "I started with four tiles."
- "I accidentally created a Steam Jungle."
- "What happens when fire meets a magical lake?"
- "I discovered a biome I didn't know existed."
- "Can you evolve this tiny island into something impossible?"

The game should naturally produce interesting screenshots and short clips.

Do not claim procedurally generated outcomes are unique to each player unless they genuinely are.

---

# PART XIII — GODOT 4 ARCHITECTURE

## 41. Technical Architecture

Use composition and data-driven definitions.

### Core Autoloads

**GameData.gd**

- Player inventory.
- Currency.
- Progression.
- Persistent upgrades.
- Game-state signals.

**SaveManager.gd**

- Serialization.
- Save versioning.
- Atomic save writes.
- Load validation.
- Migration.
- Recovery.

**GameConfig.gd**

- Economy constants.
- Gameplay limits.
- Event timing.
- Feature configuration.

### Core World Systems

**GridManager.gd**

- Coordinate occupancy.
- Expansion.
- Neighbor queries.
- Multi-cell entities.
- Tile placement.
- Fusion transactions.

**BaseTile.gd**

- Tile lifecycle.
- Harvest state.
- Production.
- Visual state.
- Selection.

**BiomeDNA.gd**

- Environmental attributes.
- Modifier application.
- Snapshot generation.
- Environmental state changes.

**ReactionEngine.gd**

- Discovery condition evaluation.
- Chain reaction queue.
- Deduplication.
- Reaction limits.
- Deterministic resolution.

**FusionManager.gd**

- Fusion candidate detection.
- Recipe matching.
- Resource requirements.
- Atomic fusion commits.

**StructureAutomation.gd**

- Golem behavior.
- Windmill production.
- Rain Totem pulses.
- Furnace production.

**WorldPulseManager.gd**

- Energy.
- Power availability.
- Target selection.
- Effects.
- Consumption.

**EventManager.gd**

- Dusk scheduling.
- Environmental event state.
- Rewards.
- Event pause/resume behavior.

### Camera and Input

**InputController.gd**

- Tap versus drag classification.
- Multitouch tracking.
- Pinch detection.
- UI touch exclusion.
- World interaction routing.

**CameraController.gd**

- Auto-framing.
- Pan.
- Pinch zoom.
- Camera boundaries.
- Recenter behavior.

### UI Systems

**UIManager.gd**

- HUD coordination.
- Modal stack.
- Notification queue.
- Navigation.
- Safe-area behavior.

**CardDraftUI.gd**

- Three-card selection.
- Rerolls.
- Draft confirmation.

**CodexUI.gd**

- Discovery collection.
- Hints.
- Details.

**ShopUI.gd**

- Product listing.
- Purchase state.
- Entitlement display.

### Services

**AdsManager.gd**

- Ad availability.
- Reward verification.
- Frequency rules.
- Consent handling.
- Fallbacks.

**PurchaseManager.gd**

- Product catalog.
- Purchase transactions.
- Entitlement persistence.
- Restore flows.

**AnalyticsManager.gd**

- Structured gameplay events.
- Monetization events.
- Funnel data.
- Error reporting integration.

## 42. Godot Scene Structure

Suggested project structure:

```text
res://
  scenes/
    main/
      Main.tscn
      MainMenu.tscn
    world/
      World.tscn
      BaseTile.tscn
      Structure.tscn
      EvolvedBiome.tscn
      CloudPlot.tscn
    ui/
      MainHUD.tscn
      CardDraftModal.tscn
      TileInspectPanel.tscn
      CodexScreen.tscn
      CraftScreen.tscn
      ShopScreen.tscn
      SettingsScreen.tscn
      DiscoveryReveal.tscn

  scripts/
    autoload/
      GameData.gd
      SaveManager.gd
      GameConfig.gd
    world/
      GridManager.gd
      BaseTile.gd
      BiomeDNA.gd
      ReactionEngine.gd
      FusionManager.gd
      StructureAutomation.gd
      WorldPulseManager.gd
      EventManager.gd
    input/
      InputController.gd
      CameraController.gd
    ui/
      UIManager.gd
      CardDraftUI.gd
      CodexUI.gd
    services/
      AdsManager.gd
      PurchaseManager.gd
      AnalyticsManager.gd

  data/
    tiles/
    recipes/
    cards/
    chapters/
    objectives/
    economy/

  assets/
    terrain/
    nodes/
    structures/
    biomes/
    ui/
    effects/
    audio/

  tests/
```

## 43. Data-Driven Definitions

Use Godot Resources or structured JSON with stable IDs for:

- Tile definitions.
- Card definitions.
- Fusion recipes.
- Environmental reactions.
- Quest definitions.
- Upgrade costs.
- Discovery rewards.
- Shop product mappings.

Do not make game balancing dependent on editing large gameplay scripts.

## 44. Input Handling

### Single Tap

Select or harvest a tile.

### Long Press

Display detailed tile inspection where appropriate.

### Single-Finger Drag

Pan the camera.

### Pinch

Zoom the camera.

### Modal Interaction

World input must be suppressed while a modal captures touch.

### Gesture Conflict Prevention

A pointer sequence must be classified by a central controller.

A tap becomes a drag only after crossing a configurable movement threshold.

When a second touch appears, the system transitions to pinch handling without triggering harvest.

## 45. Camera Requirements

- Starts framed around the four-cell island.
- Dynamically adjusts for world growth.
- Supports pan and pinch.
- Respects UI safe areas.
- Supports recenter.
- Supports photo-mode auto-framing.
- Prevents loss of the island outside navigable camera bounds.

Initial zoom range: approximately 0.5× to 2.0×, subject to real-device testing.

Do not assume the fixed starting zoom of 1.5× is correct on all devices.

## 46. Performance Requirements

Primary launch test targets:

- Stable 60 FPS on representative mid-range Android devices.
- Graceful degradation to 30 FPS on lower-end supported devices.
- No unbounded node creation.
- Limited simultaneously active particle systems.
- Environmental calculations outside per-frame loops when possible.
- Texture atlases and optimized imports.
- Minimal unnecessary draw calls.
- Efficient tile hit-testing.
- No noticeable pause during ordinary save operations.

The minimum supported Android version and memory budget must be determined through device testing.

---

# PART XIV — SAVE, OFFLINE, ANALYTICS & SAFETY

## 47. Save System

Persist:

- World seed.
- All tile/entity IDs.
- Grid coordinates.
- Environmental attributes.
- Resource cooldown state.
- Inventory.
- Currencies.
- Purchased expansions.
- Fusion entities.
- Structure production state.
- Discovery Codex.
- Objectives.
- Chapter progress.
- World Pulse energy.
- Event state.
- Settings.
- Cosmetic selections.
- Save schema version.

### Save Requirements

- Autosave on meaningful state changes using debounce.
- Save on app backgrounding.
- Validate loaded data.
- Keep backup save data.
- Support schema migrations.
- Prevent partial save corruption through atomic file replacement.
- Never regenerate purchased expansion contents after reloading.

## 48. Offline Behavior

Core gameplay must be playable offline.

The following can require connectivity:

- Ads.
- Purchases.
- Entitlement restoration.
- Analytics upload.
- Future online events.

If an advertisement is unavailable, the game remains functional.

If analytics cannot upload, the game must not crash or block progress.

## 49. Economy Integrity

- Use integer currency quantities.
- Centralize resource transactions.
- Guard against negative balances.
- Apply resource changes atomically.
- Assign unique IDs to important reward transactions.
- Deduplicate ad reward callbacks.
- Prevent duplicate purchases or repeated discovery rewards.
- Validate offline production calculations.
- Avoid trusting wall-clock time for unlimited rewards.

Local save files are not fully tamper-resistant. Do not design the business around perfect anti-cheat without a trusted backend.

## 50. Analytics

Required events:

**Onboarding**
- tutorial_started
- first_harvest
- first_expansion
- first_draft
- first_discovery
- first_fusion
- tutorial_completed

**Gameplay**
- session_started
- session_ended
- tile_placed
- biome_discovered
- fusion_completed
- quest_completed
- world_pulse_used
- chapter_completed

**Monetization**
- ad_opportunity
- ad_started
- ad_completed
- ad_reward_granted
- interstitial_shown
- store_opened
- purchase_started
- purchase_completed
- purchase_failed

**Technical**
- save_failed
- load_failed
- performance_warning
- crash

Analytics must respect applicable privacy and consent requirements.

## 51. Key Product Metrics

Track:

- D1, D7, D30 retention.
- Average session duration.
- Sessions per active user.
- Tutorial completion rate.
- First discovery rate.
- First fusion rate.
- Discovery progression.
- Ad engagement.
- Ads per daily active user.
- Ad revenue per daily active user.
- Purchase conversion.
- Average revenue per daily active user.
- Crash-free sessions.

Evaluate metrics by acquisition source, region, and device class where sample size permits.

---

# PART XV — RELEASE STRATEGY

## 52. Phase 1 — Core Vertical Slice

Implement:

- Four-cell island.
- Expansion to approximately 16 cells.
- Resource harvesting.
- Three-card drafting.
- Environmental attributes.
- Simple adjacency reactions.
- Five authored discoveries.
- One basic fusion.
- World Pulse with two powers.
- Basic HUD.
- Save/load.

**Goal:** Validate whether the core interaction is enjoyable.

No forced advertisements.

## 53. Phase 2 — Complete MVP

Implement:

- Expansion to 25–36 cells.
- Ten to twelve discoveries.
- All five DNA attributes.
- Three World Pulse powers.
- Primary quest progression.
- Three chapters.
- Codex.
- Two automation structures.
- Polished discovery animations.
- Sound and feedback.
- Tutorial.
- Basic analytics.
- Rewarded ads.
- Initial purchase integration.

**Goal:** Validate retention and monetization without overspending on content.

## 54. Phase 3 — Launch Candidate

Expand to:

- Approximately 20 discoveries.
- Five chapters.
- Dusk Tide.
- Additional automation.
- Cosmetic shop.
- Ad removal.
- Photo mode.
- Accessibility and performance polish.
- Localization-ready content.
- Crash reporting.
- Complete Play Store materials.

**Goal:** Publish a stable and polished Android game.

## 55. Post-Launch Roadmap

Potential updates:

- Additional biome families.
- New environmental powers.
- Premium adventure regions.
- Seasonal cosmetic themes.
- Seed sharing.
- New objectives.
- Rare discovery events.
- Additional evolved sanctuary types.
- Expanded island sizes.

No feature should require a major architectural rewrite if the data-driven model is implemented correctly.

---

# PART XVI — TESTING & ACCEPTANCE CRITERIA

## 56. Functional Acceptance

The game is not release-ready unless:

1. A new player can finish onboarding without external instructions.
2. Harvesting always grants the correct resource.
3. Expansions cannot overlap or be purchased twice.
4. Card drafts cannot create impossible mandatory progression.
5. Environmental reactions resolve deterministically.
6. Chain reactions terminate reliably.
7. All defined discoveries can be obtained legitimately.
8. Fusion preserves grid integrity.
9. Multi-cell entities respond as one logical entity.
10. World Pulse cannot spend charges on invalid targets.
11. Automation cannot duplicate resource transactions.
12. Loading a save restores the correct world.
13. Backgrounding during animations does not corrupt progress.
14. Ads cannot grant duplicate rewards.
15. Failed ads do not break gameplay.
16. Permanent purchases restore correctly.
17. Camera controls work on representative Android screen sizes.
18. UI remains readable with cutouts and safe areas.
19. No critical gameplay feature requires an internet connection.
20. Crash and performance testing meets release targets.

## 57. Player Validation Targets

Initial internal hypotheses:

| Metric | Desired Target |
|---|---:|
| Tutorial completion | ≥80% |
| First discovery completion | ≥70% |
| First-session median duration | ≥6 minutes |
| D1 retention | ≥30% |
| D7 retention | ≥8% |
| D30 retention | ≥2% |
| Rewarded-ad opt-in | Monitor, then optimize |
| Crash-free sessions | ≥99.5% |

These are product gates to test, not predicted outcomes or universal industry averages.

Use consistent cohort definitions and sufficiently large samples.

## 58. Go/No-Go Decisions

### Proceed With Additional Content If

- Most test players understand the game.
- Players independently experiment with combinations.
- Discovery is perceived as rewarding.
- Core sessions show repeat engagement.
- Retention improves over iterative builds.
- Monetization is not significantly harming engagement.

### Rework the Core Loop If

- Most players stop after the tutorial.
- Players only tap resources without exploring.
- Fusion feels repetitive.
- Environmental attributes are confusing.
- Objectives feel like chores.
- Ad opportunities are the main reason to continue.

### Delay Public Launch If

- Save corruption remains possible.
- Purchases are unreliable.
- Ads interrupt gameplay unexpectedly.
- Major touch-input issues remain.
- Performance is unstable on target devices.

---

# PART XVII — CREATIVE PRODUCTION & FINAL DECISIONS

## 59. Art Creation Pipeline

All game artwork should be produced against a consistent visual reference.

### Step 1: Art Bible

Create a visual specification covering:

- Perspective.
- Terrain proportions.
- Colors.
- Lighting direction.
- Object scale.
- Texture detail.
- Edge treatment.
- Shadow style.
- UI design language.

### Step 2: Reference Master Scene

Create one approved 2×2 floating island containing:

- Grass terrain.
- Oak tree.
- Boulder.
- Small shrub.
- Cloud background.

This scene becomes the reference for every generated asset.

### Step 3: Asset Creation

Produce sprite families in consistent batches.

Each asset should have:

- Unique name.
- Intended visual size.
- Transparent background where appropriate.
- Fixed orientation.
- Consistent light direction.
- Clean alpha edges.
- Appropriate pivot.

### Step 4: Review & Normalize

Inspect assets for:

- Perspective consistency.
- Color matching.
- Alignment.
- Sprite padding.
- Scale mismatch.
- Shadow consistency.
- Unwanted AI artifacts.

### Step 5: Import & Atlas

Prepare optimized atlas textures.

Keep source files separate from runtime-export assets.

### Step 6: Test in Game

Verify appearance under actual zoom levels, lighting states, and neighboring tile arrangements.

No asset is accepted solely because it looks attractive in isolation.

## 60. Final Design Decisions

**Game Identity:** Living-world environmental discovery.

**Primary Hook:** Every decision changes how the island evolves.

**Primary Progression:** Discover new biome forms and master spatial environmental interactions.

**Primary Visual Payoff:** Spectacular miniature biome transformations.

**Primary Retention System:** Objectives, secrets, mastery, and collection progression.

**Primary Monetization:** Rewarded ads with permanent optional cosmetic purchases.

**Core Engine:** Godot 4.

**Networking:** Not required for launch gameplay.

**Art Direction:** Premium stylized 2.5D miniature dioramas.

**UI Direction:** Clean fantasy explorer interface with modern mobile interaction patterns.

**Release Strategy:** Android MVP, validated before large-scale content production.

---

# FINAL PRODUCT DEFINITION

**Pocket Biome: Tiny Expansion is a portrait-first miniature world-evolution game where players create and transform floating ecosystems through resource management, strategic tile placement, environmental powers, and secret discoveries.**

The game is designed around satisfying short sessions, long-term discovery, visible world evolution, and optional monetization that preserves player enjoyment.

The product should succeed first as an enjoyable game.

Player retention, organic sharing, and monetization follow from delivering and continuously improving that experience.

**End of Master PRD v4.0.**