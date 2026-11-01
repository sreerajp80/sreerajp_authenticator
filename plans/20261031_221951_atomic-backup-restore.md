# Make backup restore all-or-nothing

**Status:** completed

## Files to change

- `lib/services/database_service.dart` — add `createAccounts`.
- `lib/providers/account_provider.dart` — change `importData`.
- `test/providers/account_provider_test.dart` — add tests.
- `docs/features.md` — section 5, say that import is all-or-nothing.

## The issue

`AccountsProvider.importData` encrypts and saves one account at a time. Each save is a separate
database write. If a save fails midway, the earlier accounts stay and the later ones are missing.
The user sees an error, but the vault now holds part of the backup.

No data is lost, and running the restore again skips the duplicates. But hard rule 5 asks for
atomic, safe database writes. Wi-Fi sync and optical sync use the same function, so they have the
same problem.

## The fix

Split `importData` into two phases:

1. **Prepare, outside the transaction.** Parse each account, skip duplicates, and encrypt the
   secret. Keep the results in a list in memory. Nothing is written yet, so a bad account or an
   encryption failure leaves the vault unchanged.
2. **Write, inside one transaction.** Add `DatabaseService.createAccounts(List<Account>)`, which
   inserts all rows in one `db.transaction`. If any insert fails, SQLite undoes all of them.
   An empty list does nothing.

Why this order:

- Secrets are encrypted before they reach the database, as hard rule 5 requires.
- The transaction stays short. A long transaction would block other database work while the app
  reads the key from secure storage.
- The transaction code stays in the service layer, following the layer rules.

Other behaviour stays the same: the duplicate rule, the added and skipped counts, and the error
passed up to the screen. The result of a failed import changes from "some accounts added" to
"nothing added". The accounts list is still reloaded only after a good import; a failed import
changes nothing in the database, so no reload is needed.

No new text for the user. The existing error message still applies.

## Tests

- A successful import saves all new accounts, with encrypted secrets.
- A database failure midway leaves no new accounts. A test-only SQLite trigger makes the insert of
  one named account fail, and the test checks that the existing accounts are unchanged and the
  earlier new accounts were undone.
- Importing the same data again after that failure, without the trigger, adds all of them.
- A malformed item in the list adds nothing.

## Out of scope

Other multi-step writes, such as `renameTag`, `deleteTag`, `bulkUpdateTags` and
`deleteMultipleAccounts`, also write one row at a time. They are separate work.

## Security impact

Storage: database writes become one transaction. Secrets are still encrypted before they are
written, and nothing new is logged or stored. This lowers risk.
