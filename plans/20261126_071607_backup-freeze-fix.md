# Backup and restore freeze the app on slow phones

**Status:** completed

## The issue

On a slow test phone (Android 10, low-end), "Create backup" freezes the app for about
15 seconds. Android then shows "App isn't responding" (an ANR). The phone log has two ANRs
for the app today. In one of them the app was closed from the ANR dialog, so that backup
was lost.

Cause: before saving, the backup turns the password into an AES key with PBKDF2-HMAC-SHA256,
300,000 rounds (`AppConstants.pbkdf2Iterations`). This runs in `_deriveKey` in
`lib/services/export_import_service.dart` on the **main isolate** (the thread that draws the
screen and handles taps). Pure-Dart crypto is slow on this phone, so the main thread is busy
for ~15 seconds.

Restore uses the same `_deriveKey`, so it freezes the same way.

Note: the Backup & Restore screen **already** shows a spinner (`_isProcessing`). It did not
help, because a frozen main thread cannot draw the spinner either. A progress window alone
will not fix this; the heavy work must leave the main thread.

## The fix

1. **Move the key work off the main thread.** In `export_import_service.dart`, run the
   password-to-key step (and the AES-GCM encrypt / decrypt with it) inside `Isolate.run`.
   This is the same method `AuthService._pbkdf2Hash` already uses for the PIN.
   - `_encryptData` and `_decryptData` become `async` (return `Future`).
   - The isolate gets only plain values (strings, bytes), so nothing else is shared.
   - The 300,000 rounds stay as they are. Security strength does not change.
2. **Show a progress window while it works (your idea).** Now the spinner can really move.
   - Backup & Restore screen: replace the bare spinner with a spinner plus a short text,
     "Please wait…" style, for backup and for restore.
   - Home screen "Export selected": today it has no progress at all. Show a small
     non-dismissible progress dialog with the same text, and close it when done.
3. **Localization.** Add one new key (for example `labelPleaseWait` — short label) to
   `app_en.arb`, `app_ml.arb`, `app_sa.arb` with real translations and an `@` description.
   Run `flutter gen-l10n`.
4. **Tests.** Update the tests that call `encryptDataForTest` / `decryptDataForTest` to
   `await` them. Add one test that a backup made by the isolate path can still be read
   (round trip). Run `flutter analyze` and `flutter test`.
5. Change log in `change_log/`.

## Files to change

- `lib/services/export_import_service.dart`
- `lib/screens/backup_restore_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb` (+ generated `app_localizations*.dart`)
- `test/services/export_import_service_test.dart`
- `test/services/export_import_file_limits_test.dart`
- `test/services/export_import_save_result_test.dart` (only if it needs `await`)

## Security impact

Storage/crypto code is touched, but behaviour does not change: same PBKDF2 rounds, same
AES-256-GCM, same `v3:` file format, so old backups still restore. The password and
plaintext are passed to a short-lived isolate in the same app process and are never logged
or written to disk. Nothing new is stored, and there is no network use.

## Out of scope

- Lowering the PBKDF2 rounds (would weaken backup security).
- A real percent progress bar (PBKDF2 has no progress callback; a spinner is honest).
