# Show the build number on the About screen

**Status:** completed

## Issue

The About screen shows only the version name (for example `Version 2.10.6`). It never shows the
build number (the `+34` part of `pubspec.yaml`, which becomes the Android `versionCode`).

The data is already there: `PackageInfo.fromPlatform()` returns `buildNumber`, and
`AppConfig.build` holds a fallback. But `lib/screens/about_screen.dart` only passes `version` to
the ARB string, and the ARB key `labelVersionNumber` has only a `{version}` placeholder.

Without the build number, two phones on the same version name but different builds look the same,
and it is hard to tell which build a tester has.

## Fix

Show the build number in the version line, in brackets:

`Version 2.10.6 (34)`

1. Add a `{build}` placeholder to `labelVersionNumber` in every declared language:
   - `en`: `Version {version} ({build})`
   - `ml`: `പതിപ്പ് {version} ({build})`
   - `sa`: `संस्करणम् {version} ({build})`

   Only a placeholder is added; the translated word stays the same, so no new translation review
   is needed.
2. Update the `@labelVersionNumber` description and placeholders in `app_en.arb`.
3. Run `flutter gen-l10n` to regenerate `lib/l10n/app_localizations*.dart`.
4. In `about_screen.dart`, pass the build number:
   `l10n.labelVersionNumber(_packageInfo?.version ?? _config.version, _packageInfo?.buildNumber ?? _config.build)`.
5. In `test/screens/about_screen_test.dart`, check that the version line with the mocked values
   (`2.9.3`, build `27`) is shown in every locale.
6. Run `dart format .`, `flutter analyze`, `flutter test`.

The build number is a plain string from the platform, like the version name, so it keeps
Latin digits in every language (same as the version today).

## Files to change

- `lib/l10n/app_en.arb`
- `lib/l10n/app_ml.arb`
- `lib/l10n/app_sa.arb`
- `lib/l10n/app_localizations.dart` (generated)
- `lib/l10n/app_localizations_en.dart` (generated)
- `lib/l10n/app_localizations_ml.dart` (generated)
- `lib/l10n/app_localizations_sa.dart` (generated)
- `lib/screens/about_screen.dart`
- `test/screens/about_screen_test.dart`

Note: the ARB and generated files already have other uncommitted edits. Those edits are kept.

## Security impact

None. The build number is public app metadata. No network, storage, permission or platform change.
