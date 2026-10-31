# Fix false contrast failures on Linux CI

**Status:** completed

## Files to change

- `test/accessibility/screen_accessibility_test.dart`
- `test/accessibility/theme_contrast_test.dart`

No app code changes. No security impact: only tests change.

## The issue

On GitHub CI (Linux), two tests fail: `Backup guidelines, light` and `Permissions guidelines, light`.
Both pass on Windows with the same Flutter version.

The failing check is `textContrastGuideline`. It reads screen pixels and takes the most common
dark colour in the text box as the text colour. It captures at low resolution. For thin 12px text
on Linux, the most common dark colour can be a letter-edge shade, not the real text colour.

| Screen | Text colour | Background | Colour the check used | Real ratio | Reported ratio |
|---|---|---|---|---|---|
| Backup | `#93000A` | `#FFDAD6` | `#B84B50` (66% text, 34% background) | 7.24 | 3.91 |
| Permissions | `#1A1A2E` | `#EBF1F9` | `#BBC0CB` (23% text, 77% background) | 15.05 | 1.61 |

So the app colours are fine and the failures are false.

## The fix

1. In `screen_accessibility_test.dart`, skip only the `textContrastGuideline` line on Linux, with a
   short comment saying why. The tap target and label checks still run on every system, and the
   pixel contrast check still runs on Windows.
2. In `theme_contrast_test.dart`, add colour pairs that do not depend on drawing, in both themes.
   These run on CI too:
   - `onPrimaryContainer` on `primaryContainer`
   - `onSecondaryContainer` on `secondaryContainer`
   - `onTertiaryContainer` on `tertiaryContainer`
   - `onErrorContainer` on `errorContainer`
   - `onSurface` on the Permissions banner colour (30% `primaryContainer` over the page colour)

   All were measured with a throw-away test and are at or above 7.19 : 1.

## Known downsides

- CI no longer runs the pixel contrast check, so a colour problem on a real screen is caught only
  when the tests are run on Windows, or by the colour pair tests if the pair is listed.
- The pixel check could also become unreliable on Windows after a Flutter upgrade.

## Not in this plan

- Low-contrast text that this check does not catch, such as the "Granted" label on the Permissions
  screen (about 2.4 : 1 in a rough measurement). This needs its own check and plan.

## Checks

- Run `dart format .`, `flutter analyze` and `flutter test` on Windows.
- Only a real CI run can prove the Linux result. This computer has no Linux environment.
