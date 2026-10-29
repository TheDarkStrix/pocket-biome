# Pocket Biome 0.17.0 Android preview

[Download the updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android 7.0+ (API24). Signed development preview. Install over the existing game to retain your island; do not uninstall.

## Reference setting, lettering and HUD correction

The0.16 draft changed cards but retained a flat sky, loose counters and a different interface. This update carries the selected concept's surrounding composition into actual game presentation:

- Independent painted cloud-realm background with distant wooded islands, mist, foreground foliage, gentle controlled drift and day/dusk/night grading.
- Illustrated Pocket Biome title logo and green framed main action.
- Named Wood/Stone/Coins resource rail, journal-object goal plaque and a top-right gear that opens actual Settings.
- Cinzel display lettering, readable Lato body text and cream/shadow contrast.
- Larger live island behind the draft, framed live Coin price, three actual illustrated offers and a narrower green Place action.
- Correct frame border density on badges and tall panels; shared slate/bronze menu surfaces and painted tools.
- Full material stock remains in Workshop/trading; Tile conditions remains connected through Settings and tile inspection. Gameplay transactions, saves, prices, rewards and provider test IDs are unchanged.

The background/logo/frame/tools are independent runtime assets. No complete concept image or Play Store screen is used as a flattened game interface. Text, controls and the playable world are live.

Remaining differences are explicit: Build retains the existing categorized catalogue/project slots rather than the lower placement tray; the dock still exposes five routes; existing terrain spacing and soil depth differ from the concept. This is not completed whole-game polish or a production release. See docs/design/REFERENCE_COMPARISON.md on main.

Source: fba2e41 on main. Source digest:86b2f563cad2a1316f9c9dce68e20e338db9a39fe680c054e9979e1000b1157c. 927 Godot assertions across16 suites, eight Python audit cases, startup and both complete public-action progression routes pass. Coverage includes named resource containment at three phone sizes/two text scales, actual gear-to-Settings-to-condition-help touch routing, and retained draft transaction/save checks. Actual rendered fixtures43–50 are constructed presentation states, not human creative approval.

APK SHA256:3fe53b5df18a258ec076b148e1b4a1992b52f7da33fa287c1a8a3b314f1d61a0. Size:100,289,639 bytes. Signature,435 retained files, ARM64 packaging,16KB ZIP/ELF alignment and embedded source/test binding pass. Current native observations are separately scoped in main's TEST_REPORT.md and artifacts.

Physical-device performance, real Google provider transactions and human creative acceptance remain unqualified. Development signing, preview/service/test IDs, publisher configuration and current release evidence remain gates. Camera quarter turns remain; continuous3D orbit and some authored structure motion remain unfinished. No store publication or production-credential substitution was performed.
