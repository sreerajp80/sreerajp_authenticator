# Architecture — Sreeraj P Authenticator

This document describes the technical architecture, layer boundaries, app lifecycle, state management, and persistence design of Sreeraj P Authenticator. Read this before changing screens, services, providers, models, or state logic.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md) | [guidelines/architecture.md](guidelines/architecture.md)

---

## 1. Scope

- Product: `Sreeraj P Authenticator`
- Repository type: `application`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`
- Declared platforms (from [`PROJECT_PROFILE.md`](PROJECT_PROFILE.md) §3):
  - `Android` (the only platform)
- The `ios/`, `macos/`, `windows/`, `linux/` and `web/` folders were removed.

---

## 2. Goals And Non-Goals

### Goals

- Generate TOTP and HOTP codes fully offline.
- Protect locally stored secrets with device-side encryption and app-lock controls.
- Support QR onboarding, grouped account management, and encrypted backup/restore.
- Support opt-in, user-initiated, same-LAN device-to-device account transfer (P2P sync)
  with no internet backend (see §14 and `docs/security.md`).

### Non-Goals

- Cloud sync, server-side account storage, or remote account recovery (P2P sync is LAN-only,
  peer-to-peer, and uses no server or account).
- Background, unattended, or internet/relayed sync.
- Protection against a fully compromised, rooted, or otherwise hostile device.

---

## 3. Architecture Summary

The app uses a Tier 1 Flutter structure with `Provider` for app state, `sqflite` for local
persistence, `flutter_secure_storage` for secret and key material, and service classes for OTP,
encryption, authentication, and import/export logic. The app is intentionally offline:
accounts, lock settings, and encrypted backups are handled locally on-device without any
application network API.

---

## 4. Repository Structure

### Current Structure Tier

- `Tier 1`
- Why this tier is appropriate now:
  - The app is a single product with a modest number of route-level screens.
  - The current separation by `providers`, `services`, `models`, `screens`, and `widgets`
    remains understandable without a feature-first split.

### Top-Level Source Layout

```text
lib/
|-- config/
|-- models/
|-- providers/
|-- screens/
|-- services/
|-- utils/
|-- widgets/
`-- main.dart
```

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/config/` | Flavor parsing and app-environment metadata |
| `lib/models/` | Account data model and mapping with multi-tag support |
| `lib/providers/` | App state, lock policy, filtering, sort order, and theme state |
| `lib/screens/` | Route-level UI and user flows |
| `lib/services/` | OTP, crypto, auth, backup/import, brand icons, database logic, and "Delete all data" (`data_wipe_service.dart`) |
| `lib/widgets/` | Reusable UI pieces shared by screens |
| `lib/utils/` | Constants, theme definitions, and shared helper content |

---

## 5. App Initialization Sequence

Documented from [`lib/main.dart`](../lib/main.dart).

| Step | Code / Call | Notes |
|------|-------------|-------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | Always first |
| 2 | `SystemChrome.setPreferredOrientations(...)` | Restricts app to portrait orientations |
| 3 | `SystemChrome.setSystemUIOverlayStyle(...)` | Transparent status and navigation bars |
| 4 | `ScreenProtector.protectDataLeakageOn()` | Enables platform screenshot/data-leak protection hooks |
| 5 | `ScreenProtector.preventScreenshotOn()` | Applies screenshot blocking; on Android this sets `FLAG_SECURE` |
| 6 | `disableScreenProtection()` | Only if the user turned off "Block screenshots" (`block_screenshots` in SharedPreferences) |
| 7 | `runApp(const MyApp())` | Starts the widget tree |

Deferred initialization:

- `SettingsProvider` loads persisted settings lazily after `runApp`.
- Database opening is lazy in [`lib/services/database_service.dart`](../lib/services/database_service.dart).
- Encryption-key bootstrap is lazy in [`lib/services/encryption_service.dart`](../lib/services/encryption_service.dart).
- Accounts load only after settings initialization and only when the app is not locked.

---

## 6. App Lifecycle Behavior

Primary lifecycle handling is implemented in [`lib/main.dart`](../lib/main.dart) and supported by `SettingsProvider`.

| Lifecycle State | App Behavior |
|----------------|--------------|
| `resumed` | Re-evaluates lock policy through `SettingsProvider.onAppResumed()` |
| `inactive` | Does not lock; intentionally ignores transient overlays like dialogs and calls |
| `paused` | Locks the app if app lock is enabled and clears decrypted OTP cache |
| `detached` | No custom handler today |
| Memory pressure | No explicit custom handler today |

---

## 7. Offline Behavior

- **Connectivity requirement**: `offline-first` — all core features (OTP generation, storage,
  backup/restore) work with no network. The only networked feature is opt-in, user-initiated
  P2P LAN sync (§14), which uses the local network but no internet backend.
- **Network permission**: The Android main manifest requests `INTERNET`, `ACCESS_NETWORK_STATE`,
  and `ACCESS_WIFI_STATE` to support P2P LAN sync (TCP sockets and reading the local IPv4 address
  for display). `INTERNET` is also present in debug/profile manifests for tooling. The app has no
  app-owned backend and makes no internet/HTTP requests.
- **Offline data sources**:
  - `sqflite` for encrypted accounts and tags
  - `SharedPreferences` for non-secret settings
  - `flutter_secure_storage` for keys, PIN hashes, and recovery material
  - Temporary files for export/share flows

Implications:

- Production Android builds intentionally include `INTERNET` (plus `ACCESS_NETWORK_STATE` /
  `ACCESS_WIFI_STATE`) to support P2P LAN sync. There is still no app-owned backend and no
  internet/HTTP client in the Dart code — sockets are used only for same-LAN peer transfer.
- P2P sync is foreground-only and user-initiated; nothing listens or connects in the background.
- The current automated coverage is unit and widget testing (including a loopback sync round-trip);
  there is not yet a dedicated airplane-mode integration test committed in this repo.

---

## 8. State Management

- Primary pattern: `Provider`
- Why this pattern was chosen:
  - The app has a small number of app-wide state domains: settings, accounts, and theme.
  - `ChangeNotifier`-based providers are sufficient and keep the app wiring simple.
- State boundaries:
  - Widgets own: form inputs, visual expansion state, loading indicators, and local interaction state
  - Providers own: lock state, theme mode, account collections, tag filtering, sort, and import state
  - Services own: OTP generation, encryption, persistence, authentication, brand icons, and backup logic

---

## 9. Data Flow

Current request/update path:

```text
Widget -> Provider -> Service -> sqflite / secure storage / platform plugin
```

This app intentionally omits a repository layer.

### Rules

- Widgets must not know: SQL schema details, encryption format details, secure-storage key names
- Services must not know: navigation policy, widget layout, or screen copy
- Providers coordinate: screen/app state with service calls and `notifyListeners()`

---

## 10. Error Handling Architecture

Current state:

- No centralized `FlutterError.onError` or `PlatformDispatcher.instance.onError` handler is set in
  [`lib/main.dart`](../lib/main.dart).
- There is no custom domain exception hierarchy yet.
- Services primarily communicate failure through `bool`, `null`, `debugPrint`, or generic
  `Exception` values.

| Exception Class | Thrown By | Meaning |
|----------------|-----------|---------|
| `Exception` | `EncryptionService` | Encryption or decryption failure |
| `PlatformException` | `AuthService` / device plugins | Local-auth or platform-plugin failure |
| `DatabaseException` | `sqflite` operations | Local DB read/write or schema issue |

- **Error escalation policy**: UI flows generally keep existing local state and show an error
  message instead of crashing the app.
- **Fatal error screen**: none implemented today

---

## 11. Domain Model

### Current Schema Version

SQLite schema version: `4`

Version history (upgrades from older versions are no longer supported, because the app has had
no public release):

| Version | Change Summary |
|---------|---------------|
| 1 | Initial schema with `accounts` and `groups` tables |
| 2 | Added `groups.icon` and `groups.createdAt` |
| 3 | Added `accounts.tags` text column |
| 4 | Migrated group membership to account tags and dropped legacy `groups` table |

### Core Models Or Entities

| Type | Purpose | Mutable? | Notes |
|------|---------|----------|-------|
| `Account` | Stores OTP account metadata and the encrypted secret | `Yes` | Supports TOTP, HOTP, Steam Guard, Blizzard, YubiKey, issuer, algorithm, digits, period, multi-tagging, and ordering |

### Serialization Strategy

- JSON models: `yes`
- Database models: `yes`
- Separate domain entities from transport models: `no`; the `Account` model is used for DB mapping and backup/import JSON

### Database Indexes

| Table | Indexed Columns | Reason |
|-------|----------------|--------|
| `accounts` | none explicit | Current queries are simple and use sort order plus created timestamp |

---

## 12. Dependency Management And Injection

- DI approach: provider tree plus manual service construction inside providers and services
- App-root dependencies:
  - `ThemeProvider`
  - `SettingsProvider`
  - `AccountProvider`
- Test replacement strategy:
  - Platform-channel mocks for `flutter_secure_storage`
  - In-memory or test-path `sqflite` databases
  - Unit tests around services and providers instead of runtime DI overrides

---

## 13. Navigation

- Navigation approach: `Navigator 1.0`
- Route definition location: route-level screens are pushed directly from widgets; app root is in
  [`lib/main.dart`](../lib/main.dart)
- Protected-route strategy: `_AppRoot` switches between `LockScreen` and `HomeScreen` based on
  `SettingsProvider`
- Deep-link support: `no`

---

## 14. Persistence And External Systems

### Local Storage

- Database: `sqflite`
- WAL mode: platform default from `sqflite`; not explicitly overridden
- Key-value storage: `SharedPreferences`
- Secure storage: `flutter_secure_storage`

### Network

- Network client: `none` (no HTTP/internet client)
- Offline behavior: `offline-first`
- P2P LAN sync: a `dart:io` `ServerSocket`/`Socket` engine
  ([`lib/services/p2p_sync_service.dart`](../lib/services/p2p_sync_service.dart))
  for opt-in, same-LAN, device-to-device account transfer. The host binds a **random
  OS-assigned port** and displays its IPv4 + port + a per-session pairing code, both as a scannable
  QR (`spauth://sync?…`) and as text; the client connects either by scanning the QR
  ([`lib/screens/sync_qr_scanner_screen.dart`](../lib/screens/sync_qr_scanner_screen.dart))
  or by typing the details in. Security is at the payload layer (PBKDF2-derived AES-256-GCM keyed
  by the out-of-band pairing code — the QR is out-of-band too, never on the wire), not the transport.
  State is driven by
  [`lib/providers/sync_provider.dart`](../lib/providers/sync_provider.dart)
  and the UI by
  [`lib/screens/sync_screen.dart`](../lib/screens/sync_screen.dart)
  with the host's tabbed send UI in
  [`lib/screens/send_to_device_screen.dart`](../lib/screens/send_to_device_screen.dart).
  The host holds the connection open after a peer authenticates and the **sender chooses what to
  share**: a Full Sync (all accounts and the syncable settings — theme, auto-lock, and sync
  idle timeout — via `SettingsProvider.syncableSettingsSnapshot`) to a fresh device, or a selective
  incremental sync of chosen categories. Payloads carry an optional `settings` object and a
  `syncMode` marker; device-specific security settings are never sent. Received accounts are
  routed through the existing import funnel (`AccountsProvider.importData`, add-only / client-wins,
  now returning `ImportResult` counts) and settings through `SettingsProvider.applySyncedSettings`
  (fill-only on an incremental sync). The host auto-stops after a configurable idle timeout
  (`SettingsProvider.syncHostIdleTimeout`), and idle auto-lock is suppressed while the sync screen is
  open (`SettingsProvider.setSyncInProgress`) so a session is not torn down mid-transfer. Full threat
  model in `docs/security.md`.
- Optical air-gap sync (no network): the same payload is sealed with AES-256-GCM by
  `OpticalSyncCrypto` ([`lib/services/optical_sync_service.dart`](../lib/services/optical_sync_service.dart)),
  keyed by a one-time transfer code shown on the receiver and typed on the sender, then sent as
  Fountain-code QR frames (version 2). See `docs/security.md` §5.2.

### Platform Channels Or Native Integrations

- `screen_protector`: screenshot and screen-recording protection
- `local_auth`: device lock and biometric authentication
- `flutter_zxing` and `camera`: QR scanning (`lib/widgets/qr_camera_view.dart`)
- `flutter_secure_storage`: key and secret-material storage
- `device_state_service` method channel: boot-count checks for adaptive unlock policy

---

## 15. Environment And Build Model

- Flavors used: `dev`, `prod`. `pubspec.yaml` sets `default-flavor: dev` for every platform, so
  release builds always pass `--flavor prod`
- Runtime config mechanism: native Android flavor; Flutter sets `FLUTTER_APP_FLAVOR` from
  `--flavor`, read by `AppFlavorConfig`
- Obfuscation: enabled for every production release build with
  `--obfuscate --split-debug-info=build/symbols/<platform>-prod-<version>/`; symbols archived
  outside the repository ([`release_process.md`](release_process.md) §6.1)

### Target Platforms And Distribution

The minimum OS for each platform, and its reason, is recorded only in
[`PROJECT_PROFILE.md`](PROJECT_PROFILE.md) §3.

| Platform | Release artifact | Channel(s) | Signing | Platform-specific notes |
|---|---|---|---|---|
| Android | `.aab` / split `.apk` | Google Play, direct APK | release keystore + Play App Signing | Camera, biometric and INTERNET (local Wi-Fi sync) permissions; `FLAG_SECURE` |

---

## 16. UI System

- Theme source of truth:
  [`lib/utils/theme.dart`](../lib/utils/theme.dart)
- Design tokens location: colors, spacing, and themed component styles currently live in
  [`lib/utils/theme.dart`](../lib/utils/theme.dart)
- Shared widget strategy: reusable components live under `lib/widgets/`
- Material package: widgets come from `material_ui` (`package:material_ui/material_ui.dart`).
  The `migrate_design_widgets` lint in `analysis_options.yaml` blocks the old SDK imports.
  `MaterialApp.builder` in `lib/main.dart` wraps the app in `MaterialUiCompatibilityBridge`
  so packages that still use the SDK library get the app theme (see §21)
- Localization (engineering standard §8): `en` (template), `ml`, `sa`. ARB files in `lib/l10n/`,
  generated `AppLocalizations` (via `l10n.yaml`). `LocaleConfig` (`lib/config/locale_config.dart`)
  holds the supported locales, the delegate list (Sanskrit fallback delegates from
  `lib/l10n/fallback_localizations.dart` first, then `GlobalMaterialLocalizations.delegates`),
  device-locale resolution and `formattingLocale(...)`. `LocaleProvider`
  (`lib/providers/locale_provider.dart`) is the single source of the chosen language; `main()`
  creates it before `runApp`, so the first frame is already in the right language. The picker is
  `lib/screens/language_settings_screen.dart`.
- Fonts: bundled Noto Sans Malayalam and Noto Sans Devanagari are the theme's
  `fontFamilyFallback` (`AppTheme.fontFamilyFallback`); licences in `fonts/OFL-*.txt`.
- About screen: `assets/config/app_config.json` holds locale maps (`LocalizedText`); row labels
  come from ARB `aboutDetail<Key>`; the screen ends with the `MadeWithLove` badge
  (`lib/widgets/made_with_love.dart`, heart token `AppTheme.heartRed`).
- Accessibility expectations:
  - Minimum touch target: 48 x 48 dp on mobile
  - Color contrast: target WCAG AA minimum
  - Screen reader: should be checked before release on Android primary flows
  - Text scale: layouts should continue working at larger text scales

---

## 17. Logging

- Logger implementation: `debugPrint` only; no dedicated logging package
- Log file location: none
- Log rotation policy: none
- Verbose logging gate:
  [`lib/config/app_flavor_config.dart`](../lib/config/app_flavor_config.dart)
  via `AppFlavorConfig.enableVerboseLogging`
- Sensitive data policy: secrets, keys, recovery data, and decrypted payloads must never be logged

---

## 18. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | Services, models, providers, and flavor config | Includes OTP vectors, encryption round-trips, auth, DB, and import/export |
| Widget | Home and security flows | Covers selected UI behavior and provider interactions |
| Integration | Not committed currently | Manual device validation still required for release flows |
| Performance | Manual | Release-build smoke testing required before distribution |

### Test Layout

```text
test/
|-- config/
|-- models/
|-- providers/
|-- services/
`-- widgets/
```

### Critical Test Areas

- RFC-based HOTP/TOTP generation and parsing
- Encryption round-trips and rejection of old formats
- App lock, recovery-key, and lockout behavior
- Encrypted backup/import flows and duplicate-handling logic
- Root routing behavior when the app is locked vs unlocked

---

## 19. Operational Constraints

- Minimum supported OS versions:
  - Recorded only in [`PROJECT_PROFILE.md`](PROJECT_PROFILE.md) §3 (Android `minSdk 29`)
- Performance constraints:
  - Cold startup target: under 2 seconds to first meaningful frame in release builds
  - Frame budget: 16 ms at 60 Hz
  - APK size budget: monitor with `--analyze-size` before release; no separate hard budget is
    committed in this repo yet
- Regulatory or store constraints: standard mobile-store security and privacy requirements apply
- Team constraints: single-developer maintenance at present
- Offline constraints: no app network backend and no internet/HTTP client. The Android release
  manifest does include `INTERNET` (plus `ACCESS_NETWORK_STATE` / `ACCESS_WIFI_STATE`) solely for
  opt-in, foreground, same-LAN P2P sync.

---

## 20. Decisions And Tradeoffs

| Decision | Chosen Option | Why | Tradeoff |
|----------|---------------|-----|----------|
| State management | `Provider` with `ChangeNotifier` | Simple app-wide state model and low wiring overhead | Less explicit than a stricter architecture like Bloc or Riverpod |
| Persistence | `sqflite` + `flutter_secure_storage` | Good fit for local structured data plus device-backed secret storage | Manual schema/version management and plugin behavior differences by platform |
| Secret protection | AES-256-GCM with device-generated key | Strong local protection with authenticated encryption | Secret recovery depends on backups; rooted-device protection remains out of scope |
| Navigation gate | Root-widget lock/home switching | Keeps lock policy centralized and simple | No declarative route guard system or deep-link story |

---

## 21. Known Risks And Follow-Ups

- Risk: There is no centralized global error-handling layer yet.
  Mitigation: Keep failures local, show safe UI errors, and add global error capture if crash
  reporting or fatal-state handling is introduced.
- Risk: Release-only hardening and offline verification still depend on manual checklist discipline.
  Mitigation: Follow [`release_process.md`](release_process.md)
  for production builds and add automation over time.
- Risk: `flutter_slidable` and `percent_indicator` still render widgets from the SDK
  `package:flutter/material.dart`. They need `MaterialUiCompatibilityBridge`, which is deprecated
  as a temporary helper. Other packages import that library, but the app shows no widget from
  them that reads its theme.
  Mitigation: when updating dependencies, check whether each package has moved to
  `material_ui`; remove the bridge (and its `ignore` comment in `lib/main.dart`) once none is left.
  The app passes no theme or colour-scheme objects into these packages (analyze is clean).

---

## 22. Related Documents

- `README.md`
- `docs/release_process.md`
- `docs/security.md`

