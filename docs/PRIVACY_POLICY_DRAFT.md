# Privacy policy drafting material — not published

Publisher identity, contact details, hosted URL, territory/age decisions and retention policy have not been supplied. This document describes implemented behavior for the publisher's final policy/Data Safety review; it is not a finished or legally reviewed policy.

Pocket Biome stores islands, settings, discoveries and entitlements in application-private device storage. Core play needs no account. Android backup is disabled; uninstalling can remove the world. Photo sharing uses Android's chooser and a private FileProvider; the game does not pick a recipient.

Own diagnostics are off by default. Opting in permits a bounded queue of app events/error information. Current telemetry endpoint is empty, so this queue stays local. The game's event payloads omit purchase tokens, advertising IDs and device IDs. Players can disable diagnostics and delete local app records. Disabling cancels pending delivery; it cannot recall data already delivered. If a receiver is later enabled, the publisher must disclose its operator, collected fields, retention and deletion process before publication.

Google Mobile Ads/UMP and Google Play Billing are third-party SDKs. Optional services connect through the Store flow. When connected, occasional ads can appear at eligible chapter breaks; rewarded benefits remain optional. Payment processing is handled by Google Play. The publisher must accurately disclose Google SDK collection/sharing, ads identifiers, consent/age handling and applicable regional choices using current Google documentation. Ad privacy choices can be reopened from Settings where UMP requires them.

Production signing credentials, production ad IDs and store product configuration have not been introduced. Current builds are labelled previews and use public test ad IDs and test product identifiers. A privacy-policy URL and support URL remain empty in data/release.json and block the production audit.
