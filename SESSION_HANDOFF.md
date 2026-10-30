# Pocket Biome — session handoff

Updated2026-10-30. The user requested progress documentation and a fully cleared session. Feature work is paused. Do not start more visual work during cleanup.

## Most important user direction

The user rejected the procedural3D replacement and asked for the **old old land graphics, before the visual pass**. The current default restores the original full painted tile surfaces and earth edges from before the added shared grass/deep cliff foundation. Keep the current menus/HUD controls and saved game. Do not replace the painted artwork with procedural models, re-enable the added foundation, or substitute generated3D portraits. Existing original art files were never deleted.

## Current repository and build

- Repository:/workspace/pocket-biome; GitHub:TheDarkStrix/pocket-biome; main.
- Runtime restoration commit:fa96a28. Documentation/evidence commits may follow without changing the tested source.
- Godot4.6.3; Android OpenGL Compatibility; version0.21.1-preview/code15.
- Tested/exported source SHA256:e7813bf2a0989e8a521e2238cd5f7044d674cd6eea24b2afb2986113fdce2de2.
- Phone APK:builds/PocketBiome-Android-test.apk; SHA256:02af7b5afb437de9ec855adacda9a256cefd11e949a45920adec594354657d34;102,216,554 bytes; ARM64/API24+.
- Download worktree:/workspace/pocket-biome-apk; branch:android-test-build. The restored binary supersedes the rejected0.21 package. Check the final branch commit and checksum before sharing an immutable download URL.
- Main README contains the latest-branch APK link. Install over the existing app; do not uninstall or delete saves.

## What was actually restored

Main.orbit_enabled=false and Main.connected_land=false. Full original TileArtwork/WorldAmbience sprite rendering is active. The added IslandEnvironment is hidden/process-disabled. Picking, fusion remnants, photo bounds and world miniatures follow the original painted land. DioramaPreview/TileThumbnail again use the original painted atlas images. Current HUD, Pack/Build/Pulse tools, gameplay systems, economy and save schema remain.

The3D renderer and connected-foundation code remain internal only. Experimental tests/capture tools explicitly opt in; they are not the player default. The restored camera has pan/pinch and four90° views. **Continuous3D orbit is disabled; do not claim it is available with the restored artwork.**

Detached decorative edge waterfalls are suppressed. An exposed water tile is not proof of a visible water source. A proper painted pond-to-lip outlet has not been supplied/implemented.

## Verified work

- 1,241 assertions across21 Godot suites, eight Python audit cases, startup and two full public-transaction campaign probes pass.
- New12-case painted_art regression protects the actual default, original card/menu assets, four-view grid picking, state isolation and absence of detached falls.
- Default scene/mobile tests no longer force a renderer override. The3D suite is explicitly experimental.
- Actual-engine restored-default screenshots:artifacts/90-original-land-before-visual-pass.png,91-original-painted-workshop.png,92-original-painted-draft.png. The capture tool writes87–89;90–92 are retained copies documenting the selected older land rendering.
- Android export/signature/package/source binding and16KB ZIP/ELF alignment pass; all575 retained phone APK members match the universal export.
- The code15 universal APK replaced the existing API29 emulator installation and preserved the primary save byte-for-byte. artifacts/android-painted-install-check.json records the scope. The test app was force-stopped for cleanup.
- Native UI/interaction/photo revalidation of the restored build has **not** been completed. Earlier0.21 orbit screenshots/results describe the rejected3D build.

## Still unfinished

The user's request for individual object animation is not complete. Existing painted canopy motion, water ripples, separate painted Windmill sails, smoke/runes, harvest/evolution/fusion and Pulse feedback remain. Independent Golem limbs, workbench tools, richer separated foliage and a natural source-connected waterfall need further work **while preserving the original graphics**. Do not describe global effects or moving an entire sprite as a completed individual rig.

All20 discoveries, five chapters, crafting, automation, objectives, Codex and validated saves remain. Broader production readiness is not certified:physical-device FPS/thermal/audio/cutout/input/lifecycle checks, provider sandbox rewards/billing/restoration/consent, publisher URLs, production signing/configuration and human creative/pacing acceptance remain open. Test IDs remain configured; do not introduce production credentials without explicit configuration.

## Resume carefully

Read IMPLEMENTATION_STATUS.md, TEST_REPORT.md, ARCHITECTURE.md, ART_ASSET_MANIFEST.md, docs/ANIMATION_STATUS.md and docs/CAMERA_ORBIT_PLAN.md. The authoritative PRD is docs/MASTER_PRD_v4.md. Older3D sections are historical and superseded by the restored-default notes. Do not infer that the rejected art direction was approved.

Useful commands:tools/godot.sh; tools/check.sh; tools/visual_review.sh tools/capture_restored_art.gd; tools/build_android.sh; python3 tools/package_phone_apk.py. Source hashing excludes docs/artifacts but includes code/assets/tests/tools. Finish imports before full checks; do not change hashed files during verification/export. Android export kills ADB; reconnect only after Godot tools finish.

Reusable SDK/JDK/toolchain and QA files remain under /workspace/runtime. Native test save backups from this restoration are painted-native-before.json and painted-native-installed.json there. Preserve them and the game saves. Do not wipe the repository/toolchain to interpret “clear session.” Chat history/context cannot be erased by a workspace action; a new chat/session is required for fresh context.
