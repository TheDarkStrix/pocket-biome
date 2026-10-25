# Current design direction

The user requests Terra Nil's style and gameplay HUD hierarchy, **not its colors**. This supersedes the earlier fixed navy/green, parchment/brass, and navy/rust interpretations. Existing isometric land strengths and working gameplay remain intact.

## Pocket Biome's visual system

Graphite surfaces and pearl text provide the base; warm amber emphasizes Build/objectives and violet identifies World Pulse. Neutral licensed typography, rounded floating capsules, subtle depth and circular tool medallions provide a mature mobile-game interface. This supersedes the previous uniformly flat, thin-bordered boxes. Original line icons handle control chrome; illustrated terrain, materials and construction outputs retain their visual role.

## Gameplay screen hierarchy

- Top: real chapter-progress dial and separate currency/land capsules, with a material row. Beneath, a compact quest card shares space with the selected-tile conditions module. Compact counts are a display convenience; exact values remain in model state and Workshop.
- Upper-right: selected-tile Moisture/Heat readings under “Tile conditions”, with a tap-to-learn explanation. All five DNA attributes and detailed influences are available in the inspector.
- Bottom: illustrated selected-biome context with readiness/cooldown progress, a World Pulse medallion showing actual energy, and a circular tool dock with Build emphasized. Detailed crafting, discovery, world and settings controls stay contextual.
- The landscape owns the central space. Gameplay framing occurs after HUD layout settles; title-preview framing is independent of gameplay pan. Photo mode hides gameplay markers and restores the prior camera on exit.
- Portrait targets, text scaling and safe areas remain functional requirements, even where visual framing is minimal.

## Reference use

Official Terra Nil screenshots were actually reviewed for grouping, data hierarchy and terrain-first composition; its palette, artwork, branding and mechanics are not copied. See UI_RESEARCH.md. The supplied references/user_art_direction.jpg remains useful for isometric proportions, natural materials and silhouettes, not as a fixed UI skin or economy specification.

Camera interaction:drag, pinch and two-finger quarter turns; World supplies explicit rotation buttons. The four-view renderer keeps painted artwork upright. Continuous free-angle orbit requires the separate3D asset/presentation phase documented in CAMERA_ORBIT_PLAN.md.
