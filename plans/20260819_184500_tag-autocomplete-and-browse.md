# Plan: Tag Autocomplete and Tag Browsing for Account Entries

**Status:** Implemented

## Issue
When creating or editing account entries in the Add/Edit Account screen:
1. Users currently have to type tag names manually in a plain text field without any autocomplete suggestions matching existing tags.
2. Typing the first character does not show matching existing tags to pick from.
3. Users have no way to browse and select from all existing tags created across other accounts in the vault.

## Fix
1. Create a dedicated `TagAutocompleteField` widget (`lib/widgets/add_account/tag_autocomplete_field.dart`) that:
   - Tracks the active tag token being typed (comma-separated).
   - Triggers autocomplete suggestions starting from the very first character typed (`query.isNotEmpty`).
   - Filters available tags matching the current query (case-insensitive substring/prefix match), omitting already selected tags.
   - Shows a clean Material dropdown/overlay menu of matching suggestions with tag icons.
   - Automatically completes the selected tag into the text field with comma separation upon selection.
2. Create a `BrowseTagsBottomSheet` (`lib/widgets/add_account/browse_tags_bottom_sheet.dart`) that:
   - Displays all existing tags in the app (`AccountsProvider.allAvailableTags`).
   - Displays a search filter to quickly find tags in large sets.
   - Allows users to multi-select/toggle tags via checkboxes or filter chips.
   - Supports selecting/clearing and applies the selected tags back into the `TextEditingController`.
   - Displays a friendly empty state when no tags exist in the vault yet.
3. Update `AccountInfoCard` (`lib/widgets/add_account/account_info_card.dart`) and `AddAccountScreen` (`lib/screens/add_account_screen.dart`):
   - Replace the plain `TextFormField` for tags with `TagAutocompleteField` connected to `availableTags` from `AccountsProvider`.
   - Provide a browse tags suffix button on the tag field to open the Browse Tags sheet.
4. Add comprehensive widget and unit tests in `test/widgets/add_account/tag_autocomplete_field_test.dart` and verify that all static analysis (`flutter analyze`) and tests pass.

## Files to Change
- **New Files**:
  - `lib/widgets/add_account/tag_autocomplete_field.dart`
  - `lib/widgets/add_account/browse_tags_bottom_sheet.dart`
  - `test/widgets/add_account/tag_autocomplete_field_test.dart`
- **Modified Files**:
  - `lib/widgets/add_account/account_info_card.dart`
  - `lib/screens/add_account_screen.dart`
