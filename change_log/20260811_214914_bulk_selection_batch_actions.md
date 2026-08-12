# Bulk Selection & Batch Actions Change Log

**Plan Reference:** `plans/20260811_214811_bulk_selection_batch_actions.md`
**Date:** 2026-08-11

## Summary of Changes
Implemented Multi-Select Mode and Batch Actions on `HomeScreen` (Improvement 6 in feature roadmap):

1. **AccountsProvider Update**:
   - Added `bulkUpdateTags(List<int> ids, List<String> tags, {bool replace = false})` to support batch tag assignment (append vs replace).

2. **AccountTile Component**:
   - Added `isSelectionMode`, `isSelected`, and `onLongPress` parameters.
   - Rendered circular checkbox indicator when in multi-select mode.
   - Disabled swipe-to-edit/delete when multi-select mode is active.

3. **HomeScreen Multi-Select Mode & Batch Action Bar**:
   - Integrated state for `_isSelectionMode` and `_selectedAccountIds`.
   - Long-pressing any account tile activates selection mode and selects the tile.
   - Header switches to Selection AppBar displaying count (e.g. "3 Selected"), Close button, and Select All / Deselect All toggle.
   - PopScope intercepts back button press to cancel selection mode cleanly.
   - Added dynamic bottom Batch Action Bar with 3 actions:
     - **Reassign Tags**: Modal dialog allowing user to append or replace tags across all selected accounts.
     - **Export Selected**: Modal password prompt to generate an encrypted `.aes` backup for only the selected accounts.
     - **Delete Selected**: Confirmation dialog requiring biometric or PIN authentication (`AuthService`) before completing bulk deletion.

4. **Roadmap Documentation**:
   - Updated `docs/feature_analysis_and_roadmap.md` to mark Improvement 6 as `[COMPLETED]` ✅ in both detail and summary table.

5. **Unit Testing**:
   - Added unit test in `test/providers/account_provider_test.dart` for `bulkUpdateTags` (verifying append vs replace logic).

## Files Changed
- `lib/providers/account_provider.dart`
- `lib/widgets/account_tile.dart`
- `lib/screens/home_screen.dart`
- `docs/feature_analysis_and_roadmap.md`
- `test/providers/account_provider_test.dart`
