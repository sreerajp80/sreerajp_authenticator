# Plan: Guideline Alignment for Project Structure, Documentation, and Code

**Status:** COMPLETED
**Date:** 2026-08-19

## 1. Issue Description

The project guidelines in `docs/guidelines/` (`AGENTS_MD_GUIDELINE.md`, `CLAUDE_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`, `GUIDELINES_MANIFEST.md`, `guideline.md`, `flutter_project_engineering_standard.md`, `release_process.md`, `security.md`) define conventions and mandatory requirements across Flutter projects.

An audit of the repository against these guidelines surfaced the following alignment items:

1. **`AGENTS.md` & `CLAUDE.md` Dual Alignment:**
   - Missing mandatory `## Localization rules` section (required for every app).
   - Missing item 3 in `## Workflow rules` regarding relative paths only and zero sensitive data / local system details.
   - Header alignment (`## What AI agents must always / never do` in `AGENTS.md` vs `## What Claude must always / never do` in `CLAUDE.md`).
   - Syncing commands, paths, and metadata between `AGENTS.md` and `CLAUDE.md`.

2. **Absolute Link & Drive Letter Clean-up in `docs/`:**
   - Multiple documents (`docs/architecture.md`, `docs/security.md`, `docs/release_process.md`, `docs/feature_analysis_and_roadmap.md`) contain obsolete `/l:/Android/SreerajP_Authenticator/...` and `file:///l:/...` paths.
   - Per `DOCS_FOLDER_GUIDELINE.md` and `flutter_project_engineering_standard.md` §21.1.1, all cross-links must use relative markdown paths.

3. **Version & Metadata Synchronization in `docs/`:**
   - `docs/release_process.md`: references old version `2.4.0+1`; needs updating to current `2.8.2+23` and symbol paths `build/symbols/android-prod/`.
   - `docs/features.md`: Section 7 references old version `2.7.11` (build `20`); needs updating to `2.8.2` (build `23`).
   - `docs/implementation_progress.md`: references old version `2.5.11+1`; needs updating to `2.8.2+23`.

4. **Formatting and Lint Verification:**
   - Run `dart format .`, `flutter analyze`, and `flutter test` to ensure zero regressions.

---

## 2. Proposed Changes

### Root AI Instructions

#### `AGENTS.md`
- Add `## Localization rules` section.
- Update `## Workflow rules` to include the relative paths & privacy rule (item 3).
- Update section header to `## What AI agents must always / never do`.
- Ensure alignment with `CLAUDE.md` and `AGENTS_MD_GUIDELINE.md`.

#### `CLAUDE.md`
- Add `## Localization rules` section.
- Update `## Workflow rules` to include the relative paths & privacy rule (item 3).
- Ensure alignment with `AGENTS.md` and `CLAUDE_MD_GUIDELINE.md`.

---

### Documentation (`docs/`)

#### `docs/architecture.md`
- Replace `/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/...` and `file:///l:/...` with clean relative paths (e.g. `../pubspec.yaml`, `../lib/main.dart`, `../lib/services/database_service.dart`).

#### `docs/security.md`
- Replace `/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/...` with relative paths (`../lib/...`, `../android/...`, `release_process.md`).

#### `docs/release_process.md`
- Replace `/l:/Android/SreerajP_Authenticator/...` with relative paths.
- Update version references from `2.4.0+1` to `2.8.2+23`.
- Update build split debug info symbols paths to `build/symbols/android-prod/`.

#### `docs/features.md`
- Update Section 7 version `2.7.11` and build `20` to `2.8.2` and `23`.

#### `docs/implementation_progress.md`
- Update Section 1 current release version to `2.8.2+23`.

#### `docs/feature_analysis_and_roadmap.md`
- Replace all `file:///l:/...` absolute links with relative paths (`../lib/...`, `../pubspec.yaml`, etc.).

---

## 3. Verification Plan

1. **Link Verification:** Ensure all relative markdown links in `docs/`, `AGENTS.md`, and `CLAUDE.md` resolve correctly without absolute paths.
2. **Static Analysis:** Run `flutter analyze` — must return 0 issues.
3. **Automated Tests:** Run `flutter test` — all unit and widget tests must pass.
4. **Code Formatting:** Run `dart format .` — ensure all code is properly formatted.
