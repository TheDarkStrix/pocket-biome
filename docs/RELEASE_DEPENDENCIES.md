# Release dependencies and decisions

The user requested no blocking questions. Record unresolved external requirements here and continue independent implementation.

- **Google Play Console:** create the three `_test` products declared in native/android/src/com/pocketbiome/PocketServices.kt, licensed testers, and internal-test upload before real Billing purchase/restore can be certified. Local entitlement tests are not store transactions.
- **AdMob/consent:** development uses Google's public test app/ad IDs. A publisher account and configured UMP messages are needed to validate release consent regions. Never replace test IDs without explicit production configuration.
- **Release identity:** production keystore/passwords and Play App Signing configuration are external secure configuration. Existing APK is signed with a development key only.
- **Telemetry:** opt-in JSONL and HTTPS delivery code exists; data/services.json deliberately leaves telemetry_url empty. Choose a receiver/privacy retention policy before publishing. Do not pretend events reach a backend.
- **Devices:** cloud software emulator validates installation and functional behavior only. At least one physical mid-range Android device plus cutout/tablet coverage is required for FPS, thermal, battery, touch comfort, audio and lifecycle qualification.
- **Product validation:** PRD player comprehension/retention targets require real playtests. Automated progression does not establish enjoyment or commercial viability.
- **Creative review:** generated assets and original synthesized audio are integrated. Use the selected Pocket Biome concept, clean slate/bronze framing, simple painted tools, named resource rail and connected painted island, with original assets. The user rejected a fixed navy/green direction and the earlier playful skin; final visual/listening review remains open.
- **Store submission:** privacy policy/data safety, content rating, listing art and screenshots, localized descriptions, SDK disclosures and final QA must precede publication. No automatic store publication is authorized or performed.

Runtime: OpenGL Compatibility is selected for both regular and mobile rendering, Android minimum API24/target36. Vulkan can be explored separately after device profiling; exported apps follow the configured renderer.

Current engineering/checklist: docs/PRODUCTION_READINESS.md. Current animation coverage and remaining authored rotor/body rigs: docs/ANIMATION_STATUS.md. SDK artifact pins are current as verified from official repositories; current store/regional policy and provider flows still need final review. The production audit intentionally fails for development signing/test IDs and missing external acceptance evidence.

Camera extension:0.21 implements continuous3D yaw/pitch, actual model backs/sides, camera-aware picking and bounds. Automated and software-rendered checks are documented; human creative approval and physical-device qualification remain open. See docs/CAMERA_ORBIT_PLAN.md.

Store review materials are prepared in store/LISTING.md and store/PRIVACY_DRAFT.md, with staged current-game captures and a documentation-only feature-graphic renderer. Final publisher/audience/contact/hosted-policy and store approvals remain external. These drafts are not public store submissions.
