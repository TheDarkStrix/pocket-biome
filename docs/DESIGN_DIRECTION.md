# Current design direction — 0.14 world-first revision

Superseded as the final whole-game target by docs/design/COHESIVE_UI_PROPOSAL.md. The user selected its final Draft panel;0.16 implements that hand using independent slate/bronze and green-button assets. The remaining title, HUD and menu work is still pending. The description below records the existing0.14 gameplay presentation retained during this phased migration; it is not a claim of current user approval.

The user rejected 0.13: gray background, large clunky HUD blocks, and an appearance closer to a complex dashboard than a game. This revision supersedes the earlier persistent-panel layout. It is implemented and under review; it is not claimed to be an approved final design.

The island is the main scene. An original sky shader supplies a luminous gradient, soft distant clouds, cloud banks and slow controlled drift; dusk/night variants preserve the existing theme choices. It uses a generated256px noise texture, three texture samples and a few analytic soft cloud shapes rather than a full-screen blur. Actual phone GPU performance remains to be measured. Reduced motion freezes the animation clock.

The HUD consists of a small resource row, a chapter prompt with readable progress, a compact goal shortcut and a leaf-shaped conditions-help action. Permanent temperature/moisture charts, the large selected-biome panel, land-capacity capsule and enclosing bottom tray are removed from gameplay. These details remain in the existing inspector, World and power screens.

Five small floating icon controls provide Journal, Build, Pulse, World and Menu. Their visible discs are smaller than their touch areas. Pulse energy is conveyed by its ring; the exact amount and cost remain in the real power picker. Saved cards, cancellation and fusion shortcuts appear only when relevant and use a compact action.

Touching land briefly reveals an inspect callout next to the tile. It expires after five seconds and does not resize the camera area or occupy the footer. Hold-to-inspect remains available. Game state, economy, saved offers and provider configuration are unchanged.

Neutral typography, original terrain/resource art and original navigation/leaf/camera icons remain in use. Daylight labels use dark ink; dusk/night labels become light. The existing supplied art sheet still guides terrain proportions. Terra Nil and the reviewed Play Store builders inform world-first composition, without copying their assets or requiring their palette.

Mobile tests require at least55% of portrait height for the world at all tested sizes/text scales, readable high counts and goal progress, comfortable targets, working transient callouts and access to real detail screens. Rendered fixtures document the direction; human creative approval remains open.

## 0.15 illustrated gameplay sheets

The user rejected the modal interiors as gray text/button lists with added icons. Gameplay sheets now use an independent mineral-ivory/teal palette, large atlas illustrations and purpose-specific composition. This is an original revision under review; it is not presented as a faithful copy of another game's UI or human-approved final art.

Drafts are a three-card horizontal carousel with touch scrolling and arrow alternatives. Each card has substantial terrain art and a real inspect action; confirmation retains the stored quote. Workshop is a categorized two-column catalogue with ingredient counts, a real three-slot crafting shelf, actual countdowns and finished-blueprint placement. World actions show the selected biome, the current island miniature and a sanctuary illustration. Pulse cards show the actual five-cell cross shape and illustrative rain/heat/frost effects before real targeting begins.

Codex silhouettes, item detail stages, fusion input/result diagrams, illustrated learning/help and reward cards replace the repeated paragraph-list format. Settings use bound switch indicators with independent volume/text controls. Legal/privacy text remains readable and complete. Short sheets fit their content; long ones scroll within safe bounds. This changes presentation and discoverability, not rewards, costs, saves or provider configuration.

0.17 implements the corrected surrounding composition: painted sky realm, title logo, named material rail, journal/gear header, Cinzel/Lato text and shared slate/bronze surfaces. See docs/design/REFERENCE_COMPARISON.md for the explicit before/after and remaining differences; the old flat-sky and ivory-sheet descriptions above are historical.
