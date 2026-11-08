# Change log: rename the app to "Authenticator SP" / "Mudrika"

Implements plan: `plans/20261108_104111_rename-app-display-name.md`

## What changed

The app name changed in every place that holds it:

| Language | Old | New (prod) | New (dev) |
|---|---|---|---|
| English | Sreeraj P Authenticator | Authenticator SP | Authenticator SP Dev |
| Malayalam | ശ്രീരാജ് പി പ്രമാണീകാരി | മുദ്രിക | മുദ്രിക Dev |
| Sanskrit | श्रीराज पी प्रमाणीकारकः | मुद्रिका | मुद्रिका Dev |

Files:

- App name sources: `assets/config/app_config.json`, `lib/config/app_config.dart` (fallback),
  `lib/utils/constants.dart`, and the six `strings.xml` files under
  `android/app/src/{dev,prod}/res/values{,-ml,-sa}/`.
- Tests: `test/config/app_flavor_config_test.dart`, `test/services/config_service_test.dart`,
  `test/screens/about_screen_test.dart`, `test/accessibility/screen_harness.dart`.
- Docs: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `README.md`, `PRIVACY.md`, and
  `docs/` (`PROJECT_PROFILE.md`, `architecture.md`, `features.md`, `dependencies.md`,
  `security.md`, `release_process.md`, `project_structure.md`, `workflow_rules.md`,
  `implementation_progress.md`).
- `docs/PROJECT_PROFILE.md` has a new "Play Store title" row:
  `en` "Authenticator SP – Offline 2FA", `ml-IN` "മുദ്രിക – ഓഫ്‌ലൈൻ 2FA".
- File header comments in `lib/main.dart`, `lib/screens/features_screen.dart`,
  `lib/screens/help/help_home_screen.dart`.

The package id `in.sreerajp.sreerajp_authenticator` did not change. The developer name
("Sreeraj P" and its Malayalam and Sanskrit forms) and the copyright lines did not change.

## Checks

- `dart format .` — 0 files changed.
- `flutter analyze` — no issues.
- `flutter test` — all 753 tests passed.
- Not yet checked on a device: the label under the icon. The user should build the dev flavor
  and look at it.

## Not done (outside the plan)

- `play_closed_testing/` (store listing notes and Play Console answers) still uses the old name.
- `docs/images/feature_graphic.png` may show the old name; it needs a redraw by the user.

## Translation review (flag)

- `ഓഫ്‌ലൈൻ` (Malayalam "offline", with a zero-width non-joiner) in the ml-IN Play Store title.
