# Draft-title alignment — 0.21.7

“Choose your next biome” was centered inside the space remaining beside the Close button. Because that button occupied only the right side, the title was visibly left of the three-card hand's center.

The draft header now reserves equal space on both sides, keeping Close as its own touch target. The title centers over the full hand and wraps centrally when larger text needs two lines. The painted island preview fits above the header using its current ready/harvested artwork, so it does not obscure the title. Other sheet headings retain their existing alignment.

Six layout cases cover 320×640, 360×780 and 540×960 at 100% and 120% text. The geometric heading-center error is zero logical pixels in every rendered case. The close target fits without overlapping the title. Twelve real screen-touch actions close and resume the sheet while preserving the exact saved cards, destination, quote and balance. This is a deliberately prepared draft fixture, not a full fresh-game playthrough or physical-phone test.

[Normal small screen](validation/draft-title-320-100.png) · [120% text](validation/draft-title-320-120.png) · [540×960](validation/draft-title-540-100.png) · [Exact validation](DRAFT_TITLE_VALIDATION.json) · [Rendered input harness](validation/draft-title-capture.gd.txt).

The complete packaged source passes **2,174 assertions in 46 Godot suites**, 22 Python tests, four campaign probes and startup. The previous tutorial, river and art fixes remain included. Version code increases 20 → 21 with the recent download's package and signing certificate. Signature/alignment/content checks establish package compatibility; actual phone installation and newcomer acceptance remain unverified. This focused layout fix does not close the broader [request-review backlog](USER_REQUEST_REVIEW.md).
