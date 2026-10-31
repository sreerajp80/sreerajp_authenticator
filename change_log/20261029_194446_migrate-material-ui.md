# Migrate to the `material_ui` package (adoption Phase 3b)

Implements plan: `plans/20261029_192848_migrate-material-ui.md`
(part of `plans/20261029_183929_adopt-updated-guidelines.md`, Phase 3, gap G6)

## What changed

### Dependencies
- `pubspec.yaml` — added `material_ui: ^1.8.0` with a comment. `flutter pub add` wrote an exact
  `1.8.0`; it was changed to the caret constraint as the standard requires.
- `pubspec.lock` — updated by `flutter pub get`. New entries: `material_ui`, plus `cupertino_ui`
  and `flutter_localizations` as indirect dependencies of `material_ui`. A few existing packages
  moved up by a patch or minor version as part of the same resolve.

### Import rewrite
- `dart fix --apply --code=migrate_design_widgets` made 54 fixes in 54 files under `lib/` and
  `test/`: one import line per file (`package:flutter/material.dart` →
  `package:material_ui/material_ui.dart`). No old Material or Cupertino import is left. No other
  line in those files changed.

### Compatibility bridge
- `lib/main.dart` — the existing `MaterialApp.builder` now wraps the app in
  `MaterialUiCompatibilityBridge` (the dev `Banner` is kept on top). Six packages still use the
  SDK Material library: `flutter_slidable`, `animations`, `shimmer`, `percent_indicator`,
  `qr_flutter`, `mobile_scanner`. The bridge gives their widgets the app theme.
- `material_ui` 1.8.0 marks the bridge as deprecated on purpose, as a temporary migration
  helper. A single `// ignore: deprecated_member_use` with a comment explains why, so
  `flutter analyze` stays at zero issues.

### Lint
- `analysis_options.yaml` — enabled `migrate_design_widgets` so old imports cannot come back.

### Docs
- `docs/architecture.md` — §16 notes the package, lint and bridge; §21 lists the six packages and
  when to remove the bridge.
- `docs/dependencies.md` — added `material_ui` to the approved list.
- `docs/implementation_progress.md` — Phase 3b ticked.

## Checks
- `flutter analyze` — no issues.
- `flutter test` — all 229 tests passed.
- `dart format` — `lib/main.dart` already formatted.
- `flutter build apk --flavor dev --debug` — built.
- Gradle daemons stopped; none left.

## Not done
- **Manual device check (needed).** Tests cannot see colours. Open the app in light and dark mode
  and check: home list swipe actions, shimmer loading, OTP timer ring, QR scanner screen, QR code
  display.
- `cupertino_ui` as a direct dependency and the localization delegates — Phase 5.
