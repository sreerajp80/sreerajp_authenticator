# Localization Part 5c — security, backup and sync

**Status:** completed

Part 5c of `plans/20261029_202317_localization-phase-5.md` (master plan
`plans/20261029_183929_adopt-updated-guidelines.md`, Phase 5).

**Security impact:** none to data, storage, network or permissions. Error handling changes only
in what the user sees: raw exception text (`'Sync failed: $e'`, `'Error restoring backup: $e'`,
…) is replaced by localized messages. The sync wire format, crypto, caps and timeouts do not
change. Logs keep the error type only (`AppLogger` already logs only `runtimeType`).

## What the issue is

The security, backup, tag-management and sync screens still show English literals under `ml`
and `sa`. Some of their text also comes from lower layers, and some is raw exception text:

- `SyncProvider` puts English sentences into `SyncError(String message)`, several with `$e`
  (`'Sync failed: $e'`, `'Could not start hosting: $e'`, `'Optical sync decoding failed: $e'`).
  `sync_screen.dart` and `optical_sync_screen.dart` show `state.message` as is.
- `P2pSyncException` (25 places) and `OpticalSyncException` (12 places) carry English messages.
  `sync_qr_scanner_screen.dart` shows `e.message` directly; the others reach the UI through
  `SyncError('… $e')`.
- `backup_restore_screen.dart` shows `'Error creating backup: $e'` and
  `'Error restoring backup: $e'`; `ExportImportService` throws
  `Exception('Invalid password or corrupted file')`, which reaches that text.
- `security_screen.dart` has its own copy of the phone-lock error mapping (the lock screen's was
  migrated in 5b).

## Scope

| File | Approx. strings |
|---|---|
| `lib/screens/security_screen.dart` | 81 |
| `lib/screens/backup_restore_screen.dart` | 48 |
| `lib/screens/sync_screen.dart` | 38 |
| `lib/screens/send_to_device_screen.dart` | 32 |
| `lib/screens/tag_management_screen.dart` | 26 |
| `lib/screens/optical_sync_screen.dart` | 24 |
| `lib/screens/sync_qr_scanner_screen.dart` | 4 |
| Error texts from `SyncProvider`, `P2pSyncService`, `OpticalSyncService`, `ExportImportService` | ~45 (become codes) |

`otp_service.dart`, `encryption_service.dart`, `database_service.dart` exception texts are not
shown in any screen (checked: `account_tile.dart` keeps `OTPException` only for state). They stay
as internal English messages, which the rules allow.

## Plan for the fix

### Error codes instead of English text (lower layers)
- `P2pSyncException` and `OpticalSyncException` get a required `code` (a new enum each, for
  example `P2pSyncErrorCode.notSyncQr`, `unsupportedVersion`, `missingHost`, `invalidPort`,
  `missingCode`, `malformedPayload`, `tooManyAccounts`, `fieldTooLarge`, `peerGone`,
  `sendFailed`, …; `OpticalSyncErrorCode.invalidFrame`, `checksumMismatch`, `incomplete`,
  `integrityFailed`, …). The English `message` stays for logs and tests.
- `SyncError` holds a `SyncErrorCode` (`hostTimeout`, `hostStartFailed`, `noDeviceConnected`,
  `nothingSelected`, `syncFailed`, `opticalStartFailed`, `opticalDecodeFailed`) and, when the
  cause was a `P2pSyncException` / `OpticalSyncException`, its code too. No `$e` in any text.
- `ExportImportService` throws a typed `BackupPasswordException` for "invalid password or
  corrupted file" instead of a plain `Exception` with English text.
- Each screen maps codes to ARB text in one small function (`_syncErrorText(l10n, error)`).

### Screens
- Move every user-visible string in the files above to ARB (`en`, `ml`, `sa`), with `@key`
  descriptions and the key prefixes. Existing tooltips move too; new tooltips are Phase 6.
- `security_screen.dart` reuses the 5b keys for phone-lock errors (`errorPhoneLock…`) and the
  shared actions (`actionCancel`, `actionOk`, …).
- `sync_qr_scanner_screen.dart` shows the localized text for the exception code.
- Counts in text use placeholders without plural forms (as in 5b), for example
  "Accounts restored: {count}".

### Files to be changed
- The screens in the scope table.
- `lib/providers/sync_provider.dart`, `lib/services/p2p_sync_service.dart`,
  `lib/services/optical_sync_service.dart`, `lib/services/export_import_service.dart`.
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`; generated `app_localizations*.dart`.
- Tests: `test/services/p2p_sync_service_test.dart` and `optical_sync_service_test.dart` (check
  the `code` of thrown exceptions, not only the type), `export_import_service_test.dart` (typed
  exception), `test/screens/tag_management_screen_test.dart` and any other widget test that pumps
  these screens (localization delegates). New: a test that every `SyncErrorCode`,
  `P2pSyncErrorCode` and `OpticalSyncErrorCode` has distinct non-empty text in `en`, `ml`, `sa`;
  a widget test that pumps the security screen in all three languages without overflow.
- `CLAUDE.md`, `AGENTS.md` (migration status), `docs/implementation_progress.md` (tick 5c),
  `docs/security.md` §3.1 only if an entry-point description changes (not expected).

### Steps
1. Codes in the exceptions, `SyncError` and the backup service; update their tests.
2. Migrate the screens, one at a time; keys go into all three ARB files together.
3. `flutter gen-l10n`, `dart format` on changed files, `flutter analyze`, `flutter test`.
4. Build `flutter build apk --flavor dev --debug`; stop Gradle daemons.
5. Docs; change log with the full English / Malayalam / Sanskrit table marked
   "needs native-reader review"; set this plan to `completed`.

## Translations

Drafts by me, following the language pack (glossary §4.4, Sanskrit §4.1, Malayalam §4.2), and the
security terms drafted in 5b (PIN in Latin letters, recovery key, phone lock, password). Every
string is listed for review. Terms that are missing from the glossary are listed again as
"glossary gaps".

## Risks

- The sync code is security-sensitive. This part changes only how errors are reported, not what
  is checked. The existing sync tests (wrong pairing code, payload caps, loopback transfer) must
  still pass unchanged apart from the new `code` assertions.
- `security_screen.dart` is long (800+ lines) with many dialogs; text-only changes, covered by the
  new widget test and your on-device check.
