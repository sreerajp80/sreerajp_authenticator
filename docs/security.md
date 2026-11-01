# Security — Sreeraj P Authenticator

This document governs the security architecture, threat model, sensitive data inventory, encryption design, session policy, and security testing checklist for Sreeraj P Authenticator. Read this before touching permissions, crypto, secure storage, authentication, or logging.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [PROJECT_PROFILE.md](PROJECT_PROFILE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md) | [guidelines/security.md](guidelines/security.md)

The `Sensitive Data Extension` applies, so this file is filled in **in full**.

---

## 1. Security Scope

- App: `Sreeraj P Authenticator`
- Data sensitivity level: `high`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`
- Platforms in scope (declared in [`PROJECT_PROFILE.md`](PROJECT_PROFILE.md) §3):
  - `Android` (the only platform)

### 1.1 Security Baseline (Every App)

Each line is `verified`, `n/a` (with a short reason), `failed` (a known gap, see §17), or
`to verify` until it has been checked. The rules are in engineering standard §15.1. Re-check this
list before every production release. Last checked for the "Delete all data" change
([`../plans/20261031_181352_android-release-blockers.md`](../plans/20261031_181352_android-release-blockers.md)),
which added no new entry point, permission or dependency.

| Area | Rule | Status |
|------|------|--------|
| Secrets | No real secrets in code, assets, `--dart-define` or native config; shipped keys restricted by the provider | `verified` — no key or token in tracked code, assets or native config; no `--dart-define`; no shipped provider keys |
| Network | HTTPS only; certificate checks never disabled; cleartext off; timeouts set | `verified` for app code — no HTTP client or certificate override in `lib/`; cleartext off in the manifest; Wi-Fi sync over local TCP is sealed at the payload layer and has timeouts (§5.1) |
| Tokens | Sign-in tokens and credentials only in platform secure storage; removed on sign-out | `n/a` — no sign-in or accounts |
| Sign-in | OAuth/OIDC with PKCE via the system browser, platform sign-in or passkeys; server enforces access | `n/a` — no sign-in and no server |
| Outside input | Intents, imports, payloads, clipboard, QR codes validated (§3.1); parameterized SQL; no path traversal | `verified` — §3.1; backup files have a size limit and the sync limits; every SQL statement uses bound values or fixed text; no file path is built from input |
| Deep links | No sensitive action without user confirmation; verified links for callbacks | `n/a` — no deep links registered (launcher intent only) |
| WebView | Not used, or allowlisted HTTPS origins, JavaScript only if needed, no bridge to untrusted content | `n/a` — the app opens no WebView. `url_launcher` declares an unexported `WebViewActivity`, which the app does not ask for |
| Platform hardening | Android components not exported unless needed; `PendingIntent` immutable; narrow `FileProvider`; private app folders | `verified` — exported: launcher activity and AndroidX `ProfileInstallReceiver` (needs the `DUMP` permission); no `FileProvider` from backup export (it uses the system save screen); no `PendingIntent` in app code |
| Randomness / crypto | `Random.secure()` for security values; standard, maintained crypto libraries only | `verified` — only `Random.secure()` and secure IVs in `lib/`; libraries are `pointycastle` / `encrypt` / `crypto` |
| Release build | No debug menus, test accounts or backdoors; `debuggable=false`; `--obfuscate` | `verified` on the prod release APK — not debuggable, built with `--obfuscate`, symbols written; dev tools are behind `AppFlavorConfig` |
| Third-party SDKs | Each SDK listed in §4 with what it collects; no secrets or PII in crash reports or analytics | `verified` — none in `pubspec.yaml` or the release APK (§4) |
| Data minimization | Only data that a feature needs is collected and kept | `verified` for app code — account data only, kept on the device |
| Web (if declared) | No secrets in the web bundle; Content Security Policy set where hosting allows | `n/a` — Web is not a declared platform |

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
- Passive eavesdropping or active MITM on the local network during P2P sync (see §5.1)
- Hostile input: crafted QR codes, corrupted or malicious backup files, a hostile sync peer

### Out Of Scope Threats

- Fully compromised or rooted devices
- OS-level compromise
- Physical hardware attacks
- Nation-state or advanced forensic adversaries
- An attacker who already knows the per-session P2P pairing code (it is shown only on the host
  screen and transferred by the user out-of-band)

### 3.1 Entry Points And Attack Surface

Every way data reaches the app from outside, and how each is checked (engineering standard
§15.1, "Input from outside the app").

| Entry Point | Example | Validation | Sensitive Action Possible? |
|-------------|---------|------------|----------------------------|
| Android intent | Launcher `MAIN` intent only; no share target, no deep link | No data read from the intent | No |
| QR code (camera) | `otpauth://totp/...` | Parsed by `OTPService.parseOtpAuthUri`; null or empty secret rejected with a message | No — user reviews before the account is saved |
| Google Authenticator export QR (camera) | `otpauth-migration://offline?data=…` | `GoogleMigrationService.parse`: input size limit, every Protobuf length checked against the bytes left, varints limited to 10 bytes, field size limits. A broken QR code is rejected as a whole; a bad account becomes a problem entry. Errors hold codes only, never scanned data | No — user chooses on a review screen, then the import funnel (`AccountsProvider.importData`) |
| Sync QR (camera) | `spauth://sync?v=1&ip=…&port=…&code=…` | `P2pSyncService.parseSyncQrPayload` rejects foreign scheme/host/version, bad port, empty code | No — only starts the normal join flow |
| Optical sync frames (camera) | Chunked QR frames (version 2) | Version 1 (plaintext) frames refused; CRC32 per chunk, parity chunks, AES-256-GCM tag check with the one-time transfer code (§5.2), then the import funnel | No — goes through `AccountsProvider.importData` |
| File import | Encrypted `.aes` backup via the system file picker | 16 MB size check before reading; password-based decryption; the Wi-Fi sync limits on account count and field length; malformed data rejected (§14) | No — add-only import |
| Wi-Fi sync socket (local network) | Peer TCP connection | Pairing-code key, AES-256-GCM tag check, 4 KB / 16 MB line caps, payload caps, timeouts (§5.1) | No — add-only import, fill-only settings |
| Clipboard | Copied OTP code, recovery key, sync code | App only writes, through `ClipboardService`; reads only to clear its own copied secret (codes 30 s, recovery key and pairing code 60 s) | No |
| Platform channels | Plugins (`local_auth`, `camera`, `flutter_zxing`, `flutter_secure_storage`, …) | Results are `bool` or typed plugin objects; the app's own channels take or return one typed value (`getBootCount`, `setSensitiveText`) | No |

---

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| OTP secret | Base32 seed / decrypted OTP secret | Encrypted in SQLite, briefly decrypted in memory | AES-256-GCM at rest, clear cache on lock/background |
| Device encryption key | `authenticator_key` | `flutter_secure_storage` only | Never log, never store in SQLite or prefs |
| App PIN verifier | PBKDF2 hash + salt | `flutter_secure_storage` | Strong KDF, no plaintext PIN persistence |
| Recovery key verifier | PBKDF2 hash + salt | `flutter_secure_storage` | One-way storage only |
| Account metadata | Account name, issuer, group, settings | SQLite / `SharedPreferences` | Keep out of logs and backups unless encrypted or intentionally exported |

### Third-Party SDKs

No analytics, ads, crash-reporting or other SDK that sends data off the device is used.

| SDK | What It Collects | Where It Sends It | Why It Is Needed |
|-----|------------------|-------------------|------------------|
| none | — | — | — |

QR decoding uses `flutter_zxing` (MIT, with zxing-cpp), which runs on the device. Its one network path,
`readBarcodeImageUrl`, is never called by the app.

History: until this change, `mobile_scanner` brought in closed-source Google ML Kit, and a debug build sent
`FIREBASE_ML_SDK` events to `firebaselogging.googleapis.com`. The current release APK has no ML Kit, Firebase,
Google Play services or data transport code in its `classes.dex`, and the emulator test showed no traffic for
the app. A release build on a real phone scanned a QR code, with no traffic recorded for the app. Optical sync of 200 test accounts,
from an emulator window to that phone, also worked, in very roughly 3 to 5 minutes (timed by eye).

---

## 5. Storage Model

### At Rest

- Primary local storage: `sqflite` database `authenticator.db`
- Secure key storage: `flutter_secure_storage`
- Settings storage: `SharedPreferences` for non-secret preferences and lock policy metadata
  (including the UI language choice `app_language`: `system` / `en` / `ml` / `sa`; not sensitive)
- Android backup behavior:
  - `android:allowBackup="false"`
  - `android:fullBackupContent="false"`
  - `android:dataExtractionRules` excludes all data from cloud backup and device transfer

### In Memory

- Sensitive values are kept in memory: `briefly`
- Memory clearing strategy:
  - OTP cache TTL is 5 minutes
  - OTP cache is cleared when the app is paused or locked
  - Export flows use temporary files that are deleted after the share attempt

### In Transit

- Network use: `P2P LAN sync only` (no internet/HTTP traffic; no app backend)
- Transport protections: the transport (plain TCP) is **not** encrypted; confidentiality and
  integrity are enforced at the payload layer (see §5.1). OTP secrets cross the wire only as
  AES-256-GCM ciphertext keyed by the out-of-band pairing code.

**HOTP counter.** The counter is not a secret. It is saved (`DatabaseService.setHotpCounter`) before
a code is shown, so a code is never shown twice; if the save fails, no code is shown.

### 5.1 P2P LAN Sync Security Model

Implemented in
[`lib/services/p2p_sync_service.dart`](../lib/services/p2p_sync_service.dart).
Opt-in, user-initiated, foreground-only, same-LAN device-to-device transfer of accounts,
and a small set of non-sensitive settings. No server, no account, no internet.

- **Secret never on the wire.** A fresh ~320-bit pairing code (64 chars from a 31-symbol alphabet)
  is generated per session, shown only on the host, and transferred to the client out-of-band. It is
  never transmitted over the network. An eavesdropper can capture the entire handshake and still
  cannot derive the key; an active MITM cannot complete the handshake without the code.
- **Out-of-band transfer: typed or scanned.** The host details (IP, port, code) may be typed on the
  client manually, or the host may display them as a QR (`spauth://sync?v=1&ip=…&port=…&code=…`,
  built by `P2pSyncService.buildSyncQrPayload`) that the client scans with its camera. The QR is an
  out-of-band channel identical in trust to typing: it is rendered only on the host screen and read
  by the peer's camera, and is **never sent over the network**. It carries the same secret already
  shown on-screen as text, so it does not increase exposure, and app-wide screenshot blocking
  (`screen_protector`, on unless the user turned it off) still applies. A scanned QR is parsed and validated by
  `P2pSyncService.parseSyncQrPayload` (foreign scheme/host/version, bad port, or empty code are
  rejected) before it feeds the normal join flow.
- **Foreground session, no mid-sync lock.** While the sync screen is active, idle/background
  auto-lock is intentionally suppressed (`SettingsProvider.setSyncInProgress`, mirroring the backup
  flag) so a host waiting for a peer is not locked out and the session torn down mid-transfer. This
  is scoped to the sync screen and cleared on exit; it does not disable the lock elsewhere.
- **Payload-layer authenticated encryption.** The pairing code is stretched with
  PBKDF2-HMAC-SHA256 (300,000 iterations, per-session random 16-byte salt sent in clear) to a
  256-bit key; every line is sealed with AES-256-GCM (random 12-byte nonce, 128-bit tag).
  Authentication is a side effect of decryption — a wrong code derives a wrong key and GCM tag
  verification fails, which is treated as an auth failure and aborts. There is no fallback cipher
  and no downgrade path.
- **Sender chooses after connect; connection held open.** The host does not push data the instant a
  peer authenticates. On successful auth it sends the encrypted accept immediately (so the peer knows
  it is connected) and then **holds the connection open**; the sender then chooses what to share
  (Full Sync, or a selective incremental sync) and the payload is pushed on that action via
  `P2pSyncService.sendToConnectedClient`. The client waits for that payload up to
  `AppConstants.syncPayloadWaitTimeout` (10 min). Only one client is held at a time; further
  connection attempts are closed. This changes the timing of the transfer, not its trust model — the
  same per-session key seals the accept and the payload.
- **Only non-sensitive settings sync; device-specific security state never leaves.** The payload may
  include a small `settings` object limited to theme mode, auto-lock timeout, and sync-host idle
  timeout (`SettingsProvider.syncableSettingsSnapshot`). App lock enablement, the App PIN, phone-lock
  / biometric quick-unlock, the recovery key, lockdown, and boot / adaptive-auth state are
  **device-specific and never transmitted**. On the receiver, a Full Sync (fresh device) applies
  these settings; an incremental sync applies a setting only if the receiver has not already set it
  (`SettingsProvider.applySyncedSettings`, fill-only), so the receiver's own choices and data are
  never overridden.
- **Forward secrecy.** Keys are per-session; there is no long-term sync key to steal.
- **Secret lifecycle.** On the host, secrets are decrypted with the device key and re-encrypted
  under the session key only transiently to build the payload. On the client, received secrets are
  re-encrypted under the receiving device's own key by the import funnel
  (`AccountsProvider.importData`) before storage. Plaintext exists only briefly in memory and is
  never logged or written to disk.
- **Hostile-peer hardening.** Even after authentication the peer is untrusted: bounded line reads
  (4 KB handshake / 16 MB payload caps) prevent memory exhaustion, socket/connect timeouts resist
  slow-loris/DoS, and payload caps (max accounts, per-field length, schema checks) are
  enforced *before* ingestion.
- **Exposure minimisation.** The host binds a **random OS-assigned port** (displayed to the user)
  and **auto-stops** after a configurable idle timeout (`SettingsProvider.syncHostIdleTimeout`,
  default 120 s, 30–600 s) if no peer completes the handshake. The random port is conflict
  avoidance and mild defense-in-depth only — it is **not** a security boundary, since a LAN
  attacker can port-scan; security rests entirely on the pairing code and GCM sealing.

### 5.2 Optical Air-Gap Sync Security Model

- **Threat.** The sending screen shows the stream for anyone in view: people nearby, CCTV, a
  phone camera, a video call. Before this model, the frames carried every account secret in plain
  QR codes.
- **Sealed before chunking.** The full sync payload is sealed once with AES-256-GCM
  (`OpticalSyncCrypto.seal`, layout `salt (16) | nonce (12) | ciphertext + tag (16)`), then cut
  into Fountain-code frames. The frames carry only ciphertext; the 8-character session hash is
  taken over the ciphertext.
- **Key from a one-time transfer code.** 12 characters from the 31-symbol pairing alphabet
  (about 59 bits), stretched with PBKDF2-HMAC-SHA256 at 300,000 iterations and a fresh 16-byte
  salt — the same function as Wi-Fi sync (§5.1). Brute force against a recording costs roughly
  10^23 hash steps.
- **Code shown on the receiver, typed on the sender.** The code never appears on the screen that
  shows the stream, so one video of the sending screen does not hold both. The code is shown as
  plain text (not selectable, never copied to the clipboard), kept in memory only, cleared on
  reset, and never logged.
- **Fail closed.** A wrong code or any changed byte fails the GCM tag check
  (`OpticalSyncErrorCode.wrongTransferCode`); nothing is parsed or imported. Version 1 (plaintext)
  frames are refused (`unsupportedVersion`), so an old sender can never feed plain secrets into a
  new receiver.
- **UI isolate.** PBKDF2 runs in a background isolate (`Isolate.run`) on both sides.

---

## 6. Cryptography Design

- Encryption algorithm for stored account secrets: `AES-256-GCM`
- Device-key strategy: random 32-byte key generated on-device and stored under
  `authenticator_key` in secure storage
- PIN derivation: `PBKDF2-HMAC-SHA256` with `100000` iterations and a 16-byte salt (PIN version 3+; version 2 used 300000 and is transparently migrated on first successful unlock)
- Recovery-key derivation: `PBKDF2-HMAC-SHA256` with `300000` iterations and a 16-byte salt
- Backup password derivation: `PBKDF2-HMAC-SHA256` with `300000` iterations and a 16-byte salt (iteration count is not stored in the backup file — must not change)
- P2P sync session-key derivation: `PBKDF2-HMAC-SHA256` with `300000` iterations and a per-session
  random 16-byte salt, from the out-of-band pairing code (see §5.1)
- Nonce or IV strategy:
  - Account secret encryption: random 12-byte GCM nonce
  - Backup encryption: random 12-byte GCM nonce plus random 16-byte salt
  - P2P sync payload: random 12-byte GCM nonce per message, prepended to the ciphertext on the wire
- Format versioning:
  - Account secrets: current `nonce:ciphertext` GCM format, only
  - Backups: current `v3:<salt>:<nonce>:<ciphertext>` format only
- Legacy format support: `no`; the app has had no public release, so no old data needs it

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
  [`lib/screens/lock_screen.dart`](../lib/screens/lock_screen.dart)

### 7.1 Usability Balance

Security must not make the app hard to use or slow (engineering standard §15.6).

- Lock grace period after backgrounding: auto-lock timeout, default 60 seconds, user can change it
  in Settings (`SettingsProvider.autoLockTimeout`).
- Fallback when biometrics are not available: app PIN.
- Response to rooted or emulator devices: none — out of scope (§3); blocking would hurt real users
  without stopping a determined attacker.
- Heavy crypto off the main isolate: PBKDF2 key derivation runs in `Isolate.run`
  (`AuthService`).
- Key-derivation cost tuned for: PIN verification uses 100,000 iterations so unlock stays fast on
  slow devices; backup, recovery and sync keys use 300,000 (not on the unlock path). Unlock time on
  the slowest target device: `to measure`.

| Control That Adds A Step For The User | Why It Is Needed |
|---------------------------------------|------------------|
| Strong auth (app PIN) after 1 hour, reboot, or 3 failed quick unlocks | Limits how long a biometric-only session can last on a lost device |
| Backup password on export and import | A backup file holds every secret |
| Pairing code for Wi-Fi sync | The local network is not trusted |
| App PIN or phone lock before "Delete all data" | The delete cannot be undone |

---

## 8. Binary Protections

### 8.1 Obfuscation

All production release builds MUST be compiled with:

```bash
--obfuscate --split-debug-info=build/symbols/<platform>-<flavor>-<version>/
```

The folder pattern is defined in [`release_process.md`](release_process.md) §6.1.

Obfuscation renames Dart class and method names in the binary. It raises the cost of casual
inspection but is **not a strong security boundary**, and it does not hide string literals —
never put a secret in a string. The debug symbol files MUST be stored securely for the lifetime of
the released version, never committed, and used only for crash symbolication.

### 8.2 R8 / ProGuard

Android release builds enable minification and resource shrinking in
[`android/app/build.gradle.kts`](../android/app/build.gradle.kts).

Current caution:

- [`android/app/proguard-rules.pro`](../android/app/proguard-rules.pro)
  is minimal; it keeps the Flutter and `sqflite` classes, and does not set `-dontobfuscate`.
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
  [`lib/config/app_flavor_config.dart`](../lib/config/app_flavor_config.dart)
  via `AppFlavorConfig.enableVerboseLogging`
- Log level in production: keep logs minimal
- Redaction strategy: do not log secret-bearing values in the first place

The app currently has no analytics or telemetry backend.

---

## 10. Platform Security Controls

### Android

- `android:allowBackup`: `false`
- `android:fullBackupContent`: `false`
- `android:dataExtractionRules`: excludes everything from `<cloud-backup>` and `<device-transfer>`
- `android:usesCleartextTraffic`: `false`
- Clipboard: secrets are marked sensitive (Android 13+ hides them in its preview) and cleared after a
  time limit. Android 10+ blocks clipboard reads from the background, so clearing then cannot check the
  content and clears anyway. Clearing does not happen if the app is killed first
- Screenshot protection:
  - Enabled at app startup through `screen_protector`, before any saved setting is read
  - Intended to prevent screenshots and screen recording on sensitive views
  - On by default. The user can turn it off with "Block screenshots" on the Security screen, after a
    warning. The choice is saved in SharedPreferences as `block_screenshots` (it is not a secret), and a
    missing value means blocked. It stays on the device: it is not in sync or backup settings, so
    outside data cannot turn protection off
  - Deliberate choice: engineering standard §15.2 asks for protection on every sensitive screen. The
    app meets this by default. Turning it off is only the user's own choice, and while it is off,
    all screens, including the optical sync stream, can be captured
- `android:debuggable`: must be `false` in release builds
- Root detection: none implemented

- Exported components: the launcher activity and AndroidX `ProfileInstallReceiver` (protected by the
  `DUMP` permission); everything else is unexported (checked in the merged prod release manifest)

---

## 11. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| `CAMERA` | Scan OTP QR codes | When entering the QR scan flow | User can still add accounts manually |
| `USE_BIOMETRIC` (also `USE_FINGERPRINT`, added by `androidx.biometric`, not by our manifest) | Unlock via local-auth capabilities | When enabling or using quick unlock | App falls back to app PIN or device lock support checks |
| `VIBRATE` | Minor haptic feedback | During supported UI interactions | App remains functional without it |
| `INTERNET` | Open TCP sockets for P2P LAN sync | When hosting or joining a sync session | All other features work without network |
| Removed with `tools:node="remove"`: `ACCESS_NETWORK_STATE` (`media3-common`), `RECORD_AUDIO` and `WRITE_EXTERNAL_STORAGE` (`camera_android_camerax`), `READ_EXTERNAL_STORAGE` (implied by the merger) | Not used by the app; `test/security/android_manifest_test.dart` keeps them out | Never | — |

Permission review rules:

- `INTERNET` is included for P2P LAN sync only; there is no internet/HTTP client and no app backend.
  `NEARBY_WIFI_DEVICES` is intentionally **not** requested (no Wi-Fi scanning/discovery is performed).
- Request permissions only at the point of use, with a rationale, never at startup.
- Remove unused permissions promptly.
- The app should remain usable in a safe degraded mode when non-critical permissions are denied.

---

## 12. OWASP Mobile Top 10 Compliance

Review and sign off each item before every production release. This is a MUST under the
`Sensitive Data Extension` and the `Production App Extension` (engineering standard §15.3).
Status after the "Delete all data" change is below. `failed` and `to verify` lines must be closed before sign-off.

| ID | Risk | Control | Status |
|----|------|---------|--------|
| M1 | Improper Credential Usage | No hardcoded secrets; secure storage for key material | `verified` |
| M2 | Inadequate Supply Chain Security | `pubspec.lock` committed; dependency audit and license check by hand | `verified` — ML Kit removed; `flutter_zxing` and `camera` reviewed (§4). Exact versions pinned |
| M3 | Insecure Authentication/Authorization | App lock, PIN hashing, quick unlock policy, lockouts, background lock; no server | `verified` by code and existing tests; real phone check on the release checklist |
| M4 | Insufficient Input/Output Validation | All outside input validated (§3.1); parameterized queries; no path traversal | `verified` |
| M5 | Insecure Communication | No internet traffic; Wi-Fi sync seals payloads with AES-256-GCM keyed by an out-of-band pairing code (transport stays plaintext by design — see §5.1) | `verified` |
| M6 | Inadequate Privacy Controls | Screenshot blocking, no secrets in logs, backups encrypted, Android backup off, "Delete all data" (§13) | `verified` by APK contents and a real phone test; "Delete all data" verified by automated tests, its phone test is on the owner's sign-off |
| M7 | Insufficient Binary Protections | `--obfuscate` applied; `android:debuggable=false` verified; R8 rules verified | `verified` for build settings — `--obfuscate`, not debuggable, R8 on. Scanning works in a release build with R8 on, on a real phone |
| M8 | Security Misconfiguration | Minimal permissions; backup disabled on Android; no accidental exported components; no debug features in prod | `verified` on the merged prod manifest. `USE_FINGERPRINT` and `ACCESS_NETWORK_STATE` are added by libraries (§11) |
| M9 | Insecure Data Storage | Secrets encrypted in SQLite; key material only in secure storage; no secrets in `SharedPreferences` | `verified` |
| M10 | Insufficient Cryptography | AES-256-GCM, PBKDF2-HMAC-SHA256, versioned migration-aware formats | `verified` |

For each `risk-accepted` item, document the justification and owner below the table.

Sign-off: ready for owner sign-off. Before signing, the release owner runs "Delete all data" on a
real phone in all three check states (§13). Not yet signed off.

---

## 13. Data Retention And Purge Policy

### Retention Schedule

| Data Type | Retention Period | Deletion Trigger |
|-----------|------------------|-----------------|
| Accounts | Until user deletes them or uninstalls the app | User delete flow, "Delete all data" or uninstall |
| PIN / recovery verifiers | Until user disables app lock or resets it | App-lock reset, "Delete all data" or uninstall |
| Settings | Until the user deletes them or uninstalls the app | "Delete all data" or uninstall |
| Temporary backup export files | Session only | Deleted after share attempt |
| Cached OTP values | Up to 5 minutes, or less on lock/background | Cache expiry, lock, or app pause |

### Purge Implementation

- "Delete all data" is on the Security screen (engineering standard §15.4). Code:
  [`lib/services/data_wipe_service.dart`](../lib/services/data_wipe_service.dart).
- The user must first pass a check:
  - App PIN set: the App PIN, with the normal wrong-PIN count and lockout. Phone lock is not accepted.
  - No App PIN: the phone lock. A failed, canceled or locked-out check stops the delete.
  - No App PIN and no phone lock: nothing can be checked, so a warning with a ticked box is the only
    guard. Anyone holding such a phone can already read the codes and uninstall the app.
- It deletes, in this order: the database; all secure storage (master key, PIN and recovery verifiers,
  failed-attempt and lockout values); all `SharedPreferences`; everything in the app's cache,
  documents and support folders. Every step runs even if an earlier one failed. If one fails, the
  user is told and can try again. Memory is cleared too: OTP cache, account list, sync session, and a
  secret the app copied to the clipboard.
- Afterward the app matches a fresh install. Screenshot blocking is back on and app lock is off.
- Limits: flash storage may keep deleted bytes for a while, but the secrets in them are encrypted and
  the key is gone. Files the user exported are outside the app's reach. The wrapping key that
  `flutter_secure_storage` keeps in Android Keystore may remain; it protects nothing afterward.
- Individual delete flows and app-lock reset also remove data.
- Temporary export files are created in the temporary directory and deleted in the same session.

### Data Purge On Uninstall

- Android: app data is removed on uninstall and cloud backup is disabled in the manifest

---

## 14. Backup, Import, Export, And Recovery

- Backup supported: `yes`
- Backup format: encrypted `.aes` file in the primary UI flow
- Import supported: `yes`
- Recovery flows:
  - Encrypted backup restore using the backup password
  - App-lock recovery key for PIN reset
- Plaintext export policy:
  - Encrypted backup is the only export path
  - No plaintext JSON or CSV export exists in the code; the service layer writes only
    password-encrypted `.aes` backups

### Validation Requirements

- Import parsing must reject malformed or incompatible backup data safely.
- Backup files must remain encrypted in normal user-facing flows.
- Recovery and migration flows must be tested when changed.
- P2P sync uses the same import funnel (`AccountsProvider.importData`) as file restore, so peer
  data is validated, deduped, and re-encrypted under the device key identically. The funnel is
  add-only (client-wins): matching accounts are skipped and the receiver's data is retained.
  Any synced settings are applied fill-only on an incremental sync (never overriding the receiver).
  Received payloads must additionally pass the sync caps (max accounts, per-field length)
  before ingestion.

---

## 15. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| OTP and crypto logic | Unit | Includes deterministic OTP vectors and encryption/decryption coverage |
| Secret storage | Unit | Secure-storage channel mocks are used in tests |
| Lock / auth flow | Unit and widget | Covers PIN validation, recovery, lockouts, and settings policy |
| Backup and recovery | Unit | Export/import parsing and rejection of old formats are tested |
| Data migration | Unit | The old PIN storage migration path is covered |
| Delete all data | Unit and widget | Every store emptied, a failed step does not stop the rest, every check path; run on a real phone before sign-off |
| P2P LAN sync | Unit | Pairing-code entropy, wire crypto round-trip, wrong-code rejection, payload caps, and a loopback host↔client transfer are covered; cross-device transfer is verified manually |
| Release hardening | Manual release verification | Obfuscation, permissions, and debuggable checks are checklist-driven |

### Required Regression Areas

- RFC 4226 HOTP vectors
- OTP URI parsing and generation
- AES-GCM secret encryption and rejection of old formats
- Backup `v3` round-trip and rejection of old formats
- Lockout and strong-auth policy transitions
- P2P sync: wrong pairing code must never yield plaintext; payload caps must hold

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
  [`release_process.md`](release_process.md)

---

## 17. Open Risks And Future Hardening

- Risk: Release binary hardening is documented but not fully automated in tooling.
  Hardening option: add automated release-build verification and symbol-archive steps.
- Risk: the system file picker has not been run on Android 10 to 12 since the storage permissions were
  removed. `file_picker` asks for no permission in its manifest or source.

---

## 18. Security Review Checklist

- [ ] Threat model reviewed after security-sensitive changes
- [ ] §1.1 Security Baseline: every line `verified` or `n/a`
- [ ] §3.1 entry points still match the code
- [ ] §12 OWASP checklist signed off
- [ ] Sensitive data inventory still matches the implementation
- [ ] No new logs expose secret or decrypted data
- [ ] Permissions reviewed for the Android merged prod manifest
- [ ] `--obfuscate` used for the prod release build
- [ ] Debug symbols archived securely
- [ ] `android:debuggable=false` verified in the release manifest
- [ ] Backup, lock, migration, and recovery paths tested if changed
- [ ] Release checklist in `docs/release_process.md` completed
