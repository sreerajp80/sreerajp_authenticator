# Plan: Update Guidelines Submodule

**Status:** Completed

## Goal
Update the `docs/guidelines` Git submodule to the latest commit on `origin/master` (`2b381be`) and synchronize `docs/GUIDELINES_MANIFEST.md` with the updated manifest from the submodule.

## Current State
- `docs/guidelines` is currently at commit `4b7e85ae79ba7011044b4e4f380bf62bf4a89af9`.
- Remote `origin/master` is at commit `2b381be` (with new guidelines including `CLAUDE_MD_GUIDELINE.md`, `AGENTS_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`, and updated standards).

## Proposed Changes
1. **Submodule Update**:
   - Fast-forward / pull the `docs/guidelines` submodule to `origin/master` (`2b381be`).
2. **Guidelines Manifest**:
   - Update `docs/GUIDELINES_MANIFEST.md` to match the latest manifest from the updated submodule.

## Files to be Changed
- `docs/guidelines` (submodule pointer commit update)
- `docs/GUIDELINES_MANIFEST.md` (pointer manifest sync)

## Verification
- Verify `git submodule status` shows the latest commit (`2b381be`).
- Run `flutter analyze` and `flutter test` to ensure zero regressions.
