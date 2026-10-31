# Project Structure — Sreeraj P Authenticator

This document describes the tracked repository file tree and directory responsibility layout for Sreeraj P Authenticator. Read this to understand where files live and maintain project layout conventions.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [guidelines/guideline.md](guidelines/guideline.md)

---

## 1. Repository Root

```text
sreerajp_authenticator/
|-- android/               Android app module, flavors, Gradle config, launcher resources
|-- assets/                Bundled application assets (config, icons, brands, images)
|-- change_log/            Completed change logs (yyyymmdd_hhMMss_<short-slug>.md)
|-- docs/                  Project documentation and shared Flutter guidelines submodule
|-- fonts/                 Inter font files declared in pubspec.yaml
|-- lib/                   Flutter application source
|-- plans/                 Change proposals (yyyymmdd_hhMMss_<short-slug>.md)
|-- test/                  Unit and widget tests mirroring app layers
|-- analysis_options.yaml  Lint and analyzer configuration
|-- pubspec.yaml           Package manifest, dependencies, assets, and fonts
|-- pubspec.lock           Resolved package versions
|-- README.md              Main project overview and usage instructions
|-- LICENSE                Project license
|-- AGENTS.md              Project rules for AI agents (same content as CLAUDE.md)
|-- CLAUDE.md              Claude Code entry point and project rules
`-- GEMINI.md              Pointer for Gemini CLI — imports AGENTS.md
```

---

## 2. Documentation Directory (`docs/`)

```text
docs/
|-- guidelines/                     Git submodule (https://github.com/sreerajp80/Flutter_Guidelines)
|-- GUIDELINES_MANIFEST.md          Portable pointer file linking shared guidelines (copied unchanged)
|-- PROJECT_PROFILE.md              [Living] Product brief, platforms, stores, languages, identity, About options, tools
|-- architecture.md                 [Living] Architecture, layers, lifecycle, state, and persistence
|-- security.md                     [Living] Security rules, threat model, sensitive data, and crypto
|-- release_process.md              [Living] Build commands, signing, obfuscation, release checklist
|-- features.md                     [Living] Comprehensive feature catalog and supported algorithms
|-- workflow_rules.md               [Living] Plan-before-changing, approval gate, log-after-changing
|-- dependencies.md                 [Living] Approved baseline and prohibited package constraints
|-- project_structure.md            [Living] File tree and directory responsibility layout
|-- implementation_plan.md          [Point-in-time] Phase-by-phase build and compliance roadmap
|-- implementation_progress.md      [Living] Status checklist by phase, with a Last updated line
`-- feature_analysis_and_roadmap.md [Point-in-time] Detailed feature expansion analysis
```

---

## 3. Flutter App Layout

```text
lib/
|-- main.dart
|-- config/
|   |-- app_config.dart
|   `-- app_flavor_config.dart
|-- models/
|   `-- account.dart
|-- providers/
|   |-- account_provider.dart
|   |-- settings_provider.dart
|   `-- theme_provider.dart
|-- screens/
|   |-- help/
|   |   |-- faq_screen.dart
|   |   |-- guide_screen.dart
|   |   `-- help_screen.dart
|   |-- about_screen.dart
|   |-- add_account_screen.dart
|   |-- appearance_screen.dart
|   |-- backup_restore_screen.dart
|   |-- features_screen.dart
|   |-- home_screen.dart
|   |-- lock_screen.dart
|   |-- optical_sync_screen.dart
|   |-- permissions_screen.dart
|   |-- qr_scanner_screen.dart
|   |-- security_screen.dart
|   |-- send_to_device_screen.dart
|   |-- settings_screen.dart
|   |-- sync_qr_scanner_screen.dart
|   |-- sync_screen.dart
|   |-- tag_management_screen.dart
|   `-- theme_mode_settings_screen.dart
|-- services/
|   |-- auth_service.dart
|   |-- brand_icon_service.dart
|   |-- config_service.dart
|   |-- database_service.dart
|   |-- device_state_service.dart
|   |-- data_wipe_service.dart
|   |-- encryption_service.dart
|   |-- export_import_service.dart
|   |-- optical_sync_service.dart
|   |-- otp_service.dart
|   `-- p2p_sync_service.dart
|-- utils/
|   |-- constants.dart
|   `-- theme.dart
`-- widgets/
    |-- account_tile/
    |   |-- account_avatar.dart
    |   |-- otp_code_display.dart
    |   |-- pattern_painter.dart
    |   `-- timer_indicator.dart
    |-- add_account/
    |   |-- account_info_card.dart
    |   |-- advanced_settings_card.dart
    |   `-- tag_autocomplete_field.dart
    |-- home/
    |   |-- home_bottom_bar.dart
    |   |-- home_empty_state.dart
    |   |-- home_fab_button.dart
    |   |-- home_search_bar.dart
    |   `-- home_tag_chips.dart
    |-- account_tile.dart
    `-- pin_verification_dialog.dart
```

## Layer Responsibilities

| Path | Responsibility |
|------|----------------|
| `lib/main.dart` | App entry point, provider wiring, routing bootstrap, flavor initialization, screen protector hooks |
| `lib/config/` | Flavor configuration and metadata typed models |
| `lib/models/` | Core domain data models (`Account` with multi-tag and brand icon integration) |
| `lib/providers/` | Provider-based state management (`AccountProvider`, `SettingsProvider`, `ThemeProvider`) |
| `lib/screens/` | Route-level UI screens, help views, and primary user workflows |
| `lib/services/` | Business logic for authentication, OTP, encryption, storage, optical/P2P sync, brand icons, and import/export |
| `lib/utils/` | Shared technical constants and design theme definitions |
| `lib/widgets/` | Reusable UI building blocks organized by feature area |

## Test Layout

The `test/` folder mirrors the production structure so each layer has focused coverage.

```text
test/
|-- config/
|   `-- app_flavor_config_test.dart
|-- models/
|   `-- account_test.dart
|-- providers/
|   |-- account_provider_test.dart
|   |-- provider_test_helpers.dart
|   |-- settings_provider_test.dart
|   `-- theme_provider_test.dart
|-- screens/
|   `-- tag_management_screen_test.dart
|-- services/
|   |-- auth_service_test.dart
|   |-- brand_icon_service_test.dart
|   |-- config_service_test.dart
|   |-- database_service_test.dart
|   |-- encryption_service_test.dart
|   |-- export_import_service_test.dart
|   |-- optical_sync_service_test.dart
|   |-- otp_service_test.dart
|   `-- p2p_sync_service_test.dart
`-- widgets/
    |-- add_account/
    |   `-- tag_autocomplete_field_test.dart
    |-- home/
    |   `-- home_widgets_test.dart
    `-- security_auth_widgets_test.dart
```

## Supporting Project Areas

| Path | Purpose |
|------|---------|
| `android/app/build.gradle.kts` | Android build types, product flavors, signing, and APK naming |
| `android/app/src/main/` | Android manifest, Kotlin entry point, launcher icons, and theme resources |
| `assets/icons/` | Bundled app icons and foreground artwork |
| `assets/icons/brands/` | Bundled brand vector icons (Google, GitHub, Microsoft, AWS, Discord, etc.) |
| `assets/config/app_config.json` | Single source of truth for About screen constants |
| `docs/architecture.md` | High-level architecture reference |
| `docs/security.md` | Security model and implementation notes |
| `docs/release_process.md` | Release workflow documentation |
| `docs/features.md` | Comprehensive feature and algorithm catalog |
| `docs/guidelines/flutter_build_flavors_guide.md` | Build flavor and release command guide |
| `docs/guidelines/flutter_project_engineering_standard.md` | Shared engineering standards for the Flutter project |
| `analysis_options.yaml` | Lint and analyzer configuration |

## Working Conventions

- State management follows the Provider pattern under `lib/providers/`.
- Business logic belongs in `lib/services/`.
- Data models live in `lib/models/`.
- Tests should be added under `test/` in the matching feature or layer directory.
- Android flavor and release behavior is configured in `android/app/build.gradle.kts`.
