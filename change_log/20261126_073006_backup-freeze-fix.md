# Backup and restore no longer freeze the app

Implements plan: `plans/20261126_071607_backup-freeze-fix.md`

## Problem

On a slow phone, "Create backup" froze the app for about 15 seconds and Android showed
"App isn't responding". The 300,000-round PBKDF2 password-to-key step ran on the main
isolate, which also draws the screen. The existing spinner could not move either.

## What changed

- `lib/services/export_import_service.dart`
  - The password-to-key step and the AES-256-GCM encrypt / decrypt now run in a
    background isolate (`Isolate.run`), the same way `AuthService` already hashes the PIN.
  - New static helpers `_encryptV3`, `_decryptV3` and a static `_deriveKey` hold the
    crypto work. `_encryptData` / `_decryptData` are now `async` wrappers.
  - No logging inside the isolate (the logger is not set up there). The caller logs a
    failed decrypt instead. Still no secret, password or plaintext in logs.
  - Same PBKDF2 rounds, same AES-256-GCM, same `v3:` file format. Old backups still restore.
  - `encryptDataForTest` / `decryptDataForTest` now return `Future`s.
- `lib/screens/backup_restore_screen.dart` — the processing view shows the spinner with a
  "Please wait…" text, for both backup and restore.
- `lib/screens/home_screen.dart` — "Export selected" now shows a "Please wait…" dialog the
  user cannot close while the export runs (`_showBackupProgressDialog`). The
  backup-in-progress flag is now cleared in a `finally` block.
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` — new key `labelPleaseWait`
  (en "Please wait…", ml "കാത്തിരിക്കുക…", sa "प्रतीक्ष्यताम्…", both from the language pack
  glossary). Generated `app_localizations*.dart` updated with `flutter gen-l10n`.
- Tests (`test/services/export_import_service_test.dart`,
  `export_import_file_limits_test.dart`, `export_import_save_result_test.dart`) now
  `await` the crypto helpers. These tests now go through the isolate path, so they already
  cover the planned round-trip check. No separate new test was needed.

## Checks

- `dart format` — no changes needed.
- `flutter analyze` — no new issues. The 2 existing infos in the generated
  `lib/l10n/app_localizations.dart` (old SDK delegates list) were already there before.
- `flutter test` — all 753 tests pass.
- Not yet checked on the real slow phone. That needs a new build installed on it.

## Security impact

Behaviour and strength are unchanged. The password and plaintext go only to a short-lived
isolate in the same app process. They are never logged or written to disk.
