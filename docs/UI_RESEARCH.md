# Current application — 0.14 feedback correction

The user explicitly rejected the gray background and large persistent cards in 0.13 as dashboard-like. Enlarging or rounding those modules did not address the requested world-first experience. The current revision removes the panel hierarchy from gameplay: resources and a small goal prompt sit directly over an atmospheric sky, detailed statistics are contextual, and five small floating icons replace the enclosing dock. Visible control size is reduced while touch areas are retained. World hub actions no longer each have a heavy bordered card.

The reviewed SimCity BuildIt screenshots show small independent controls over the world, and Pocket City2 groups tools away from the main landscape. Those observations now inform how much interface is visible, rather than just the arrangement of large boxes. The source evidence and its promotional-image limitations below remain unchanged; no new downloads/retention claim is made. See DESIGN_DIRECTION.md for the current implementation and review status.

---

# 0.13 mobile HUD redesign — current reference review

2026-10-25: public Google Play listings and publisher screenshots were fetched successfully. This supersedes the earlier access failures below. Exact screenshot URLs and displayed download bands are recorded in artifacts/mobile-ui-references.json. Reference images are research only, stored outside shipping assets.

| Source actually reviewed | Evidence and observations | Applied to Pocket Biome |
|---|---|---|
| [SimCity BuildIt](https://play.google.com/store/apps/details?id=com.ea.game.simcitymobile_row) | Listing displays 100M+ downloads; screenshots0/2 show actual HUD, level badge, compact currency pills, independent tool icons and a prominent construction control | Separate currency/material displays, chapter identity, icon-led dock and clear primary construction action |
| [Pocket City 2](https://play.google.com/store/apps/details?id=com.codebrewgames.pocketcity2) | Listing displays 500K+; screenshot0 shows level badge, top resource groups, lower tool group and large Build action | Give Build its own warm accent; group secondary navigation; avoid four equally weighted boxed text buttons |
| [Township](https://play.google.com/store/apps/details?id=com.playrix.township) | Listing displays 500M+; reviewed images1/3 are promotional compositions with icon currency and contextual action examples | Recognizable illustrated material and selection content; no claim these promotions are unmodified current HUD captures |
| [Pocket City](https://play.google.com/store/apps/details?id=com.codebrewgames.pocketcitygame) / [Pocket Build](https://play.google.com/store/apps/details?id=moonbear.PocketBuild) | Listings display 1M+/5M+ respectively. Reviewed Pocket City image3 and Pocket Build image1 are promotional; Pocket Build shows a compact resource strip and construction icon | Support the world-first approach; do not infer their complete menus from promotional images |

These are displayed install bands, not independently measured active users, revenue, retention or proof of what will work for this game. No third-party art, branding, code or palette is copied. Terra Nil remains the restraint/landscape reference, with independent colors and portrait composition.

## Implemented presentation

Rounded floating currency capsules; a readable separate material row; a chapter quest card with a real next-step action; selected-biome illustration/name/production state and cooldown progress; original World Pulse emblem with an energy ring and exact amount; circular tool medallions with an amber Build emphasis; an illustrated World action grid; softer modal chrome and stronger scrim. Gold is a functional emphasis, not a return to the rejected ornate/parchment style. The numerical game state and save schema are unchanged.

Visual review caught large-text currency wrapping in the first candidate. Currency/materials now span the header, with only the quest sharing space with conditions beneath them. Optional footer actions reserve their width before shaping; changing minimum sizes triggers relayout so camera/input bounds follow the actual HUD. Native review also exposed clipped quest progress; the count now has its own visible line beneath the complete instruction.

Actual OpenGL captures27–29 document the result, including a small-screen/120% text/high-count fixture. These are constructed presentation states, not earned progression or human approval. Physical Android validation remains separately scoped.

---

# Current application — hierarchy with an independent palette

The user explicitly says not to use Terra Nil's colors. Pocket Biome applies the reference's three screen zones using its own graphite/pearl/muted-violet palette: actual chapter/resource data upper-left, local ecology upper-right, contextual controls/tool dock below. Earlier palette interpretations in this research history are superseded by DESIGN_DIRECTION.md. No reference-game branding or assets ship in Pocket Biome.

---

# Latest implementation clarification

Terra Nil is a reference for information hierarchy and functional screen zones, not a color specification. The user explicitly clarified this. Pocket Biome now uses graphite/pearl/muted-violet styling, a real chapter dial and resource ledger upper-left, local DNA meters upper-right, and contextual controls/tool dock below. The original corner grouping adapts the reference to portrait mobile; no reference colors, branding or artwork are copied as a palette/theme.

---

# Primary reference update — Terra Nil

The user rejected the parchment interface as too childish and explicitly requested Terra Nil. This section supersedes the earlier interpretation below.

**Actually reviewed:** [Terra Nil official Steam page](https://store.steampowered.com/app/1593030/Terra_Nil/) and three official Steam screenshots downloaded via its Akamai CDN. The page identifies Terra Nil; two reviewed screenshots include the actual in-game HUD/tool strip and ecological meters, while one shows terrain/structures without HUD. Reference images are retained outside shipping assets under /workspace/runtime/research/terra_nil_official_*.jpg.

Observed patterns: dark flat modules with thin cool borders; off-white compact data; an orange/rust selected-action state; illustrated construction thumbnails in a narrow strip; readable environmental meters at the screen edge; and landscape occupying most of the composition. The visual weight belongs to restoration/terrain, rather than ornamental menus.

Implemented interpretation: charcoal/pine panels, fine borders, minimal corners and no shadows; neutral licensed Inter-derived typography; an unoutlined light wordmark; original line icons for control chrome; rust used only for primary/active actions; quieter backdrop with no decorative bubbles; and the existing compact functional HUD/dock/context hierarchy. Portrait targets remain at least48dp where applicable. No Terra Nil assets or branding are copied.

Access update: Terra Nil's Steam page and official CDN are now readable. Earlier EA/Google Play/Pocket City attempts were blocked, so their current listing metrics remain unverified. Steam's page being accessible does not establish access to every developer site.

---

# Builder UI research and application

Research date: 2026-10-25. The user requests inspiration from established builders, specifically SimCity, while retaining Pocket Biome's environmental discovery twist.

## Material actually reviewed

1. **SimCity BuildIt — archived gameplay and production screens.** Community documentation: https://github.com/julianperrott/SimCityBuildItBot . Viewed the actual game images at `post/img/simcity_screenshot.jpg` and `post/img/simcity_raw_materials.jpg` in that repository. These are older screenshots, not a claim about the current release. The community tool code was not installed or executed.
   - Global currencies stay at screen edges while the city remains visible.
   - Selected production facilities expose illustrated item choices and a short queue.
   - Ingredient panels show owned/required quantities with a clear shortage color.
   - Apply: compact resource ledger, contextual inspector, illustrated crafting, distinct production state. Do not import its timers, economy, branding or artwork.
2. **Dorfromantik — gameplay board screenshot.** https://github.com/nikghub/dorftipster/blob/main/img/game_example.png . Viewed the game image, not just the helper's interface. The helper code was not run.
   - The landscape occupies nearly the entire screen, with sparse corner controls and a visible next-tile stack.
   - Apply: remove persistent explanatory text/extra power buttons from the island, keep the board readable, and make drafting/targeting contextual. Pocket Biome retains its square grid, DNA and fusion rules.

Only these reviewed images support the visual observations above. Third-party images remain outside shipping assets. Our UI, terrain, icons and typography are original/generated or openly licensed as documented in ART_ASSET_MANIFEST.md.

## Official source access and popularity evidence

Attempted Google Play listings, EA's SimCity BuildIt page, Pocket City's developer site and Steam pages. The environment returned proxy 403 responses. Required domains were saved in the cloud configuration draft; this does not activate runtime access. Current store screenshots, download counts and reviews remain unverified. We do not infer commercial success from GitHub star counts or helper projects.

## Possible matches for the remembered game

Pocket City / Pocket City 2, Pocket Build, Pocket Land and Land Builder are investigation candidates, not an identification. Their names and common genre associations alone do not establish a 2×2 rule or match the user's memory. Current official source comparison remains pending access. SimCity BuildIt and Dorfromantik are the two concrete visual references reviewed in this pass.

## Implemented interpretation

Parchment/brass/ink styling and licensed Nunito/Fredoka typography; compact resource header; four illustrated dock actions; a single Pulse selector; selected-biome context; transient notices; modal scrim and close affordance; live island title hero and clear Play/Continue hierarchy. Mobile text, touch routing and save restoration remain acceptance checks rather than assumed outcomes.

## 0.15 modal feedback

The user rejected the modal interiors as text/button lists with icons. The new sheets use original illustrated item-card/catalogue layouts and existing game artwork, real island miniatures and power/fusion schematics. These are not claimed as faithful reproductions of Pocket City2 or SimCity BuildIt. Actual screenshots33–39 and scoped interaction evidence document the implementation; subjective approval remains open.
