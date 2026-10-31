# Update agent instruction files and baseline docs (adoption Phase 2)

Implements plan: `plans/20261029_191438_agent-and-docs-files.md`
(part of `plans/20261029_183929_adopt-updated-guidelines.md`, Phase 2)

Documentation only. No app code, manifest or build file changed. Nothing in `docs/guidelines/`
changed.

## What changed

| File | Change |
|---|---|
| `CLAUDE.md` | Rewritten in Thin style to the new `CLAUDE_MD_GUIDELINE.md`: identity adds stores, languages and an exact connectivity line; docs table adds the profile, Start Here, `guideline.md`, language pack and store readiness docs; Windows/Linux release commands with versioned symbol folders; Security Baseline rules; full localization rules for `en`/`ml`/`sa` with a "migration in progress" note; three new workflow rules (Security impact line, read-only submodule, checks-only CI); iOS removed |
| `AGENTS.md` | Same content as `CLAUDE.md`, written out in full, with "AI agents" wording |
| `GEMINI.md` (new) | Pointer for Gemini CLI. Gemini CLI reads `GEMINI.md` by default and supports `@file` imports, so it imports `@./AGENTS.md` instead of copying the rules |
| `docs/security.md` | Added §1.1 Security Baseline table, §3.1 entry points, third-party SDK table, §7.1 usability balance, Linux controls, reshaped §12 OWASP to the sign-off form; removed iOS; Production App Extension added to profiles |
| `docs/release_process.md` | Rewritten to the new template: scope with channels and store gates, §6.3–§6.7 hardening checks, Performance / Localization / Store Readiness checklist groups, Windows and Linux build steps (channels not decided), distribution table, release evidence; removed `--dart-define=FLUTTER_APP_FLAVOR` (Flutter sets it from `--flavor`) and the stale version number |
| `docs/architecture.md` | Declared platforms; §15 adds Target Platforms And Distribution and Platform Differences tables; minimum OS now points to the profile; iOS removed |
| `docs/GUIDELINES_MANIFEST.md` | Replaced with the current copy from the submodule, unchanged |
| `docs/workflow_rules.md` | Added Security impact line, status lifecycle, privacy rule, read-only submodule rule, checks-only CI rule |
| `docs/project_structure.md` | Added `PROJECT_PROFILE.md` and `GEMINI.md`; marked `ios/`, `macos/`, `web/` as not declared; `implementation_progress.md` marked Living |
| `docs/implementation_progress.md` | `**Date:**` → `**Last updated:** 2026-10-29`; added the adoption phases checklist; version now points to `pubspec.yaml` |
| `README.md` | Fixed the platform line (Android 10+, Windows, Linux; iOS/macOS/web not declared) |

## Correction made during this phase

The app has no feature called "Air Sync". It has **Wi-Fi sync** ("Sync to Another Device", local
TCP sockets) and **Optical Air-Gap sync** (camera only). Earlier text used "Air Sync" for the
Wi-Fi feature. All living docs now say "Wi-Fi sync". The INTERNET permission is needed for Wi-Fi
sync only; Optical Air-Gap sync needs no network permission. Older plan and change log files are
point-in-time records and were not rewritten.

## Status values used

Security checklist lines are `n/a` only where the reason is clear today (no sign-in, no WebView,
no deep links, no Web platform). Every other line is `to verify` and is checked in Phase 7. No
line is marked `verified` yet.

## Checks

- All relative links in the changed files point to existing files.
- No absolute paths or local machine details in the changed files (the only matches were the
  rule text that lists forbidden examples, and URL schemes).
- No code changed, so `flutter analyze` / `flutter test` were not re-run (last run: clean, 229 tests
  passed, in Phase 3).

## Found, not fixed here

- Platform support of `mobile_scanner`, `local_auth`, `screen_protector` and the Wi-Fi sync
  sockets on Windows and Linux is not checked (`docs/architecture.md` §15, `to verify`).
- Backup import may lack a file size check before parsing (`docs/security.md` §17, Phase 7).
- `android:dataExtractionRules` is needed to stop device-to-device transfer on API 31+
  (`docs/release_process.md` §6.4, Phase 7).
