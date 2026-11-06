# Automatic advertising and revenue setup

Pocket Biome uses automatic interstitials at newly completed activities as its main advertising path, alongside optional rewarded extras. The current build still uses Google test units and earns no live advertising revenue. Real earning requires the owner's AdMob setup and a qualified production release.

## Automatic placements

| Saved result | Where the automatic ad is considered |
|---|---|
| Chapter completion | Continue, next-objective action, Close or Android Back from the chapter celebration |
| Habitat restoration | Leaving the earned restoration moment for the island or next activity |
| Living River restoration | Closing the genuine bloom result; intermediate observed seasons do not present ads |
| Original expedition | Returning home from a newly completed restoration |
| Expedition replay | Returning from each genuinely completed fresh attempt |
| Authored mastery | Returning from each saved challenge/practice completion |

These interstitials do not require opting into a reward. They are presented only if a loaded ad and the eligibility rules permit it. Reopening a historical result does not manufacture another opportunity. Replay/challenge attempts keep their existing reward rules; fresh attempts can monetize without replaying one-time home rewards.

Normal Pack, Journal, settings, crafting and world-menu closure are ad-free. No automatic ads are presented on launch, exit, resource collection or ordinary terrain placement. Result screens explain that occasional ads support the game and that earned progress has already been saved.

## Starting cadence

The current configurable policy is `balanced_breaks_v1` in `data/services.json`:

| Setting | Default |
|---|---:|
| First automatic ad, player with no recorded interstitial impression | At least 180 seconds of active play |
| New app session with prior recorded interstitial exposure | At least 60 active seconds |
| Minimum interval before another automatic ad | 180 seconds after the last fullscreen dismissal, including rewarded ads |
| Rolling automatic exposure cap | 6 actual interstitial impressions in 30 minutes |
| Result opportunity lifetime | 90 active seconds |
| Failed-show retry backoff | 30 active seconds, requiring another fresh result |

This is a starting policy, not a demonstrated revenue optimum. Frequency history contains only local timestamps and persists across app restarts/worlds. Creating another island does not reset the cap. Long sessions regain exposure slots as earlier impressions leave the rolling window. Rewarded extras remain voluntary and retain their three-per-day cap.

Opening guidance stays protected. An active home lesson protects its teaching activity; if the player leaves it to complete a side expedition/replay/mastery, that completed side activity can still monetize. An unfinished home lesson cannot disable all side-activity revenue indefinitely. Drafts, weather, active targeting/placement/movement, fullscreen presentations and pending rewards remain protected. Remove-ads entitlements suppress every automatic placement.

The engine counts active foreground play independently of the island's age. Photo/launch/background time does not advance the first-play clock. Automatic spacing uses the persisted fullscreen end time. During actual fullscreen presentation the game simulation pauses, including on platforms where the OS does not pause the activity.

## Availability, saves and failed shows

A result is registered after its gameplay transaction saves successfully. Failed completion saves create no opportunity. Closing the result consumes the opportunity if it is ineligible or no ad is ready; a later load cannot pop it over unrelated gameplay. Native dispatch rejects a delayed UI-thread request rather than waiting for a load. A pending-dispatch watchdog releases the request if a callback never arrives.

Only actual SDK impression callbacks consume rolling exposure slots. Dispatch, request/load and failed show are distinct. Duplicate callbacks are deduplicated. Actual dismissal starts the spacing interval. A failure does not waste an entire successful-ad cooldown, but repeated attempts still have a backoff. Quiet no-fill recovery is throttled in both the game and native bridge and does not automatically present an ad. Cadence persistence failures suppress further forced ads while core play remains usable.

Accepted earned reward receipts remain payable if weather begins while an optional ad is showing, with durable save/acknowledgement and idempotency preserved.

## Measure player value and revenue together

The local report in playtest diagnostics includes the policy ID, active time, opportunities, denial reasons, dispatches, actual SDK impressions/failures and SDK-reported value grouped by placement/currency. It never treats a dispatch as an impression, combines currencies or claims a publisher payout. It does not upload automatically or establish retention. AdMob's actual reporting and a properly consented player-behavior study are needed to tune revenue per player, completion and return rates together.

The synthetic schedules retained in `MONETIZATION_VALIDATION.json` assume completed teaching and 100% simulated fill:

| Synthetic session | Current simulated impressions | Earlier timing/placement comparison |
|---|---:|---:|
| Five-minute first session with a suitable result at 220 seconds | 1 | 0 |
| Thirty-minute story session | 6 | 2 |
| Thirty-minute returning mastery session | 6 | 0 |

These are exposure-coverage tests, not real views, income estimates, human session lengths or evidence of a retention/revenue lift. Real sessions may have fewer eligible results, lower fill and longer tutorials.

## Supply the live configuration

The owner needs an approved AdMob Android app and separate interstitial/rewarded units. App/unit IDs are public identifiers; passwords, bank details and signing secrets should not be pasted into configuration files or chat.

The three fields belong in `data/services.json` under `admob`:

- `app_id`: the Android app ID with `~` separator.
- `interstitial_unit_id`: the fullscreen unit ID with `/` separator.
- `rewarded_unit_id`: a different rewarded unit ID with `/` separator.
- `audience`: an explicit intended-audience choice; it remains `unconfigured` until supplied.

Run `python3 tools/ad_config.py` to inspect readiness. Production mode rejects missing/test/malformed IDs, mismatched publishers, duplicate units, invalid cadence values or an unset audience. The build generates native resources and binds the manifest/SDK to those resources, so ad IDs no longer require editing Kotlin. The APK audit checks both the embedded configuration and native resource values.

Debug builds always request test ad units, even if real identifiers have been supplied. The preview APK therefore remains a test artifact. Never use live units to manufacture QA impressions or clicks.

For an **ads-only first release**, `billing_enabled: false` disables native billing and purchase controls. This permits an ads-funded edition without setting up optional IAP products. Current sandbox builds retain their existing test store. If billing is enabled for release, real products and store qualification are still required; existing remove-ads entitlements remain respected.

Native audience settings include an appropriate content-rating limit, explicit child-directed/under-age tags for a children/families configuration, and the corresponding consent parameter. This is not proof of legal/store audience eligibility. Intended age groups, regions, age/consent behavior and actual SDK delivery must be qualified on devices before production.

A production release also needs genuine privacy/support URLs, release signing, owner account/app approval and the phone/provider acceptance in [ANDROID_ACCEPTANCE.md](ANDROID_ACCEPTANCE.md). Source/configuration checks do not certify those external requirements. No production account, IDs, audience declaration or physical device was available during this implementation, and no public app release was performed.
