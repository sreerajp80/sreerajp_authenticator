# Claude Code Rules — SreerajP Authenticator

## Mandatory standards (read and apply)

For any work on this repository, treat the following documents as authoritative for their domains.
Consult them before architectural, build, release, or security-related changes, and ensure new
code and tests stay consistent with them.

| Document | What it governs |
|----------|-----------------|
| [`docs/architecture.md`](docs/architecture.md) | Tier 1 layout, path ownership, app init and lifecycle, offline behavior, state and data flow, persistence, navigation, schema version, logging as implemented, testing layout, operational constraints |
| [`docs/flutter_build_flavors_guide.md`](docs/flutter_build_flavors_guide.md) | `dev` / `prod` flavors, `--dart-define=FLUTTER_APP_FLAVOR`, Android signing and gitignore rules, R8/ProGuard, obfuscation and `--split-debug-info`, artifact choice (APK vs AAB), iOS/Windows notes where relevant |
| [`docs/flutter_project_engineering_standard.md`](docs/flutter_project_engineering_standard.md) | Applicability profiles (see below), structure and architecture baseline, UI/UX and accessibility, performance, error handling patterns, database migrations, testing and CI expectations, dependency and git hygiene |
| [`docs/release_process.md`](docs/release_process.md) | Versioning (`pubspec.yaml`), pre-release checks, prod build commands, signing, release checklist, evidence and distribution |
| [`docs/security.md`](docs/security.md) | Threat model, sensitive data inventory, storage and crypto rules, app lock and session policy, logging policy, permissions, OWASP alignment, backup/import/export, security testing and review checklist |

**Conflict resolution:** If the engineering standard or flavors guide disagrees with how this app
is documented to behave, follow **`docs/architecture.md`** and **`docs/security.md`** for this
repository. Use the engineering standard and flavors guide as the baseline; use the project docs
for app-specific facts (for example, `debugPrint`-only logging and the intentional omission of a
repository layer).

## Applicability profiles (this repository)

Per `docs/architecture.md` and `docs/security.md`, this app uses:

- **Core Baseline**
- **Production App Extension**
- **Sensitive Data Extension**

Use **`docs/flutter_project_engineering_standard.md`** for what those profiles imply (MUST /
SHOULD / MAY), subject to the conflict rule above.

## Project Overview

Flutter authenticator app (TOTP/HOTP) with AES-256-GCM encryption, biometric auth, and QR scanning.

## Commands

- **Run all tests:** `flutter test`
- **Run a specific test file:** `flutter test test/path/to/file.dart`
- **Build APK:** `flutter build apk` (use flavor and `dart-define` per `docs/flutter_build_flavors_guide.md` and `docs/release_process.md`)
- **Analyze code:** `flutter analyze`

## Testing

- **Always run `flutter test` after every code change** to verify nothing is broken.
- Tests live in `test/` mirroring `lib/` structure (e.g., `test/services/`, `test/models/`).
- OTP tests use RFC 4226 test vectors — do not change expected values.
- Encryption tests mock `FlutterSecureStorage` via platform channel mocks in `setUp`.
- When adding or modifying a service, add or update corresponding unit tests.
- Critical and regression areas are listed in `docs/architecture.md` and `docs/security.md`; extend
  tests when touching those flows.

## Architecture

Full detail: **`docs/architecture.md`**. In short:

- **State management:** Provider pattern (`lib/providers/`).
- **Services:** Business logic in `lib/services/` — encryption, OTP, database, auth.
- **Models:** `lib/models/` — `Account`, `Group`.
- **Encryption:** AES-256-GCM with 12-byte nonce. Legacy XOR and AES-CBC are decrypt-only for migration.
- **OTP:** Custom HMAC + dynamic truncation (RFC 4226/6238), not the `otp` package's generator.
- Respect path ownership (`config/`, `models/`, `providers/`, `screens/`, `services/`, `widgets/`,
  `utils/`). Document material init, schema, or boundary changes in `docs/architecture.md` when
  appropriate.

## Code Style

- Follow existing patterns — use `flutter_lints` rules.
- Keep services stateless where possible; use static methods in `OTPService`.
- Do not add comments, docstrings, or type annotations to unchanged code.
- Prefer `dart format` and zero new analyzer issues, as in the engineering standard.

## Security Rules

Full detail: **`docs/security.md`**. In short:

- Never log secrets, keys, or decrypted data (even in debug builds — see FIX_ORDER.md #2).
- Encryption key is stored in FlutterSecureStorage under alias `authenticator_key`.
- Secrets in the database are always encrypted; plaintext only exists transiently in memory.
- Do not weaken encryption (e.g., no ECB mode, no hardcoded keys, no disabling GCM auth tags).
- Production release hardening (obfuscation, symbols, permissions, debuggable) follows
  **`docs/release_process.md`** and **`docs/security.md`**.
