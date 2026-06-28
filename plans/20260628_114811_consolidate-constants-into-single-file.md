# Consolidate editable constants into `constants.dart`

**Status:** completed

## Goal

Make app branding / About-screen text easy to edit by gathering the editable
constant *values* into the existing single file `lib/utils/constants.dart`
(`AppConstants`), instead of being spread across `about_screen_content.dart`
and `app_flavor_config.dart`.

## The issue

Editable, user-facing constants are currently in three places:

1. `lib/utils/constants.dart` — crypto / DB / sync / auth constants (`AppConstants`).
2. `lib/utils/about_screen_content.dart` — About-screen strings, developer info,
   copyright/footer, plus an `AboutInfoEntry` helper class and a computed
   `developerInitials` getter.
3. `lib/config/app_flavor_config.dart` — flavor logic that *also* hardcodes the
   editable branding strings inline (app name, environment name, banner label).

So to change the app name or About text you must hunt across multiple files.

### Important constraint (cannot change)

- **App version stays in `pubspec.yaml`** (`version: 2.5.6+1`). It is the build
  system's source of truth, read at runtime via `PackageInfo`. It is *not* moved.

## Approach

Move all editable string/value constants into `AppConstants` in
`lib/utils/constants.dart`, under a new section, and update references.

### 1. `lib/utils/constants.dart` (add a new section)

Add an `// ─── App / Branding / About ───` section to `AppConstants` containing:

- Branding strings currently inlined in `AppFlavorConfig`:
  - `appNameProd = 'Sreeraj P Authenticator'`
  - `appNameDev  = 'Sreeraj P Authenticator Dev'`
  - `environmentNameProd = 'Production'`, `environmentNameDev = 'Development'`
  - `bannerLabelProd = 'PROD'`, `bannerLabelDev = 'DEV'`
- All plain About-screen strings currently in `AboutScreenContent`
  (section titles, descriptions, privacy policy text, feature labels, links,
  developer name/email, AI-used value, copyright, footer, licenses legalese,
  close/open-source labels).
- The `AboutInfoEntry` helper class and the `developerInfo` list.
- The computed `developerInitials` getter (kept as a `static String get`).

(Adding one small helper class + a computed getter is a minor departure from the
file being purely `static const`, but it keeps everything in one place as
requested.)

### 2. `lib/config/app_flavor_config.dart`

Keep the flavor *logic* (enum, parsing, `instance`, `isDev/isProd`,
`showEnvironmentBanner`, `enableVerboseLogging`) — that is runtime behavior, not
constants. Change only the string getters to return the new constants:

- `appName` → `isDev ? AppConstants.appNameDev : AppConstants.appNameProd`
- `environmentName` → `... AppConstants.environmentName{Dev,Prod}`
- `bannerLabel` → `... AppConstants.bannerLabel{Dev,Prod}`

Add `import '../utils/constants.dart';`.

### 3. `lib/utils/about_screen_content.dart`

**Delete this file.** Its `appName` / `environmentName` getters delegated to
`AppFlavorConfig`; consumers will use `AppFlavorConfig` / `AppConstants` directly.

### 4. `lib/screens/about_screen.dart`

Replace all `AboutScreenContent.*` references (~30) with `AppConstants.*`, and
the existing `AboutScreenContent.appName` / `environmentName` getters with
`AppFlavorConfig.instance.appName` / `.environmentName` (the file already imports
and uses `AppFlavorConfig` at line 184, so usage is consistent). Update imports:
drop `about_screen_content.dart`, add `utils/constants.dart`.

## Files to be changed

- `lib/utils/constants.dart` — add App/Branding/About section, `AboutInfoEntry`,
  `developerInfo`, `developerInitials`.
- `lib/config/app_flavor_config.dart` — string getters reference `AppConstants`.
- `lib/utils/about_screen_content.dart` — **deleted**.
- `lib/screens/about_screen.dart` — update references + imports.

## Out of scope / unchanged

- `pubspec.yaml` version (must stay).
- `AppFlavorConfig` flavor logic and its consumers (`app_logger.dart`,
  `otp_service.dart`, `main.dart`) — unchanged.
- `test/config/app_flavor_config_test.dart` — still valid (tests logic, not strings).

## Verification

- `flutter analyze` → zero new issues.
- `flutter test` → all pass (no existing test references `AboutScreenContent`).
- Manual sanity: About screen renders all text and version correctly.

## Notes / decision points

- Alternative considered: move the *entire* `AppFlavorConfig` class into
  `constants.dart` too. Rejected because it is runtime logic (enum + parsing),
  not constants, and `docs/architecture.md` assigns flavor config to `config/`.
  This plan moves the *values* it hardcodes, which satisfies "edit in one place".
- Pre-existing inconsistency (not fixed here unless you want it): copyright text
  says `© 2026` while `licensesLegalese` says `© 2025`.
