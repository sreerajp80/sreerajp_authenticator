# Plan: Project Structure, Codebase, and Documentation Alignment to Guidelines

**Status:** Completed  
**Date:** 2026-08-24  
**Author:** AI Pair Programmer  

---

## 1. Issue & Motivation

A thorough audit of the project structure, code, and documentation against the shared Flutter guidelines in `docs/guidelines/` (specifically `DOCS_FOLDER_GUIDELINE.md`, `AGENTS_MD_GUIDELINE.md`, `CLAUDE_MD_GUIDELINE.md`, `GUIDELINES_MANIFEST.md`, and `guideline.md`) identified a few areas needing synchronization and alignment:

1. **Root AI Instructions (`AGENTS.md` & `CLAUDE.md`)**:
   - Outdated reference to `Group` in immutable models statement (groups were replaced by tag-based organization in SQLite schema v4).
   - Missing `docs/features.md` in the "Read these docs before working" table.

2. **Architecture Documentation (`docs/architecture.md`)**:
   - Section 4 Ownership Rules, Section 5 Initialization, Section 7 Offline Behavior, and Section 8 State Management still reference legacy `groups` and `GroupsProvider`.
   - Section 11 Domain Model lists SQLite schema version as `2` (initial schema + group icon), whereas `DatabaseService` is at schema version `4` (v3 tags column, v4 migration of groups to tags and dropping groups table).
   - Section 12 Dependency Management lists `GroupsProvider` as an active app-root dependency.
   - Section 18 lists migration 1 to 2 instead of 1 to 4.

3. **Project Structure Document (`docs/project_structure.md`)**:
   - File trees for `lib/`, `test/`, and `docs/` omit multiple added screens (e.g. `appearance_screen.dart`, `features_screen.dart`, `help/`, `optical_sync_screen.dart`, `send_to_device_screen.dart`, `sync_screen.dart`, `tag_management_screen.dart`, `theme_mode_settings_screen.dart`), services (`brand_icon_service.dart`, `optical_sync_service.dart`, `p2p_sync_service.dart`), widgets, test files, and doc files (`docs/features.md`).

4. **Release Process Document (`docs/release_process.md`)**:
   - Version in Section 1 is listed as `2.8.2+23`, which drifted from `pubspec.yaml` and `assets/config/app_config.json` (`2.9.2+26`).

5. **Implementation Progress Document (`docs/implementation_progress.md`)**:
   - Version in Section 1 is listed as `2.8.2+23`, which needs updating to `2.9.2+26`.
   - Milestones need updating with recently completed capabilities (Steam/non-standard algorithms, tag management & brand icons, optical air-gap sync, schema v4).

6. **Feature Reference Document (`docs/features.md`)**:
   - Title is `# SreerajP Authenticator — Feature Reference`. `DOCS_FOLDER_GUIDELINE.md` §4 specifies `# <Title> — <AppName>` format: `# Feature Reference — SreerajP Authenticator`.

7. **Feature Analysis & Roadmap Document (`docs/feature_analysis_and_roadmap.md`)**:
   - Section 2 Codebase Architecture Overview lists outdated `Group` model and `Group` provider.

---

## 2. Proposed Changes

### Root AI Instructions

- **[`AGENTS.md`](../AGENTS.md)** & **[`CLAUDE.md`](../CLAUDE.md)**:
  - Add `docs/features.md` to "Read these docs before working" table.
  - Update models rule to reference `Account` with tag-based organization.

### Documentation Files (`docs/`)

- **[`docs/architecture.md`](../docs/architecture.md)**:
  - Update SQLite schema version to `4` with complete migration history (v1 through v4).
  - Update Core Models table to `Account` (with tags support and brand icon integration).
  - Remove references to `Group` and `GroupsProvider` across layer ownership, app init, state management, and root provider dependencies (`ThemeProvider`, `SettingsProvider`, `AccountProvider`).
- **[`docs/project_structure.md`](../docs/project_structure.md)**:
  - Completely refresh `lib/`, `test/`, and `docs/` trees to reflect the exact current directory structures.
  - Update layer and test descriptions.
- **[`docs/release_process.md`](../docs/release_process.md)**:
  - Update current release version from `2.8.2+23` to `2.9.2+26` to match `pubspec.yaml` and `assets/config/app_config.json`.
- **[`docs/implementation_progress.md`](../docs/implementation_progress.md)**:
  - Update current release version to `2.9.2+26`.
  - Update completed milestones and active checklists.
- **[`docs/features.md`](../docs/features.md)**:
  - Adjust title to `# Feature Reference — SreerajP Authenticator`.
- **[`docs/feature_analysis_and_roadmap.md`](../docs/feature_analysis_and_roadmap.md)**:
  - Update Section 2 Architecture Overview to reflect current models and providers.

---

## 3. Verification Plan

1. **Relative Links & Privacy Verification:**
   - Confirm all cross-references across `docs/`, `AGENTS.md`, and `CLAUDE.md` use clean relative links and contain zero absolute system paths, machine names, or credentials.
2. **Static Analysis:**
   - Run `flutter analyze` to ensure 0 warnings and 0 errors.
3. **Automated Test Suite:**
   - Run `flutter test` to ensure all 228+ unit and widget tests pass.
4. **Code Formatting:**
   - Run `dart format .` to maintain standard code formatting.
