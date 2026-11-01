# Import accounts from Google Authenticator

Implements `plans/20261101_101428_google-authenticator-import.md`.

## What changed

- **New parser:** `lib/services/google_migration_service.dart` reads `otpauth-migration://` QR codes with a small hand-written Protobuf reader. No new dependency. Every length is checked, and errors hold codes only, never scanned data. It also holds `GoogleMigrationCollector`, which gathers the QR codes of one export in any order.
- **New review screen:** `lib/screens/google_import_review_screen.dart` lists the accounts found, marks duplicates and problem entries, and saves the chosen ones through `AccountsProvider.importData`, in one transaction.
- **Scanner:** `lib/screens/qr_scanner_screen.dart` sends migration links to the new flow, shows "Scanned X of Y", and lets the user continue with part of an export after a warning. Other QR codes behave as before.
- **Provider:** `lib/providers/account_provider.dart` now exposes `duplicateKey` and `existingDuplicateKeys`, and `importData` uses them, so the review screen and the import apply the same rule.
- **Text:** 18 new keys in the English, Malayalam and Sanskrit ARB files, plus an updated `descFeatures15`. Generated files were rebuilt.
- **Docs:** `docs/features.md`, `docs/security.md`, `docs/architecture.md`, `docs/feature_analysis_and_roadmap.md`.
- **Tests:** `test/services/google_migration_service_test.dart`, `test/services/google_migration_test_data.dart` (shared fake data), `test/screens/google_import_review_screen_test.dart`, and new groups in `test/providers/account_provider_test.dart`.

## Differences from the plan

- Added one problem type, `shortSecret`. The app needs a Base32 secret of at least `AppConstants.minSecretLength` characters, so a shorter one is shown as a problem instead of being imported.
- The code check uses an RFC 4226 HOTP value (counter 1 gives `287082`) instead of an RFC 6238 value. It tests the same secret path and needs no clock.

## Verification

- `dart format` on the changed files: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 753 tests pass.

**Not done yet:** the manual device tests in the plan. No APK was built and no real Google Authenticator export was scanned. This means the following are still unconfirmed:

- Whether Google's HOTP counter means "next unused", as the app stores it. `GoogleMigrationService.counterFromGoogle` assumes so, and any change belongs in that function.
- The real export format, because all test data is hand-built from the format as publicly described.

## Translations to review

All new Malayalam and Sanskrit text needs review by a reader of those languages. The least certain terms are:

- Malayalam: `ഇറക്കുമതി` for "import", and the loan word `എക്സ്പോർട്ട്` in `errorMigrationOtherExport` and `descFeatures15`.
- Sanskrit: `विवरणानयनम्` and `आनीयताम्` for "import", `निर्यातात्` for "from an export", `गणकाधारित` for "counter-based", `विसंवदिष्यन्ति` for "will no longer match", and `गणनविधिः` for "algorithm".

## Known limits

- Duplicates can only be skipped, using name + issuer + type. An account that matches on all three but has a different secret must be added by hand.
- Dart can't reliably wipe strings from memory. Scanned data is dropped when the flow ends, but not erased.
