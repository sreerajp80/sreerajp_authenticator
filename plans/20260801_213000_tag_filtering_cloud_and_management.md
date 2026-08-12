# Two-Tab Home Screen (Accounts & Tag Cloud) and Tag Management

**Status:** Approved

## Issue
1. **Home Screen Layout:** Horizontal tag filter bar on the main list was inconvenient and tag filtering wasn't updating account cards.
2. **Account Card Tags:** Tag labels were subtle and hard to read on account cards.
3. **No Tag Management Screen:** Users had no dedicated area to view tag statistics, rename tags across accounts, or delete unused tags.

---

## Proposed Solution: 2-Tab Home Screen Architecture

### Tab 1: "Accounts" (Primary View)
- Displays all authenticator account cards (with search bar, sorting, manual drag-to-reorder, and swipe actions).
- When a tag filter is active, displays an active filter banner (e.g., `Filtered by #Work (3) [Clear Filter]`).
- Tapping `[Clear Filter]` resets filter and displays all account cards again.
- Account cards feature high-contrast, rounded tag badges so tag labels stand out clearly.

### Tab 2: "Tags" (Tag Cloud & Management View)
- Displays a visual **Tag Cloud** of all tags with their assigned account counts (e.g., `#Work (3)`, `#Crypto (2)`).
- **Tapping a tag chip** in Tab 2 sets that tag filter and **automatically switches to Tab 1**, displaying only the cards with that tag.
- Includes a **"Manage Tags"** action button at the top:
  - Allows editing/renaming any tag across all accounts.
  - Allows deleting any tag from all accounts.
  - Quick search and cleanup of unused tags.

---

## Files to Change

### 1. [lib/providers/account_provider.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/providers/account_provider.dart)
- Add `renameTag(String oldTag, String newTag)`: Renames tag across all accounts and updates DB.
- Add `deleteTag(String tag)`: Removes tag from all accounts and updates DB.
- Add `getAccountCountForTag(String tag)` helper.
- Update `filteredAccounts` logic so selected tag filters (AND/OR matching) are properly applied when `selectedTags` is non-empty.

### 2. [lib/screens/home_screen.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/home_screen.dart)
- Implement `TabController` (or `TabBarView` / `IndexedStack`) with 2 main tabs:
  - **Tab 1: Accounts**
  - **Tab 2: Tags**
- Integrate search bar, active filter banner (`Filtered by #Tag [Clear]`), and account list into Tab 1.
- Apply `provider.selectedTags` properly in `_getFilteredAndSortedAccounts`.

### 3. [NEW] [lib/widgets/home/home_tag_cloud_view.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/widgets/home/home_tag_cloud_view.dart)
- Build the **Tag Cloud View** for Tab 2:
  - Header with total tag count and "Manage Tags" button.
  - `Wrap` layout of tag chips with account count badges.
  - Tapping a tag invokes `provider.toggleTag(tag)` and switches `HomeScreen` to Tab 1.

### 4. [NEW] [lib/screens/tag_management_screen.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/tag_management_screen.dart)
- Build the dedicated **Tag Management Screen**:
  - Search bar for tags.
  - Edit/rename tag dialog (updates all member accounts).
  - Delete tag dialog (removes tag from all member accounts).
  - Empty state when no tags exist.

### 5. [lib/widgets/account_tile.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/widgets/account_tile.dart)
- Update tag chip rendering on account cards with higher contrast background, rounded border, and bold text color.

### 6. [lib/screens/settings_screen.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/settings_screen.dart)
- Add a "Manage Tags" settings tile linking to `TagManagementScreen`.

### 7. Tests
- Add unit tests for `renameTag`, `deleteTag`, and tag filtering in `test/providers/account_provider_test.dart`.
- Add widget tests for 2-tab `HomeScreen` and `TagManagementScreen`.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` (must return zero issues).
- Run `flutter test` (all unit and widget tests must pass).

### Manual Verification
- Verify switching between Tab 1 (Accounts) and Tab 2 (Tags).
- Verify tapping a tag in Tab 2 switches to Tab 1 with filter applied.
- Verify clearing filter on Tab 1 shows all cards.
- Verify high-contrast tag badges on account cards.
- Verify renaming/deleting tags in Tag Management updates accounts cleanly.
