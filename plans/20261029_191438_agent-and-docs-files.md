# Update agent instruction files and baseline docs (adoption Phase 2)

**Status:** completed

Part of master plan: `plans/20261029_183929_adopt-updated-guidelines.md` (Phase 2, gaps G11,
G13, G14 — layout only).

**Security impact:** none. Documentation only; no code, manifest or build file changes.

## What the issue is

The new guidelines changed the required shape of the agent files and the baseline docs:

- `CLAUDE_MD_GUIDELINE.md` / `AGENTS_MD_GUIDELINE.md` add identity rows (stores, languages), new
  doc references (`PROJECT_PROFILE.md`, `guideline.md`, `platform_store_readiness.md`), new
  localization rules (declared languages, language packs, `material_ui`, tooltips, About badge),
  the Security Baseline, and three new workflow rules (a "Security impact" line in plans, the
  guidelines submodule is read-only, CI is checks only). Our `CLAUDE.md` / `AGENTS.md` lack these
  and still list iOS, which no longer ships.
- The project uses Gemini, which reads `GEMINI.md` by default, not `AGENTS.md`. The guidelines
  say to point it at `AGENTS.md` and never keep two copies of the rules
  (`AI_AGENT_START_HERE.md` §4 step 3).
- The `security.md` template now has §1.1 Security Baseline table, §3.1 entry points, a
  third-party SDK list, §7.1 usability balance, Linux / macOS platform controls, and an OWASP
  sign-off. Our `docs/security.md` has none of these and still has an iOS section.
- The `release_process.md` template now has more hardening checks (§6.3–§6.7), localization and
  store-readiness checklist groups, and Windows / Linux release steps. Ours covers Android only.
- `docs/GUIDELINES_MANIFEST.md` is an old copy; it must be the current file, copied unchanged.
- `docs/workflow_rules.md` lacks the three new workflow rules. `docs/project_structure.md` does
  not list `docs/PROJECT_PROFILE.md`. `docs/implementation_progress.md` is a living file but has a
  `**Date:**` line instead of `**Last updated:**` (`DOCS_FOLDER_GUIDELINE.md` §5).

## Files to be changed

| File | Change |
|---|---|
| `CLAUDE.md` | Rewrite in Thin style to the new template order and checklist |
| `AGENTS.md` | Same content as `CLAUDE.md`, written out in full (not a link), wording for "AI agents" |
| `GEMINI.md` (new) | Short pointer: "Read and follow `AGENTS.md`". No rules copied. I will check the Gemini CLI docs for the current default file name before writing it |
| `docs/security.md` | Reshape to the new template; keep all existing app content (P2P sync model, crypto, etc.) |
| `docs/release_process.md` | Reshape to the new template for Android, Windows, Linux |
| `docs/architecture.md` | Add "Target Platforms And Distribution" and "Platform Differences" under §15; drop iOS mentions |
| `docs/GUIDELINES_MANIFEST.md` | Replace with the current `docs/guidelines/GUIDELINES_MANIFEST.md`, unchanged |
| `docs/workflow_rules.md` | Add the three new workflow rules |
| `docs/project_structure.md` | Add `docs/PROJECT_PROFILE.md` and `GEMINI.md` |
| `docs/implementation_progress.md` | `**Date:**` → `**Last updated:** 2026-10-29`; add the adoption phases as a checklist |

Not changed: anything in `docs/guidelines/`, app code, build files. `README.md` is checked
against engineering standard §21.3 and changed only if it is wrong about platforms or versions.

## Plan for the fix

### `CLAUDE.md` and `AGENTS.md`

- Identity table: platforms Android (minSdk 29) / Windows / Linux; stores (Google Play, direct APK;
  Windows and Linux not decided yet); languages `en` (template), `ml`, `sa`; connectivity
  "offline; local network only for Air Sync" (the app uses INTERNET for local sockets, so the
  old "fully offline" line is not exact).
- Docs table: add `docs/PROJECT_PROFILE.md`, `docs/guidelines/guideline.md`,
  `docs/guidelines/platform_store_readiness.md`, `docs/guidelines/AI_AGENT_START_HERE.md`,
  `docs/guidelines/language_packs/sanskrit_malayalam.md`.
- Build commands: Android, Windows and Linux release commands with versioned symbol folders.
- Signing: two backups (one offline); full `.gitignore` list; other platforms' signing outside git.
- Security rules: point to the Security Baseline (standard §15.1) and `docs/security.md`.
- Localization rules: the new full list for `en` / `ml` / `sa`, Sanskrit fallback delegate,
  language picker, short labels, tooltips, `material_ui`, About badge
  "Made with {heart} in India". Add one honest line: "Migration in progress — the app does not
  meet these rules yet; see the adoption plan (Phases 5–6)."
- Workflow rules: add Security-impact line, read-only submodule, checks-only CI.
- Keep the existing hard rules, architecture, testing and dependency sections (still true).

### `docs/security.md`

- §1: profiles in force (all three), sensitivity `high`, platforms Android / Windows / Linux.
- New §1.1 Security Baseline table. Status per line: `n/a` with a reason where clear today (no
  sign-in, no WebView, no web build, no third-party SDKs that send data); every other line
  `to verify (Phase 7)`. No line is marked `verified` without a check.
- New §3.1 entry points: QR codes (camera and image), backup import files, Air Sync socket,
  optical sync QR frames, clipboard, Android intents / exported activity.
- §4: add "Third-Party SDKs" (none that send data).
- §7.1 usability balance (lock timeout, biometrics) from what the code does now.
- §10: remove iOS; add Linux; keep Android and Windows.
- §12: OWASP checklist in the template's sign-off form, items left unchecked until Phase 7.

### `docs/release_process.md`

- Follow the template section order. Add §6.3 size analysis, §6.4 debuggable / backup check,
  §6.5 cleartext, §6.6 asset and secret leak audit, §6.7 exported component audit.
- Checklist: add Performance, Localization and Store Readiness groups.
- §9 Android steps (Google Play bundle + split APKs); §11 Windows and §11B Linux steps with the
  channel marked "not decided yet". Remove the iOS-free "Platforms Not Yet Tracked Here" section.
- Keep the release owner as "Developer (Sreeraj P)".

### Checks

- Every relative link in the changed files points to a file that exists.
- No absolute paths or local machine details in any changed file.
- Write the change log, set this plan to `completed`, and update the master plan.
