# Pocket Biome — 0.21.2 Android test update

[Download the current APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

Android 7.0+ / ARM64. About 98 MiB. Development preview with Google test ad IDs.

## Fixed: land dropping after gathering

Harvested Fiber/Oak/Forest/Stone/Clay/Iron now retain their growing artwork's ground contact. The visible tile no longer jumps down or up when its plants/resources change. Original painted art and saved gameplay are retained. Rendered ready/harvested comparisons and all four camera views are checked.

Version code increases 15 → 16. **This APK uses the same signing key as the immediately preceding gameplay/animation download. Install over that recent build; do not uninstall first.** Static package/signature/version compatibility is verified; no attached phone was available for an install/save-preservation acceptance run.

The much older restored-paint test APK had a different signing key and cannot update in place. If Android rejects an update, keep that old app installed if its island matters. Uninstalling removes local progress; save transfer across that old signing change is still pending.

All five chapters, twenty discoveries, tutorials, habitat projects, Living River, crafting/automation, expeditions, wildlife and painted-object motion from the preceding build remain included.

Runtime commit: `d26758f6cb8a40350bb1ab450332d477e25d1c62`.
Tested source SHA-256: `68a4fc0d4a90508d0ce684a54df4cfa36ffc927103fa51e2e28319fa239473dd`.
APK SHA-256: `9ed02da304cf20b605233a33ccd2c608aa96b695952e9983c5b8f63cd0511a33`.

The unchanged source passes 2,012 assertions in 42 Godot suites, 22 Python checks, startup and four automated campaign routes. Package/source/signature/16 KB alignment checks pass. Details and before/after screenshots are in the source branch's `docs/LAND_ALIGNMENT_AUDIT.md` and `docs/LAND_ALIGNMENT_VALIDATION.json`.

Phone audio/vibration/performance/save acceptance, human comprehension/enjoyment, actual native provider testing and production/store setup remain open. Test ads do not earn live revenue.
