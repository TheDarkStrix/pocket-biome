# Current Android test download

[Download APK](https://github.com/TheDarkStrix/pocket-biome/raw/refs/heads/android-test-build/PocketBiome-Android-test.apk) · [metadata/checksum](https://github.com/TheDarkStrix/pocket-biome/tree/android-test-build)

The APK is 102,469,035 bytes and built from runtime commit `d716c8e`. Its SHA-256 is `c5336560796648a8acbff7955bd9a68555d5e9b1b19bfcd7f5b79e6d57d2889f`; source SHA-256 is `5748bcd27fe04b88d0d3658d30df1053d357cba92ddbd1ec21e9e9fdd7b89560`. [Gameplay/render/package evidence](GAME_JUICE_VALIDATION.json) describes what was verified. It uses Google test ad IDs.

## Upgrade issue found during download delivery

The previous hosted APK has signing-certificate SHA-256 `0aef85d4d7b8721d31b6c671f85e6997ec92c6bad6f7cf5f2f62d8e6d5e6aa89`; the current build has `c624f680df74e7edd9e7a2e83495d5405e1b4cde328f55967bc43c39848029a9`. Both use package `com.thedarkstrix.pocketbiome` and version code 15. Android will reject an in-place update because the certificates differ. Verifying a signature on each APK does not establish compatibility between them.

Do not uninstall the old app if its saved island must be preserved. No in-app save export/import path was found in this implementation; safe transfer for this signing change is still pending. Fresh installs can use the download normally. Retaining a stable signing key and qualifying version increments/update/save migration are release tasks.

## Actual remaining work

- Safe update/save-transfer delivery for older test installations and stable release signing/version management.
- Physical-phone campaign, touch/readability, save/process-death, audio/vibration and sustained performance acceptance.
- Unfamiliar-player tutorial comprehension, pacing, enjoyment and reasons to return; tune from observed play rather than automated completion alone.
- Actual native ad/consent/no-fill/reward lifecycle acceptance using test IDs during QA. Live IDs and revenue measurement come later.
- Production policy/support URLs, audience/data-safety/content-rating decisions, store product configuration if billing is retained, final store media and release AAB.

Registered pond-to-cliff waterfall artwork remains an optional visual enhancement. The painted object rigs, growth/wildlife feedback and milestone effects listed in the current animation inventory are implemented. Automated checks do not qualify these remaining release/player tasks.
