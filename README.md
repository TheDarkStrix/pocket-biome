# Pocket Biome — 0.21.4 painted-land joins

[Download the current APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

Android 7.0+ / ARM64. About 98 MiB. Development preview with Google test ad IDs.

## Fixed: neighboring blocks looking separate

The previous patch corrected harvested artwork height but left sprite gutters in the grid spacing and painted cliff faces between occupied tiles. The renderer now fits the visible cap spacing, hides only internal soil walls and blends narrow shared edges using the existing grass painting. Outer earth edges and original terrain/structure art are retained. The old replacement floor/cliffs and procedural 3D view remain disabled.

Goal/placement outlines, inverse touch mapping, clipped-wall picking, animated foliage/objects and island portraits follow the same layout. Partial fused edges keep their exposed outer wall. No land ownership, progress, inventory or adjacency is changed. Water-offer recovery from 0.21.3 remains included.

Version code increases 17 → 18 with the same package and signing key as the recent builds. Install over those recent downloads; do not uninstall first. Static update compatibility is verified; physical installation/save acceptance remains pending. The much older restored-paint APK used a different key: if Android rejects an update, keep that old app installed if its saved island matters, because uninstalling removes local progress.

Runtime commit: `2a36e090a9c70e5fb177436dd2cf476ffcb3f3a9`.
Tested source SHA-256: `c243ae1fcdb4b2aebfc1ab459bd4bff60eb65de3f3061f27e148c43c9de58535`.
APK SHA-256: `14b902adfb816503a798b5b552371c95fe313d0b266575af78dcbbaf6e0d3f9b`.

The unchanged source passes 2,074 assertions in 44 Godot suites, 22 Python checks, startup and four automated campaign routes. Rendered review covers ready/harvested joins in four views, Water recovery and small-screen touch controls, a 36-cell island, photos and result portraits. Package/source/signature/16 KB alignment checks pass; all 663 retained ARM64-package files match the universal export.

Before/after captures and scoped evidence are in the source branch's `docs/PAINTED_SEAMS_AUDIT.md` and `docs/PAINTED_SEAMS_VALIDATION.json`. Rendered/automated results are not physical-phone or unfamiliar-player acceptance. Test ads do not earn live revenue; production/store setup remains open.
