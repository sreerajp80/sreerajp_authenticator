# Plan: Appearance, Features, and Help Cards in Settings

**Status:** Implemented

## Issue
The Settings screen in SreerajP Authenticator lacks dedicated top-level hubs for Appearance, Features, and Help, similar to those in `SreerajPContactSphere`. Currently, theme options are embedded inline, there is no comprehensive feature exploration hub, and Help is a simple alert dialog.

## Fix
1. **Appearance Hub & Sub-Screens**:
   - Add a dedicated `Appearance` card under Settings.
   - Create `lib/screens/appearance_screen.dart` with sections for Theme Mode and display preferences.
   - Create `lib/screens/theme_mode_settings_screen.dart` offering Light, Dark, and System modes with detailed descriptions and visual selection.

2. **Features Showcase Hub**:
   - Add a `Features` card under Settings.
   - Create `lib/screens/features_screen.dart` mirroring ContactSphere's categorized design with a gradient header card, section headers, detailed descriptions, and highlight chips for:
     - Core OTP & 2FA Tools (TOTP, HOTP, QR Scanner, Brand Icons, Countdown Rings)
     - Vault Security & Encryption (AES-256-GCM, Biometrics, Auto-Lock, Screenshot Guard, Zero Telemetry)
     - Organization & Productivity (Tagging, Tag Cloud, Search & Filtering, Account Reordering)
     - Data Transfer & Backups (Local P2P Wi-Fi Sync, Optical Air-Gap Sync, Encrypted Backup/Restore)

3. **Help Center & Dedicated Guide Screens**:
   - Add a `Help` card under Settings.
   - Create `lib/screens/help/help_home_screen.dart` as the central Help Center with categorized topic navigation.
   - Create dedicated in-depth help screens under `lib/screens/help/`:
     - `getting_started_help_screen.dart`: QR code scanning, manual account creation, and secret key setup.
     - `time_sync_help_screen.dart`: TOTP time drift, clock synchronization, and HOTP counter advancement.
     - `tag_management_help_screen.dart`: Tagging accounts, filtering, batch management, and tag cloud usage.
     - `biometrics_help_screen.dart`: Fingerprint / Face ID unlock, device PIN fallback, and auto-lock behavior.
     - `vault_security_help_screen.dart`: AES-256-GCM hardware key storage, zero telemetry, and Screenshot Guard (`FLAG_SECURE`).
     - `p2p_sync_help_screen.dart`: Local Wi-Fi P2P device-to-device account transfer and security model.
     - `optical_sync_help_screen.dart`: Animated high-density QR air-gap synchronization for offline devices.
     - `backup_help_screen.dart`: Encrypted JSON backup files, password protection, and safe restore/merge behavior.
     - `faq_troubleshooting_help_screen.dart`: Comprehensive FAQ cards addressing common questions, troubleshooting steps, and security guidelines.

4. **Settings Screen Integration**:
   - Update `lib/screens/settings_screen.dart` to integrate the Appearance, Features, and Help cards with consistent 3D neumorphic styling and auto-lock monitoring.

## Files to Change
- **New Files**:
  - `lib/screens/appearance_screen.dart`
  - `lib/screens/theme_mode_settings_screen.dart`
  - `lib/screens/features_screen.dart`
  - `lib/screens/help/help_home_screen.dart`
  - `lib/screens/help/getting_started_help_screen.dart`
  - `lib/screens/help/time_sync_help_screen.dart`
  - `lib/screens/help/tag_management_help_screen.dart`
  - `lib/screens/help/biometrics_help_screen.dart`
  - `lib/screens/help/vault_security_help_screen.dart`
  - `lib/screens/help/p2p_sync_help_screen.dart`
  - `lib/screens/help/optical_sync_help_screen.dart`
  - `lib/screens/help/backup_help_screen.dart`
  - `lib/screens/help/faq_troubleshooting_help_screen.dart`
- **Modified Files**:
  - `lib/screens/settings_screen.dart`
