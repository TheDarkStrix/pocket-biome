# Pocket Biome 0.20.0 Android preview

[Download APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk)

ARM64 Android7.0+ / API24. Signed development preview. Install over your existing game to keep the island; do not uninstall.

## Reported visual problems corrected

- Occupied land uses an opaque continuous grass carpet and soft sprite-edge joins. The old cap sampling included brown soil, making channels between plots; that source is removed. Intentionally empty cells stay empty.
- One compact resource rail with simple Log/Stone/Coin art replaces three heavy gold boxes. Thin slate/bronze/green materials replace oversized frame hardware throughout the UI.
- Bottom tools now use complete clean tan backpack, wooden mallet and blue rain-totem medallions matched to the selected concept, with a framed Build label and live Pulse ring. The unrelated stone warhammer/gritty plates are replaced.
- Workshop structures are shown without raised soil blocks or concentric halo rings. All recipe categories, exact costs, missing requirements, queue/completion/placement/cancellation and Pack destinations remain.

## Gameplay and animation

Windmill sails now rotate as an independent painted layer around a registered axle. Pausing automation, reduced motion, photo mode and backgrounding keep its current pose; full-revolution bounds and moving alpha picking are covered. Terrain, building body and game state do not rotate with the sails.

New late-land prices keep counters0–12 unchanged, then use a linear12-Coin step capped360. The full32-purchase budget is6,025 Coins rather than48,754. Already-saved drafts retain their exact old offers, target and price, validated against their original policy. No owned land or paid extras reset.

Source:d885f75. Source/test/export digest:489a4b3d13763da89de63350992befc1ab879dc2ad87079298c0f58d6acf0116. All1,087 assertions across19 Godot suites, eight Python audit cases, startup and both complete20-discovery/five-chapter progression probes pass. The expert probes take1,097/1,076 active seconds and1,662/1,509 manual collections; these are not human completion-time, enjoyment or retention claims.

Actual staged OpenGL captures70–75, native observations and store-review materials are on main in TEST_REPORT.md/artifacts/docs/store. No generated concept board is used as a flattened screen. Current native install/save/UI evidence is documented separately; screenshots are not physical-device qualification.

APK SHA256:cb68e1d97abb8a95371fe84525b8476f68d9a03fc822082bccd46f82ac9b9312. 101,579,779 bytes. All476 retained members match the universal APK byte-for-byte. Signature,16KB ZIP/ELF alignment and tested-source binding pass.

Continuous true3D orbit, real provider sandbox/production configuration/signing, physical-device performance/audio and human creative/pacing review remain open. Test advertising/product IDs remain configured. Store copy/privacy drafts and the feature graphic are not a public store submission. This is not production certification.
