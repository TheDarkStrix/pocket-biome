# Production readiness — current evidence

This is a signed development preview, not a store-ready or commercially certified release. The user requested autonomous work; missing external requirements are recorded here without blocking independent engineering.

## Current visual correction

0.21.1 restores the original painted land from before the added foundation/grass pass. Procedural3D models and their menu portraits are disabled. The default camera is again painted pan/zoom/four-view rotation. Decorative edge falls are suppressed pending real source-connected artwork; individual Golem/workbench animation is still open. Earlier3D evidence below is historical.

## Earlier engineering evidence

- Continuous3D camera yaw/pitch with pan/pinch/twist, compass drag, actual model backs/sides, ray-based picking and3D mobile fitting (docs/CAMERA_ORBIT_PLAN.md).
- Ongoing foliage deformation with fixed terrain/trunk seam, water-surface ripples, furnace/vent smoke and embers, a registered rotating Windmill rotor with work dust, and helper/totem/shrine activity lights. Cosmetic state cannot alter rewards or saved occupancy. Paused automation has no work effects. Reduced motion freezes idle activity; photos keep still framing. The2D feedback redraw is bounded to30Hz; app/3D rendering is capped at60FPS.
- Preserved placement, crossfade/evolution, fusion, three World Pulse effects and responsive HUD/menu animations.
- Fixed environment/automation timing drift caused by slightly late frames; preserve scheduled cadence and skip stalled slots without bursts.
- In-app privacy/data disclosure and local diagnostic deletion. Opt-out cancels pending diagnostic delivery. Native crash capture follows the diagnostics opt-in, including avoiding historical exits from opt-out periods. Ad measurement initialization is delayed in the manifest. Native Google UMP privacy choices are reachable from Settings when required; consent can retry after connection failure, and ad loading/showing checks release consent.
- SDK pins verified against official artifact repositories: Ads 25.5.0, UMP 4.0.0, Billing 8.3.0. Kotlin 2.3.21 is required by current Ads metadata. AGP 8.10.1 matches the installed Gradle 8.11.1 and API36 build. Native compilation/export validation is recorded in TEST_REPORT.md. This is not a statement that every regional/store requirement has been certified.
- Android build stamps embed the tested source hash. A staged APK must pass signature, package/SDK, portrait, packaged-file, ARM64, 16 KB ZIP and ELF-load alignment checks before replacing a previous good build. Production audit refuses development signing, test IDs, preview versions and missing current QA evidence.

## Release gate

Run `python3 tools/audit_android.py --apk builds/PocketBiome-debug.apk --production --output artifacts/production-readiness.json`.

Exit 2 is expected for the current preview. It must not be called a successful store release check. The report enumerates blockers. Evidence-path fields in data/release.json intentionally remain unconfigured; reports must be tied to the current source hash. A static audit cannot authenticate a declaration or substitute for human review.

## External and human acceptance still open

| Requirement | Current state | Needed evidence/configuration |
|---|---|---|
| Signing/release bundle | Development key only | Secure production/upload signing and Play App Signing; release AAB/internal-test upload |
| Google services | Public test ads and `_test` products | Explicit production configuration; Play products/testers; successful sandbox reward/purchase/restore/consent tests |
| Physical Android qualification | Cloud software emulator only | Real mid-range devices, cutouts/tablets, sustained FPS/thermal/battery/memory/audio, interrupted saves/background/kill restoration |
| Publisher policy/contact | Not provided | Hosted final privacy policy, support contact, accurate Data Safety/SDK disclosures and policy review |
| Diagnostics backend | Empty endpoint; own logs local | Receiver/privacy retention policy if network reporting is enabled, or an explicit decision to ship local diagnostics only |
| Creative/player review | Generated diorama art and synthesized audio integrated | Human visual/audio review, comprehension/economy/retention playtests; resolve any art seams and remaining authored rigs |
| Store listing | No submission performed | Content rating, listing assets, localization, SDK disclosures and final release review |

Google's artifact repositories were reachable; the AdMob deprecation documentation page was proxy-blocked. Final SDK support/policy checks must be reviewed before submission. No production credentials, publisher identity or account configuration have been invented.

0.20 fixes reported terrain channels and reference-tool/header/Workshop mismatches, adds full-revolution motor bounds/picking, and replaces the exponential late price tail with exact legacy-quote compatibility. Current automatic checks total1,087. Store review materials do not satisfy missing publisher/device/provider/creative gates. Continuous true3D orbit is an open engineering phase.
