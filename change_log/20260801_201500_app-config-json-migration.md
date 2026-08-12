# Change Log: App Config JSON & About Screen Migration

**Plan Reference:** [`plans/20260801_201500_app-config-json-migration.md`](../plans/20260801_201500_app-config-json-migration.md)

## Summary of Changes

Migrated `sreerajp_authenticator` to conform with Section 1 of [`docs/guidelines/guideline.md`](../docs/guidelines/guideline.md) by introducing `assets/config/app_config.json`, the `AppConfig` data model, `ConfigService` asset loader, and updating `AboutScreen` to be completely data-driven.

## Created and Modified Files

1. **`assets/config/app_config.json`** `[NEW]`
   - Created JSON asset file containing app metadata (`appName`, `description`, `version`, `build`, `details`).

2. **`pubspec.yaml`** `[MODIFY]`
   - Registered `- assets/config/` in the `flutter.assets` section.

3. **`lib/config/app_config.dart`** `[NEW]`
   - Created `AppConfig` data model with `fallback` instance and non-throwing `fromJson` parser.

4. **`lib/services/config_service.dart`** `[NEW]`
   - Created `ConfigService` loader class with `load()` and `loadAndVerify()` to read asset data and log version drift warnings.

5. **`lib/screens/about_screen.dart`** `[MODIFY]`
   - Refactored `AboutScreen` to dynamically load `AppConfig` via `ConfigService` and render rows for `config.details.entries` with `mailto:` tap handling.

6. **`test/services/config_service_test.dart`** `[NEW]`
   - Created unit test suite covering model deserialization, fallback handling, asset loader errors, and package info verification.

## Verification

- **Static Code Analysis:** `flutter analyze` completed with 0 errors and 0 warnings.
- **Automated Test Suite:** `flutter test` executed 226 tests with 100% pass rate.
