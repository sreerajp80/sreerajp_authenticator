# Default sort to alphabetical (by account name) and persist the user's choice

**Status:** completed

## The issue

Two problems with account sorting on the home screen:

1. **Wrong default.** The default sort is "Manual" (`sortOrder`). The user wants the
   default to be alphabetical — specifically **By Account Name** (confirmed with the
   user; the other alphabetical option is "By Issuer").

2. **Choice is not preserved.** The selected sort is held only in local widget state
   (`_sortBy` in `_HomeScreenState`). It resets to the default every time the app is
   restarted or the home screen is rebuilt. The user wants the chosen sort to stick
   across app restarts.

Current behavior lives in:

- `lib/screens/home_screen.dart:37` — `String _sortBy = 'manual';` (local, not persisted).
- `lib/screens/home_screen.dart:252-254` — sort menu `onSelected` sets local state only.
- `lib/screens/home_screen.dart:124-149` — `_getFilteredAndSortedAccounts` switch;
  the `default:` (manual) branch sorts by `sortOrder`.

The app already has a clear pattern for persisted preferences: `SettingsProvider`
backed by `SharedPreferences` (e.g. `exportFormat`, `themeMode`, `autoLockTimeout`).
We will reuse that pattern for the sort preference.

## The plan

### 1. Add a persisted `sortBy` preference to `SettingsProvider`

In `lib/providers/settings_provider.dart`:

- Add a SharedPreferences key constant: `_keySortBy = 'sort_by'`.
- Add a field `String _sortBy = AppConstants.defaultSortBy;` and a getter
  `String get sortBy => _sortBy;`.
- In `_loadSettings()`, read it: `_sortBy = prefs.getString(_keySortBy) ?? AppConstants.defaultSortBy;`.
  Guard against unknown/legacy values by validating against the known set
  (`manual`, `issuer`, `account`, `date`) and falling back to the default if not
  recognized.
- Add a setter `Future<void> setSortBy(String value)` that validates the value,
  updates `_sortBy`, persists via `prefs.setString(_keySortBy, _sortBy)`, and calls
  `notifyListeners()` — mirroring `setExportFormat`.

Note: this stays a device-local preference. It will **not** be added to
`syncableSettingsSnapshot()` / `applySyncedSettings()`, consistent with how a
purely local UI preference should behave (no security or cross-device requirement).
If cross-device sync of the sort choice is wanted, that can be a separate change.

### 2. Add the default constant

In `lib/utils/constants.dart` (near `defaultSortOrder`):

- Add `static const String defaultSortBy = 'account';` (By Account Name).

### 3. Use the persisted value in the home screen

In `lib/screens/home_screen.dart`:

- Remove the local `String _sortBy = 'manual';` field. Instead read the current
  value from `SettingsProvider` (via `context.watch`/`Consumer` in `build`, and
  `context.read` in callbacks). The simplest, lowest-risk change:
  - Replace all reads of `_sortBy` with `settings.sortBy` where `settings` is the
    `SettingsProvider` already available in `build`.
  - In the sort menu `onSelected`, call `context.read<SettingsProvider>().setSortBy(value)`
    instead of `setState(() => _sortBy = value)`. The provider's `notifyListeners`
    will rebuild the affected `Consumer`s.
  - Keep the existing "Long press and drag to reorder" SnackBar when the user
    selects `manual`.
- Confirm the two other `_sortBy` usages update accordingly:
  - the "manual" info banner (`home_screen.dart:356`),
  - the `ReorderableListView` vs normal list branch (`home_screen.dart:434`).
  Both must read `settings.sortBy` so they react to the persisted value. This means
  the relevant part of the widget tree must be inside a `Consumer<SettingsProvider>`
  (or use `context.watch`) so a sort change rebuilds it.

Default sort behavior itself (the switch in `_getFilteredAndSortedAccounts`) does
not need new cases — `'account'` already sorts alphabetically by name. Only the
default value changes, from `manual` to `account`.

### 4. Tests

- `test/providers/` — add/extend a settings provider test to verify:
  - default `sortBy` is `'account'` when nothing is stored,
  - `setSortBy` persists and is re-read on reload,
  - an invalid stored value falls back to the default.
  (Follow the existing SharedPreferences mock pattern used by other settings tests.)
- Run the full suite with `flutter test` and `flutter analyze` (zero new issues),
  per the project standards.

## Files to be changed

- `lib/utils/constants.dart` — add `defaultSortBy` constant.
- `lib/providers/settings_provider.dart` — add persisted `sortBy` field, getter,
  loader, and `setSortBy` setter.
- `lib/screens/home_screen.dart` — read/write sort from `SettingsProvider` instead
  of local state; default now alphabetical via the constant.
- `test/providers/settings_provider_test.dart` (or the existing settings test file)
  — add coverage for default, persistence, and fallback.

## Risks / notes

- Behavior change: existing users who never touched sorting will now see accounts
  ordered alphabetically by name instead of manual order on next launch. This is the
  requested behavior. Users can still switch back to "Manual" (and that choice will
  now be remembered).
- The manual drag-to-reorder feature is unchanged; it is still available when the
  user selects "Manual".
- No database, schema, or crypto changes. No security-relevant surface touched.
