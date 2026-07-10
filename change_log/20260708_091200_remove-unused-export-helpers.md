# Change log — Remove unused plain-JSON and CSV export/import helpers

Implements plan: `plans/20260708_090500_remove-unused-export-helpers.md`

## What changed

Removed dead code from the export/import service — plain-text JSON and CSV
export/import helpers that no screen called. The Backup & Restore UI only ever
uses the encrypted `.aes` flow.

### `lib/services/export_import_service.dart`
- Removed `exportAccounts(...)` — plain JSON export, no caller.
- Removed `importAccounts()` — plain JSON import, no caller.
- Removed `exportAccountsAsCSV(...)` — CSV export, no caller.
- Removed `_accountsToCsv(...)` — CSV builder, only used by the removed CSV export.
- Removed `accountsToCsvForTest(...)` — `@visibleForTesting` helper for the CSV builder.
- Kept the live encrypted flow (`exportAccountsEncrypted`, `importAccountsEncrypted`),
  `_parseBackupJson` (still used by encrypted import), and all crypto helpers.
- No imports became unused (`file_picker`, `share_plus`, `path_provider` still used
  by the encrypted flow).

### `test/services/export_import_service_test.dart`
- Removed the `CSV export` test group (the only tests covering removed code).

### `docs/security.md`
- Updated the "Plaintext export policy" bullet: the code no longer contains any
  plaintext JSON or CSV export path; the service writes only password-encrypted
  `.aes` backups.

## Verification
- `flutter analyze` on the changed files: no issues.
- `flutter test` (full suite): 205 tests passed.
