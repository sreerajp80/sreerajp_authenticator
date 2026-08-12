# Dependencies — SreerajP Authenticator

This document lists the approved baseline dependencies, package responsibilities, and explicit prohibited dependencies for SreerajP Authenticator.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md)

---

## 1. Approved Baseline Dependencies

All external packages must fit the offline-first security posture of the app. The following baseline dependencies are approved and configured in [`pubspec.yaml`](../pubspec.yaml):

| Package | Purpose / Responsibility |
|---------|--------------------------|
| `base32` | Base32 decoding and encoding for OTP secrets |
| `mobile_scanner` | QR code scanning via camera |
| `qr_flutter` | Rendering QR codes for account export |
| `sqflite` | Local SQLite database for encrypted account and group data |
| `shared_preferences` | Non-sensitive key-value preferences (e.g. theme, lock timeout) |
| `flutter_secure_storage` | Device secure key storage (`authenticator_key`, PIN/recovery hashes) |
| `local_auth` | Biometric (fingerprint/face) and device credential authentication |
| `screen_protector` | Screenshot and screen recording protection (`FLAG_SECURE`) |
| `provider` | Application state management |
| `encrypt` & `pointycastle` | AES-256-GCM encryption and cryptographic operations |
| `crypto` | HMAC hashing for RFC 4226/6238 TOTP/HOTP generation |
| `file_picker` & `share_plus` | Encrypted backup import and export file handling |
| `permission_handler` | Camera and storage permission management |
| `url_launcher` | Opening external license or documentation links |
| `flutter_slidable`, `flutter_animate`, `shimmer`, `animations`, `flutter_svg` | UI enhancements and animations |

---

## 2. Prohibited / Blocked Dependencies

To preserve the fully offline, zero-telemetry posture of the authenticator, the following package categories are strictly prohibited:

- **HTTP / Networking Clients:** `http`, `dio`, `chopper` (unless specifically audited for LAN-only sync).
- **Cloud / BaaS SDKs:** `firebase_*`, `amplify_*`, `supabase_*`.
- **Analytics & Tracking:** `firebase_analytics`, `mixpanel_flutter`, `amplitude_flutter`, `appsflyer_sdk`.
- **Crash Reporting & Telemetry:** `sentry`, `firebase_crashlytics`, `bugsnag_flutter`.
- **Ad Networks:** `google_mobile_ads`, `facebook_audience_network`.

---

## 3. Dependency Verification Procedure

Before adding any new package:

1. Inspect the package's `pubspec.yaml` for transitive network or analytics dependencies.
2. Confirm the package license is open source (MIT, BSD-3-Clause, Apache-2.0). Commercial or source-available licenses are prohibited.
3. State the technical rationale in a `plans/` proposal and obtain explicit approval before adding to `pubspec.yaml`.
