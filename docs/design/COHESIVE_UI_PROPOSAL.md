# Cohesive interface proposal — design stage

Update0.16: the user selected the final Draft panel. Its three-card selection/confirmation flow, generated frame/button materials, serif labels and visible-world layout are now implemented and covered by rendered fixtures40–42. The rest of this board remains a proposal. The historical description below describes the original design-only checkpoint and must not be read as claiming all four screens ship.

The user rejects the current interface as a data sheet and explicitly asks to return to their Pocket Biome logo/asset-sheet reference. The current 0.15 APK is unchanged. The generated four-screen board is a visual proposal, not an implemented build, production asset pack, tested layout, approved design or screenshot of gameplay. It is deliberately labelled that way.

## Basis actually reviewed

The supplied docs/references/user_art_direction.jpg contains the material vocabulary we previously failed to carry into the interface: sculpted wood/stone/leaf branding, dark inset metal surfaces, narrow warm edges, painted physical resource objects, a compact hub rail, backpack/hammer/settings tool silhouettes and an illustrated recipe frame. The new board uses these as its primary identity reference.

Current public Google Play listings and publisher screenshots were fetched and visually reviewed:

- SimCity BuildIt: https://play.google.com/store/apps/details?id=com.ea.game.simcitymobile_row — screenshot0 shows compact edge currencies, independent illustrated tools and construction access over a largely unobstructed world.
- Pocket City 2: https://play.google.com/store/apps/details?id=com.codebrewgames.pocketcity2 — screenshot0 shows grouped utility tools and a clearly emphasized Build control; it is landscape, so a portrait adaptation is a design decision, not a reproduction.
- My Little Universe: https://play.google.com/store/apps/details?id=com.savetheworld.game — screenshots0/1 show grouped inventory, recognizable pack/action objects, and construction costs located at the relevant world location. Its character-driven 3D movement and low-poly art are not being proposed for Pocket Biome.

Exact screenshot URLs/access limitations are in playstore-review.json. The proposed board is original, inspired by the user's supplied sheet. It is not claimed to match any reference game's entire UI. A candidate Pocket Land URL returned404 and provides no evidence.

## One visual system across the game

World: the diorama is the main subject; atmospheric depth and distant land create a setting. Any backdrop must preserve contrast with expansion clouds and node silhouettes. The actual game's 2:1 ground geometry, anchors and four-view camera remain technical constraints, regardless of a concept illustration's perspective.

Identity: title/logo and controls share the sheet's wood, mineral and leaf materials. Prefer narrow shaped rims, restrained wear and tactile objects. Avoid decorative foliage on every edge and excessive gold trim. The generated board is somewhat more ornate than the target; treat it as a direction rather than a pixel-perfect specification.

HUD: one compact named resource rail replaces loose floating numbers. No standalone temperature/DNA panel. A quest-book object opens objectives/Codex; a gear opens settings. Pack, Build and Pulse are the primary physical tool controls. Small visible tool art still requires48dp hit targets, separation and safe-area handling.

Title: branded diorama scene and one Continue/Play action; settings/audio secondary. It should belong to the same world as gameplay, rather than use a separate app-menu skin.

Build: contextual lower workbench tray while the island remains visible for placement. Land/Structures/Craft tabs and a horizontally browsable shelf expose the actual catalogue. Select an object, see owned/required ingredient objects and one explicit build/craft action. Actual queues and completed blueprints have a separate shelf within the same tray, not18 always-expanded recipe cards.

Draft: one hand of three illustrated terrain cards, one selected card and one explicit confirmation. Costs are named; moving/reopening retains the saved offers/quote. Detailed conditions are available through a secondary info action rather than repeated paragraphs and five bars on every card.

Pack: all seven material types, Coins, exact counts, trading and finished blueprints remain accessible. The board shows only three example rail resources; Fiber/Clay/Iron/Brick/Dew must not be removed. A contextual required material can join the rail during a project, with stable ordering. No fake plus/purchase control is added merely because the reference sheet has one.

Pulse: the rain-totem tool opens three illustrated abilities and exact energy; selecting previews the existing five-cell reach on the actual island. The controller still requires confirmation and cancellation spends nothing.

Codex/objectives: field-journal object with discovery artwork/silhouettes, page/category navigation and concise actionable clues. All existing discoveries, chapters and free hints remain. Fusion presents four matching input plots and a sanctuary result; tile inspection is a local action.

Settings/privacy/store: reachable utility surfaces with the same materials and clear controls; legal/consent text stays complete. Test-provider disclosures and actual localized purchase prices remain explicit. No production configuration or monetization behavior changes in this design stage.

## Implementation sequence and acceptance

1. Establish reusable frame/icon/rail assets and an isolated gameplay/title presentation. Preserve the working0.15 interaction/economy/save layer.
2. Implement one complete gameplay-to-Build-to-placement flow and one draft/confirm flow. Compare actual rendered screens with the board; do not count an image-generation result as implemented artwork or UI.
3. Apply the same navigation/material rules to Pack, Pulse, Journal, fusion, settings and optional services without removing functionality.
4. Verify real touch swipes/targets, large text and safe areas; retained quotes/recipes and exact transactions; native save restoration; shader/atlas/device performance. Then produce a new APK.

Asset preparation is still required: independent logo components, transparent tool sprites, normal/pressed/disabled states, scalable frame corners/edges and catalogue selection pieces. Do not slice and stretch this presentation-board PNG into the game as final assets. The board's illustrative values, tiles and recipes are not authoritative balancing data. Human visual acceptance remains open; no permission question is required to make the proposal reviewable.
