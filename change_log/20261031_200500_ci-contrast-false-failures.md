# Fix false contrast failures on Linux CI

Implements `plans/20261031_200131_ci-contrast-false-failures.md`.

## Why

`Backup guidelines, light` and `Permissions guidelines, light` failed on Linux CI and passed on
Windows. `textContrastGuideline` reads pixels. For thin 12px text on Linux, it took a letter-edge
shade as the text colour. It reported 3.91 and 1.61, while the real ratios are 7.24 and 15.05.
The app colours were fine, so no app code changed.

## What changed

- `test/accessibility/screen_accessibility_test.dart`: `textContrastGuideline` no longer runs on
  Linux. The tap target and label checks still run on every system.
- `test/accessibility/theme_contrast_test.dart`: added 5 colour pairs in both themes, 10 tests in
  all: text on the primary, secondary, tertiary and error containers, and text on the Permissions
  banner.

## Checks

- `dart format`: no changes needed. `flutter analyze`: no issues.
- `flutter test` on Windows: all 583 tests pass.
- The Linux result is not yet proven. It needs a real CI run after this change is pushed.

## Known limits

- CI no longer runs the pixel contrast check. A colour problem on a real screen is caught only when
  the tests run on Windows, or by a colour pair test if that pair is listed.
- The "Granted" label on the Permissions screen (about 2.4 : 1 in a rough measurement) is not
  changed or checked. It needs its own check and plan.
