# Fix tag cloud header overflow and Manage tags button

**Status:** completed

## Files to change

- `lib/widgets/home/home_tag_cloud_view.dart`
- `lib/l10n/app_en.arb` (description of `actionManageTags` only; the text stays the same)
- `lib/l10n/app_localizations.dart` (generated, by `flutter gen-l10n`)
- `test/widgets/home/home_tag_cloud_view_test.dart` (new)

## Issue

In the Tags tab, the header is a `Row` with two children: a text column (title and description)
and the "Manage tags" button. The text column has no width limit, so it stays on one line and
takes all the room it wants. In Malayalam the description is long, and the button label is long
too, so the button is pushed off the right edge of the screen and cut off.

The button also uses `Icons.tune`, which looks like a filter, but it opens the tag management
screen (rename and delete tags).

## Fix

1. Wrap the text column in `Expanded`. The text then gets only the width left after the button,
   and the description wraps if needed. This is still needed with a smaller button, because
   without it the text can still push the button off the screen.
2. Add a `SizedBox(width: 8)` between the text and the button, so they do not touch.
3. Set `crossAxisAlignment: CrossAxisAlignment.start` on the `Row`, so the button stays level with
   the title when the description takes several lines.
4. Replace `OutlinedButton.icon` with `IconButton.outlined`, with no visible label.
   - Use `l10n.actionManageTags` as the `tooltip:`. Engineering standard §7.8 requires a localized
     tooltip on every icon-only control, and screen readers also read it.
   - Keep the same outline colour. `IconButton` keeps a 48 x 48 touch target.
5. Use `Icons.edit_outlined` as the icon. With no label, the icon must explain the action alone.
   It means "change", and the tag management screen uses the same icon for rename. A tag icon
   (`Icons.sell_outlined`) would only say "tags", which the tab already says.
6. Update the `@actionManageTags` description in `app_en.arb` to say it is the tooltip of an
   icon-only button, then run `flutter gen-l10n`. No translated text changes.

## Tests

Add a widget test that shows the view in Malayalam on a narrow screen (360 wide) and checks that:

- no overflow error happens,
- the button (found by its tooltip) is fully inside the screen.

Run `flutter analyze` and `flutter test`.

## Trade-offs

- On a phone a tooltip shows only on long-press, so the action is less obvious than a labelled
  button. The same screen can also be opened from Settings, which lowers this risk.
- A large system font no longer causes a problem for the button, as its size does not depend on
  the label.
