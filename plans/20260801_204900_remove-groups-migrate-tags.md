# Plan: Remove Groups Feature & Migrate to Tags

**Status:** Approved — implementing

**Plan file:** `plans/20260801_204900_remove-groups-migrate-tags.md`
**Related change log:** `change_log/20260801_205000_remove-groups-migrate-tags.md`

---

## Problem

The app has both a Groups feature (with `Group` model, `GroupsProvider`, `GroupManagementScreen`, group tabs on home screen, and group dropdown in the add/edit form) and a Tags feature. Tags are already complete and provide equivalent functionality. Maintaining both is redundant.

## Fix

1. Add SQLite schema version 4 migration: for each group in the `groups` table, append the group name as a tag on every account in that group. Then drop the `groups` table.
2. Remove the `Group` model, `GroupsProvider`, `GroupManagementScreen`, `HomeGroupTabs`, group dropdown in `AccountInfoCard`, and group badge in `AccountTile`.
3. Remove all group references from providers, services, screens, and tests.
4. Keep the Tags UI and filter logic fully intact.

## Files Changing

### Delete
- `lib/models/group.dart`
- `lib/providers/group_provider.dart`
- `lib/widgets/home/home_group_tabs.dart`
- `lib/screens/group_management_screen.dart`

### Modify
- `lib/utils/constants.dart`
- `lib/services/database_service.dart`
- `lib/models/account.dart`
- `lib/providers/account_provider.dart`
- `lib/services/export_import_service.dart`
- `lib/widgets/account_tile.dart`
- `lib/widgets/add_account/account_info_card.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/add_account_screen.dart`
- `lib/screens/backup_restore_screen.dart`
- `lib/screens/sync_screen.dart`
- `lib/screens/send_to_device_screen.dart`
- `lib/screens/lock_screen.dart`
- `lib/main.dart`
- `test/widgets/home/home_widgets_test.dart`
- `test/services/p2p_sync_service_test.dart`
- `test/services/export_import_service_test.dart`
- `docs/architecture.md`
