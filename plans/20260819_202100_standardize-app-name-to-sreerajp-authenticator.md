# Plan: Standardize App Name to SreerajP Authenticator

**Status:** Implemented

## Issue
The app name was inconsistently formatted across various platform manifests, configurations, source files, tests, and documentation (e.g. `Sreeraj P Authenticator`, `Sreerajp Authenticator`, `sreerajp_authenticator`, and `Sreeraj Authenticator`). The required consistent display name everywhere is `SreerajP Authenticator` (and `SreerajP Authenticator Dev` for dev flavor).

## Fix
1. **Application Configurations & Constants**:
   - Update `assets/config/app_config.json` appName to `"SreerajP Authenticator"`.
   - Update fallback `appName` in `lib/config/app_config.dart` to `'SreerajP Authenticator'`.
   - Update `AppConstants.appNameProd` to `'SreerajP Authenticator'` and `AppConstants.appNameDev` to `'SreerajP Authenticator Dev'` in `lib/utils/constants.dart`.
   - Update `lib/screens/home_screen.dart` title to use `AppFlavorConfig.instance.appName`.
   - Update header description in `lib/main.dart` to `'SreerajP Authenticator'`.

2. **Platform Native Manifests & Runners**:
   - Update Android flavor manifest placeholders in `android/app/build.gradle.kts` (`"SreerajP Authenticator Dev"` and `"SreerajP Authenticator"`).
   - Update iOS `CFBundleDisplayName` in `ios/Runner/Info.plist` to `SreerajP Authenticator`.
   - Update Web manifest `name` and `short_name` in `web/manifest.json` and `<title>` / `<meta apple-mobile-web-app-title>` in `web/index.html` to `SreerajP Authenticator`.
   - Update Windows window title in `windows/runner/main.cpp` and product name / file description in `windows/runner/Runner.rc` to `SreerajP Authenticator`.

3. **Tests**:
   - Update expected flavor app name assertions in `test/config/app_flavor_config_test.dart`.

4. **Documentation & Agent Guidelines**:
   - Update `README.md`, `docs/architecture.md`, `docs/release_process.md`, `docs/security.md`, `docs/feature_analysis_and_roadmap.md`, `AGENTS.md`, and `CLAUDE.md` to consistently reference `SreerajP Authenticator`.

## Files to Change
- **Modified Files**:
  - `assets/config/app_config.json`
  - `lib/config/app_config.dart`
  - `lib/utils/constants.dart`
  - `lib/screens/home_screen.dart`
  - `lib/main.dart`
  - `android/app/build.gradle.kts`
  - `ios/Runner/Info.plist`
  - `web/manifest.json`
  - `web/index.html`
  - `windows/runner/main.cpp`
  - `windows/runner/Runner.rc`
  - `test/config/app_flavor_config_test.dart`
  - `README.md`
  - `docs/architecture.md`
  - `docs/release_process.md`
  - `docs/security.md`
  - `docs/feature_analysis_and_roadmap.md`
  - `AGENTS.md`
  - `CLAUDE.md`
