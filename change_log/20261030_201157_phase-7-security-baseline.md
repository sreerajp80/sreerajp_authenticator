# Phase 7: Security Baseline check

Implements `plans/20261030_194117_phase-7-security-baseline.md`.

## Main findings

### ML Kit sends data to Google (confirmed)

On a `dev` debug build, on an Android 15 emulator with internet, with the camera open for about 75
seconds and no QR code shown:

- The app's own process logged a request to `https://firebaselogging.googleapis.com/v0cc/log/batch`,
  then `Status Code: 200`.
- It stored 12 `FIREBASE_ML_SDK` events.
- Android's per-app counter shows about 2 KB sent and 5 KB received.

This breaks hard rule 3 (zero telemetry). ML Kit being closed source also breaks hard rule 1. The exact
content sent was not read, because it is gzip over TLS. The packet capture came out empty, so the
evidence is the app log and the per-app counter.

### Release builds do not compile (new, not caused by this phase)

`screen_protector` 1.4.2 compiles against API 33. Since the toolchain upgrade, the release AAR metadata
check needs 34 or later, so `assembleProdRelease` fails. The last prod APK dates from August. Fixing it
was not in the approved plan, so it was not changed. Versions 1.4.3 and later use API 36.

Because of this, the ML Kit test ran on a `dev` debug build, not a release build. These stay `to verify`:
`debuggable=false` and obfuscation on a real release build, and the merged prod manifest.

## What changed

- **Manifest:** removed `ACCESS_WIFI_STATE`, `ACCESS_NETWORK_STATE`, `USE_FINGERPRINT`. Added
  `android:dataExtractionRules` (new `res/xml/data_extraction_rules.xml`) and
  `android:usesCleartextTraffic="false"`.
- **Final permissions (merged `dev` debug manifest):** `ACCESS_WIFI_STATE` is gone. `USE_FINGERPRINT`
  stays, added by `androidx.biometric`. `ACCESS_NETWORK_STATE` stays, added by ML Kit, until ML Kit is
  replaced.
- **Backup import (`lib/services/export_import_service.dart`, `lib/screens/backup_restore_screen.dart`):**
  16 MB size check before reading; the Wi-Fi sync limits now apply; a wrong password, a too-large file and
  invalid content each show their own message; cancelling the picker shows nothing.
- **Clipboard (new `lib/services/clipboard_service.dart`, `MainActivity.kt`):** secrets are marked
  sensitive on Android. Codes clear after 30 seconds; the recovery key and pairing code after 60.
- **Startup (new `lib/utils/screen_protection.dart`, `lib/main.dart`):** `ScreenProtector` runs on Android
  only.
- **User text (`en`, `ml`, `sa`):** corrected the privacy dialog, the permissions card and the
  zero-telemetry claims. Keys renamed: `labelNoCloudService`, `descNoCloudService`,
  `errorBackupPassword`. New keys: `errorBackupTooLarge`, `errorBackupInvalid`.
- **Tests:** new `test/security/android_manifest_test.dart`, `test/services/clipboard_service_test.dart`,
  `test/services/export_import_file_limits_test.dart`, `test/utils/screen_protection_test.dart`. Updated
  `test/widgets/account_tile_copy_test.dart`.
- **Docs:** `docs/security.md`, `docs/dependencies.md`, `docs/PROJECT_PROFILE.md`,
  `docs/release_process.md`, `docs/features.md`, `docs/implementation_progress.md`, `README.md`.

## One change beyond the plan text

The plan said clearing happens only if the clipboard still holds the copied value. Android 10+ blocks
clipboard reads from the background, so the old check never cleared anything once the user had switched
apps to paste. Now an unreadable clipboard is cleared too. The cost is that something copied in another
app during the time limit can be wiped.

## Checks

- `dart format`: no changes needed. `flutter analyze`: no issues. `flutter test`: 566 passed.
- `dev` debug APK builds. Gradle daemons stopped, none left over.
- Clipboard clearing and the sensitive flag ran only in unit tests, not on a device.

## Not done

- **Real phone check, owner:** Wi-Fi sync between two devices (the host must show its real IP, not
  `127.0.0.1`), app lock with fingerprint and phone lock, optical sync, QR scanning, and copying a code
  then switching apps.
- `docs/security.md` §12 is not signed off, and cannot pass until the blockers in §17 are closed.
- Release blockers recorded in §17: ML Kit, the release build, "Delete all data".
- Linux keyring fallback, file modes, and the desktop database are still unchecked.

## Translations to review

All new `ml` and `sa` text is a draft. Please check especially:

- `sa`: `कोषः` (vault), `छायाग्राहक-QR-अवलोककः` (camera QR scanner), `अन्तर्जालरहितप्रधानम्` (offline-first),
  `अपनेष्यते` (will be removed).
- `ml`: `നിലവറ` (vault), `ഓഫ്‌ലൈൻ മുൻഗണന` (offline-first), `ക്ലിപ്പ്ബോർഡ്` (clipboard).
