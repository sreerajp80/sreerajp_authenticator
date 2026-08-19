# Change Log — Standardize App Name to SreerajP Authenticator

**Plan File:** [plans/20260819_202100_standardize-app-name-to-sreerajp-authenticator.md](file:///l:/Android/SreerajP_Authenticator/plans/20260819_202100_standardize-app-name-to-sreerajp-authenticator.md)

## Summary of Changes
Standardized the application display name and references to `SreerajP Authenticator` (and `SreerajP Authenticator Dev` for dev flavor) across configurations, platform native manifests, runners, screens, tests, and documentation:

1. **Configurations & Constants**:
   - Updated `assets/config/app_config.json` `appName` to `"SreerajP Authenticator"`.
   - Updated fallback `appName` in `lib/config/app_config.dart` to `'SreerajP Authenticator'`.
   - Updated `AppConstants.appNameProd` to `'SreerajP Authenticator'` and `AppConstants.appNameDev` to `'SreerajP Authenticator Dev'` in `lib/utils/constants.dart`.
   - Updated `HomeScreen` (`lib/screens/home_screen.dart`) app bar title to dynamically use `AppFlavorConfig.instance.appName`.
   - Updated file header comment in `lib/main.dart` to `'SreerajP Authenticator'`.

2. **Platform Native Manifests & Runners**:
   - Updated `android/app/build.gradle.kts` manifestPlaceholders to `"SreerajP Authenticator Dev"` and `"SreerajP Authenticator"`.
   - Updated `ios/Runner/Info.plist` `CFBundleDisplayName` to `SreerajP Authenticator`.
   - Updated `web/manifest.json` (`name` and `short_name`) and `web/index.html` (`<title>` and `<meta name="apple-mobile-web-app-title">`) to `SreerajP Authenticator`.
   - Updated `windows/runner/Runner.rc` (`FileDescription` and `ProductName`) and `windows/runner/main.cpp` (window creation title) to `SreerajP Authenticator`.

3. **Tests & Quality**:
   - Updated test assertions in `test/config/app_flavor_config_test.dart` to check for `SreerajP Authenticator Dev` and `SreerajP Authenticator`.
   - Ran `flutter analyze` — 0 issues found.
   - Ran `flutter test` — all 228 tests passed.

4. **Documentation & Guidelines**:
   - Updated `README.md`, `docs/architecture.md`, `docs/release_process.md`, `docs/security.md`, `docs/feature_analysis_and_roadmap.md`, `AGENTS.md`, and `CLAUDE.md` to consistently reference `SreerajP Authenticator`.

---

## Files Modified
- [assets/config/app_config.json](file:///l:/Android/SreerajP_Authenticator/assets/config/app_config.json)
- [lib/config/app_config.dart](file:///l:/Android/SreerajP_Authenticator/lib/config/app_config.dart)
- [lib/utils/constants.dart](file:///l:/Android/SreerajP_Authenticator/lib/utils/constants.dart)
- [lib/screens/home_screen.dart](file:///l:/Android/SreerajP_Authenticator/lib/screens/home_screen.dart)
- [lib/main.dart](file:///l:/Android/SreerajP_Authenticator/lib/main.dart)
- [android/app/build.gradle.kts](file:///l:/Android/SreerajP_Authenticator/android/app/build.gradle.kts)
- [ios/Runner/Info.plist](file:///l:/Android/SreerajP_Authenticator/ios/Runner/Info.plist)
- [web/manifest.json](file:///l:/Android/SreerajP_Authenticator/web/manifest.json)
- [web/index.html](file:///l:/Android/SreerajP_Authenticator/web/index.html)
- [windows/runner/Runner.rc](file:///l:/Android/SreerajP_Authenticator/windows/runner/Runner.rc)
- [windows/runner/main.cpp](file:///l:/Android/SreerajP_Authenticator/windows/runner/main.cpp)
- [test/config/app_flavor_config_test.dart](file:///l:/Android/SreerajP_Authenticator/test/config/app_flavor_config_test.dart)
- [README.md](file:///l:/Android/SreerajP_Authenticator/README.md)
- [docs/architecture.md](file:///l:/Android/SreerajP_Authenticator/docs/architecture.md)
- [docs/release_process.md](file:///l:/Android/SreerajP_Authenticator/docs/release_process.md)
- [docs/security.md](file:///l:/Android/SreerajP_Authenticator/docs/security.md)
- [docs/feature_analysis_and_roadmap.md](file:///l:/Android/SreerajP_Authenticator/docs/feature_analysis_and_roadmap.md)
- [AGENTS.md](file:///l:/Android/SreerajP_Authenticator/AGENTS.md)
- [CLAUDE.md](file:///l:/Android/SreerajP_Authenticator/CLAUDE.md)
- [plans/20260819_202100_standardize-app-name-to-sreerajp-authenticator.md](file:///l:/Android/SreerajP_Authenticator/plans/20260819_202100_standardize-app-name-to-sreerajp-authenticator.md)

---

## Verification Results

### Static Analysis
- Executed `flutter analyze` — **0 issues found** (clean pass).

### Automated Tests
- Executed `flutter test` — **228 tests passed** (0 failures).
