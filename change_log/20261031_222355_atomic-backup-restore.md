# Make backup restore all-or-nothing

Implements `plans/20261031_221951_atomic-backup-restore.md`.

## What changed

- `lib/services/database_service.dart`: added `createAccounts`, which inserts a list of accounts in
  one transaction.
- `lib/providers/account_provider.dart`: `importData` now parses, skips duplicates and encrypts
  first, keeping the results in memory. It then saves them together with `createAccounts`.
- `test/providers/account_provider_test.dart`: added three tests:
  - a good import saves all accounts with encrypted secrets;
  - a database failure midway saves nothing, and a retry then adds every account;
  - a malformed item saves nothing.
- `docs/features.md`: section 5 now says that import is all-or-nothing.

## Behaviour change

If an import fails, no new accounts are added. Before, the accounts handled before the failure
stayed saved. Wi-Fi sync and optical sync use the same function, so they get the same behaviour.
The duplicate rule, the counts and the error messages are unchanged.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: all 592 tests pass.
- Not tried on a real device. The failure case was tested only with a test-only SQLite trigger.

## Not changed

`renameTag`, `deleteTag`, `bulkUpdateTags` and `deleteMultipleAccounts` still write one row at a
time.
