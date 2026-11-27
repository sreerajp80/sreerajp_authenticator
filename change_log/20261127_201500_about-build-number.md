# Change log: show the build number on the About screen

Plan: `plans/20261127_200837_about-build-number.md`

## What changed

- `lib/l10n/app_en.arb` — `labelVersionNumber` is now `Version {version} ({build})`. Added the
  `build` placeholder and updated the description.
- `lib/l10n/app_ml.arb` — `പതിപ്പ് {version} ({build})`.
- `lib/l10n/app_sa.arb` — `संस्करणम् {version} ({build})`.
  Only the placeholder was added; the translated words did not change, so no translation review
  is needed.
- `lib/l10n/app_localizations*.dart` — regenerated with `flutter gen-l10n`.
- `lib/screens/about_screen.dart` — passes `PackageInfo.buildNumber` (fallback:
  `AppConfig.build`) to the version line. The line now reads like `Version 2.10.6 (34)`.
- `test/screens/about_screen_test.dart` — checks that the version line with the mocked version
  `2.9.3` and build `27` is shown in every language.

## Checks

- `dart format`: done.
- `flutter test`: all 753 tests passed.
- `flutter analyze`: 2 `info` items, both already present before this change. They are in the
  generated `lib/l10n/app_localizations.dart` (lines 91–92: the deprecated
  `GlobalMaterialLocalizations` / `GlobalCupertinoLocalizations` names). The app does not use that
  generated delegate list; it uses `LocaleConfig.localizationsDelegates`.
- Not yet checked on a real phone.
