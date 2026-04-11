# Security

This app is security-sensitive. It stores OTP secrets locally, protects them with authenticated
encryption, and gates access with app-lock controls.

---

## 1. Security Scope

- App: `Sreeraj P Authenticator`
- Data sensitivity level: `high`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Sensitive Data Extension`
- Platforms in scope:
  - `Android` (primary target)
  - `iOS` (runner present)
  - `Windows` (runner present)

---

## 2. Security Objectives

- Protect locally stored OTP secrets and recovery material against casual extraction on a normal
  consumer device.
- Prevent accidental disclosure through logs, screenshots, backups, or weak storage locations.
- Preserve migration and recovery compatibility without weakening current encryption.

---

## 3. Threat Model Summary

### In Scope Threats

- Lost or stolen device
- Casual local access by another user of the same device
- Plaintext disclosure through logs or backups
- Reverse engineering of the release binary
- Accidental disclosure through screenshots or screen recording

### Out Of Scope Threats

- Fully compromised or rooted devices
- OS-level compromise
- Physical hardware attacks
- Nation-state or advanced forensic adversaries

---

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| OTP secret | Base32 seed / decrypted OTP secret | Encrypted in SQLite, briefly decrypted in memory | AES-256-GCM at rest, clear cache on lock/background |
| Device encryption key | `authenticator_key` | `flutter_secure_storage` only | Never log, never store in SQLite or prefs |
| App PIN verifier | PBKDF2 hash + salt | `flutter_secure_storage` | Strong KDF, no plaintext PIN persistence |
| Recovery key verifier | PBKDF2 hash + salt | `flutter_secure_storage` | One-way storage only |
| Account metadata | Account name, issuer, group, settings | SQLite / `SharedPreferences` | Keep out of logs and backups unless encrypted or intentionally exported |

---

## 5. Storage Model

### At Rest

- Primary local storage: `sqflite` database `authenticator.db`
- Secure key storage: `flutter_secure_storage`
- Settings storage: `SharedPreferences` for non-secret preferences and lock policy metadata
- Android backup behavior:
  - `android:allowBackup="false"`
  - `android:fullBackupContent="false"`

### In Memory

- Sensitive values are kept in memory: `briefly`
- Memory clearing strategy:
  - OTP cache TTL is 5 minutes
  - OTP cache is cleared when the app is paused or locked
  - Export flows use temporary files that are deleted after the share attempt

### In Transit

- Network use: `none`
- Transport protections: `not applicable`

---

## 6. Cryptography Design

- Encryption algorithm for stored account secrets: `AES-256-GCM`
- Device-key strategy: random 32-byte key generated on-device and stored under
  `authenticator_key` in secure storage
- PIN and recovery-key derivation: `PBKDF2-HMAC-SHA256` with `300000` iterations and a 16-byte salt
- Nonce or IV strategy:
  - Account secret encryption: random 12-byte GCM nonce
  - Backup encryption: random 12-byte GCM nonce plus random 16-byte salt
- Format versioning:
  - Account secrets: current `nonce:ciphertext` GCM format, with legacy XOR and AES-CBC decrypt support
  - Backups: current `v3:<salt>:<nonce>:<ciphertext>` format with legacy `v2` and CTR/SIC decrypt support
- Legacy format support: `yes`, for migration and backward-compatible imports

### Rules

- Keys, IVs, salts, and passwords are not hardcoded.
- Randomness uses secure random generation.
- Encrypted formats are versioned or format-distinguished for migration compatibility.

---

## 7. Authentication And Access Control

- App-lock strategy:
  - `App PIN`
  - `Phone Screen Lock`
  - optional biometric unlock through `local_auth` on supported devices
- Fallback behavior:
  - If quick unlock is unavailable or disallowed, the app requires the app PIN
- Session-expiry rule:
  - Strong auth is required again after 1 hour
  - Strong auth is required after device reboot
  - Strong auth is required after 3 failed quick-unlock attempts
  - Lockdown mode forces app PIN entry
- Background lock rule: triggered on `AppLifecycleState.paused`
- Protected-route strategy: app root switches between lock and home based on `SettingsProvider`
- Lock screen implementation:
  [`lib/screens/lock_screen.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/lock_screen.dart)

---

## 8. Binary Protections

### 8.1 Obfuscation

Production Android builds should be compiled with:

```powershell
--obfuscate --split-debug-info=build/symbols/android-prod-2.4.0+1/
```

This is part of the release process and should be applied to any distributable prod build.

### 8.2 R8 / ProGuard

Android release builds enable minification and resource shrinking in
[`android/app/build.gradle.kts`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/android/app/build.gradle.kts).

Current caution:

- [`android/app/proguard-rules.pro`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/android/app/proguard-rules.pro)
  is minimal and currently disables Java/Kotlin obfuscation with `-dontobfuscate`.
- Review this file whenever new dependencies are added.

### 8.3 Debuggable Flag

`android:debuggable` must remain `false` in release builds. Verify the merged release manifest
before distribution.

---

## 9. Logging And Telemetry Policy

### Never Log

- OTP secrets
- Encryption keys
- Recovery keys
- Decrypted payloads
- Full backup contents
- Raw secure-storage values

### Allowed Diagnostic Context

- Operation or screen name
- High-level error category
- Non-sensitive identifiers when justified

### Logging Controls

- Logger implementation: `debugPrint`
- Verbose logging gate:
  [`lib/config/app_flavor_config.dart`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/config/app_flavor_config.dart)
  via `AppFlavorConfig.enableVerboseLogging`
- Log level in production: keep logs minimal
- Redaction strategy: do not log secret-bearing values in the first place

The app currently has no analytics or telemetry backend.

---

## 10. Platform Security Controls

### Android

- `android:allowBackup`: `false`
- `android:fullBackupContent`: `false`
- Screenshot protection:
  - Enabled at app startup through `screen_protector`
  - Intended to prevent screenshots and screen recording on sensitive views
- `android:debuggable`: must be `false` in release builds
- Root detection: none implemented

### iOS

- Keychain usage: `flutter_secure_storage` uses the platform secure store
- Privacy descriptions in `Info.plist`:
  - `NSCameraUsageDescription`
  - `NSFaceIDUsageDescription`
  - `NSPhotoLibraryUsageDescription`
- ATS: no custom `NSAllowsArbitraryLoads` setting is declared
- Sensitive-screen app-switcher overlay: not implemented in the current iOS runner

### Windows

- Secret storage is provided through the `flutter_secure_storage` Windows plugin
- Sensitive files should remain in app-private support or temp directories
- No Windows Event Log integration is implemented

---

## 11. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| `CAMERA` | Scan OTP QR codes | When entering the QR scan flow | User can still add accounts manually |
| `USE_BIOMETRIC` / `USE_FINGERPRINT` | Unlock via local-auth capabilities | When enabling or using quick unlock | App falls back to app PIN or device lock support checks |
| `VIBRATE` | Minor haptic feedback | During supported UI interactions | App remains functional without it |
| `NSPhotoLibraryUsageDescription` | Import encrypted backup files on iOS flows | At point of file selection | Backup import remains unavailable until granted |

Permission review rules:

- Android prod builds should not include `INTERNET`.
- Request permissions only at the point of use.
- The app should remain usable in a safe degraded mode when non-critical permissions are denied.

---

## 12. OWASP Mobile Top 10 Alignment

| ID | Risk | Current Control | Status |
|----|------|-----------------|--------|
| M1 | Improper Credential Usage | No hardcoded secrets; secure storage for key material | `implemented` |
| M2 | Inadequate Supply Chain Security | `pubspec.lock` committed; dependency review still manual | `manual review` |
| M3 | Insecure Authentication | App lock, PIN hashing, quick unlock policy, lockouts | `implemented` |
| M4 | Insufficient Input/Output Validation | OTP parsing, import parsing, and DB writes are handled in code | `implemented` |
| M5 | Insecure Communication | No app network traffic | `implemented` |
| M6 | Inadequate Privacy Controls | Screenshot blocking, no secrets in logs, backups encrypted in UI flow | `implemented` |
| M7 | Insufficient Binary Protections | Release hardening is documented but still checklist-driven | `manual review` |
| M8 | Security Misconfiguration | Minimal permissions, backup disabled on Android | `implemented` |
| M9 | Insecure Data Storage | Secrets encrypted in SQLite and key material isolated in secure storage | `implemented` |
| M10 | Insufficient Cryptography | AES-256-GCM, PBKDF2-HMAC-SHA256, migration-aware formats | `implemented` |

---

## 13. Data Retention And Purge Policy

### Retention Schedule

| Data Type | Retention Period | Deletion Trigger |
|-----------|------------------|-----------------|
| Accounts and groups | Until user deletes them or uninstalls the app | User delete flow or uninstall |
| PIN / recovery verifiers | Until user disables app lock or resets it | App-lock reset or uninstall |
| Temporary backup export files | Session only | Deleted after share attempt |
| Cached OTP values | Up to 5 minutes, or less on lock/background | Cache expiry, lock, or app pause |

### Purge Implementation

- The repo does not currently implement a single in-app "Delete all data" action.
- Data is primarily removed through individual delete flows, app-lock reset flows, or uninstall.
- Temporary export files are created in the temporary directory and deleted in the same session.

### Data Purge On Uninstall

- Android: app data is removed on uninstall and cloud backup is disabled in the manifest
- iOS: Keychain persistence across reinstall should be considered if iOS becomes a primary release target
- Windows: credential persistence across reinstall should be considered if Windows becomes a primary release target

---

## 14. Backup, Import, Export, And Recovery

- Backup supported: `yes`
- Backup format: encrypted `.aes` file in the primary UI flow
- Import supported: `yes`
- Recovery flows:
  - Encrypted backup restore using the backup password
  - App-lock recovery key for PIN reset
- Plaintext export policy:
  - Primary UI is encrypted backup only
  - Legacy JSON and CSV export helpers still exist in the service layer and should not be treated as the recommended path

### Validation Requirements

- Import parsing must reject malformed or incompatible backup data safely.
- Backup files must remain encrypted in normal user-facing flows.
- Recovery and migration flows must be tested when changed.

---

## 15. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| OTP and crypto logic | Unit | Includes deterministic OTP vectors and encryption/decryption coverage |
| Secret storage | Unit | Secure-storage channel mocks are used in tests |
| Lock / auth flow | Unit and widget | Covers PIN validation, recovery, lockouts, and settings policy |
| Backup and recovery | Unit | Export/import parsing and legacy format support are tested |
| Data migration | Unit | Legacy XOR, AES-CBC, and old PIN storage migration paths are covered |
| Release hardening | Manual release verification | Obfuscation, permissions, and debuggable checks are checklist-driven |

### Required Regression Areas

- RFC 4226 HOTP vectors
- OTP URI parsing and generation
- AES-GCM secret encryption and legacy decrypt compatibility
- Backup format compatibility across current and legacy versions
- SQLite schema migration from v1 to v2
- Lockout and strong-auth policy transitions

---

## 16. Incident Response Notes

- Triage owner: `Sreeraj P`
- Severity model: `critical`, `high`, `medium`, `low`
- Immediate containment actions:
  - Stop distributing the affected build
  - Patch and rebuild the prod artifact
  - Re-check lock, migration, and backup paths
- User communication trigger: notify users if a shipped build can expose secrets, break lock
  guarantees, or corrupt imported/exported data
- Patch release process reference:
  [`docs/release_process.md`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/docs/release_process.md)

---

## 17. Open Risks And Future Hardening

- Risk: Release binary hardening is documented but not fully automated in tooling.
  Hardening option: add automated release-build verification and symbol-archive steps.
- Risk: iOS and Windows uninstall/reinstall secret persistence behavior is not yet fully managed for
  a primary release target.
  Hardening option: add first-run reinstall detection and secure-store cleanup rules if those
  platforms move into active distribution.

---

## 18. Security Review Checklist

- [ ] Threat model reviewed after security-sensitive changes
- [ ] Sensitive data inventory still matches the implementation
- [ ] No new logs expose secret or decrypted data
- [ ] Android permissions reviewed in the merged prod manifest
- [ ] `--obfuscate` used for the prod release build
- [ ] Debug symbols archived securely
- [ ] `android:debuggable=false` verified in the release manifest
- [ ] Backup, lock, migration, and recovery paths tested if changed
- [ ] Release checklist in `docs/release_process.md` completed
