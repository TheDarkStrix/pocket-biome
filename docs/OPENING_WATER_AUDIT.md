# Opening Water recovery — 0.21.3 preview

The first draft guaranteed Water, but a player could place that pond beyond the starting Meadow. The tutorial still asked for Water next to the Oak while subsequent random hands could omit it. Reopening or moving a saved draft kept that missing-Water hand, so the stated next action could not be followed.

While the first-discovery guidance needs Water, the model guarantees one Water card in the pending hand. A valid old missing-Water save is repaired when its draft opens or moves; repair replaces only the middle offer, preserves the foundation/other offer, destination, saved price/revision, wallet and existing pond, and does not consume a rewarded redraw. Repeated repair is idempotent. Normal choices resume after discovery or guidance dismissal. Late genuine rewarded-redraw callbacks retain required Water.

The correct empty edge-sharing Oak plots have gold outlines and Water markers. The hand selects Water, explains whether it will reach the Oak and offers a free “Show Water plots beside the Oak” route when the destination is remote. Opening recovery has no ad-redraw button. **Repair is free; placing a new plot still charges the normal saved quote.** No discovery, reward or learning completion is fabricated. If the Oak has no empty adjacent plot, guidance offers Rain rather than another impossible cloud instruction.

## Verification

Twenty-three focused assertions include 64 seeded openings, missing-Water save/load repair, unchanged wallet/quote/other offers, no ad/redraw consumption, idempotence, hand relocation, late callbacks, normal post-discovery/skipped-guidance choices, surrounded-Oak guidance, real card controls and ordinary simulated discovery.

The final unchanged source passes 2,035 assertions in 43 Godot suites, 22 Python checks, startup and four automated campaign routes. Android export, package/source binding, signature, 16 KB alignment and all 659 retained ARM64-package files pass. Version code increases 16 → 17 with the same signer/package as the preceding download; this is static update compatibility, not an observed phone installation.

The graphical recovery uses seven actual screen-touch actions across normal portrait and 320×640/120%-text fixtures. It opens an old saved hand, verifies visible Water and a remote-placement warning, shows valid plots, confirms neighbor Water for the exact quote, retains the first pond, sees the objective advance immediately and reaches a discovery through the ordinary running clock. The small-screen sequence also confirms actual placement. The first small-window attempt exposed a harness coordinate error: injected events used logical coordinates under canvas stretch. The retained harness converts them to physical window pixels and the final replay passes. This required no additional game change.

[Exact source-bound reports](OPENING_WATER_VALIDATION.json) · [retained rendered touch harness](validation/opening-water-visual.gd.txt)

Inspected captures: [highlighted plots](validation/opening-water-highlighted-plots.png), [repaired remote hand](validation/opening-water-remote-saved-hand.png), [correct Water choice](validation/opening-water-correct-water-hand.png), [objective advanced](validation/opening-water-water-placed.png), [small-screen confirmation](validation/opening-water-small-screen-confirm.png).

The fixture constructs a valid pre-fix missing-Water hand; its initial island/Coins come from ordinary model actions. The resulting touch sequence is not a physical-phone or unfamiliar-player study. Those acceptance tasks and production provider/store configuration remain open. Test advertising remains selected.
