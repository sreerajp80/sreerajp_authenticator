# Adopt the updated shared guidelines

**Status:** completed

## What the issue is

The `docs/guidelines` submodule moved from `2b381be` to `644faee` (see
`plans/20261028_212312_update-guidelines-submodule.md`). The new guidelines add many rules. The
app does not meet a large number of them yet.

The guidelines say an existing app must adopt them in **small, separately approved steps**
(`docs/guidelines/AI_AGENT_START_HERE.md` §5), and that project choices (platforms, languages,
About badge, and so on) must come from a new `docs/PROJECT_PROFILE.md`, never from a guess.

So this file is a **master plan**. It lists every gap found and splits the work into phases. Each
phase gets its own detailed plan, approval and change log. Approving this file approves the phase
order and Phase 1 only.

## Gaps found (audit)

| # | Rule (guideline reference) | What the app has today | Gap |
|---|---|---|---|
| G1 | `docs/PROJECT_PROFILE.md` is required and is the source of all project choices (Start Here §0, §5; Docs Folder §6) | Missing | Create it |
| G2 | Localization: `l10n.yaml`, one ARB file per declared language, every UI string from `AppLocalizations`, parity test (Standard §8, DoD §23.1) | No `l10n.yaml`, no `lib/l10n/`, about 181 `Text('...')` literals in `lib/` | Full migration needed. `CLAUDE.md` already claims ARB is used, which is not true |
| G3 | In-app language picker when two or more languages; fallback delegate for languages Flutter does not cover, such as Sanskrit (Standard §8.3, §8.4) | None | Depends on languages chosen in G1 |
| G4 | Every icon-only control has a localized tooltip (Standard §7.8) | About 22 `IconButton`s, about 15 `tooltip` uses, none localized | Add tooltips |
| G5 | About signature badge is optional, off by default; if on: text from ARB `madeWithLove` with `{heart}` placeholder, no emoji, red token `#E53935`, `Semantics` label (guideline.md §1.7) | Hard-coded `'Made with ❤️ in India'` in `lib/utils/constants.dart` | Decide on/off in G1, then fix or remove |
| G6 | Depend on `material_ui` / `cupertino_ui` packages instead of `package:flutter/material.dart` (Standard §6.1, §5.3) | 47 files import `flutter/material.dart` | Migrate with `dart fix --apply --code=migrate_design_widgets` |
| G7 | Latest stable Flutter; use the Android AGP / Kotlin / Gradle versions Flutter generates; Java 17 (Standard §5.3) | Installed Flutter is 3.47.6 / Dart 3.13.5. Project: AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14, JVM target 11. `CLAUDE.md` says Flutter `^3.44.8` | Update toolchain via the Flutter migrator, move to Java 17 |
| G8 | Use `kotlin { compilerOptions { } }`, not the old `kotlinOptions { }` block (Standard §5.3) | `android/app/build.gradle.kts` uses `kotlinOptions` | Replace |
| G9 | GitHub CI that runs only format / analyze / test, no secrets, pinned Flutter version, no Dependabot (Standard §19) | No `.github/` folder | Add `.github/workflows/ci.yml` (only if the code is hosted on GitHub — asked in G1) |
| G10 | Only declared platforms are kept and touched (Start Here §1 rule 4) | `android/`, `ios/`, `windows/`, `linux/`, `macos/`, `web/` all exist. `CLAUDE.md` lists only Android, iOS, Windows | Decide platforms in G1; remove or keep the extra folders |
| G11 | `docs/security.md` §1.1 Security Baseline table, and full security doc for the Sensitive Data Extension (Standard §15.1, §15.2) | `docs/security.md` exists but does not follow the new template sections | Re-shape to the new template and verify each baseline item |
| G12 | Security Baseline checks on code (Standard §15.1): `Random.secure()` only, parameterized SQL, imported-file size/type checks, `exported="false"` where possible, cleartext off, permissions only when used | `Random()` not found (good). `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `USE_FINGERPRINT` permissions present | Verify each item; check why network permissions are needed for local P2P sync and record it |
| G13 | `CLAUDE.md` and `AGENTS.md` follow the new `CLAUDE_MD_GUIDELINE.md` / `AGENTS_MD_GUIDELINE.md`, point to `AI_AGENT_START_HERE.md`, and state the submodule is read-only | Older format; Flutter version and target SDK values are out of date | Rewrite to the new guidelines |
| G14 | Store readiness gate for each declared channel (`platform_store_readiness.md`), filled `docs/release_process.md` | `docs/release_process.md` follows the old template | Re-shape; run the gate before the next release |
| G15 | Language packs for declared languages (for example `language_packs/sanskrit_malayalam.md`) | n/a until languages are chosen | Applies only if Malayalam / Sanskrit are declared |

Other new rules (lifecycle, performance, logging, assets, testing) will be checked inside the
phase that touches that code, so this list does not grow without limit.

## Plan for the fix (phases)

Each phase = its own plan file in `plans/`, its own approval, its own change log. No feature work
is mixed in.

1. **Phase 1 — Project profile (G1).** I ask you the intake questions (below). Then I write
   `docs/PROJECT_PROFILE.md` from the code plus your answers. No code changes.
2. **Phase 2 — Agent and docs files (G13, G11 layout, G14 layout).** Update `CLAUDE.md`,
   `AGENTS.md`, and reshape `docs/security.md` and `docs/release_process.md` to the new templates.
3. **Phase 3 — Toolchain (G7, G8, G6).** Done before Phase 2 at the owner's request; see
   `plans/20261029_185250_toolchain-upgrade.md`. The `material_ui` part (G6) gets its own plan. Update `pubspec.yaml` SDK constraint, Android build
   files via the Flutter migrator, Java 17, `compilerOptions`, `minSdk = 29` (profile §3), and
   the `material_ui` migration.
   Build, analyze, test, then stop Gradle daemons.
4. **Phase 4 — Platforms (G10).** Remove or keep `linux/`, `macos/`, `web/` (and others) as the
   profile says.
5. **Phase 5 — Localization (G2, G3, G5, G15).** Add `l10n.yaml`, ARB files for every declared
   language, move all UI strings, parity test, language picker and fallback delegate if needed,
   About badge per profile. This is the largest phase and may be split per screen group.
6. **Phase 6 — Tooltips and accessibility (G4).**
7. **Phase 7 — Security Baseline check (G12, G11 content).** Verify each item in code, fix gaps,
   fill `docs/security.md` §1.1.
8. **Phase 8 — CI (G9).** Add the checks-only workflow, if hosted on GitHub.

## Files to be changed

This master plan itself changes no project file. Files per phase:

- Phase 1: `docs/PROJECT_PROFILE.md` (new)
- Phase 2: `CLAUDE.md`, `AGENTS.md`, `docs/security.md`, `docs/release_process.md`,
  `docs/architecture.md` (only if the template changed it)
- Phase 3: `pubspec.yaml`, `android/settings.gradle.kts`,
  `android/gradle/wrapper/gradle-wrapper.properties`, `android/app/build.gradle.kts`,
  `android/gradle.properties` (only migrator-written flags), all `lib/` and `test/` files that
  import Material/Cupertino
- Phase 4: platform folders (only removal, if chosen)
- Phase 5: `l10n.yaml` (new), `lib/l10n/*.arb` (new), `lib/main.dart`, most files in
  `lib/screens/` and `lib/widgets/`, `lib/utils/constants.dart`, new tests in `test/`
- Phase 6: files in `lib/screens/` and `lib/widgets/` with icon-only buttons
- Phase 7: as found; `android/app/src/main/AndroidManifest.xml` possibly; `docs/security.md`
- Phase 8: `.github/workflows/ci.yml` (new)

Never changed: anything inside `docs/guidelines/` (read-only submodule), `pubspec.lock` by hand.

## Phase 1 intake questions

1. **Platforms:** which ship? Today the code has Android, iOS, Windows, Linux, macOS, Web.
2. **Stores / channels:** for each platform (for example Google Play only; direct APK; Microsoft
   Store; none yet).
3. **Languages:** English only, or more? (The old rule forced English + Malayalam + Sanskrit; the
   new rules let the profile decide.) Who checks each translation (a role)?
4. **About badge:** keep it? If yes, exact English text (today: "Made with ❤️ in India"; the new
   rule uses `{heart}` instead of the emoji, for example "Made with {heart} in India").
5. **Identity:** publisher name as shown in stores; public support contact; website; copyright
   owner; licence of the app code (a `LICENSE` file exists — confirm which); privacy policy URL.
6. **Git hosting:** GitHub? If yes, CI checks run there.
7. **AI agents used:** Claude Code only, or also others (Gemini, Codex, ...)?
8. **Applicability profiles:** I propose Production App Extension + Sensitive Data Extension
   (it stores OTP secrets). Confirm?
