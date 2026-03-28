# Claude Code Rules — SreerajP Authenticator

## Project Overview

Flutter authenticator app (TOTP/HOTP) with AES-256-GCM encryption, biometric auth, and QR scanning.

## Commands

- **Run all tests:** `flutter test`
- **Run a specific test file:** `flutter test test/path/to/file.dart`
- **Build APK:** `flutter build apk`
- **Analyze code:** `flutter analyze`

## Testing

- **Always run `flutter test` after every code change** to verify nothing is broken.
- Tests live in `test/` mirroring `lib/` structure (e.g., `test/services/`, `test/models/`).
- OTP tests use RFC 4226 test vectors — do not change expected values.
- Encryption tests mock `FlutterSecureStorage` via platform channel mocks in `setUp`.
- When adding or modifying a service, add or update corresponding unit tests.

## Architecture

- **State management:** Provider pattern (`lib/providers/`).
- **Services:** Business logic in `lib/services/` — encryption, OTP, database, auth.
- **Models:** `lib/models/` — `Account`, `Group`.
- **Encryption:** AES-256-GCM with 12-byte nonce. Legacy XOR and AES-CBC are decrypt-only for migration.
- **OTP:** Custom HMAC + dynamic truncation (RFC 4226/6238), not the `otp` package's generator.

## Code Style

- Follow existing patterns — use `flutter_lints` rules.
- Keep services stateless where possible; use static methods in `OTPService`.
- Do not add comments, docstrings, or type annotations to unchanged code.

## Security Rules

- Never log secrets, keys, or decrypted data (even in debug builds — see FIX_ORDER.md #2).
- Encryption key is stored in FlutterSecureStorage under alias `authenticator_key`.
- Secrets in the database are always encrypted; plaintext only exists transiently in memory.
- Do not weaken encryption (e.g., no ECB mode, no hardcoded keys, no disabling GCM auth tags).
