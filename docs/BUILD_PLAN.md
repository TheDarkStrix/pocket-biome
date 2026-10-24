# Continuation plan

User authorization: finish the initial-release PRD autonomously; push verified milestones to GitHub. Do not ask blocking preference questions. Preserve navy/green UI and reference materials. External requirements are recorded in RELEASE_DEPENDENCIES.md.

Current milestone: 592 passing assertions + full public-action simulation (20 discoveries, five chapters, 35 cells, 119 transactions, 5199 active seconds). Signed debug Android APK built with explicit OpenGL mobile/desktop setting; artifact fingerprint in artifacts/android-build.json. Latest code includes live inspector/workshop, quantity crafting/requirements, three-power selector, photo lighting, eleven sound cues, founder effects, DNA tint/glow, debounced saves/background flush, schema2 migration hardening and reward save-failure retry. GitHub main initial checkpoint 2337b48; further checkpoints follow verified changes.

Native blocker under investigation: API29 AOSP TCG emulator, no KVM. Earlier Vulkan override fixed; OpenGL initialization confirmed after reducing unused 3D light limit. SwiftShader/ANGLE backend produced Android System UI ANRs; now testing host Mesa GL via Xorg :95, emulator process launched with -gpu host -cores4. Current adb endpoint must be rediscovered after every Godot invocation because Godot may kill the adb daemon. Do not run Godot checks/import/export while exercising adb. No native playable-screen claim yet.

Remaining work:
1. Finish native install/launch/gameplay, save restoration, input and photo-chooser checks where emulator permits. A system-level ANR is not automatically an app crash; inspect native logs.
2. Run/inspect final graphical captures for recent UI changes; preserve actual gameplay captures separately from visual fixtures.
3. Keep docs/test evidence/fingerprint current and push next verified checkpoint to main. APKs stay ignored; do not commit production credentials/keys.
4. Save updated reusable cloud install/start configuration. Existing checkout is isolated; no worktree needed. Dependencies verified under /workspace/runtime (Godot4.6.3, JDK17.0.16+8, SDK36/build36.1/NDK29, Gradle8.11.1). tools/bootstrap_android.py --install-sdk reran successfully.
5. Real provider transactions, production signing/consent/telemetry receiver, physical-device performance and human product validation remain explicit external release gates. Never claim them completed through boundary tests.

Avoid creating /home/agent/.emulator_console_auth_token: a previously granted file-path mount causes sandbox startup failures if that file exists. Current emulators log console unavailable, but adb remains usable. Runtime homes/AVDs/caches use /workspace/runtime.
