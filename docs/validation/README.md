**Validation reproduction**

The final source-bound report is [Director validation](../DIRECTOR_VALIDATION.json). Earlier full-run reports are retained here to substantiate the three development/audit passes. Scores are developer judgments, not player ratings.

- `./tools/check.sh` runs the automated suites, four campaign probes and startup using the configured Godot runtime.
- Copy `opening-touch.gd.txt` to a `.gd` path outside the project, then run it with `POCKET_VISUAL_TIMEOUT=100 ./tools/visual_review.sh /absolute/path/opening.gd`. It drives actual screen-touch events and the live game clock through the first restoration. It writes only an isolated test save and review artifacts.
- `rendered-fixtures.gd.txt` constructs explicit review states for screen/layout inspection. It is deliberately different from an earned playthrough.
- `logic-profile.gd.txt` measures cached desktop/headless scene refresh. It cannot qualify phone performance.

The graphical helpers need the documented Xorg/Mesa cloud environment. Physical Android, live publisher/provider behavior and unfamiliar-person observation require those actual resources. The shipped APK excludes QA tools and reports.


Living River evidence is in `../CORRIDOR_VALIDATION.json`. The `river-*.gd.txt` files are reproducible external scene harnesses, stored as text so APKs exclude them. Copy a harness to `/workspace/runtime/river-review/` with a `.gd` extension, create that directory first, then run it using `POCKET_VISUAL_TIMEOUT=110 ./tools/visual_review.sh /workspace/runtime/river-review/<name>.gd`. They write their captures/reports there. `river-opening.gd.txt` writes to `/workspace/runtime/director-review/`; create that directory before running. Rendered fixture routes are distinguished from the fresh-start ordinary-clock walkthrough and simulated complete campaigns.

Player-journey evidence is in `../JOURNEY_VALIDATION.json`. Copy `journey-touch.gd.txt` or `journey-profile.gd.txt` to `/workspace/runtime/journey-review/` with a `.gd` extension after creating that directory. Use `POCKET_VISUAL_TIMEOUT=150 ./tools/visual_review.sh /workspace/runtime/journey-review/<name>.gd` for the rendered walkthrough. The opening harness writes to `/workspace/runtime/director-review/`. These constructed-fixture captures and ordinary-clock opening runs remain distinct from full campaign simulations and physical-device qualification.
