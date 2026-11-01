# Feature Reference — Sreeraj P Authenticator

This file is a full list of what this app is and what it can do today. It is
meant to be given to an LLM (or a person) as ground truth, so they can check
"does this app already have X" before adding a new feature to another app.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [architecture.md](architecture.md)

---

## 1. What this app is

**Sreeraj P Authenticator** is a privacy-first, offline-first two-factor authentication (2FA) app built with Flutter.

- **Canonical short description** (from `assets/config/app_config.json`): *"Privacy-first, offline-first TOTP/HOTP authenticator app with AES-256-GCM vault encryption."*
- **Inclusive extended description**: *"Sreeraj P Authenticator is a privacy-first, offline-first 2FA authentication app featuring AES-256-GCM vault encryption, multi-algorithm support (TOTP, HOTP, Steam Guard, Blizzard, YubiKey), tag-based account organization with offline brand vector icons, biometric & recovery key security, lockdown mode, screen data leakage protection (FLAG_SECURE), password-encrypted backups, dual offline device-to-device sync (Wi-Fi LAN & Optical Air-Gap QR), 3D/neumorphic UI design, and zero telemetry."*

It generates one-time passcodes (OTPs) the same way apps like Google Authenticator or Authy do, but with no cloud account, no internet backend, and no telemetry — everything runs and stays on the device.

Beyond plain TOTP/HOTP codes (see Section 2), it also supports Steam Guard,
Blizzard, and YubiKey accounts; lets the user organize accounts with
free-form tags, optional description notes, and offline-matched brand icons (Section 3); protects the
vault with AES-256-GCM encryption, an App PIN, and/or the phone's own screen lock, plus a recovery
key (Section 4); can export/import a password-encrypted backup file (Section 5); and
can move accounts to another device three different offline ways — Wi-Fi LAN
sync, camera-only "optical air-gap" sync, and single-account QR scanning
(Section 6). The sections below are the detailed reference; this paragraph
is just the summary.

- Platform: Android only (minSdk 29).
- Package id: `in.sreerajp.sreerajp_authenticator`
- State management: Provider + ChangeNotifier.
- Database: SQLite (`sqflite`) for account data (encrypted fields) +
  `flutter_secure_storage` (Android Keystore-backed) for the master key, PIN
  hash, and recovery key hash.
- No `http`/`dio`/cloud SDKs/analytics/ads are used or allowed.

---

## 2. OTP types and algorithms supported

Handled in `lib/services/otp_service.dart`.

| Type | Notes |
|---|---|
| **TOTP** (time-based) | Standard `otpauth://totp/...` accounts. |
| **HOTP** (counter-based) | Added from `otpauth://hotp/...` QR codes. The counter is stored per account and means the next unused value. The account tile has a "Next code" button: each tap makes the code, saves the next counter, then shows the code. |
| **Steam Guard** | 5-character codes using Steam's own alphabet (`23456789BCDFGHJKMNPQRTVWXY`), 30 s period. Recognized from `steam://` URIs and `otpauth://` with a steam algorithm/host. |
| **Blizzard Authenticator** | 8-digit HMAC-SHA1 TOTP, supports hex-encoded secrets. |
| **YubiKey (HMAC-SHA1 OTP)** | Standard TOTP with hex-secret support. |

Other details:
- Hash algorithms: SHA1 (default), SHA256, SHA512.
- Secret encodings: Base32 (standard) and Hex, auto-detected.
- Digits: 6 or 8 in the manual-entry UI (other algorithms like Steam use their
  own fixed digit count internally).
- Period: 30 or 60 seconds in the manual UI.
- **Fallback / Error Display**: If an OTP secret fails decryption or cannot be generated, the account tile displays `'------'` as a placeholder instead of crashing.
- **Only TOTP with SHA1/256/512 can be added manually in the UI.** HOTP needs a QR code.
  Steam, Blizzard, and YubiKey accounts can only be added by scanning a
  QR code or importing a matching URI — there's no manual dropdown for them.
- Decrypted secrets are cached in memory for 5 minutes, then cleared; also
  cleared immediately when the app locks or goes to the background.
- The manual-entry dropdown values (6/8 digits, 30/60 s period) only apply to
  plain TOTP/HOTP. Steam Guard and Blizzard have fixed parameters of
  their own that don't come from those dropdowns: Steam is always 5 digits,
  Blizzard is always 8 digits.
- `otp_service.dart` has a `generateOtpAuthUri` function that can build a
  plain `otpauth://` URI from a decrypted secret, but nothing in the app
  calls it today — it is not wired to any screen (no "share as QR" feature
  exists yet).

---

## 3. Account management

- **Add account**: manual entry form (Account Name, Issuer, Secret Key, Tags, optional Description / Notes), or scan a QR code (`flutter_zxing`).
  The add-account FAB: single tap opens the QR scanner directly, while a long-press opens a bottom-sheet menu allowing the user to choose between QR Scanner or Manual Entry.
  The QR scanner screen has a flashlight/torch toggle button for scanning in low light.
- **Edit account**: same form, pre-filled (including optional Account Description). Editing the secret key or advanced
  settings (digits/period/algorithm) requires the app to have App Lock turned
  on, and requires re-entering the PIN even if the app is already unlocked.
- **Delete account**: swipe-to-delete with a confirmation dialog. Bulk delete
  is available from selection mode on the home screen and asks for a check
  first.
- **Reorder accounts**: drag-and-drop when sort mode is "Manual".
- **Sort options**: Manual, by Issuer (default), by Account name, by Date
  added.
- **Search**: a search bar on the home screen matches name, issuer, and tags.
- **Tags**:
  - Free-form, multiple tags per account.
  - Tag filter chips on the home screen (multiple tags = AND filter).
  - A dedicated "Tags" tab on the home screen showing a tag cloud.
  - A Tag Management screen: rename a tag everywhere, delete a tag from all
    accounts, see how many accounts use each tag, search tags.
- **Brand icons**: offline SVG icon matching for common services (Google,
  GitHub, AWS/Amazon, Binance, Discord, Proton, Nintendo, Steam, Microsoft,
  Apple/iCloud — 10 brands in all) based on the issuer/account name — no network calls.
  Strips domain extensions (`.com`, `.org`, `.io`, etc.) and normalizes names.
  Falls back to a colored letter avatar if no brand match is found.
- **Account tile (list item)**: live-updating TOTP code with a countdown ring (for HOTP, a "Next code" button instead of the ring),
  an eye button to show/hide the code (auto-hides again after ~28 seconds),
  one tap on the tile to copy the code to the clipboard (even while hidden; in
  selection mode a tap selects instead), and the clipboard is automatically
  cleared 30 seconds later if unchanged.

---

## 4. Security features

Screens: Security, Lock, Permissions. Services: `auth_service.dart`,
`encryption_service.dart`.

- **App Lock** (optional, user-enabled), which can use either or both of:
  - **App PIN** (4–6 digits), stored as a PBKDF2-HMAC-SHA256 hash
    (100,000 iterations), never stored or logged in plain text.
  - **Phone Screen Lock** (`local_auth`) — fingerprint, face unlock,
    pattern, PIN, or password, whatever the device itself uses.
- **Recovery Key**: a 16-character key (shown once, in groups of 4) created
  when the App PIN is first set. Lets the user reset a forgotten PIN. Cannot
  be viewed again after the first time it's shown. Can be regenerated at any
  time from Settings → Security → "Reset Recovery Key" (requires re-entering
  the current App PIN); the old key stops working once a new one is made.
- **Forced full-PIN re-entry** (not just quick unlock) happens after:
  - 1 hour of inactivity,
  - the phone has been rebooted (detected via Android boot count),
  - 3 failed Phone Screen Lock attempts in a row,
  - "Lockdown Mode" is turned on — a manual toggle in Settings → Security
    (only shown once an App PIN is set) that forces PIN-only unlock until
    the user turns it off again.
- **PIN lockout**: after repeated wrong PIN attempts, the app locks out for
  increasing time — 30 s, 60 s, 5 min, then 30 min for 8+ attempts.
- **Auto-lock**: configurable timeout (Immediately / 30 s / 1 min / 5 min /
  10 min) after the app is backgrounded. Paused automatically during a
  backup/restore or a device sync so it doesn't cut off a long operation.
- **Encryption at rest**: AES-256-GCM for account secrets.
- **Screen protection**: blocks screenshots and screen recording, and hides
  the app's content in the Android recent-apps switcher (`FLAG_SECURE`). On by
  default; the "Block screenshots" switch on the Security screen turns it off,
  after a warning (Android only).
- **No backup via Android's own backup system**: `android:allowBackup` is
  `false`, so the only way to back up data is the app's own encrypted export
  (see below).
- Nothing sensitive (secrets, keys, PIN, decrypted codes) is ever written to
  logs, in debug or release builds.
- **Delete all data**: a row on the Security screen removes all accounts, the
  App PIN, the recovery key, settings and cached files, so the app is like a
  fresh install. It warns first, then asks for the App PIN, or the phone lock
  when no PIN is set. With neither, a ticked box is required. Backup files saved
  elsewhere are not deleted (`docs/security.md` §13).
- **Haptic feedback**: short vibrations on key interactions — PIN entry,
  copying a code, deleting an account, and the add-account FAB.

---

## 5. Backup and restore (export / import)

- **Format**: a single password-encrypted file (`.aes` extension, JSON
  inside). There is no plain-text export option in the UI.
- **Export**: all accounts are decrypted, put into JSON, then re-encrypted
  with a password the user types in (PBKDF2, 300,000 iterations, then
  AES-256-GCM). The file is saved through the system save screen (`file_picker`), and success is shown only after it is written.
- **Import**: user picks the backup file via the system file picker (`file_picker`), types the password, and the app decrypts and
  adds the accounts. Accounts that already exist (same name + issuer + type)
  are skipped automatically, and the user is provided an `ImportResult` dialog telling how many were added vs
  skipped. The new accounts are saved in one database transaction, so if the
  import fails, none of them are added.
- Only the current backup format (`v3`) can be read. Older formats are refused
  with a message (`docs/security.md` §6); the app has had no public release, so
  no old backups need them.

---

## 6. Device-to-device sync

Three separate, fully offline ways to move data to another device — no
server or internet involved in any of them.

### a) P2P Wi-Fi (LAN) sync
- One device "hosts" (opens a local network connection) and shows a QR code
  plus IP address, port, and a random pairing code. The QR code encodes an out-of-band URI (`spauth://sync?v=1&ip=<ip>&port=<port>&code=<code>`). The other device scans
  the QR or types the details in by hand.
- The pairing code (shown on screen, never sent over the network) is used to
  derive an AES-256-GCM encryption key for the whole session. If the code is
  wrong, the connection simply fails to decrypt.
- Two modes: **Full Sync** (send everything, including a snapshot of
  settings — theme, auto-lock timeout, sync host idle timeout — good for
  setting up a brand new device) or **Selective Sync** (choose to send
  Accounts and/or Settings; never overwrites data the other device already
  has, only adds or fills in what's missing).
- The host automatically stops listening after an idle timeout (configurable from 30 s to 600 s, default 120 s / 2 minutes) so it doesn't stay open forever.
- **Hostile Peer Hardening**: Payload size and account bounds (16 MB maximum payload size, 5,000 maximum accounts, 4 KB maximum field length) are enforced in `AppConstants` before deserializing peer payloads to protect against memory exhaustion.
- Needs only the `INTERNET` permission, for local sockets — no
  Bluetooth/Nearby APIs.

### b) Optical Air-Gap sync (camera only, no network at all)
- One device shows an **animated QR code** stream (encodes the same account
  + settings data, broken into small chunks with error-correction so dropped
  frames don't matter).
- The other device just points its camera at the screen and reconstructs the
  data, with a live progress indicator.
- The sender can show 10, 12 or 15 frames per second.
- Useful when there's no shared Wi-Fi at all, since it uses zero network
  connections in either direction.
- **Encrypted with a one-time transfer code.** The receiving device shows a
  12-character code (`ABCD-EFGH-JKMN`); the user types it on the sending
  device before the stream starts. The payload is sealed with AES-256-GCM
  (key from the code via PBKDF2), so the QR frames carry only ciphertext.
  A wrong code imports nothing. Both devices need this app version: older
  plaintext frames are refused (`docs/security.md` §5.2).

### c) Single-account QR import
- The everyday "add one account by scanning its QR code" feature
  (`lib/screens/qr_scanner_screen.dart`). This is a separate screen from the
  P2P pairing scanner used in Section 6a (`lib/screens/sync_qr_scanner_screen.dart`,
  which only reads host IP/port/pairing-code QR codes) — the two share the
  same underlying `flutter_zxing` package but are different screens with
  different purposes. Both scanner screens have a flashlight/torch toggle
  button.

---

## 7. UI, theming, and settings

- **Theme**: System / Light / Dark, kept in sync across devices as part of
  "Settings" sync.
- **Accent colour**: Blue (default), Teal, Indigo, Green, Copper or Graphite, in
  Settings → Appearance. Applied at once and kept on this device only (not synced).
  There is no red choice, because the timer turns red for a code's last 5 seconds.
- Account cards show the first tag and then `+N`; a screen reader hears every tag.
- Custom look and feel (raised 3D-style cards), custom Inter app font, swipe
  actions, animated FAB, gradient app bar.
- **Home screen**: two tabs — Accounts (search, tag filter, sortable list)
  and Tags (tag cloud view).
- **Settings screen** covers: theme, App Lock/security screen, backup &
  restore, tag management, device sync, sync host timeout, permissions, Help
  & Support, and an About section (version info, help, privacy policy text,
  open-source licenses).
- **About screen** also discloses which AI tools were used to help build the
  app (Developer section, "AI Used" entry), alongside developer name and
  contact email. Tapping the Email row opens the device's mail app
  (`mailto:` link).
- **Dev vs Prod build flavors**: a small "DEV"/"PROD" banner is shown on
  screen so it's obvious which build is running.
- **Config-driven About info**: the app name, description (canonical: *"Privacy-first, offline-first TOTP/HOTP authenticator app with AES-256-GCM vault encryption."*), version and build number (the current values are in `pubspec.yaml`), and the About screen's "Developer" list (Author, Email, License,
  AI tools used, IDE used) are not hardcoded in Dart — they're read at
  runtime from `assets/config/app_config.json` by
  `lib/services/config_service.dart`. If that file is missing or invalid,
  the app falls back to built-in defaults so the About screen never breaks.
  In debug builds only, if the JSON's version/build doesn't match the app's
  real package version, a debug-only warning is printed (not shown to the
  user).

---

## 8. Permissions and platform notes

- Android permissions used: Camera (QR scanning), biometric/fingerprint
  (App Lock), Vibrate, plus Internet (only for the optional P2P sync feature —
  the app has no other network use).
- The Permissions screen lists Camera, Biometric/Device Lock, Vibration,
  Secure Storage, and Local Database, and explains why each is needed. Only
  **Camera** gets a live, checked runtime status (granted / denied); the
  other four are shown as static informational rows with no live check.
  The Internet permission (used only for the optional P2P sync feature) is
  declared in the Android manifest but is **not** shown on this screen.
- The app works fully without a camera (camera is an optional device
  feature, not a hard requirement).

---

## 9. Known gaps / things not implemented

- No cloud sync or cloud account of any kind (by design — this app is
  offline-only).
- No plain-text export option (encrypted `.aes` export only).
- Manual account entry only supports TOTP with SHA1/256/512; other
  types (HOTP, Steam, Blizzard, YubiKey) require a QR/URI import.
- Import from other authenticator apps covers Google Authenticator's export
  QR codes only. Other formats (e.g. Aegis, 2FAS) are not supported. Besides
  that, only this app's own `.aes` backup file and single-account
  `otpauth://`/vendor URIs (via QR scan) can be imported.
- Google Authenticator import skips an account with the same name, issuer and
  type as one already in the app, even if its secret differs. That account
  must be added by hand.
