# Project Structure — SreerajP Authenticator

This document describes the tracked repository file tree and directory responsibility layout for SreerajP Authenticator. Read this to understand where files live and maintain project layout conventions.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [guidelines/guideline.md](guidelines/guideline.md)

---

## 1. Repository Root

```text
sreerajp_authenticator/
|-- android/               Android app module, flavors, Gradle config, launcher resources
|-- assets/                Bundled application assets
|-- change_log/            Completed change logs (yyyymmdd_hhMMss_<short-slug>.md)
|-- docs/                  Project documentation and shared Flutter guidelines submodule
|-- fonts/                 Inter font files declared in pubspec.yaml
|-- ios/                   iOS runner project and test target
|-- lib/                   Flutter application source
|-- linux/                 Linux desktop runner
|-- macos/                 macOS runner and test target
|-- plans/                 Change proposals (yyyymmdd_hhMMss_<short-slug>.md)
|-- test/                  Unit and widget tests mirroring app layers
|-- web/                   Web runner shell and icons
|-- windows/               Windows desktop runner
|-- analysis_options.yaml  Lint and analyzer configuration
|-- pubspec.yaml           Package manifest, dependencies, assets, and fonts
|-- pubspec.lock           Resolved package versions
|-- README.md              Main project overview and usage instructions
|-- LICENSE                Project license
|-- AGENTS.md              Repository-specific automation rules
`-- CLAUDE.md              Agent entry point and canonical project rules
```

---

## 2. Documentation Directory (`docs/`)

```text
docs/
|-- guidelines/                  Git submodule (https://github.com/sreerajp80/Flutter_Guidelines)
|-- GUIDELINES_MANIFEST.md       Portable pointer file linking shared guidelines
|-- architecture.md              [Living] Architecture, layers, lifecycle, state, and persistence
|-- security.md                  [Living] Security rules, threat model, sensitive data, and crypto
|-- release_process.md           [Living] Build commands, signing, obfuscation, release checklist
|-- workflow_rules.md            [Living] Plan-before-changing, approval gate, log-after-changing
|-- dependencies.md              [Living] Approved baseline and prohibited package constraints
|-- project_structure.md         [Living] File tree and directory responsibility layout
|-- implementation_plan.md       [Point-in-time] Phase-by-phase build and compliance roadmap
|-- implementation_progress.md   [Point-in-time] Live status checklist by phase
`-- feature_analysis_and_roadmap.md [Point-in-time] Detailed feature expansion analysis
```

---

## 3. Flutter App Layout

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
| `docs/guidelines/flutter_build_flavors_guide.md` | Build flavor and release command guide |
| `docs/guidelines/flutter_project_engineering_standard.md` | Shared engineering standards for the Flutter project |
| `analysis_options.yaml` | Lint and analyzer configuration |

## Working Conventions

- State management follows the Provider pattern under `lib/providers/`.
- Business logic belongs in `lib/services/`.
- Data models live in `lib/models/`.
- Tests should be added under `test/` in the matching feature or layer directory.
- Android flavor and release behavior is configured in `android/app/build.gradle.kts`.
