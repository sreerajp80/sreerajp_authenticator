# Update the guidelines submodule

**Status:** completed

## Files to change

- `docs/guidelines` (submodule pointer only — no files inside the submodule are edited)

## Issue

The `docs/guidelines` submodule (shared Flutter guidelines) is pinned at commit `2b381be`.
The upstream `master` branch is 15 commits ahead (latest `644faee`). The project is reading
an old copy of the shared guidelines.

## Plan

1. In `docs/guidelines`, check out the latest `origin/master` (fast-forward only).
2. In the parent project, stage the new submodule pointer.
3. Do not edit any file inside the submodule.
4. Write a change log in `change_log/`.
5. Do not commit or push unless asked.
