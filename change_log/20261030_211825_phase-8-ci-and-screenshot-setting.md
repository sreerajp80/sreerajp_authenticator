# Phase 8 (CI) and a setting to block screenshots

Implements `plans/20261030_210811_phase-8-ci-and-screenshot-setting.md`. This finishes the last
phase of `plans/20261029_183929_adopt-updated-guidelines.md`.

## What changed

### CI

- New `.github/workflows/ci.yml`: checks only, as engineering standard §19 asks. Runs on pull
  requests and pushes to `main`, with read-only permissions, no secrets, and Flutter pinned to
  3.47.6. Steps: `flutter pub get`, format check, `flutter analyze`, `flutter test`.

### Block screenshots setting

- `lib/utils/screen_protection.dart`: added `disableScreenProtection()` and
  `isScreenProtectionSupported`.
- `lib/providers/settings_provider.dart`: added the `block_screenshots` setting (default on) and
  `setBlockScreenshots`. The change is applied to the window first and saved only if that worked.
- `lib/main.dart`: protection is still turned on first. It is turned off only if the saved choice
  says so.
- `lib/screens/security_screen.dart`: new "Screen privacy" section with a "Block screenshots"
  switch. Android only. It also shows when app lock is off. Turning it off shows a warning first.
- The setting is not part of Wi-Fi sync or backup settings, so outside data cannot change it.

### Text

- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`: six new keys, and regenerated code.
- Corrected `helpVault08`, `helpFaq12` and `descFeatures47`, which implied the block is always on.

### Tests

- `test/utils/screen_protection_test.dart`: off calls on Android, no calls on desktop.
- New `test/screens/security_screen_block_screenshots_test.dart`: default on, saved choice, plugin
  failure, warning cancel and confirm, switch hidden on Windows.
- `test/screens/security_screen_l10n_test.dart`: test window made taller, because the new section
  pushed the last card off screen in Malayalam.

### Docs

- `docs/security.md`: the setting, and the §15.2 decision below.
- `docs/features.md`, `docs/architecture.md`, `docs/PROJECT_PROFILE.md`,
  `docs/implementation_progress.md`, `CLAUDE.md`, `AGENTS.md`: updated. Phase 8 is ticked.

## Differences from the plan

- No new dialog button key: the warning uses the existing "Cancel" and "Confirm" buttons.
- One error message key was added (`errorBlockScreenshotsFailed`), shown if the change fails.

## Decision recorded: guideline §15.2

Engineering standard §15.2 says screen capture protection MUST be on for every screen that shows
sensitive data. The app meets this by default. Turning it off is the user's own choice, after a
warning. While it is off, every screen can be captured, including the optical sync stream.

## Checks

- `dart format --set-exit-if-changed`: no changes.
- `flutter analyze`: no issues.
- `flutter test`: all 579 tests passed.

Not yet checked:

- The CI workflow has not run on GitHub. It runs after the work is committed and pushed.
- The real screenshot block has not been tried on a phone.

## Translations to review

Please review these new or changed Malayalam and Sanskrit strings:

- `titleScreenPrivacySection`, `labelBlockScreenshots`, `descBlockScreenshots`,
  `titleAllowScreenshots`, `descAllowScreenshotsWarning`, `errorBlockScreenshotsFailed`
- `helpVault08`, `helpFaq12`, `descFeatures47`
- Sanskrit in particular: `मूलतः` is used for "by default", and `पटलगोपनीयता` for "screen privacy".
