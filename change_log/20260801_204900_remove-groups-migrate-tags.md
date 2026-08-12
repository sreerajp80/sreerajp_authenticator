# Change Log: Remove Groups Feature and Migrate to Tags

**Plan Reference:** `plans/20260801_204900_remove-groups-migrate-tags.md`
**Timestamp:** 2026-08-01 20:49:00

## Summary of Changes

Removed the obsolete Groups feature entirely across the app, replacing and migrating group organization into multi-dimensional tags.

### 1. Database Schema & Migration (v4)
- Incremented `databaseVersion` to `4` in `constants.dart`.
- Added migration logic `_onUpgrade` in `database_service.dart` from v3 to v4:
  - Fetches existing `groupId` references for accounts and appends the associated group name into the account's comma-separated `tags` column.
  - Drops the `groups` table.
- Removed all Group CRUD methods (`createGroup`, `getAllGroups`, `updateGroup`, `deleteGroup`).

### 2. Models & Data layer
- Deleted `lib/models/group.dart`.
- Updated `lib/models/account.dart` to remove `groupId` from parameters, `toMap()`, `fromMap()`, and `copyWith()`.

### 3. Providers & State Management
- Deleted `lib/providers/group_provider.dart`.
- Removed `GroupsProvider` registration from `main.dart` and `LockScreen`.
- Cleaned up `lib/providers/account_provider.dart`:
  - Removed `moveAccountsToGroup`, `getAccountCountForGroup`, and `getAccountsByGroup`.
  - Updated `importData` signature and logic (no longer processes groups, returns account-only import result).

### 4. UI Screens & Widgets
- Deleted `lib/widgets/home/home_group_tabs.dart` and `lib/screens/group_management_screen.dart`.
- Updated `HomeScreen`: Removed group tabs, group management folder icon button in app bar, and group filtering logic. Retained tag filter bar.
- Updated `AddAccountScreen` & `AccountInfoCard`: Removed group selector dropdown.
- Updated `AccountTile`: Removed group badge.
- Updated `BackupRestoreScreen`, `SyncScreen`, and `SendToDeviceView`: Removed group choices, checkboxes, and counts from backup, restore, and P2P sync flows.

### 5. Export / Import & P2P Sync Services
- `export_import_service.dart`: `dataToJson` and encrypted backup format emit empty `groups: []` array for backwards compatibility; import ignores legacy `groups` key.
- `p2p_sync_service.dart`: Removed group limits and group payload parsing.

### 6. Tests & Cleanup
- Deleted `test/models/group_test.dart` and `test/providers/group_provider_test.dart`.
- Updated `account_test.dart`, `database_service_test.dart`, `export_import_service_test.dart`, `p2p_sync_service_test.dart`, `account_provider_test.dart`, `home_widgets_test.dart`, and `provider_test_helpers.dart`.
- Verified zero static analysis issues (`flutter analyze`).
- Verified all unit and widget tests pass (210/210 tests passed).
