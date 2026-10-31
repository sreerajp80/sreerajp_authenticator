# Migrate to the `material_ui` package (adoption Phase 3b)

**Status:** completed

Part of master plan: `plans/20261029_183929_adopt-updated-guidelines.md` (Phase 3, gap G6).

**Security impact:** adds one dependency (`material_ui`, published by the Flutter team, BSD-3
licence, no network code). No change to storage, permissions, network or platform folders.

## What the issue is

Engineering standard §6.1 says every app MUST use the standalone `material_ui` package and
import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`. The SDK copy
is frozen and on Flutter's deprecation path.

Today 54 Dart files in `lib/` and `test/` import `package:flutter/material.dart`. A dry run of
`dart fix --dry-run --code=migrate_design_widgets` proposes 55 fixes in 55 files (one import
line per file). No file imports `package:flutter/cupertino.dart`.

Six packages the app uses still import the SDK Material library inside their own code:
`flutter_slidable`, `animations`, `shimmer`, `percent_indicator`, `qr_flutter`, `mobile_scanner`.
Their widgets look up the SDK `Theme`, which is a different type from the `material_ui` one. The
standard says to wrap the app with `MaterialUiCompatibilityBridge` in `MaterialApp.builder` while
such packages are in use, so their widgets still get the app's theme.

## Files to be changed

- `pubspec.yaml` — add `material_ui: ^1.8.0` (current version on pub.dev). If `dart fix` writes
  `material_ui: any`, replace it with the caret constraint.
- `pubspec.lock` — updated by `flutter pub get` only.
- `analysis_options.yaml` — enable the `migrate_design_widgets` lint so old imports cannot come
  back.
- 54–55 files in `lib/` and `test/` — import line rewritten by `dart fix` (no hand edits).
- `lib/main.dart` — wrap the existing `MaterialApp.builder` result in
  `MaterialUiCompatibilityBridge` (keeps the dev `Banner`).
- `docs/architecture.md` §16 (UI System) and §21 (Known Risks) — note the package, the bridge,
  and the six packages that still use the SDK library.
- `docs/dependencies.md` — add `material_ui` to the approved list.

`cupertino_ui` is **not** added now: the app uses no Cupertino widget. It is added in Phase 5,
where the Sanskrit fallback delegates need it (standard §8.3.1). The localization delegate issue
seen in the owner's other app (gen-l10n still writes SDK delegates) also belongs to Phase 5.

## Plan for the fix

1. `flutter pub add material_ui` (then set `^1.8.0` if needed).
2. `dart fix --apply --code=migrate_design_widgets`.
3. Check that no `package:flutter/material.dart` import is left in `lib/` or `test/`.
4. Add `MaterialUiCompatibilityBridge` in `lib/main.dart`. First confirm the class name and
   constructor in the installed `material_ui` source; if it differs or does not exist in 1.8.0,
   stop and ask.
5. Enable the lint in `analysis_options.yaml`.
6. Run `dart format` on the changed files only, `flutter analyze`, `flutter test`.
7. Build `flutter build apk --flavor dev --debug`, then `android\gradlew --stop` and end leftover
   Gradle / Kotlin daemons.
8. Update the docs, write the change log, set this plan to `completed`.

## Risks

- A third-party widget (for example a slidable action or the scanner overlay) could show the
  wrong colours if the bridge does not cover it. Tests cannot see this; you will need a quick
  manual look on a device in light and dark mode: home list swipe actions, shimmer loading,
  OTP progress ring, QR scanner screen, QR code display.
- `dart format` is only run on files this change touches, so the 43 files with older formatting
  drift stay as they are (separate formatting-only change).
