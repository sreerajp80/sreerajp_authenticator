# Close the remaining Android release blockers

**Plan:** `plans/20261031_181352_android-release-blockers.md`

## What changed

### Delete all data

- New `lib/services/data_wipe_service.dart`. It deletes the database, all secure storage, all
  preferences and the files in the cache, documents and support folders. Every step runs even if an
  earlier one failed.
- `DatabaseService.deleteAllData` closes and deletes the database.
- `SettingsProvider.deleteAllData` runs the delete, reads settings back from the empty stores and
  turns screenshot blocking back on.
- `AccountsProvider`, `ThemeProvider` and `LocaleProvider` gained a way to read their state again.
- `ClipboardService.clearPendingSecret` clears a copied secret right away.
- The Security screen has a new "Data" section. The check is the App PIN if one is set, otherwise the
  phone lock. If neither exists, the warning needs a ticked box. If the phone reports a lock but then
  has none to check, the warning is shown again with the box.
- 11 new ARB keys in `en`, `ml` and `sa`.
- New tests: `test/services/data_wipe_service_test.dart`,
  `test/screens/security_screen_delete_all_test.dart`, and one test in
  `test/services/clipboard_service_test.dart`.

### Privacy policy

- New `PRIVACY.md` at the repository root. `docs/PROJECT_PROFILE.md` §1 updated.

### Docs

- `docs/security.md`: §1.1 note, §7.1, §12 (M6 and the sign-off line), §13, §15, §17.
- `docs/features.md`: removed the debug helpers and the old backup claim; no version number is quoted
  now; corrected the permissions and bulk delete text; added the new action.
- `docs/release_process.md`: open-blockers note, §6.2 `-dontobfuscate` claim, parity test wording.
- `CLAUDE.md`, `AGENTS.md`: parity test wording.
- `docs/implementation_progress.md`, `docs/architecture.md`, `docs/project_structure.md`: new service.

### Old plans

Only the status line changed. 13 plans had a wrong status; 13 more used a spelling the rules do not
allow. The plan lists each one.

## Small differences from the plan

- The plan's heading said 15 wrong statuses, but its table lists 13. The heading was corrected.
- `docs/project_structure.md` was not in the plan's file list. It lists every service, so the new one
  was added.
- The plan said the owner would run the checks. They were run here as well, because `CLAUDE.md` says
  to always run `flutter analyze` and `flutter test`.

## Checks

- `dart format .`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 571 tests passed.

## Not done

- **Not run on a real phone.** The tests fake the phone lock, secure storage and file folders. Real
  behavior still needs the owner's test, described in the plan.
- **§12 is not signed off.** This is the owner's statement, to be made after the phone test.
- **`PRIVACY.md` is not pushed,** so the About screen link stays broken until it is on `main`.
- Absolute paths in 9 older plans and 9 older change logs are not fixed; the plan left them out.

## Translations to review

All 11 new `ml` and `sa` strings are drafts and need the translation reviewer. Please check these most
closely: `descDeleteAllDataWarning` and `descDeleteAllDataUnderstand` in both languages, and
`descAuthReasonDeleteAllData` and `errorDeleteAllDataFailed` in `sa`.
