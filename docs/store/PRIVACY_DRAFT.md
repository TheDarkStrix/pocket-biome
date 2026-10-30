# Pocket Biome privacy disclosure — publisher review draft

This draft reflects the current implementation. Publisher identity, private contact, effective date, hosted URL and audience decisions must be completed before release. It is not a published final policy.

## Your island

The game stores your island, inventory, progress, settings, purchase entitlements and reward receipts on your device. Core gameplay needs no account or internet connection. Uninstalling or clearing app storage may remove the local world. The game does not currently provide account-based cloud saves.

## Diagnostics

Diagnostics are off by default. Enabling them allows a limited local app-event/error log and supported Android crash diagnostics. The game excludes purchase tokens, payment details and advertising identifiers from its own diagnostic payloads. The current build has no configured upload endpoint: these logs stay on the device. The in-game Privacy screen can delete local diagnostics. Turning diagnostics off cancels pending game-controlled uploads. A future hosted receiver requires an updated policy and retention/contact details before enabling it.

## Optional Google services

Connecting optional store services enables Google advertising/consent and Play Billing integrations. Google may process information described in its current advertising and Play documentation, including service/device identifiers and interaction or transaction information. The publisher must verify Google SDK disclosure guidance for the exact release versions and complete the store's Data Safety form accordingly.

Google handles payment collection. The game uses purchase/reward receipts to grant permanent extras and prevent duplicate rewards; it does not receive full payment-card details. Applicable advertising privacy choices are available in Settings when Google's consent system requires them. Core progression remains playable if you decline to connect optional services.

## Photos

A photo remains in app storage until you explicitly choose to share it. Sharing opens Android's system chooser; you choose the destination. The game does not select a recipient or post automatically.

## Controls and requests

Settings offers sound, motion, analytics and relevant ad-privacy controls. Clearing app storage removes local data; uninstalling may do so too. Final publisher contact, legal rights/request handling, audience/children decisions, service-specific retention and regional notices require publisher review. Do not collect sensitive privacy requests through a public issue thread.

## Implementation references

ServiceHub.gd, Telemetry.gd, PocketServices.kt, data/services.json and the in-app Privacy screen are the engineering sources for this draft. Sandbox provider IDs remain configured; this file does not authorize enabling production credentials or uploading the game.
