# Fix low contrast of status labels on the Permissions screen

**Status:** completed

## Files to change

- `lib/utils/theme.dart`
- `lib/screens/permissions_screen.dart`
- `test/accessibility/theme_contrast_test.dart`

No security impact: only colours and tests change.

## The issue

The status labels on the Permissions screen are 11px text and need at least 4.5 : 1. Their icons
need at least 3 : 1. The same colour is used in both themes, and most uses are too faint:

| Status | Colour | Light | Dark |
|---|---|---|---|
| Not granted | `#FFA726` | 1.70 | 6.71 |
| Granted | `#4CAF50` | 2.37 | 4.85 |
| Denied | `#EF5350` | 2.90 | 4.05 |

The `wifi_off` icon in the Privacy card also uses `successGreen`, so it is below 3 : 1 in light.

The screen tests do not catch this. The camera tile merges its texts into one label for screen
readers, so the guideline finds no matching text. The test harness also only shows "Granted".

## The fix

1. In `lib/utils/theme.dart`, add three methods that choose a status colour for the theme. Each
   takes a `Brightness`. Keep the three existing colour constants, because `errorCoral` is also the
   theme's `error` colour.

   | Method | Light | Ratio | Dark | Ratio |
   |---|---|---|---|---|
   | `statusSuccess` | `#1B5E20` | 6.29 | `#4CAF50` (no change) | 4.85 |
   | `statusWarning` | `#8A5200` | 5.16 | `#FFA726` (no change) | 6.71 |
   | `statusError` | `#B71C1C` | 5.18 | `#FF8A80` | 5.82 |

   Ratios are for the colour on its own 10% tint over the card colour, as the screen draws it.

2. In `lib/screens/permissions_screen.dart`, use these methods for the status colour and the
   `wifi_off` icon and its tint. The tint keeps the same 10% strength.

3. In `test/accessibility/theme_contrast_test.dart`, add a test for each method in both themes. It
   checks the colour on its 10% tint over the card colour, at least 4.5 : 1.

## Known downsides

- The tests check the colours, not that the screen uses them. A later edit could put the old
  constant back without a test failing.
- The status colours now look darker in the light theme, so please look at them on a phone.

## Not in this plan

- Text and icons on the glossy gradient, and other screens such as Settings and Security. They have
  not been measured reliably. The theme's light `error` colour may also be too faint where it is
  used as text.

## Checks

- Run `dart format .`, `flutter analyze` and `flutter test` on Windows.
- CI has to run after the push for the Linux result.
