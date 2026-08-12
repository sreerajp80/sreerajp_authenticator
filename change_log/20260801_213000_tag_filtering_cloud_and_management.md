# Change Log: Two-Tab Home Screen (Accounts & Tag Cloud) and Tag Management

**Plan Reference:** [plans/20260801_213000_tag_filtering_cloud_and_management.md](../plans/20260801_213000_tag_filtering_cloud_and_management.md)
**Timestamp:** 2026-08-01 21:30:00

## Summary of Changes

Implemented a 2-tab Home Screen structure (`Accounts` and `Tag Cloud`), enhanced tag label visibility on account cards, and created a dedicated **Tag Management Screen** to rename or delete tags across accounts.

---

## Detailed Changes

### 1. `lib/providers/account_provider.dart`
- Added `renameTag(String oldTag, String newTag)`: Renames tag across all assigned accounts and updates the database.
- Added `deleteTag(String tag)`: Removes tag from all assigned accounts and updates the database.
- Added `getAccountCountForTag(String tag)`: Calculates account member count for a given tag.
- Updated `filteredAccounts` and tag matching logic to perform normalized, case-insensitive tag comparison.

### 2. `lib/screens/home_screen.dart`
- Upgraded `HomeScreen` to a **2-Tab Layout**:
  - **Tab 1 ("Accounts")**: Main account list view with search bar, manual drag reordering, sorting, and active filter banner (`Filtered by: #Tag [Clear Filter]`).
  - **Tab 2 ("Tags")**: Displays `HomeTagCloudView`.
- Fixed account filtering in `_getFilteredAndSortedAccounts` so selecting a tag dynamically filters the active account list.

### 3. `lib/widgets/home/home_tag_cloud_view.dart` [NEW]
- Created the **Tag Cloud View** widget for Tab 2:
  - Visual tag cloud chips with account member counts (e.g., `#Work (3)`).
  - Tapping a tag sets the active filter and automatically switches view back to Tab 1.
  - Includes a **"Manage Tags"** header button linking to `TagManagementScreen`.

### 4. `lib/screens/tag_management_screen.dart` [NEW]
- Created the **Tag Management Screen**:
  - Displays list of all active tags and total account usage counts.
  - Edit dialog to rename tags across all member accounts.
  - Delete dialog to remove tags from member accounts.
  - Tag search filter and empty state.

### 5. `lib/widgets/account_tile.dart`
- Enhanced tag badge design with higher contrast backgrounds, subtle borders, and bold text color for readability on account cards.

### 6. `lib/screens/settings_screen.dart`
- Added **"Manage Tags"** list tile under Settings navigation.

### 7. Unit Tests
- Updated `test/providers/account_provider_test.dart` with unit tests for `renameTag`, `deleteTag`, and `getAccountCountForTag`.

---

## Verification

- **`flutter analyze`**: `No issues found!` (0 errors, 0 warnings, 0 infos).
- **`flutter test`**: All provider and widget unit test suites passed cleanly (`All tests passed!`).
