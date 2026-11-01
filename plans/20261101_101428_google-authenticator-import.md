# Import accounts from Google Authenticator

**Status:** completed

**Security impact:** This adds a new parser for untrusted outside input that holds many secrets in one QR code. It adds no permissions, dependencies or network use. Secrets are encrypted with the existing `EncryptionService` path before saving. Parsed secrets stay in memory only until the import ends.

## The issue

The app can only add one account per QR code, or restore its own `.aes` backup (`docs/features.md`, known limits). Someone moving from Google Authenticator must set up every account again.

Google Authenticator exports accounts as one or more QR codes. Each holds an `otpauth-migration://offline?data=...` link. `OTPService.parseOtpAuthUri` rejects this link today, so the user only sees "invalid QR code".

## Scope

In scope: Google Authenticator export QR codes, scanned with the existing scanner.

Not in scope: Aegis, Bitwarden and CSV imports, next-code preview, clipboard changes. Each gets its own plan.

## Files to change

New:

- `lib/services/google_migration_service.dart`: decode and validate the QR data. No UI text.
- `lib/screens/google_import_review_screen.dart`: review and choose accounts.
- `test/services/google_migration_service_test.dart`
- `test/screens/google_import_review_screen_test.dart`
- `change_log/<timestamp>_google-authenticator-import.md`

Changed:

- `lib/screens/qr_scanner_screen.dart`: send migration links to the new flow and show batch progress.
- `lib/providers/account_provider.dart`: add a duplicate check for the review screen, using the same key as `importData`.
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`, and the generated `app_localizations*.dart` files.
- `lib/widgets/sync_error_text.dart` is not changed. The new error codes get their own small mapping in the review or scanner code.
- `test/providers/account_provider_test.dart`
- `docs/features.md`, `docs/architecture.md`, `docs/security.md`, `docs/feature_analysis_and_roadmap.md`
- The features and help text that says only `otpauth://` is supported (`descFeatures15` and any matching help keys).

## The fix

### 1. Parser (`lib/services/google_migration_service.dart`)

A small hand-written Protobuf reader. The format is simple, so no new dependency is needed.

Steps:

1. Check the link is `otpauth-migration://offline` with a `data` value. Reject input over a fixed size limit.
2. Base64-decode `data`. URL parsing can turn `+` into a space, so restore it first.
3. Read the outer message: accounts (field 1), batch size (3), batch index (4), batch id (5). Other fields are skipped by wire type.
4. Read each account: secret (1), name (2), issuer (3), algorithm (4), digits (5), type (6), counter (7).

Safety rules:

- Every length is checked against the bytes left before reading.
- A varint (Protobuf's variable-size number) is limited to 10 bytes.
- A broken outer message rejects that whole QR code, because the data can't be trusted.
- A broken or unsupported single account becomes a "problem" entry. The others still import.
- The service returns codes, not text: for example `notMigrationLink`, `malformedData`, `unsupportedAlgorithm`, `unsupportedType`, `missingSecret`.
- Decode errors are never logged with the exception object. `FormatException` can carry the source data, which here includes secrets. Only the code is logged.

Mapping to `Account`:

| Google value | App value |
|---|---|
| Secret (raw bytes) | Base32 text, the form the app stores |
| Name `Issuer:user` | Split if the issuer field is empty, otherwise strip a matching prefix |
| Algorithm unset, SHA1, SHA256, SHA512 | `SHA1`, `SHA1`, `SHA256`, `SHA512` |
| Algorithm MD5 | Problem entry |
| Digits unset, six, eight | 6, 6, 8 |
| Type TOTP | `totp`, period 30 (the format has no period field) |
| Type HOTP | `hotp`, counter kept |
| Type unset | Problem entry |

### 2. HOTP counter

The app stores the next unused value. Whether Google's number means the same must be checked with a real export using a throwaway HOTP account, as described under Verification. The mapping lives in one small function with a test. If Google's number means "last used", that function adds 1.

### 3. Scanner flow (`lib/screens/qr_scanner_screen.dart`)

- A link starting with `otpauth-migration://` goes to the new flow. All other QR codes behave exactly as they do now.
- Batches are matched on batch id. Scanning the same batch twice is ignored.
- A QR code from a different export shows a message and is not mixed in.
- The screen shows progress such as "Scanned 2 of 3". When all are scanned, it opens the review screen.
- The user can continue with the batches scanned so far, after a warning that some are missing.
- Scanned data is held only in the screen's state and dropped when the flow ends. Dart can't reliably wipe strings from memory, so this limits how long the data is kept but does not erase it.

### 4. Review screen (`lib/screens/google_import_review_screen.dart`)

- Lists each account by issuer and name. Secrets and codes are never shown.
- New accounts are selected by default.
- Accounts already in the app are marked and can't be selected. The match is the existing rule: name + issuer + type.
- Problem accounts are listed with a reason and can't be selected.
- Import button with the selected count, and a cancel button.
- After import, show how many were added and remind the user that HOTP accounts should no longer be used in the old app.
- Text comes from ARB files, icon-only controls have tooltips, and the layout works with screen readers.

### 5. Saving

Reuse `AccountsProvider.importData`, which already encrypts first and then calls `DatabaseService.createAccounts` in one transaction. The whole selection saves, or none of it does. The database assigns IDs. The timestamp ID used in the single-QR flow is not used, because accounts in a batch could get the same value.

### 6. Text

New keys go into all three ARB files with real translations and `@key` descriptions in the template. Labels stay short. Run `flutter gen-l10n`. Any uncertain Malayalam or Sanskrit translation is flagged in the change log.

### 7. Tests

Tests use hand-built data with fake secrets only.

Parser:

- One account, many accounts, each algorithm, digit size and type.
- Batch fields, including missing ones (treated as 1 of 1).
- Unknown fields are skipped.
- `+` handling in the link.
- Bad input never throws out of the service: empty data, bad Base64, cut-off data, a length larger than the data left, a varint that is too long, oversize input, invalid UTF-8 in names.
- HOTP counter is kept, including large values.
- Round trip: a known RFC 6238 secret given as raw bytes produces the expected code.

Provider and screen:

- Duplicate check matches `importData`.
- A failed save leaves no accounts.
- Review screen: selection, duplicates, problem entries, parity in all three languages (existing `test/l10n/` tests).

## Verification

Automated: `dart format .`, `flutter analyze`, `flutter test`.

Manual, on a device, with throwaway test accounts only:

1. Export one QR code and check the codes match Google Authenticator.
2. Export enough accounts to produce several QR codes, then test missing, repeated and out-of-order scans.
3. Export one HOTP account and check the next code matches. This settles the counter question.
4. Scan again and confirm everything shows as a duplicate.
5. Scan a normal `otpauth://` QR code and confirm it still works.
6. After the Gradle build, stop the Gradle and Kotlin daemons.

## Known limits

- Duplicates can only be skipped. There is no "keep both". Two accounts with the same name, issuer and type but different secrets will show as duplicates, and the user must add the second one by hand.
- Google's format supports only the values listed above, so Steam and other special types do not come through this path.
