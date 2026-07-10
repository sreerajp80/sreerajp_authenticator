# Remove unused plain-JSON and CSV export/import helpers

**Status:** completed

## The issue

The Backup & Restore screen has only two actions — "Create Encrypted Backup" and
"Restore from Backup". Both use the encrypted `.aes` flow. The service layer still
carries older plain-text JSON and CSV export/import helpers that no screen calls.
They are dead code that also weakens the security posture (methods that write
unencrypted secrets to disk), so they should be removed.

## What is unused (confirmed by search)

In `lib/services/export_import_service.dart`:

- `exportAccounts(...)` — plain JSON export (lines ~109–152). No caller.
- `importAccounts()` — plain JSON import (lines ~154–174). No caller.
- `exportAccountsAsCSV(...)` — CSV export (lines ~176–218). No caller.
- `_accountsToCsv(...)` — CSV builder (lines ~253–274). Used only by
  `exportAccountsAsCSV` and the test helper below.
- `accountsToCsvForTest(...)` — `@visibleForTesting` helper (lines ~380–382) that
  only exists to test the dead CSV builder.

The only references anywhere are these definitions themselves plus the CSV test
group in the test file. The UI calls only `exportAccountsEncrypted` and
`importAccountsEncrypted`.

### What must stay

- `exportAccountsEncrypted`, `importAccountsEncrypted` — the live flow.
- `_parseBackupJson` — still used by `importAccountsEncrypted` (do NOT remove).
- All crypto helpers (`_deriveKey`, `_encryptData`, `_decryptData`,
  `_legacyPadPassword`) and their test helpers — still used.
- Imports: `file_picker` (used by encrypted import), `share_plus` (used by
  encrypted export) both remain in use, so no import removals expected. Will
  re-check after editing.

## Files to be changed

1. `lib/services/export_import_service.dart`
   - Delete `exportAccounts`, `importAccounts`, `exportAccountsAsCSV`,
     `_accountsToCsv`, and `accountsToCsvForTest`.
   - Verify no now-unused imports remain; remove any that become unused.

2. `test/services/export_import_service_test.dart`
   - Delete the `CSV export` test group (lines ~335–383), which is the only test
     that exercises the removed code. All other tests target code that stays.

3. `docs/security.md`
   - Update the "Plaintext export policy" bullet (line ~348) that says the legacy
     JSON and CSV export helpers "still exist in the service layer", since they
     will no longer exist. Change it to state the app has no plaintext export path.

## Plan for the fix

1. Remove the five members from the service file.
2. Remove the CSV test group from the test file.
3. Update the security.md bullet to reflect that plaintext/CSV export no longer
   exists in the code.
4. Run `flutter analyze` (expect zero new issues) and `flutter test` (expect all
   pass) to confirm nothing is broken.

## Risk

Low. The removed code has no callers and is not part of any user-facing flow.
The only tests removed are the ones covering the removed code.
