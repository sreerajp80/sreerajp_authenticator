# Fix low contrast of status labels on the Permissions screen

Implements `plans/20261031_203926_permissions-status-contrast.md`.

## What changed

- `lib/utils/theme.dart`: added `statusSuccess`, `statusWarning` and `statusError`. Each takes a
  `Brightness` and returns the colour for that theme. The old constants stay.
- `lib/screens/permissions_screen.dart`: the camera status label and icon, and the `wifi_off` icon
  and its tint, now use these methods.
- `test/accessibility/theme_contrast_test.dart`: added 6 tests, one for each status in each theme,
  at least 4.5 : 1 on the status colour's 10% tint over the card colour.

| Status | Light, old → new | Dark, old → new |
|---|---|---|
| Granted | 2.37 → 6.29 (`#1B5E20`) | 4.85, no change |
| Not granted | 1.70 → 5.16 (`#8A5200`) | 6.71, no change |
| Denied | 2.90 → 5.18 (`#B71C1C`) | 4.05 → 5.82 (`#FF8A80`) |

## Checks

- `dart format`: done. `flutter analyze`: no issues.
- `flutter test` on Windows: all 589 tests pass.
- Not yet done: checking the new colours on a phone, and a CI run on Linux.

## Known limits

- The tests check the colours, not that the screen uses them.
- Text and icons on the glossy gradient, and other screens such as Settings and Security, were not
  measured reliably. The theme's light `error` colour may also be too faint where it is used as text.
