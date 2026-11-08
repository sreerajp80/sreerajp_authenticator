# Rename the app: "Authenticator SP" (English) and "Mudrika" (Malayalam, Sanskrit)

**Status:** completed

## The issue

The app is called "Sreeraj P Authenticator" in every language. This causes two problems:

- On the home screen and in the app drawer, only about 10–12 characters fit under the icon, so
  the name is cut short ("Sreeraj P Au…").
- The app drawer sorts apps A–Z by the first word. Users look for an authenticator under **A**,
  but this app sorts under **S**.

The user chose new names:

| Where | English | Malayalam | Sanskrit |
|---|---|---|---|
| Name under the icon and in the app (prod) | `Authenticator SP` | `മുദ്രിക` | `मुद्रिका` |
| Name under the icon (dev flavor) | `Authenticator SP Dev` | `മുദ്രിക Dev` | `मुद्रिका Dev` |
| Play Store title | `Authenticator SP – Offline 2FA` (30 chars) | `മുദ്രിക – ഓഫ്‌ലൈൻ 2FA` (ml-IN listing) | — (Play has no Sanskrit listing) |

"Mudrika" means "signet ring". In the Shakuntalam story, a ring proves who a person is. That is
what an authenticator does.

The package id `in.sreerajp.sreerajp_authenticator` does **not** change. It cannot change after
the app is published, and users never see it.

## Files to change

App name sources (they must match each other — `CLAUDE.md` localization rules):

- `assets/config/app_config.json` — `appName` for `en`, `ml`, `sa`.
- `lib/config/app_config.dart` — the built-in fallback `appName` map.
- `lib/utils/constants.dart` — `appNameProd`, `appNameDev`.
- `android/app/src/prod/res/values/strings.xml`
- `android/app/src/prod/res/values-ml/strings.xml`
- `android/app/src/prod/res/values-sa/strings.xml`
- `android/app/src/dev/res/values/strings.xml`
- `android/app/src/dev/res/values-ml/strings.xml`
- `android/app/src/dev/res/values-sa/strings.xml`

Tests that check the name:

- `test/config/app_flavor_config_test.dart`
- `test/services/config_service_test.dart`
- `test/screens/about_screen_test.dart`
- `test/accessibility/screen_harness.dart`

Docs and comments that name the product (simple text replace of "Sreeraj P Authenticator"):

- `docs/PROJECT_PROFILE.md` — the "App display name" row gets the new names, plus a new
  "Play Store title" row (en and ml-IN).
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` — project identity table, flavor table, localization
  rule that quotes the three names.
- `README.md`, `PRIVACY.md`
- `docs/architecture.md`, `docs/features.md`, `docs/dependencies.md`, `docs/security.md`,
  `docs/release_process.md`, `docs/project_structure.md`, `docs/workflow_rules.md`,
  `docs/implementation_progress.md`
- File header comments in `lib/main.dart`, `lib/screens/features_screen.dart`,
  `lib/screens/help/help_home_screen.dart`.

Not changed:

- `plans/` and `change_log/` — they are history and keep the old name.
- `docs/guidelines/` — read-only submodule.
- `lib/l10n/app_ml.arb` key `descAuthReasonPhoneLock` uses "പ്രമാണീകാരി" as a common noun
  ("the authenticator"), not as the app name. It stays.
- `docs/images/feature_graphic.png` — the picture may show the old name. Redrawing it is a
  separate job for the user; only the README alt text changes now.
- The Play Store listing itself is typed in Play Console by the user. This plan only records the
  titles in `docs/PROJECT_PROFILE.md`.

## Plan for the fix

1. Update the nine app-name sources above with the new names.
2. Update the four tests to expect the new names.
3. Update the docs and header comments.
4. Run `dart format .`, `flutter analyze` and `flutter test`. (`flutter gen-l10n` is not
   needed, because no ARB file changes.)
5. The user builds the dev flavor and checks the name under the icon in English and, if
   possible, with the phone set to Malayalam.
6. Write the change log.

## Translation review (flag)

- `മുദ്രിക` (Malayalam) and `मुद्रिका` (Sanskrit) are the standard words for a signet ring.
- `ഓഫ്‌ലൈൻ` is the usual Malayalam spelling of "offline" (it uses a zero-width non-joiner after
  `ഫ്`). Please check it reads well to you.

## Known downsides (accepted by the user)

- On a phone set to Malayalam, the icon reads "മുദ്രിക". Typing "authenticator" in the launcher
  will not find it. Few phones are set to Malayalam, and Android does not offer Sanskrit as a
  phone language on most devices, so the effect is small.
- On phones with one-line labels, "Authenticator SP" (16 chars) may show as "Authenticator…",
  which looks like Google's or Microsoft's app. The icon must make the difference clear.
- The app has two brand names (English and Malayalam). That is fine, but store text and
  screenshots must use the right one per language.
- Name availability (other apps, trademarks) has not been checked. The user should search
  Play Store for "Authenticator SP" and "Mudrika" before publishing.

## Security impact

None. It touches Android platform resource files (`strings.xml`) only for the label text. No
permission, storage, network or signing change.
