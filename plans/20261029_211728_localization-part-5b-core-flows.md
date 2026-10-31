# Localization Part 5b — core flows

**Status:** completed

Part 5b of `plans/20261029_202317_localization-phase-5.md` (master plan
`plans/20261029_183929_adopt-updated-guidelines.md`, Phase 5).

**Security impact:** none to data, storage, network or permissions. The lock screen and the
biometric / phone-lock prompts change only where their text comes from. One behavior fix: the QR
scanner no longer shows raw exception text to the user (it showed `Error: <exception>`); it shows
a friendly message and logs the error without secrets.

## What the issue is

Part 5a built the localization setup. The core screens still show English literals under `ml`
and `sa`. Some of their text also comes from the wrong layer:

- `SettingsProvider.unlockInstructionText` and `pinRequiredMessage` return English sentences.
  Providers must not hold UI text.
- `AuthService.authenticateWithBiometric()` / `authenticateWithPhoneLock()` pass English
  `localizedReason` text to the system prompt. Services must not hold UI text, and the system
  prompt must follow the chosen language.
- `qr_scanner_screen.dart` shows `'Error: ${e.toString()}'` in a snackbar (twice). That breaks
  hard rule 4 (friendly feedback on bad input) and can show internal details.
- `permissions_screen.dart` builds status text ("Granted", "Denied", …) in the widget.

## Scope (about 260 strings)

| File | Approx. strings |
|---|---|
| `lib/screens/lock_screen.dart` | 56 |
| `lib/screens/home_screen.dart` | 49 |
| `lib/screens/add_account_screen.dart` | 31 |
| `lib/screens/qr_scanner_screen.dart` | 22 |
| `lib/screens/permissions_screen.dart` | 22 |
| `lib/widgets/add_account/` (`advanced_settings_card`, `account_info_card`, `browse_tags_bottom_sheet`, `tag_autocomplete_field`) | 40 |
| `lib/widgets/home/` (`home_tag_cloud_view`, `home_empty_state`, `home_fab_button`, `home_tag_filter_bar`, `home_search_bar`) | 22 |
| `lib/widgets/pin_verification_dialog.dart`, `lib/widgets/account_tile.dart` | 15 |
| `lib/widgets/account_tile/*` | 0 (checked) |

Technical text stays literal: OTP algorithm names (`SHA1`, `SHA256`, …), the `otpauth://` URI
format, digit counts shown as numbers, and the `------` placeholder.

## Files to be changed

- The files in the table above — every user-visible string to ARB. Existing `tooltip:` values in
  these files move to ARB too (`tooltip…` keys). Adding tooltips to icon-only buttons that have
  none is Phase 6, not this part.
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` — the new keys, with `@key` descriptions and
  the prefix rules; `app_localizations*.dart` regenerated.
- `lib/providers/settings_provider.dart` — replace `unlockInstructionText` with an enum getter
  `unlockInstruction` (`setUpPinWithPhoneLock`, `phoneLockOnly`, `phoneLockOrPin`, `pinOnly`).
  Remove `pinRequiredMessage`; the screen maps the existing `PinRequiredReason` to ARB text.
- `lib/screens/lock_screen.dart` — maps those enums to `AppLocalizations`.
- `lib/services/auth_service.dart` — `authenticateWithBiometric({required String reason})` and
  `authenticateWithPhoneLock({required String reason})`: the caller passes the localized prompt
  text. Callers: `lock_screen.dart`, `home_screen.dart`, and `security_screen.dart` (Part 5c
  screen; only the two call sites change, with two new ARB keys).
- `lib/screens/qr_scanner_screen.dart` — the two `catch` blocks show a localized
  "could not read this QR code" message and log through `AppLogger` (no secret or payload in the
  log).
- Tests: `test/providers/settings_provider_test.dart` (enum instead of English text),
  `test/services/auth_service_test.dart` and `test/widgets/security_auth_widgets_test.dart` (new
  `reason` parameter), `test/widgets/home/home_widgets_test.dart` and
  `test/widgets/add_account/tag_autocomplete_field_test.dart` (localization delegates; run in
  `en`, `ml`, `sa` where they check text). New: a lock-screen widget test that pumps the screen in
  all three languages with no exception and no overflow.
- `CLAUDE.md`, `AGENTS.md` — the "migration in progress" note lists 5b screens as migrated.
- `docs/implementation_progress.md` — tick Part 5b.

Not changed: services and providers used only by 5c screens (`p2p_sync_service`,
`optical_sync_service`, `sync_provider`, `export_import_service`); `otp_service` exception texts
(they are not shown on the 5b screens — confirmed by grep; checked again in 5c).

## Plan for the fix

1. Provider and service changes (enum getter, `reason` parameter) and their tests.
2. Migrate the screens and widgets file by file; add keys to all three ARB files at the same time
   (the parity test fails otherwise).
3. QR scanner error handling.
4. `flutter gen-l10n`, `dart format` on changed files, `flutter analyze`, `flutter test`
   (including `test/l10n/`).
5. Build `flutter build apk --flavor dev --debug`; stop Gradle daemons.
6. Docs; change log with the full English / Malayalam / Sanskrit table marked
   "needs native-reader review"; set this plan to `completed`.

## Translations

Drafts by me, following the language pack glossary (§4.4), the Sanskrit rules (§4.1: `-ताम्`
imperatives on buttons, nominal titles, no Hindi markers) and the Malayalam rules (§4.2: `-ക്കുക`
verbs on buttons, `അതെ` / `ഇല്ല`, atomic chillu). Every string is listed for your review.

## Risks

- `lock_screen.dart` and `home_screen.dart` are large (1,000+ lines each). The change is text only,
  but a wrong mapping could show the wrong instruction on the lock screen. The provider test and
  the new lock-screen test cover each enum value.
- Long Malayalam / Sanskrit text on buttons may wrap. The label-length test catches short keys;
  the rest needs your on-device look.
