# Architecture

This document describes the current implementation of the Sreeraj P Authenticator Flutter app.

## 1. Scope

- Product: `Sreeraj P Authenticator`
- Repository type: `application`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`
- Platforms in repository:
  - `Android` (primary target)
  - `iOS` (runner present)
  - `Windows` (runner present)

---

## 2. Goals And Non-Goals

### Goals

- Generate TOTP and HOTP codes fully offline.
- Protect locally stored secrets with device-side encryption and app-lock controls.
- Support QR onboarding, grouped account management, and encrypted backup/restore.

### Non-Goals

- Cloud sync, server-side account storage, or remote account recovery.
- Protection against a fully compromised, rooted, or otherwise hostile device.

---

## 3. Architecture Summary

The app uses a Tier 1 Flutter structure with `Provider` for app state, `sqflite` for local
persistence, `flutter_secure_storage` for secret and key material, and service classes for OTP,
encryption, authentication, migration, and import/export logic. The app is intentionally offline:
accounts, groups, lock settings, and encrypted backups are handled locally on-device without any
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
| `lib/models/` | Account and group data models and mapping |
| `lib/providers/` | App state, lock policy, filtering, and theme state |
| `lib/screens/` | Route-level UI and user flows |
| `lib/services/` | OTP, crypto, auth, migration, backup/import, and database logic |
| `lib/widgets/` | Reusable UI pieces shared by screens |
| `lib/utils/` | Constants, theme definitions, and shared helper content |

---

## 5. App Initialization Sequence

Documented from [`lib/main.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/main.dart).

| Step | Code / Call | Notes |
|------|-------------|-------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | Always first |
| 2 | `SystemChrome.setPreferredOrientations(...)` | Restricts app to portrait orientations |
| 3 | `SystemChrome.setSystemUIOverlayStyle(...)` | Transparent status and navigation bars |
| 4 | `ScreenProtector.protectDataLeakageOn()` | Enables platform screenshot/data-leak protection hooks |
| 5 | `ScreenProtector.preventScreenshotOn()` | Applies screenshot blocking; on Android this sets `FLAG_SECURE` |
| 6 | `runApp(const MyApp())` | Starts the widget tree |

Deferred initialization:

- `SettingsProvider` loads persisted settings lazily after `runApp`.
- Database opening is lazy in [`lib/services/database_service.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/services/database_service.dart).
- Encryption-key bootstrap is lazy in [`lib/services/encryption_service.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/services/encryption_service.dart).
- Accounts and groups load only after settings initialization and only when the app is not locked.

---

## 6. App Lifecycle Behavior

Primary lifecycle handling is implemented in [`lib/main.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/main.dart) and supported by `SettingsProvider`.

| Lifecycle State | App Behavior |
|----------------|--------------|
| `resumed` | Re-evaluates lock policy through `SettingsProvider.onAppResumed()` |
| `inactive` | Does not lock; intentionally ignores transient overlays like dialogs and calls |
| `paused` | Locks the app if app lock is enabled and clears decrypted OTP cache |
| `detached` | No custom handler today |
| Memory pressure | No explicit custom handler today |

---

## 7. Offline Behavior

- **Connectivity requirement**: `fully offline`
- **Network permission**: Android main manifest does not request `INTERNET`; debug/profile manifests add it for tooling only
- **Offline data sources**:
  - `sqflite` for accounts and groups
  - `SharedPreferences` for non-secret settings
  - `flutter_secure_storage` for keys, PIN hashes, and recovery material
  - Temporary files for export/share flows

Implications:

- Production Android builds should keep `INTERNET` absent from the merged release manifest.
- There is no app-owned backend and no intentional network client in the Dart code.
- The current automated coverage is unit and widget testing; there is not yet a dedicated
  airplane-mode integration test committed in this repo.

---

## 8. State Management

- Primary pattern: `Provider`
- Why this pattern was chosen:
  - The app has a small number of app-wide state domains: settings, accounts, groups, and theme.
  - `ChangeNotifier`-based providers are sufficient and keep the app wiring simple.
- State boundaries:
  - Widgets own: form inputs, visual expansion state, loading indicators, and local interaction state
  - Providers own: lock state, theme mode, account/group collections, filtering, sort, and import state
  - Services own: OTP generation, encryption, persistence, migrations, authentication, and backup logic

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
  [`lib/main.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/main.dart).
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

SQLite schema version: `2`

Migration history:

| Version | Change Summary |
|---------|---------------|
| 1 | Initial schema with `accounts` and `groups` tables |
| 2 | Added `groups.icon` and `groups.createdAt` |

### Core Models Or Entities

| Type | Purpose | Mutable? | Notes |
|------|---------|----------|-------|
| `Account` | Stores OTP account metadata and the encrypted secret | `Yes` | Supports TOTP and HOTP, issuer, algorithm, digits, period, grouping, and ordering |
| `Group` | Stores UI grouping metadata for accounts | `Yes` | Includes name, description, color, icon, sort order, and optional timestamp |

### Serialization Strategy

- JSON models: `yes`
- Database models: `yes`
- Separate domain entities from transport models: `no`; the same `Account` and `Group` models are
  used for DB mapping and backup/import JSON

### Database Indexes

| Table | Indexed Columns | Reason |
|-------|----------------|--------|
| `accounts` | none explicit | Current queries are simple and use sort order plus created timestamp |
| `groups` | none explicit | Current queries are simple and use sort order plus name |

---

## 12. Dependency Management And Injection

- DI approach: provider tree plus manual service construction inside providers and services
- App-root dependencies:
  - `ThemeProvider`
  - `SettingsProvider`
  - `GroupsProvider`
  - `AccountsProvider`
- Test replacement strategy:
  - Platform-channel mocks for `flutter_secure_storage`
  - In-memory or test-path `sqflite` databases
  - Unit tests around services and providers instead of runtime DI overrides

---

## 13. Navigation

- Navigation approach: `Navigator 1.0`
- Route definition location: route-level screens are pushed directly from widgets; app root is in
  [`lib/main.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/main.dart)
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

- Network client: `none`
- Offline behavior: `fully offline`

### Platform Channels Or Native Integrations

- `screen_protector`: screenshot and screen-recording protection
- `local_auth`: device lock and biometric authentication
- `mobile_scanner`: QR scanning
- `flutter_secure_storage`: key and secret-material storage
- `device_state_service` method channel: boot-count checks for adaptive unlock policy

---

## 15. Environment And Build Model

- Flavors used: `dev`, `prod` on Android
- Runtime config mechanism: `--dart-define=FLUTTER_APP_FLAVOR=<value>`
- Build outputs currently documented and used:
  - `debug APK`
  - `release APK`
  - `release app bundle`
- Additional runners: iOS and Windows runners are present, but Android is the primary documented
  release target today
- Obfuscation: should be enabled explicitly for production release builds with
  `--obfuscate --split-debug-info=build/symbols/android-prod-2.4.0+1/` for the current Android prod release

---

## 16. UI System

- Theme source of truth:
  [`lib/utils/theme.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/utils/theme.dart)
- Design tokens location: colors, spacing, and themed component styles currently live in
  [`lib/utils/theme.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/utils/theme.dart)
- Shared widget strategy: reusable components live under `lib/widgets/`
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
  [`lib/config/app_flavor_config.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/config/app_flavor_config.dart)
  via `AppFlavorConfig.enableVerboseLogging`
- Sensitive data policy: secrets, keys, recovery data, and decrypted payloads must never be logged

---

## 18. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | Services, models, providers, and flavor config | Includes OTP vectors, encryption round-trips, migration, auth, DB, and import/export |
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
- Encryption round-trips and legacy format decryption
- SQLite schema migration from version 1 to 2
- App lock, recovery-key, and lockout behavior
- Encrypted backup/import flows and duplicate-handling logic
- Root routing behavior when the app is locked vs unlocked

---

## 19. Operational Constraints

- Minimum supported OS versions:
  - Android: `21+`
  - iOS and Windows runners: present, but not the primary release target documented here
- Performance constraints:
  - Cold startup target: under 2 seconds to first meaningful frame in release builds
  - Frame budget: 16 ms at 60 Hz
  - APK size budget: monitor with `--analyze-size` before release; no separate hard budget is
    committed in this repo yet
- Regulatory or store constraints: standard mobile-store security and privacy requirements apply
- Team constraints: single-developer maintenance at present
- Offline constraints: no app network backend and no Android release `INTERNET` permission

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
  Mitigation: Follow [`docs/release_process.md`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/docs/release_process.md)
  for production builds and add automation over time.

---

## 22. Related Documents

- `README.md`
- `docs/release_process.md`
- `docs/security.md`

