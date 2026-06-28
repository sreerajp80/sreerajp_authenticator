# Change log — Consolidate editable constants into `constants.dart`

Implements plan
[`plans/20260628_114811_consolidate-constants-into-single-file.md`](../plans/20260628_114811_consolidate-constants-into-single-file.md).

## Summary

Gathered all editable branding / About-screen constant *values* into the single
file `lib/utils/constants.dart` (`AppConstants`), so they can be edited in one
place. App version remains in `pubspec.yaml` (build source of truth, unchanged).

## Changes

- **`lib/utils/constants.dart`**
  - Added `// ─── App / Branding (flavor-dependent) ───` section: `appNameProd`,
    `appNameDev`, `environmentNameProd/Dev`, `bannerLabelProd/Dev`.
  - Added `// ─── About Screen ───` section: all About-screen strings (titles,
    descriptions, privacy policy text, feature labels, links, developer
    name/email, AI-used value, copyright, footer, licenses legalese, button
    labels), the `developerInfo` list, and the computed `developerInitials` getter.
  - Added top-level `AboutInfoEntry` helper class (moved from the deleted file).

- **`lib/config/app_flavor_config.dart`**
  - `appName`, `environmentName`, `bannerLabel` getters now return the new
    `AppConstants.*` values instead of inline literals.
  - Added `import '../utils/constants.dart';`.
  - Flavor logic (enum, parsing, `instance`, flags) unchanged.

- **`lib/utils/about_screen_content.dart`** — **deleted** (contents relocated).

- **`lib/screens/about_screen.dart`**
  - Replaced `import '../utils/about_screen_content.dart';` with
    `import '../utils/constants.dart';`.
  - `AboutScreenContent.appName` / `.environmentName` → `AppFlavorConfig.instance.*`.
  - All other `AboutScreenContent.*` references → `AppConstants.*`.

## Verification

- `flutter analyze` → No issues found.
- `flutter test` → all 194 tests passed.

## Notes

- App version not moved (lives in `pubspec.yaml`, read via `PackageInfo`).
- Pre-existing copyright inconsistency left as-is: `copyrightText` says `© 2026`
  while `licensesLegalese` says `© 2025`.
