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
