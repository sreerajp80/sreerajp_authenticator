# Bulk Selection & Batch Actions Plan

**Status:** Proposed

## Problem / Feature Statement
Currently in `SreerajP Authenticator`, account actions (edit, delete, reassign tags) can only be performed individually per account tile. Managing multiple accounts requires repeating actions one by one.

## Proposed Fix
Implement Multi-Select Mode and Batch Actions on `HomeScreen` (Improvement 6 in feature roadmap):
1. **Multi-Select Mode Trigger**:
   - Long-press any account tile on `HomeScreen` to enter Multi-Select Mode.
   - Show top Selection App Bar (selected count, close button, select all / deselect all toggle).
   - Show selection checkbox on each account tile.
   - Disable swipe-to-edit/delete while in selection mode.
2. **Batch Actions Bar**:
   - Display a bottom action bar with 3 batch actions:
     - **Bulk Reassign Tags**: Modal to add or replace tags across all selected accounts.
     - **Bulk Export Selected**: Encrypted `.aes` export for only the selected subset of accounts.
     - **Bulk Delete**: Delete all selected accounts after single biometric / phone lock authentication gate.
3. **Provider & Helper Updates**:
   - Add helper methods in `AccountsProvider` for batch tag updates if needed.
4. **Documentation**:
   - Update `docs/feature_analysis_and_roadmap.md` to mark Improvement 6 as `[COMPLETED]` ✅.

## Files to Modify
- `lib/screens/home_screen.dart` (Add multi-select state, selection app bar, batch actions bottom bar, integration with account tile events)
- `lib/widgets/account_tile.dart` (Add multi-select props: `isSelectionMode`, `isSelected`, `onLongPress`, selection checkbox UI)
- `lib/providers/account_provider.dart` (Add `bulkUpdateTags` helper method)
- `docs/feature_analysis_and_roadmap.md` (Mark Improvement 6 as completed)

## Verification Plan
1. Run `flutter analyze` to ensure zero static analysis warnings/errors.
2. Run `flutter test` to ensure all existing tests pass and add unit tests for batch operations.
