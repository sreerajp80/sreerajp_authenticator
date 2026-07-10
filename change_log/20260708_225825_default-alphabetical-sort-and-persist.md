# Change log: default alphabetical sort and persist the user's choice

Implements plan `plans/20260708_223624_default-alphabetical-sort-and-persist.md`.

## What changed

Two behaviors were changed on the home screen account list:

1. **Default sort is now alphabetical by issuer** (was "Manual" / `sortOrder`).
2. **The selected sort is now remembered across app restarts** (was reset every launch
   because it lived only in local widget state).

## Files changed

### `lib/utils/constants.dart`
- Added `defaultSortBy = 'issuer'` — the new default sort (alphabetical by issuer, with
  accounts that have no issuer pushed to the end).
- Added `sortByOptions = ['manual', 'issuer', 'account', 'date']` — the recognized sort
  values, used for validation.

### `lib/providers/settings_provider.dart`
- Added a persisted `sortBy` preference following the existing `SharedPreferences`
  pattern:
  - New key `_keySortBy = 'sort_by'`.
  - New field `_sortBy` (defaults to `AppConstants.defaultSortBy`) and getter `sortBy`.
  - Loads the value in `_loadSettings()`, validating it through `_normalizeSortBy`
    (unknown or missing values fall back to the default).
  - New `setSortBy(String value)` setter: ignores unrecognized values (never changes the
    current sort on bad input), persists valid changes, and notifies listeners.
- This is a device-local preference; it is intentionally **not** added to
  `syncableSettingsSnapshot()` / `applySyncedSettings()`.

### `lib/screens/home_screen.dart`
- Removed the local `String _sortBy = 'manual';` field.
- `build` now reads the current sort from the provider:
  `final sortBy = context.watch<SettingsProvider>().sortBy;`.
- The sort menu `onSelected` now calls `context.read<SettingsProvider>().setSortBy(value)`
  instead of `setState`. The "Long press and drag to reorder" SnackBar on selecting
  "Manual" is unchanged.
- `_getFilteredAndSortedAccounts` now takes a `sortBy` parameter instead of reading the
  removed field. The sort menu selection highlight, the manual info banner, and the
  `ReorderableListView`-vs-normal-list branch all read the provider value, so a sort
  change (and the persisted value on launch) takes effect immediately.

### `test/providers/settings_provider_test.dart`
- Added four tests: default is `'account'`; `setSortBy` persists and reloads on a fresh
  provider; invalid `setSortBy` input is ignored (keeps current); an unknown stored value
  falls back to the default.

## Verification

- `flutter analyze` on the changed files: no issues.
- `flutter test`: all 209 tests pass, including the four new sort tests.

## Notes / behavior impact

- Existing users who never changed the sort will now see accounts alphabetical by issuer
  on their next launch. They can still choose "Manual" (drag-to-reorder), and that choice
  is now remembered.
- No database, schema, crypto, or security surface was touched.
