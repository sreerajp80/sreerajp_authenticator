# Sreeraj P Authenticator

Flutter authenticator app for generating TOTP and HOTP codes with encrypted local storage, app lock, QR onboarding, grouped account management, and encrypted backup/restore.

## Overview

This project is an offline-first authenticator application built with Flutter and Provider. Secrets are stored locally in SQLite after device-side encryption, the encryption key is kept in `FlutterSecureStorage`, and the app can be protected with either an app PIN or the device's screen lock.

The repository includes the standard Flutter runners for Android, iOS, web, desktop, and tests. The implemented security model, permissions, and build flavor workflow are currently documented around the Android app, which is the primary target reflected in the codebase.

## Implemented Features

### OTP

- TOTP and HOTP support
- SHA-1, SHA-256, and SHA-512 algorithms
- Configurable digits and period
- QR parsing from `otpauth://` URIs
- Manual account entry
- Countdown display for time-based codes
- Clipboard copy from the account list

### Account Management

- Search by account name or issuer
- Group-based filtering
- Manual drag-and-drop ordering
- Sort by manual order, issuer, account name, or date added
- Swipe actions for edit and delete
- Sensitive edits gated behind app-lock verification when enabled

### Groups

- Create, edit, and delete custom groups
- Choose group colors and icons
- Reassign accounts when groups are removed

### Security

- AES-256-GCM for stored secrets with a 12-byte nonce
- Encryption key stored under `authenticator_key` in secure storage
- Screenshot and screen-recording protection enabled at app startup
- App lock with:
  - App PIN
  - Device screen lock
  - Optional biometric unlock for PIN mode
- PIN hashing with PBKDF2-HMAC-SHA256
- Recovery key flow for PIN-based lock mode
- Progressive lockout after failed PIN attempts
- Auto-lock when backgrounded or after timeout
- Decrypted OTP secrets cached briefly in memory and cleared on lock/background

### Backup And Restore

- Encrypted export and import through the in-app UI using password-protected `.aes` backups
- Backup encryption uses PBKDF2-HMAC-SHA256 plus AES-256-GCM
- Accounts and groups are restored without overwriting existing data
- Duplicate groups and accounts are skipped during import

### Migration Support

- Legacy XOR-encrypted secrets can be migrated forward
- Legacy AES-CBC account secrets are decrypt-only and migrated to GCM
- Older PIN storage is migrated from `SharedPreferences` to secure storage
- Older backup formats are still supported for decryption during import

## Security Model

- No network permission is declared in the Android manifest.
- Secrets are encrypted before they are written to the database.
- The encryption key is created on-device and persisted via `FlutterSecureStorage`.
- Android system backup is disabled with `android:allowBackup="false"` and `android:fullBackupContent="false"`.
- Camera permission is only needed for QR scanning.
- Biometric and fingerprint capabilities are optional.

Out of scope: this app does not try to protect against a fully compromised or rooted device. It is designed for strong local protection on a normal consumer device, not for hostile-system guarantees.

## User Flow

### Add an Account

1. Tap the floating action button on the home screen.
2. Choose QR scan or manual entry.
3. For manual entry, provide the account name and Base32 secret.
4. Optionally set issuer, digits, period, algorithm, and group.
5. Save the account. The secret is encrypted before persistence.

### Secure the App

1. Open `Settings` -> `Security`.
2. Enable app lock.
3. Choose either:
   - `App PIN`
   - `Phone Screen Lock`
4. If you choose `App PIN`, save the recovery key shown by the app.
5. Optionally enable biometric authentication for PIN mode.
6. Set the auto-lock timeout.

### Backup And Restore

1. Open `Settings` -> `Backup & Restore`.
2. Create an encrypted backup with a password.
3. Store the generated `.aes` file somewhere safe.
4. To restore, select the backup file and enter the same password.

## Tech Stack

| Area | Implementation |
|------|----------------|
| UI | Flutter Material |
| State management | Provider |
| Local database | `sqflite` |
| Secure key storage | `flutter_secure_storage` |
| Auth | `local_auth` |
| QR scanning | `mobile_scanner` |
| Encryption | `encrypt` + `pointycastle` |
| Sharing / file flows | `share_plus`, `file_picker`, `path_provider` |

## Project Structure

```text
lib/
|-- config/      Flavor configuration
|-- models/      Account and group models
|-- providers/   App state with Provider
|-- screens/     Route-level UI
|-- services/    OTP, auth, encryption, database, migration, import/export
|-- utils/       Constants and theme helpers
`-- widgets/     Reusable UI components

test/
|-- config/
|-- models/
|-- providers/
|-- services/
`-- widgets/
```

## Development Setup

### Prerequisites

- Flutter SDK
- Android SDK / Android Studio
- A connected Android device or emulator

### Install Dependencies

```bash
flutter pub get
```

### Run The App

Development flavor:

```bash
flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev
```

Production flavor:

```bash
flutter run --flavor prod --dart-define=FLUTTER_APP_FLAVOR=prod
```

The `--dart-define` value matters because the in-app flavor config reads `FLUTTER_APP_FLAVOR` to control the app name, environment label, and the `DEV` banner.

## Android Flavors

| Flavor | Package ID | App Name | Purpose |
|--------|------------|----------|---------|
| `dev` | `in.sreerajp.sreerajp_authenticator.dev` | `Sreeraj P Authenticator Dev` | Local development and internal testing |
| `prod` | `in.sreerajp.sreerajp_authenticator` | `Sreeraj P Authenticator` | Release builds |

## Common Commands

Run tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Build a development APK:

```bash
flutter build apk --flavor dev --debug --dart-define=FLUTTER_APP_FLAVOR=dev
```

Build production split APKs:

```bash
flutter build apk --flavor prod --release --split-per-abi --dart-define=FLUTTER_APP_FLAVOR=prod
```

Build a Play Store bundle:

```bash
flutter build appbundle --flavor prod --release --dart-define=FLUTTER_APP_FLAVOR=prod
```

## Testing Scope

The current test suite covers:

- OTP generation and RFC 4226 HOTP vectors
- OTP URI parsing and generation
- Encryption round-trips and legacy decryption paths
- Authentication and recovery-key logic
- Database, migration, export/import, providers, and home widgets
- Flavor configuration

## Notes And Limitations

- The app is designed to work fully offline.
- QR scanning requires camera permission.
- Correct device time is critical for TOTP accuracy.
- The current in-app backup UI is focused on encrypted `.aes` backups.
- JSON and CSV export helpers still exist in the service layer for compatibility, but they are not the primary user-facing backup flow in the current screens.

## Related Docs

- `docs/project_structure.md`
- `docs/flutter_build_flavors_guide.md`
- `docs/release_process.md`

## License

This project is developed by Sreeraj P. See `LICENSE`.
