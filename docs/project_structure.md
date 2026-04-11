# Project Structure

This document describes the current tracked repository layout for `sreerajp_authenticator` and the responsibility of each major area. Generated build outputs may exist locally, but they are not part of the maintained source structure described here.

## Repository Root

```text
sreerajp_authenticator/
|-- android/               Android app module, flavors, Gradle config, launcher resources
|-- assets/                Bundled application assets
|-- docs/                  Project documentation, architecture, security, and release guides
|-- fonts/                 Inter font files declared in pubspec.yaml
|-- ios/                   iOS runner project and test target
|-- lib/                   Flutter application source
|-- linux/                 Linux desktop runner
|-- macos/                 macOS runner and test target
|-- test/                  Unit and widget tests mirroring app layers
|-- web/                   Web runner shell and icons
|-- windows/               Windows desktop runner
|-- analysis_options.yaml  Lint and analyzer configuration
|-- pubspec.yaml           Package manifest, dependencies, assets, and fonts
|-- pubspec.lock           Resolved package versions
|-- README.md              Main project overview and usage instructions
|-- LICENSE                Project license
|-- AGENTS.md              Repository-specific automation rules
`-- CLAUDE.md              Additional local agent guidance
```

## Flutter App Layout

```text
lib/
|-- main.dart
|-- config/
|   `-- app_flavor_config.dart
|-- models/
|   |-- account.dart
|   `-- group.dart
|-- providers/
|   |-- account_provider.dart
|   |-- group_provider.dart
|   |-- settings_provider.dart
|   `-- theme_provider.dart
|-- screens/
|   |-- about_screen.dart
|   |-- add_account_screen.dart
|   |-- backup_restore_screen.dart
|   |-- group_management_screen.dart
|   |-- home_screen.dart
|   |-- lock_screen.dart
|   |-- permissions_screen.dart
|   |-- qr_scanner_screen.dart
|   |-- security_screen.dart
|   `-- settings_screen.dart
|-- services/
|   |-- auth_service.dart
|   |-- database_service.dart
|   |-- device_state_service.dart
|   |-- encryption_service.dart
|   |-- export_import_service.dart
|   |-- migration_service.dart
|   `-- otp_service.dart
|-- utils/
|   |-- about_screen_content.dart
|   |-- constants.dart
|   `-- theme.dart
`-- widgets/
    |-- account_tile.dart
    |-- pin_verification_dialog.dart
    |-- account_tile/
    |   |-- account_avatar.dart
    |   |-- otp_code_display.dart
    |   |-- pattern_painter.dart
    |   `-- timer_indicator.dart
    |-- add_account/
    |   |-- account_info_card.dart
    |   `-- advanced_settings_card.dart
    `-- home/
        |-- home_empty_state.dart
        |-- home_fab_button.dart
        |-- home_group_tabs.dart
        `-- home_search_bar.dart
```

## Layer Responsibilities

| Path | Responsibility |
|------|----------------|
| `lib/main.dart` | App entry point, provider wiring, routing bootstrap, flavor initialization |
| `lib/config/` | Flavor-specific runtime configuration |
| `lib/models/` | Core data models such as accounts and groups |
| `lib/providers/` | Provider-based state management for accounts, groups, settings, and theme |
| `lib/screens/` | Route-level UI screens and primary user workflows |
| `lib/services/` | Business logic for authentication, device state, OTP, encryption, storage, migration, and import/export |
| `lib/utils/` | Shared constants, theme definitions, and static content |
| `lib/widgets/` | Reusable UI building blocks split by feature area |

## Test Layout

The `test/` folder mirrors the production structure so each layer has focused coverage.

```text
test/
|-- config/
|   `-- app_flavor_config_test.dart
|-- models/
|   |-- account_test.dart
|   `-- group_test.dart
|-- providers/
|   |-- account_provider_test.dart
|   |-- group_provider_test.dart
|   |-- provider_test_helpers.dart
|   |-- settings_provider_test.dart
|   `-- theme_provider_test.dart
|-- services/
|   |-- auth_service_test.dart
|   |-- database_service_test.dart
|   |-- encryption_service_test.dart
|   |-- export_import_service_test.dart
|   |-- migration_service_test.dart
|   `-- otp_service_test.dart
`-- widgets/
    |-- security_auth_widgets_test.dart
    `-- home/
        `-- home_widgets_test.dart
```

## Supporting Project Areas

| Path | Purpose |
|------|---------|
| `android/app/build.gradle.kts` | Android build types, product flavors, signing, and APK naming |
| `android/app/src/main/` | Android manifest, Kotlin entry point, launcher icons, and theme resources |
| `assets/icons/` | Bundled app icons and foreground artwork |
| `docs/architecture.md` | High-level architecture reference |
| `docs/security.md` | Security model and implementation notes |
| `docs/release_process.md` | Release workflow documentation |
| `docs/flutter_build_flavors_guide.md` | Build flavor and release command guide |
| `docs/flutter_project_engineering_standard.md` | Local engineering standards for the Flutter project |
| `analysis_options.yaml` | Lint and analyzer configuration |

## Working Conventions

- State management follows the Provider pattern under `lib/providers/`.
- Business logic belongs in `lib/services/`.
- Data models live in `lib/models/`.
- Tests should be added under `test/` in the matching feature or layer directory.
- Android flavor and release behavior is configured in `android/app/build.gradle.kts`.
