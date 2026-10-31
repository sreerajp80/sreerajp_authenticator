# Fix tag cloud header overflow and Manage tags button

Implements `plans/20261030_213456_tag-cloud-header-overflow.md`.

## What changed

- `lib/widgets/home/home_tag_cloud_view.dart`
  - The header text column is now in `Expanded`, so the description wraps and cannot push the
    button off the screen.
  - Added an 8-pixel gap between the text and the button, and aligned the button with the title.
  - "Manage tags" is now an icon-only `IconButton.outlined`. Its label moved to `tooltip:`, and
    the icon changed from `Icons.tune` to `Icons.edit_outlined`.
- `lib/l10n/app_en.arb`: updated the `@actionManageTags` description. No translated text changed.
- Ran `flutter gen-l10n`.
- `test/widgets/home/home_tag_cloud_view_test.dart` (new): checks for no overflow and that the
  button is inside a 360-wide screen in Malayalam.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: all tests pass.
- With `Expanded` removed for a moment, the new test failed with an overflow of 422 pixels. The
  fix was then restored and the test passed.
- Not checked on a real device or emulator.
