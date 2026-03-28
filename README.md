# Sreeraj P Authenticator

A secure, open-source two-factor authentication (2FA) app built with Flutter. Generate TOTP and HOTP codes to protect your online accounts with military-grade encryption and a modern, user-friendly interface.

---

## Features

### Two-Factor Authentication
- **TOTP (Time-based One-Time Password)** — Generate time-based codes that refresh automatically (RFC 6238)
- **HOTP (HMAC-based One-Time Password)** — Counter-based code generation (RFC 4226)
- **Multiple hash algorithms** — SHA-1, SHA-256, and SHA-512
- **Configurable codes** — 4 to 8 digit codes, 15 to 60 second refresh periods

### Account Management
- **QR code scanning** — Add accounts instantly by scanning QR codes from any service
- **Manual entry** — Add accounts by typing in the secret key and account details
- **Edit and delete** — Modify account details or remove accounts with swipe actions
- **Search and filter** — Quickly find accounts by name or issuer
- **Sort options** — Sort accounts manually, by name, or by date created

### Group Organization
- **Custom groups** — Organize accounts into named groups (e.g., Work, Personal, Finance)
- **Group colors and icons** — Personalize groups with custom colors and icons
- **Group filtering** — View accounts by group for quick access

### Security
- **AES-256-GCM encryption** — All secrets are encrypted on-device using AES-256-GCM with keys stored in Android Keystore
- **App lock** — Lock the app with your device screen lock (PIN/pattern/biometric), custom app PIN, or biometric authentication (fingerprint/face)
- **PIN recovery** — Recover access if you forget your app PIN using a one-time recovery key (PBKDF2-hashed, never stored in plaintext). Recovery keys exist only when you use **App PIN**; they are not available when using **Phone Screen Lock**
- **Brute-force protection** — Progressive lockout after 5 failed attempts (30s, 1m, 5m, 30m)
- **Auto-lock** — Configurable auto-lock timeout when the app goes to the background
- **Screenshot protection** — Prevents screenshots and screen recording to keep codes private
- **Zero-knowledge architecture** — All data stays on your device; no servers, no cloud sync

### Backup and Restore
- **Encrypted backups** — Export all accounts and groups as a password-protected `.aes` file using AES-256-GCM with PBKDF2 key derivation (300,000 iterations)
- **JSON export** — Export accounts as plain JSON (not recommended for sensitive data)
- **CSV export** — Export account data as CSV for external use
- **Import** — Restore from encrypted backup, JSON, or CSV files with automatic format detection

### Appearance
- **Light and dark themes** — Choose between light, dark, or system-default theme
- **Modern design** — Clean Material Design 3 interface with smooth animations
- **Countdown timers** — Visual progress indicators show remaining time for each code

---

## How It Works

### Adding an Account

1. **Open the app** and tap the **+** button on the home screen
2. Choose **Scan QR Code** or **Enter Manually**
   - **QR Code**: Point your camera at the QR code provided by the service (e.g., Google, GitHub, Discord). The app automatically reads the `otpauth://` URI and fills in all account details
   - **Manual Entry**: Enter the account name, issuer, and secret key. Optionally configure the algorithm, digit count, and time period
3. Optionally assign the account to a **group**
4. Tap **Save** — the secret is encrypted and stored securely on your device

### Viewing Codes

- The home screen displays all your accounts with their current OTP codes
- TOTP codes refresh automatically — a circular countdown timer shows remaining validity
- Tap a code to copy it to your clipboard
- Use the search bar to quickly find specific accounts

### Editing or Deleting Accounts

- **Swipe left** on an account to reveal edit and delete options
- When editing, the secret key is protected and requires authentication to view or modify

---

## Backup and Restore Guide

### Creating a Backup

1. Open **Settings** from the navigation drawer
2. Tap **Backup & Restore**
3. Choose **Export Encrypted Backup** (recommended)
4. Enter a strong password (minimum 8 characters) — this password encrypts your backup using AES-256-GCM with PBKDF2 key derivation
5. Save or share the generated `.aes` file to a secure location (USB drive, encrypted cloud storage, etc.)

### Restoring from Backup

1. Open **Settings** > **Backup & Restore**
2. Tap **Import Backup**
3. Select your backup file (`.aes`, `.json`, or `.csv`)
4. For encrypted backups, enter the password you used during export
5. Accounts and groups are restored and re-encrypted with your device's key

### Backup Formats

| Format | Encrypted | Includes Groups | Recommended |
|--------|-----------|-----------------|-------------|
| `.aes` (Encrypted) | Yes (AES-256-GCM) | Yes | Yes |
| `.json` (Plain) | No | Yes | No |
| `.csv` (Plain) | No | No | No |

> **Important**: Store your backup password safely. If you lose it, the encrypted backup cannot be recovered. Unencrypted exports (JSON/CSV) contain your raw secrets — handle them with extreme care and delete after use.

---

## Android Permissions

| Permission | Purpose | Required |
|------------|---------|----------|
| **Camera** | Scanning QR codes to add accounts | Optional (only needed for QR scanning) |
| **Biometric / Fingerprint** | Biometric authentication for app lock | Optional (only needed if biometric lock is enabled) |
| **Vibrate** | Haptic feedback on interactions | Optional |

- The app does **not** require internet access, contacts, location, or any other sensitive permissions
- Camera and biometric hardware are declared as optional features — the app works without them
- Android system backup is disabled (`allowBackup=false`) to prevent unencrypted secrets from appearing in device backups

---

## How to Use This App

### First Launch
1. Install and open the app
2. You'll land on the home screen — it's empty until you add accounts

### Setting Up App Security (Recommended)
1. Go to **Settings** > **Security**
2. Enable **App Lock** — choose from:
   - **Device Screen Lock** — Uses your phone's existing PIN, pattern, or biometric. No app-specific recovery key is created in this mode
   - **App PIN** — Set a custom PIN just for this app. A **recovery key** (format: `XXXX-XXXX-XXXX-XXXX`) is generated and displayed once — **save it somewhere safe**. This is the only way to recover access if you forget your PIN
   - **Biometric** — Use fingerprint or face unlock
3. Configure **Auto-Lock Timeout** — how quickly the app locks when you switch away
4. (Optional) To regenerate your recovery key at any time, go to **Settings** > **Security** > **Reset Recovery Key** (requires current PIN)

### Recovering a Forgotten PIN
1. On the lock screen, tap **Forgot PIN?**
2. Enter the 16-character recovery key you saved when setting up your PIN
3. If the key is valid, the old PIN is cleared and you are prompted to set a **new PIN**
4. A **new recovery key** is generated — save it again, as the old one is now invalid

> **Important**: Recovery keys apply only to the **App PIN** lock type. If you use **Phone Screen Lock**, there is no app-specific recovery key because authentication is handled by your device. If you use **App PIN** and never saved the recovery key, there is no way to recover access. You would need to reinstall the app, which erases all accounts. Always keep your recovery key in a safe place.

### Adding Your First Account
1. Go to the service you want to protect (e.g., Google, GitHub, Discord)
2. Navigate to that service's **Security** or **2FA settings** and choose to set up an authenticator app
3. The service will show a QR code
4. In Sreeraj P Authenticator, tap **+** > **Scan QR Code** and point your camera at the QR code
5. The account is added automatically — you'll see a 6-digit code on the home screen
6. Enter this code back into the service to complete 2FA setup
7. **Save any backup/recovery codes** the service provides

### Daily Use
- Open the app whenever you need a 2FA code
- Codes refresh every 30 seconds (default) — wait for a fresh code if the timer is almost up
- Use search or group filters to find accounts quickly

### Before Switching Phones
1. **Create an encrypted backup** before wiping or switching your device
2. Transfer the `.aes` backup file to your new device
3. Install the app on the new device and **restore from backup**
4. Verify that all accounts generate correct codes before removing the app from the old device

---

## Technical Details

- **Platform**: Flutter (Android, iOS, Web, Desktop)
- **Min Android SDK**: 21 (Android 5.0 Lollipop)
- **Database**: SQLite (local, on-device)
- **Secret Storage**: Android Keystore via Flutter Secure Storage
- **Encryption**: AES-256-GCM (device), PBKDF2-HMAC-SHA256 + AES-256-GCM (backups, PIN recovery keys)
- **State Management**: Provider pattern
- **OTP Standards**: RFC 4226 (HOTP), RFC 6238 (TOTP)

---

## Building from Source

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio or VS Code with Flutter extension
- Android SDK 21+

### Steps
```bash
git clone <repository-url>
cd sreerajp_authenticator
flutter pub get
flutter run --flavor dev
```

### Build Flavors

The Android app now uses two product flavors:

| Flavor | Package ID | App Name | Intended Use |
|--------|------------|----------|--------------|
| `dev` | `in.sreerajp.sreerajp_authenticator.dev` | `Sreeraj P Authenticator Dev` | Local development, internal testing |
| `prod` | `in.sreerajp.sreerajp_authenticator` | `Sreeraj P Authenticator` | Production builds and releases |

- `dev` and `prod` can be installed side by side on the same device
- `dev` shows an in-app `DEV` banner for visual separation
- The About screen shows the active environment and package name

### Common Commands

Run the development flavor:

```bash
flutter run --flavor dev
```

Run the production flavor:

```bash
flutter run --flavor prod
```

Build a development APK:

```bash
flutter build apk --flavor dev --debug
```

Build production split APKs for mixed-device sharing:

```bash
flutter build apk --flavor prod --release --split-per-abi
```

Build a Play Store bundle:

```bash
flutter build appbundle --flavor prod --release
```

For a reusable explanation of flavor/mode combinations and artifact choices, see `docs/flutter_build_flavors_guide.md`.

### Testing

```bash
flutter test
```

---

## License

This project is developed by Sreeraj P.

