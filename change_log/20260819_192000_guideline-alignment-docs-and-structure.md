# Change Log: Guideline Alignment for Project Structure, Documentation, and Code

**Date:** 2026-08-19  
**Plan Reference:** [plans/20260819_190300_guideline-alignment-docs-and-structure.md](../plans/20260819_190300_guideline-alignment-docs-and-structure.md)

---

## 1. Overview

Audited and updated the project structure, root agent instructions (`AGENTS.md` and `CLAUDE.md`), and repository documentation files under `docs/` to ensure full compliance with the shared Flutter guidelines in `docs/guidelines/`.

---

## 2. Changes Made

### Root AI Instructions

- **[`AGENTS.md`](../AGENTS.md) & [`CLAUDE.md`](../CLAUDE.md)**:
  - Added mandatory `## Localization rules` section for single/multi-language compliance.
  - Added privacy and relative paths rule (item 3) under `## Workflow rules`.
  - Aligned section headers (`## What AI agents must always / never do` in `AGENTS.md` and `## What Claude must always / never do` in `CLAUDE.md`).
  - Synchronized commands, paths, and metadata between both files.

### Project Documentation (`docs/`)

- **[`docs/architecture.md`](../docs/architecture.md)**:
  - Replaced obsolete absolute `/l:/Android/...` and `file:///l:/...` links with relative repository paths (`../lib/...`, `release_process.md`).
  - Updated debug symbols path to `build/symbols/android-prod/`.
- **[`docs/security.md`](../docs/security.md)**:
  - Replaced obsolete absolute paths with relative paths (`../lib/...`, `../android/...`, `release_process.md`).
  - Updated debug symbols path to `build/symbols/android-prod/`.
- **[`docs/release_process.md`](../docs/release_process.md)**:
  - Replaced obsolete absolute links with relative paths (`../pubspec.yaml`, `../android/...`).
  - Updated current release version to `2.8.2+23`.
  - Updated debug symbols path to `build/symbols/android-prod/`.
- **[`docs/features.md`](../docs/features.md)**:
  - Updated Section 7 version `2.7.11` (build `20`) to `2.8.2` (build `23`) matching `assets/config/app_config.json` and `pubspec.yaml`.
- **[`docs/implementation_progress.md`](../docs/implementation_progress.md)**:
  - Updated Section 1 current release version to `2.8.2+23`.
- **[`docs/feature_analysis_and_roadmap.md`](../docs/feature_analysis_and_roadmap.md)**:
  - Replaced all `file:///l:/...` absolute links across architecture summaries, feature descriptions, and the roadmap table with clean relative links.

---

## 3. Verification & Results

1. **Relative Links Verification:**
   - Ran searches across `docs/`, `AGENTS.md`, and `CLAUDE.md` to confirm zero absolute system paths or drive letters remain.
2. **Dart Formatting:**
   - Ran `dart format .` — formatted 73 files with 0 changes needed.
3. **Static Analysis:**
   - Ran `flutter analyze` — passed with 0 warnings or errors.
4. **Automated Test Suite:**
   - Ran `flutter test` — all 228 unit and widget tests passed cleanly.
