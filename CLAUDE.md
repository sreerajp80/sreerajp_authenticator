# CLAUDE.md — Sreeraj P Authenticator

This file is read by Claude Code at the start of every session in this repository.
Read it before making any change. See the docs table below for full detail.

Follow the guidelines listed in `docs/GUIDELINES_MANIFEST.md`, starting with
`docs/guidelines/AI_AGENT_START_HERE.md`.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | Sreeraj P Authenticator |
| Type | Offline-first TOTP/HOTP two-factor authenticator app with AES-256-GCM vault, biometrics, and QR onboarding |
| Platforms | Android (minSdk 29, targetSdk = Flutter default) — declared in `docs/PROJECT_PROFILE.md` |
| Stores / channels | Android: Google Play, direct APK |
| Languages | `en` (template), `ml` (Malayalam), `sa` (Sanskrit) |
| Package / org id | `in.sreerajp.sreerajp_authenticator` |
| Flutter SDK | 3.47.6 (stable) |
| Dart SDK | `^3.13.5` |
| Android toolchain | AGP 9.4.1, Kotlin Gradle Plugin 2.4.10, Gradle 9.8.0, Java 17 |
| State management | `Provider` + `ChangeNotifier` |
| Navigation | Named routes / `MaterialPageRoute` |
| Database | `sqflite` (encrypted fields) + `flutter_secure_storage` (AES key, PIN/recovery hashes) |
| Orientation | Portrait only (`SystemChrome.setPreferredOrientations`) |
| Connectivity | Offline — no internet backend or cloud account. Local network only, for Wi-Fi sync ("Sync to Another Device") between two devices (needs the INTERNET permission for local sockets) |

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| `docs/PROJECT_PROFILE.md` | Always — product brief, platforms, stores, languages, identity, About options, tools |
| `docs/architecture.md` | Changing structure, screens, state, services, models, database schema |
| `docs/security.md` | Touching permissions, biometrics, encryption, storage, logging, screen protection, entry points |
| `docs/release_process.md` | Building a release, versioning (`pubspec.yaml`), keystore signing, obfuscation |
| `docs/features.md` | Understanding existing capabilities, algorithms, and supported formats |
| `docs/workflow_rules.md` | Proposing changes, approval workflow, writing plans and change logs |
| `docs/dependencies.md` | Adding or evaluating external packages and dependency constraints |
| `docs/project_structure.md` | Navigating directory trees and path responsibility boundaries |
| `docs/GUIDELINES_MANIFEST.md` | The shared Flutter guidelines index |
| `docs/guidelines/AI_AGENT_START_HERE.md` | Read order, adoption steps, "ready for the stores" checklist |
| `docs/guidelines/flutter_project_engineering_standard.md` | Any code change — layers, naming, testing, accessibility, localization, security |
| `docs/guidelines/guideline.md` | About screen, Android keystore, `lib/` layout |
| `docs/guidelines/language_packs/sanskrit_malayalam.md` | Any Malayalam or Sanskrit text |
| `docs/guidelines/flutter_build_flavors_guide.md` | Modifying Gradle configs, build flavors (`dev`/`prod`), signing |
| `docs/guidelines/platform_store_readiness.md` | Before any release; when touching permissions or store-listed behavior |

> `docs/<file>` = this app's own filled-in copy. `docs/guidelines/<file>` = the shared reference
> in the submodule; never copy it into `docs/`.

---

## Hard rules (must follow — these override convenience)

1. Open source only. Commercial or source-available SDKs are prohibited. Check package licenses before adding.
2. Offline-first. The app works 100% locally, without cloud backends, tracking, or remote accounts. The only network use is local-network Wi-Fi sync between the user's own devices.
3. Scoped storage and zero telemetry. Never log secrets, keys, decrypted OTP data, or PIN hashes (even in debug builds).
4. Never crash on invalid QR codes or corrupted backups. Every parser must have a safe failure path with friendly user feedback.
5. Atomic / safe database writes. Encrypt secrets before writing to disk; plaintext exists transiently in memory only.

---

## Architecture rules

- Layout: Tier 1 layer-first under `lib/` (`config/`, `models/`, `providers/`, `screens/`, `services/`, `utils/`, `widgets/`, `main.dart`). Do not restructure without instruction. Full detail: `docs/architecture.md`.
- Layer boundaries: Widgets must not execute raw SQL, manage encryption keys, or handle file paths directly. Services must not depend on `BuildContext` or navigation routes.
- Dependency direction: `screens → providers → services → database/secure_storage → models`.
- Models are immutable data classes (`Account` with tag-based organization). Never mutate model properties in place.

---

## Build & run commands

```bash
flutter pub get                        # install dependencies
flutter run --flavor dev               # daily development (dev flavor)
flutter run --flavor prod              # production build with debug tooling
flutter analyze                        # static analysis (must return zero issues)
flutter test                           # run all unit and widget tests
dart format .                          # format all Dart code before committing

# Production release APK (split per ABI)
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/ --split-per-abi

# Production Play Store bundle
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/
```

> Size analysis (`--analyze-size`) is a separate throw-away build: run it before the release
> build, never ship it (`docs/release_process.md` §6.3).

> On Android the app defines flavors, so a bare `flutter run` uses the default `dev` flavor
> (`default-flavor` in `pubspec.yaml`). Pass `--flavor` to be explicit.

---

## Build flavors

| Flavor | App ID | Display name | Signing |
|--------|--------|--------------|---------|
| dev | `in.sreerajp.sreerajp_authenticator.dev` | Sreeraj P Authenticator Dev | Debug keystore (automatic) |
| prod | `in.sreerajp.sreerajp_authenticator` | Sreeraj P Authenticator | Release keystore (`android/key.properties`) |

---

## Signing / keystore

- Release keystore file: `android/release-keystore.jks`. Back it up as
  `docs/guidelines/guideline.md` §2.3 says: at least two separate secure backups, at least one offline.
- Configured via `android/key.properties` (gitignored — never commit).
- `.gitignore` must include: `android/key.properties`, `*.jks`, `*.keystore`, and `build/` (which also holds the debug symbols).

---

## Security rules

- Never log secrets, keys, PINs, or decrypted OTP seeds — even in debug builds.
- Follow the Security Baseline (`docs/guidelines/flutter_project_engineering_standard.md` §15.1)
  and the Sensitive Data Extension (§15.2). Never weaken a security control to make something
  work; ask first. Status of each baseline item: `docs/security.md` §1.1.
- No secrets in code, assets, or `--dart-define` — anything shipped in the app is public.
- Treat all outside input as untrusted: QR codes, imported backups, Wi-Fi sync data, clipboard,
  intents (`docs/security.md` §3.1). Use parameterized SQL only.
- Store the master device key in `flutter_secure_storage` under alias `authenticator_key`; never in SharedPreferences.
- SQLite database fields (`secret`, etc.) are encrypted at rest with AES-256-GCM.
- Prevent data leakage: `FLAG_SECURE` screen protector enabled at startup in `main.dart`. It stays on unless the user turns off "Block screenshots" in Settings; the default is on, and sync or backup data must never change it.
- `android:allowBackup="false"` must remain in `AndroidManifest.xml`.
- Request only the permissions the app needs (`docs/security.md` §11).

---

## Localization rules

> **Localization is complete** (Phase 5, parts 5a–5d — see
> `plans/20261029_202317_localization-phase-5.md`). Every screen, including the features and help
> screens, takes its text from the ARB files. Help menu paths ("Settings → …") are built from the
> same keys as the real buttons, so they cannot drift apart.
> Providers and services hold no UI text: they return enums or codes (for example
> `SettingsProvider.unlockInstruction`, `SyncError.code`, `P2pSyncException.code`,
> `OpticalSyncException.code`), and system prompts get their text from the caller
> (`AuthService.authenticateWithPhoneLock(reason: …)`). Sync error codes become text in
> `lib/widgets/sync_error_text.dart`. Never show raw exception text (`'… $e'`) to the user.

- Declared languages (from `docs/PROJECT_PROFILE.md`): **English (`en`, template), Malayalam
  (`ml`), Sanskrit (`sa`)**. Every feature and every screen works in every declared language.
- All user-visible text comes from `lib/l10n/*.arb` via `AppLocalizations` — never a raw string literal in a widget.
- `l10n.yaml` (project root) and one ARB file per declared language (`app_<code>.arb`) must exist.
  Run `flutter gen-l10n` after editing any `.arb` file.
- Every new key goes into **every** declared language's file with a real translation. Never leave
  the English value sitting in the `ml` or `sa` file.
- Every ARB key needs an `@key` description entry in the template file.
- Language pack in force: `docs/guidelines/language_packs/sanskrit_malayalam.md` — follow its
  rules, gates and glossary. Flag any translation you are unsure of for review in the change log.
- `supportedLocales` equals the declared languages; a fallback delegate is installed for `sa`
  (engineering standard §8.3.1). Format dates and numbers with the `formattingLocale(...)` helper (§8.3.2).
- The language is user-selectable in Settings (System default + each language by its own name),
  saved (`app_language` in SharedPreferences, read before `runApp` by `LocaleProvider`), and applied
  without restarting the app.
- `MaterialApp` uses `LocaleConfig.localizationsDelegates` (`lib/config/locale_config.dart`), never
  the generated `AppLocalizations.localizationsDelegates` (it names the old SDK delegates).
- The app name is never an ARB key: it comes from `appName` in `assets/config/app_config.json`
  (English `Sreeraj P Authenticator`, Malayalam `ശ്രീരാജ് പി പ്രമാണീകാരി`, Sanskrit
  `श्रीराज पी प्रमाणीकारकः`) and matches the Android `strings.xml` files in
  `android/app/src/{dev,prod}/res/values*/`.
- Tests that guard these rules live in `test/l10n/` (parity, label length, Hindi markers,
  Sanskrit fallback).
- Menu, button, label, tab and tooltip strings stay short in every declared language (engineering
  standard §8.6); only `desc…`/`help…`/`empty…`/`error…`/`body…`/`aboutDetail…` keys may be long.
- Every icon-only control has a localized `tooltip:` (engineering standard §7.8).
- Material and Cupertino come from the `material_ui` / `cupertino_ui` packages (with a caret `^`
  constraint). Import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`
  (engineering standard §6.1).
- The About screen is data-driven and localized; it ends with the signature badge
  "Made with {heart} in India" (`docs/guidelines/guideline.md` §1.7).
- Literals are allowed only for logs, non-UI exception messages, asset paths, route names,
  map/JSON keys, `Semantics` test tags and developer-only screens.
- The one other source of user-visible text is the About-screen values in
  `assets/config/app_config.json` (locale maps, `docs/guidelines/guideline.md` §1). The app name
  comes from `appName` there and matches every platform's own files (§1.8).

---

## Code style / naming

- Files: `snake_case.dart`; Classes: `PascalCase`; Variables/methods: `camelCase`; Providers: `camelCase` + `Provider` suffix.
- Use `package:` imports (`package:sreerajp_authenticator/...`), avoiding relative imports in `lib/`.
- Run `dart format .` and maintain `flutter analyze` at zero warnings before every commit.

---

## Testing rules

- Mirror `lib/` structure in `test/` (e.g., `test/services/`, `test/models/`, `test/providers/`).
- Critical coverage areas: RFC 4226 / RFC 6238 OTP vector tests, AES-256-GCM encryption, database migrations, backup export/import, Wi-Fi sync and optical sync parsing, the localization parity test.
- Always run `flutter test` after code changes to ensure zero regressions.

---

## Dependency constraints

- Blocked dependencies: HTTP clients (`http`, `dio`), cloud SDKs (`firebase_*`), analytics (`mixpanel`, `amplitude`), crash reporting (`sentry`), ad networks (`google_mobile_ads`).
- Always check `pubspec.yaml` for transitive network/tracking packages before introducing any dependency. Full list: `docs/dependencies.md`.

---

## Where things live

```
CLAUDE.md            # Claude Code entry point & project rules
AGENTS.md            # same rules for other AI agents
GEMINI.md            # pointer for Gemini — read AGENTS.md
docs/                # design docs (Thin style); PROJECT_PROFILE.md; guidelines/ submodule (read-only)
plans/               # change proposals (yyyymmdd_hhMMss_<short-slug>.md)
change_log/          # implemented change logs (yyyymmdd_hhMMss_<short-slug>.md)
lib/                 # Flutter app source
test/                # unit and widget test suite
```

---

## Workflow rules (mandatory)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named
   `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to change, the issue,
   and the fix. Then **STOP and get explicit approval** before editing/creating/deleting any
   project file (other than the plan). A question or ambiguous reply is not approval.
   A plan that touches network, storage, sign-in, permissions, deep links, WebViews, platform
   folders or dependencies has a short **"Security impact"** line (engineering standard §22.2).
2. **Log after changing.** After implementing, write a change log to `change_log/` named
   `yyyymmdd_hhMMss_<short-slug>.md` describing what changed and referencing its plan.
3. **Relative paths & privacy only.** `plans/` and `change_log/` files are committed and may become
   public on the internet. They MUST use relative repository paths only (never absolute system
   paths like `C:\...`, `l:\...`, or `file:///...`). They MUST NOT contain any **local system
   details** — OS user name, computer/host name, home or drive-letter paths, network share names,
   LAN/internal IP addresses, local server URLs with ports, device serial numbers, personal email
   addresses — or any secret (API keys, tokens, passwords, keystore passphrases, credentials, PII).
   Write them as if a stranger will read them; nothing should reveal the machine they came from.
4. **The guidelines submodule is read-only.** `docs/guidelines/` is read-only. Never edit, pull,
   check out or commit the submodule or its version. If a guideline needs a change, write a note
   for the user instead (`docs/guidelines/DOCS_FOLDER_GUIDELINE.md` §1.1). If the folder is empty
   or missing, stop and ask the user.
5. **CI is checks only.** GitHub CI runs only `flutter pub get`, the format check,
   `flutter analyze`, `flutter test`, and other pass/fail check scripts. No Dependabot or other
   update bot: dependencies are updated by hand. CI never builds release artifacts, signs, holds
   signing secrets, uploads, or publishes. Release builds are done locally
   (`docs/guidelines/flutter_project_engineering_standard.md` §19).

Create `plans/` and `change_log/` if they do not exist.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and explanations in
  plain, simple English. Short sentences, common words. Explain any jargon you must use.

---

## What Claude must always / never do

**Always:**
- Read `CLAUDE.md`, `docs/PROJECT_PROFILE.md` and the referenced `docs/` before proposing changes.
- State target layers (`lib/providers/`, `lib/services/`, etc.) before adding classes.
- Run `flutter analyze` and `flutter test` to verify changes.
- Keep `lib/main.dart` clean and thin.
- After any Gradle build, run `android\gradlew --stop` and end leftover Gradle / Kotlin daemons.

**Never:**
- Log secrets, encryption keys, decrypted seeds, or PIN verifiers.
- Put SQL queries or encryption logic directly inside UI widget classes.
- Add network telemetry, analytics, or cloud-based SDKs.
- Edit generated or lock files manually (`pubspec.lock`).
- Create or edit platform folders that `docs/PROJECT_PROFILE.md` does not declare (`ios/`, `macos/`, `windows/`, `linux/`, `web/`).
