# Pocket Biome 0.18.0 Android preview

[Download the updated APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android 7.0+ (API24). Signed development preview. Install over the existing game to retain your island; do not uninstall.

## Scenery attached to your land

The distant painted sky in0.17 did not supply the environment on/under the playable island. This update adds actual occupied-cell scenery:

- A shared foundation with painted rock faces, irregular tapered tips and connecting surface detail.
- Hanging roots/ivy and soft local vapor at the real island boundary.
- Shader-animated water ribbons/spray on exposed unfrozen water edges, capped at two outlets. Interior/frozen water does not leak through neighboring cells.
- Boundary updates for expansion, fused ownership, holes and all four camera turns; pooled depth-ordered wall nodes hide farther outlets correctly.
- Title/photo framing and static World miniatures include the new base, roots and spray.
- Reduced-motion/photo modes keep decoration static. Cached geometry ignores cooldown/DNA clocks.

This is live geometry with separate material/root/water artwork. No complete island image replaces gameplay. Existing surface-pad soil bands remain above the new connected base; a complete surface-art replacement is not claimed. Distant sky, illustrated title, framed resource rail, UI type and menu materials from0.17 remain. The lower contextual Build tray, three-tool navigation, continuous3D orbit and some authored structure motion remain unfinished.

Source:8db8282 on main. Digest:f02463374599904bdad50f4740c6c1539232aec476940035bfb9328466e850fd. 975 Godot assertions across17 suites, eight Python audit tests, startup and both complete public-action progression routes pass. New coverage includes shared corners, exposed/owned cells, interior/frozen water, bounds, caching, reduced motion and triangulation of long/negative-coordinate staircases/rings in all four views. Existing real-touch expansion/placement/fusion/pulse/save tests pass. Actual rendered fixtures51–59 use constructed art states, not earned progression. Clock-only frames show cosmetic movement; no FPS claim is made.

APK SHA256:7917fa83fb7846a244fa52dd671116538998c15ac5a96780f9439a59f0499d15. Size:100,942,129 bytes. Signature,448 retained members, ARM64 packaging,16KB ZIP/ELF alignment and embedded source/test binding pass. Current native observations are scoped separately in main's TEST_REPORT.md and artifacts.

Economy, saved fields/prices, resource production and provider test IDs are unchanged. Roots, rock sides, mist and waterfalls do not create gatherable resources or rewards. Production signing/configuration and physical-device/provider/creative evidence remain release gates. This is a development preview, not store certification. No production credentials or store publication were used.
