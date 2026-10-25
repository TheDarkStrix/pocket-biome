# Current design direction — 0.14 world-first revision

The user rejected 0.13: gray background, large clunky HUD blocks, and an appearance closer to a complex dashboard than a game. This revision supersedes the earlier persistent-panel layout. It is implemented and under review; it is not claimed to be an approved final design.

The island is the main scene. An original sky shader supplies a luminous gradient, soft distant clouds, cloud banks and slow controlled drift; dusk/night variants preserve the existing theme choices. It uses a generated256px noise texture, three texture samples and a few analytic soft cloud shapes rather than a full-screen blur. Actual phone GPU performance remains to be measured. Reduced motion freezes the animation clock.

The HUD consists of a small resource row, a chapter prompt with readable progress, a compact goal shortcut and a leaf-shaped conditions-help action. Permanent temperature/moisture charts, the large selected-biome panel, land-capacity capsule and enclosing bottom tray are removed from gameplay. These details remain in the existing inspector, World and power screens.

Five small floating icon controls provide Journal, Build, Pulse, World and Menu. Their visible discs are smaller than their touch areas. Pulse energy is conveyed by its ring; the exact amount and cost remain in the real power picker. Saved cards, cancellation and fusion shortcuts appear only when relevant and use a compact action.

Touching land briefly reveals an inspect callout next to the tile. It expires after five seconds and does not resize the camera area or occupy the footer. Hold-to-inspect remains available. Game state, economy, saved offers and provider configuration are unchanged.

Neutral typography, original terrain/resource art and original navigation/leaf/camera icons remain in use. Daylight labels use dark ink; dusk/night labels become light. The existing supplied art sheet still guides terrain proportions. Terra Nil and the reviewed Play Store builders inform world-first composition, without copying their assets or requiring their palette.

Mobile tests require at least55% of portrait height for the world at all tested sizes/text scales, readable high counts and goal progress, comfortable targets, working transient callouts and access to real detail screens. Rendered fixtures document the direction; human creative approval remains open.
