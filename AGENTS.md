# AGENTS.md — SreerajP Authenticator

This file is read by agents at the start of every session in this repository.
Read it before making any change. See the docs table below for full detail.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | SreerajP Authenticator |
| Type | Offline-first TOTP/HOTP two-factor authenticator app with AES-256-GCM vault, biometrics, and QR onboarding |
| Platform(s) | Android (primary target, minSdk 21, targetSdk 34), iOS (runner present), Windows (runner present) |
| Package / org id | `in.sreerajp.sreerajp_authenticator` |
| Flutter SDK | `^3.44.8` (or higher) |
| Dart SDK | `^3.12.2` (or higher) |
| State management | `Provider` + `ChangeNotifier` |
| Navigation | Named routes / `MaterialPageRoute` |
| Database | `sqflite` (encrypted fields) + `flutter_secure_storage` (AES key, PIN/recovery hashes) |
| Orientation | Portrait only (`SystemChrome.setPreferredOrientations`) |
| Connectivity | Fully offline — no internet backend / cloud account required |

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| `docs/architecture.md` | Changing structure, screens, state, services, models, database schema |
| `docs/security.md` | Touching permissions, biometrics, encryption, storage, logging, screen protection |
| `docs/release_process.md` | Building a release, versioning (`pubspec.yaml`), keystore signing, obfuscation |
| `docs/workflow_rules.md` | Proposing changes, approval workflow, writing plans and change logs |
| `docs/dependencies.md` | Adding or evaluating external packages and dependency constraints |
| `docs/project_structure.md` | Navigating directory trees and path responsibility boundaries |
| `docs/GUIDELINES_MANIFEST.md` | Reviewing the shared Flutter guidelines index |
| `docs/guidelines/flutter_project_engineering_standard.md` | Any code change — layers, naming, testing, accessibility |
| `docs/guidelines/flutter_build_flavors_guide.md` | Modifying Gradle configs, build flavors (`dev`/`prod`), signing |

---

## Hard rules (must follow — these override convenience)

1. Open source only. Commercial or source-available SDKs are prohibited. Check package licenses before adding.
2. Fully offline-first. The app operates 100% locally without cloud backends, tracking, or remote account requirements.
3. Scoped storage and zero telemetry. Never log secrets, keys, decrypted OTP data, or PIN hashes (even in debug builds).
4. Never crash on invalid QR codes or corrupted backups. Every parser must have a safe failure path with friendly user feedback.
5. Atomic / safe database writes. Encrypt secrets before writing to disk; plaintext exists transiently in memory only.

---

## Architecture rules

- Layout: Tier 1 layer-first under `lib/` (`config/`, `models/`, `providers/`, `screens/`, `services/`, `utils/`, `widgets/`, `main.dart`). Do not restructure without instruction.
- Layer boundaries: Widgets must not execute raw SQL, manage encryption keys, or handle file paths directly. Services must not depend on `BuildContext` or navigation routes.
- Dependency direction: `screens → providers → services → database/secure_storage → models`.
- Models are immutable data classes (`Account`, `Group`). Never mutate model properties in place.

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
  --obfuscate --split-debug-info=build/symbols/android-prod/ --split-per-abi

# Production Play Store bundle
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod/
```

---

## Build flavors

| Flavor | App ID | Display name | Signing |
|--------|--------|--------------|---------|
| dev | `in.sreerajp.sreerajp_authenticator.dev` | Sreeraj P Authenticator Dev | Debug keystore (automatic) |
| prod | `in.sreerajp.sreerajp_authenticator` | Sreeraj P Authenticator | Release keystore (`android/key.properties`) |

---

## Signing / keystore

- Release keystore file: `android/release-keystore.jks`. Keep offline backup.
- Configured via `android/key.properties` (gitignored — never commit).
- `.gitignore` includes: `key.properties`, `*.jks`, `*.keystore`, `build/symbols/`.

---

## Security rules

- Never log secrets, keys, PINs, or decrypted OTP seeds — even in debug builds (`debugPrint`-only).
- Store master device key in `flutter_secure_storage` under alias `authenticator_key`.
- SQLite database fields (`secret`, etc.) are encrypted at rest with AES-256-GCM.
- Prevent data leakage: `FLAG_SECURE` screen protector enabled at startup in `main.dart`.
- `android:allowBackup="false"` must remain in `AndroidManifest.xml`.

---

## Localization rules

- All user-visible text comes from `lib/l10n/*.arb` via `AppLocalizations` — never a raw string literal in a widget. This applies even though the app ships in a single language.
- `l10n.yaml` (project root) and `lib/l10n/app_<base>.arb` should be maintained. Run `flutter gen-l10n` after editing any `.arb` file.
- Every ARB key needs an `@key` description entry.
- Literals are allowed only for logs, non-UI exception messages, asset paths, route names, and map/JSON keys.

---

## Code style / naming

- Files: `snake_case.dart`; Classes: `PascalCase`; Variables/methods: `camelCase`; Providers: `camelCase` + `Provider` suffix.
- Use `package:` imports (`package:sreerajp_authenticator/...`), avoiding relative imports in `lib/`.
- Run `dart format .` and maintain `flutter analyze` at zero warnings before every commit.

---

## Testing rules

- Mirror `lib/` structure in `test/` (e.g., `test/services/`, `test/models/`, `test/providers/`).
- Critical coverage areas: RFC 4226 / RFC 6238 OTP vector tests, AES-256-GCM encryption, database migrations, backup export/import.
- Always run `flutter test` after code changes to ensure zero regressions.

---

## Dependency constraints

- Blocked dependencies: HTTP clients (`http`, `dio`), cloud SDKs (`firebase_*`), analytics (`mixpanel`, `amplitude`), crash reporting (`sentry`), ad networks (`google_mobile_ads`).
- Always check `pubspec.yaml` for transitive network/tracking packages before introducing any dependency.

---

## Where things live

```
AGENTS.md            # repository-specific automation rules & project rules
CLAUDE.md            # canonical agent entry point & project rules
docs/                # design docs & shared guidelines submodule (Thin profile)
plans/               # change proposals (yyyymmdd_hhMMss_<short-slug>.md)
change_log/          # implemented change logs (yyyymmdd_hhMMss_<short-slug>.md)
lib/                 # Flutter app source
test/                # unit and widget test suite
```

---

## Workflow rules (mandatory — from global rules)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named
   `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to change, the issue,
   and the fix. Then **STOP and get explicit approval** before editing/creating/deleting any
   project file (other than the plan). A question or ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to `change_log/` named
   `yyyymmdd_hhMMss_<short-slug>.md` describing what changed and referencing its plan.
3. **Relative paths & privacy only.** `plans/` and `change_log/` files are committed and may become
   public on the internet. They MUST use relative repository paths only (never absolute system
   paths like `C:\...`, `l:\...`, or `file:///...`). They MUST NOT contain any **local system
   details** — OS user name, computer/host name, home or drive-letter paths, network share names,
   LAN/internal IP addresses, local server URLs with ports, device serial numbers, personal email
   addresses — or any secret (API keys, tokens, passwords, keystore passphrases, credentials, PII).
   Write them as if a stranger will read them; nothing should reveal the machine they came from.

Create `plans/` and `change_log/` if they do not exist.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and explanations in
  plain, simple English. Short sentences, common words. Explain any jargon you must use.

---

## What AI agents must always / never do

**Always:**
- Read `AGENTS.md` and referenced `docs/` before proposing changes.
- State target layers (`lib/providers/`, `lib/services/`, etc.) before adding classes.
- Run `flutter analyze` and `flutter test` to verify changes.
- Keep `lib/main.dart` clean and thin.

**Never:**
- Log secrets, encryption keys, decrypted seeds, or PIN verifiers.
- Put SQL queries or encryption logic directly inside UI widget classes.
- Add network telemetry, analytics, or cloud-based SDKs.
- Edit generated or lock files manually (`pubspec.lock`).
