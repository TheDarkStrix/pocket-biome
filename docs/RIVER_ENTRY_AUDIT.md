# Living River entry — 0.21.5

The previous tests covered routes on prepared islands and did not prove the first-restoration entry worked with saved land cards. River mutations rejected a pending hand, but their error message was hidden behind the modal. Choosing an approach also gave no direct spring selection, and the small opening island had no eligible remote grove. These gaps explain the reported apparently inactive controls.

The river now keeps saved land cards, their destination and quote while planning, saving flow and observing seasons. An approach opens blue Water selection; confirming a spring opens grove selection. The selected source stays marked. Reachable trees are highlighted, and tapping one previews its actual connected natural-land path. Drawn routes remain available. Stone and machinery still block channels. Invalid selections and persistence failures have visible feedback; compound edits roll back entirely.

When no distant tree can receive Water, setup explains the requirement and offers actual construction or the Forest in the player's saved hand. It selects the real card at its ordinary quoted price. It does not award terrain or complete the puzzle. New route confirmation states its default available flow; saving commits route and allocation together. Existing allocations, including deliberate pauses, remain unchanged when rerouting. The channel has a wider bank, visible Water and moving droplets; a disconnected or dry channel shows its dry bed. Planning hides unusable cloud buttons, reserves room for its controls and prevents toast overlap.

## Verification

The unchanged packaged source passes **2,102 assertions in 45 Godot suites**, 22 Python tests, startup and four campaign probes. The new entry suite covers the actual approach/source controls, missing-grove recovery, real saved-card selection, route preview without mutation, disclosed default flow, deliberate zero allocation, saved-hand persistence and atomic failure recovery. The existing Living River model suite continues to cover both approaches and later restoration stages.

Two rendered OpenGL touch runs start from new saves and earn the opening through normal harvesting, gathering, crafting and discovery timers. They claim the first habitat, retain a real land hand, choose the wetland approach and spring, encounter the missing-grove screen, buy its actual offered Forest, retain another hand, preview and save a channel with two flow, and observe the grove to maturity. No stock, completed habitats or river state is injected. The desktop uses 540×960; the small-screen fixture uses 320×640 with its corresponding display scale. These scripts use actual screen-touch events and modal scrolling, not just button signals. The runs validate the resulting save and unchanged pending hand.

[Exact reports and package identity](RIVER_ENTRY_VALIDATION.json) · [reproducible fresh-save walkthrough](validation/river-entry-fresh.gd.txt)

[Follow-up: exact lesson-screen button reproduction, published APK text and fresh touch runs](RIVER_LESSON_BUTTON_AUDIT.md).

[Blue spring selection](validation/river-entry-mobile-choose-spring.png) · [Actual missing-grove recovery](validation/river-entry-mobile-needs-grove.png) · [Channel preview](validation/river-entry-mobile-visible-channel-preview.png) · [Visible saved river](validation/river-entry-mobile-flowing-river.png) · [Desktop river](validation/river-entry-desktop-flowing-river.png)

These captures are unedited game renders. The fresh walkthrough reaches grove maturity, not the full flowering-corner finale. Later stages are covered by the separate model and control suites. No physical Android phone is attached: installation, actual touch hardware, performance, native provider behavior and unfamiliar-player comprehension/enjoyment remain unqualified. Package/signature/version compatibility is checked against the previous downloadable APK; this is not evidence of a physical installation. Google test ad IDs remain selected.
