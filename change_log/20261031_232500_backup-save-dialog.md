# Save backups with the system save screen

Implements `plans/20261031_230624_backup-save-dialog.md`.

## What changed

- `lib/services/export_import_service.dart`: `exportAccountsEncrypted` now saves through
  `FilePicker.saveFile` (the system save screen). It returns `true` only when a saved location
  comes back. The temporary cache file is gone. A new `fileSaver` constructor option lets tests
  replace the save call.
- `lib/screens/home_screen.dart`: "Export selected" now calls `setBackupInProgress` around the
  export, as the backup screen does.
- `pubspec.yaml`, `pubspec.lock`: removed `share_plus`.
- `test/services/export_import_save_result_test.dart`: new tests for saved, cancelled and failed.
- `docs/features.md`, `docs/dependencies.md`, `docs/security.md`: replaced the `share_plus` notes.

## Why

The share sheet tells the app only which app was chosen, not whether it finished. Choosing Drive
and then cancelling inside Drive showed "Backup created". The sheet also never lists the system
Files app, because that app does not receive shared files.

## Verified

- `flutter analyze`: no issues. `flutter test`: all 701 tests pass.
- Emulator, dev flavor, with a fake account:

| Action | Result |
|--------|--------|
| Create backup | System Files save screen opens with the file name filled in |
| Cancel the save screen | "Backup canceled or failed" |
| Save to `Download` | "Backup created", and the file exists |
| Delete the account, then restore that file | "Accounts restored: 1", and the account is back |
| Export selected, cancel | "Failed to export selected accounts" |
| Export selected, save | File exists in `Download` |

## Not verified

- The `setBackupInProgress` guard on "Export selected" was not tested with the app lock firing.
- Files by Google was not tested, because it is not installed on the emulator.
- Behaviour on a real phone was not tested.

## Known small issue

Cancelling "Export selected" shows "Failed to export selected accounts", although nothing failed.
The wording was left as it is, because `exportAccountsEncrypted` returns one `false` for both cases.
