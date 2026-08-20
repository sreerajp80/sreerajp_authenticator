# Change Log: Appearance, Features, and Help Cards in Settings

**Date:** 2026-08-20
**Referenced Plan:** `plans/20260820_204500_appearance-features-help-settings-cards.md`

## Summary of Changes
1. **Appearance Hub & Theme Selection Screen**:
   - Added dedicated `Appearance` card in Settings.
   - Created `lib/screens/appearance_screen.dart` as the appearance hub.
   - Created `lib/screens/theme_mode_settings_screen.dart` allowing users to configure Light, Dark, and System theme modes with live visual status and descriptive cards.

2. **Features Showcase Screen**:
   - Added dedicated `Features` card in Settings.
   - Created `lib/screens/features_screen.dart` with a gradient header card and structured categories:
     - Core 2FA & OTP Tools (TOTP, HOTP, QR Scanner, Brand Icons, Countdown Ring)
     - Vault Security & Privacy (AES-256-GCM, Biometrics, Inactivity Auto-Lock, FLAG_SECURE, Zero Telemetry)
     - Organization & Productivity (Multi-Tag System, Interactive Tag Cloud, Instant Search, Account Ordering)
     - Sync, Air-Gap & Backups (Local Wi-Fi P2P Sync, Optical Air-Gap Sync, Encrypted Backups, Safe Conflict Resolution)

3. **Help Center & Dedicated Guide Screens**:
   - Added dedicated `Help` card in Settings.
   - Created `lib/screens/help/help_home_screen.dart` as the central Help Center with categorized topic navigation.
   - Created 9 comprehensive in-depth guide screens under `lib/screens/help/`:
     - `getting_started_help_screen.dart`
     - `time_sync_help_screen.dart`
     - `tag_management_help_screen.dart`
     - `biometrics_help_screen.dart`
     - `vault_security_help_screen.dart`
     - `p2p_sync_help_screen.dart`
     - `optical_sync_help_screen.dart`
     - `backup_help_screen.dart`
     - `faq_troubleshooting_help_screen.dart`

4. **Settings Screen Restructuring**:
   - Updated `lib/screens/settings_screen.dart` with clean 3D neumorphic styling, glossy overlays, and auto-lock monitoring across all screens.

## Verification
- Static analysis: `flutter analyze` completed with 0 issues.
- Automated tests: `flutter test` ran 228 tests with 100% pass rate (0 failures).
- Code formatting: `dart format .` applied across all codebase files.
