# Private Android and provider acceptance

The current build is a development-signed, ARM64 test preview. No public app release is part of this change. Install/update with the same package/signature to retain a world; the smoke tool uses `adb install -r` and never clears app data. Keep an exported backup before manually starting a new island for first-session testing.

Current download: `0.21.7-preview` retains the latest gameplay/animation, land-alignment, Water-recovery and painted-seam test APKs' signing identity and increases version code 20 → 21. The much older restored-paint APK used a different certificate and cannot update in place. Do not uninstall it if its saved island matters; transfer across that old signing change is still pending. See [APK_DOWNLOAD.md](APK_DOWNLOAD.md).

## Available device smoke tool

Run `python3 tools/device_smoke.py` to record device availability. With an authorized attached device, select it explicitly:

```
python3 tools/device_smoke.py --serial DEVICE_SERIAL --apk builds/PocketBiome-Android-test.apk --output artifacts/device-smoke.json
```

The tool rejects stale embedded source bindings, installs/updates, launches, checks that the process survives, and saves an app-start screenshot plus app-PID logs. Its report always keeps full physical acceptance false: startup alone does not qualify gameplay, battery, native providers or a release. With no device it writes a blocked report and exits 2. It does not silently choose a device or upload evidence.

## Complete the private playthrough

Record APK checksum, embedded source SHA, device/OS/display, observed behavior and failures. Run at least one small/older phone and a representative current Android phone before release. These are acceptance tasks, not results already obtained.

| Area | Action / acceptance criterion |
|---|---|
| Opening | Fresh island: finish harvest, Water comparison/placement, discovery/inspection, crafting/placement and first spring using the visible guidance |
| Advanced guidance | Complete all four lessons; skip, resume and revisit each; compare displayed progress with actual outcomes; no lesson creates currency or progress by opening it |
| Objectives | Reach all five chapters; every incomplete row opens a useful next action; the finale requires suitable connected habitats and 25 cells |
| Pacing | Record confusion, repeated taps, forced waiting and abandonment points. Separate node collections from Gather-ready taps. Compare guided decisions with the known-solution simulation rather than treating its duration as a human target |
| Save/resume | Background during route drag, saved draft, crafting, lesson, reward and blueprint confirmation; force-stop/relaunch; no duplicate reward, lost purchase, phantom touch or reset of paid progress |
| Touch/accessibility | One-handed taps/drags; 100%/120% text; Reduced Motion; safe insets; no clipped action, misleading overlay or colour-only requirement |
| Performance/audio | Sustained max-size island, visitors and routes; observe frame pacing, heat, battery use, audio mix, interruption and volume behavior on the actual hardware |
| Sharing | Record real milestones, export PNG/GIF, open/cancel the chooser and delete local images; no upload without explicit action |
| Offline/failures | Airplane mode and reconnect; no-fill/load/show failure; gameplay remains available and retries do not flood requests or open ads unexpectedly |
| Ad breaks | Test IDs only during QA. Verify three-minute first exposure, one-minute returning-session guard, three-minute spacing after any fullscreen dismissal, six impressions per rolling half-hour, lesson/draft/weather/reward/fullscreen exclusions and remove-ads; verify Continue/Close/Android Back and completed side activities; old result history must not create a fresh break |
| Earned rewards | Dismiss early, fail a show, duplicate a callback, interrupt a save and restore after process death; accepted earned rewards commit exactly once, including when weather starts during presentation |
| Production consent | With the intended audience and production consent configuration, test eligible/ineligible regions, unavailable forms, withdrawal and privacy options. Debug's test path is not evidence of release consent behavior |
| Billing | Play sandbox: query real configured products, cancel/pending/purchase/acknowledge/restore/remove-ads, process death and local save failure. Simulated callbacks do not certify these flows |

## Production configuration still required

Use the owner's actual publisher/ad and Play Console accounts, product/ad unit IDs, audience decisions, HTTPS privacy/support pages and release signing. Do not fabricate URLs, identifiers or passing reports. Keep test IDs for QA until those are supplied and qualified. `data/release.json` and `data/services.json` intentionally still describe incomplete release configuration.

`tools/audit_android.py --apk builds/PocketBiome-debug.apk --production` must continue to reject the preview. Device, Play sandbox and creative evidence must name the exact current source, include genuine observed results and receive human review before filling the release-evidence locations. Do not point a full physical-device declaration at a startup-only smoke report.

The monetization-specific configuration, debug-unit rules, ads-only billing switch and exact missing live inputs are in [AD_MONETIZATION.md](AD_MONETIZATION.md). No simulated exposure count qualifies real SDK delivery or revenue.
