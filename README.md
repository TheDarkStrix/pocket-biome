# Pocket Biome 0.21.0 Android preview

[Download APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android7.0+ / API24. Install over the existing game to keep the island; do not uninstall. Signed development preview with test advertising/product configuration.

## Living island and free camera

The world now uses actual3D miniature models and a continuous360° camera, with visible backs/sides. Drag land to pan, pinch to zoom and twist two fingers to orbit. Drag the small compass to orbit/tilt; desktop right-drag and keyboard arrows on the compass are also supported. World retains quarter-turn shortcuts. Camera movement never spends resources or rearranges saved land.

Trees, reeds and flowers sway in wind; water ripples and catches light; waterfalls flow down exposed edges; ivy, mist, smoke and three flapping butterflies bring movement around the island. Windmills have independent3D sails. Rain/Heat/Frost use pooled3D particles with affected-area feedback. Harvested nodes show stumps/fragments and regrow when the real cooldown ends. Four forest models converge into their fused sanctuary. Build has a translucent placement ghost and all40 base/discovery portraits match the runtime models.

The existing reference-inspired resource rail, Pack/Build/Pulse tools and menus remain. All20 discovery profiles, five chapters, crafting, objectives, automation, optional service routes and validated saves are retained. Original authored procedural geometry is implemented; final human art-direction approval and a separately rigged Golem are not claimed.

Source:af58aa7. Tested/exported source SHA256:21c28f7b4ad091cf8b90f6510afb8e4dbf3ef6e96a1f5bb5842ef8b4fd08ebb7. All1,229 assertions across20 Godot suites, eight Python audit cases, startup and both complete campaign probes pass. The new140 cases cover the shipping3D camera/gameplay separately from retained legacy atlas fixtures. Actual-engine captures80–86 and an animated living-world GIF are on main under artifacts.

APK SHA256:a674185f660dc258b6eda471fb5ab89b06195cb7732349c93433c78908877a23. 102,216,554 bytes. All575 retained members match the universal APK; signature,16KB ZIP/ELF alignment and exact tested-source binding pass.

Physical-device frame-time/thermal/audio/input qualification, final human creative/pacing review, provider sandbox acceptance and production signing/publisher configuration remain open. Software-emulator observations are scoped in TEST_REPORT.md and do not certify phone performance. This is a development preview, not the completed public store release.

Native code14/source af58aa7 check:replacement installation preserved the save byte-for-byte; actual Android Title/Continue/Draft/Later/Build rendered, and a compass touch swipe visibly changed yaw/pitch without spending or changing owned tiles. Sampled logs show no script/fatal/game-ANR entries. See main artifacts/android-orbit-check.json and captures61–65.
