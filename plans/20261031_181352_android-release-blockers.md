# Close the remaining Android release blockers

**Status:** completed

## What the issue is

1. The app has no "Delete all data" action (engineering standard §15.4). This blocks every release.
2. `PRIVACY.md` does not exist, so the About screen link is broken. This blocks Google Play.
3. The OWASP list in `docs/security.md` §12 is not signed off.
4. Some docs and old plans are out of date.

**Security impact:** this change adds a way to delete the database, the master key, the PIN and
recovery verifiers, settings and cached files, behind a user check. It adds no permission, no
dependency and no network use.

## Files to be changed

| Area | Files |
|---|---|
| Delete all data, code | `lib/services/data_wipe_service.dart` (new), `lib/services/database_service.dart`, `lib/providers/settings_provider.dart`, `lib/providers/account_provider.dart`, `lib/providers/theme_provider.dart`, `lib/providers/locale_provider.dart`, `lib/services/clipboard_service.dart`, `lib/screens/security_screen.dart` |
| Delete all data, text | `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb`, generated `lib/l10n/app_localizations*.dart` |
| Delete all data, tests | `test/services/data_wipe_service_test.dart` (new), `test/providers/` (new or extended), `test/screens/security_screen_delete_all_test.dart` (new) |
| Privacy policy | `PRIVACY.md` (new), `docs/PROJECT_PROFILE.md` |
| Docs | `docs/security.md`, `docs/features.md`, `docs/release_process.md`, `docs/implementation_progress.md`, `docs/architecture.md`, `CLAUDE.md`, `AGENTS.md` |
| Old plans | Only the `**Status:**` line of the plans listed in part 4 |

`docs/guidelines/` is not touched.

## Plan for the fix

### Part 1: Delete all data

**Where it lives.** A new "Data" section at the bottom of the Security screen, always visible, with
one red "Delete all data" row. Layers: `SecurityScreen` → `SettingsProvider` → `DataWipeService`.

**Who must prove they are the owner.** The owner's rule: App PIN if one is set; if not, phone lock.

| State | Check |
|---|---|
| App PIN is set | App PIN, with the normal wrong-PIN count and lockout. Phone lock is not accepted here, because it is the weaker check and lockdown mode exists to block it |
| No App PIN, phone has a lock | Phone lock (fingerprint, face, pattern, PIN or password). Failed, canceled or locked out stops the delete |
| No App PIN, phone has no lock | Nothing can be checked, so a warning dialog with an "I understand this cannot be undone" checkbox is the only guard |

The last row is a gap the owner's rule did not cover. If the app refused here, the user could not
delete their data, which §15.4 requires. Anyone holding such a phone can already read the codes and
uninstall the app, so this adds no real risk. Bulk delete already allows the same case
(`bulkDeleteAllowedAfterPhoneLock`). The checkbox is used instead of a typed word, because typing a
word in Malayalam or Sanskrit is hard on many keyboards.

**The flow.**

1. Warning dialog: all accounts, PIN, recovery key and settings go; it cannot be undone; backup
   files saved elsewhere are not deleted; make a backup first.
2. The check from the table. The existing `showPinVerificationDialog` is reused for the PIN.
3. Auto-lock is paused during the delete (`setBackupInProgress`), so the phone-lock prompt cannot
   lock the app halfway.
4. Delete, then return to the home screen, now empty, with a short message.

**What is deleted, in this order.** Each step still runs if an earlier one failed.

| Order | What | How |
|---|---|---|
| 1 | Accounts database | Close it, then `deleteDatabase`, which also removes its side files |
| 2 | Master key, PIN and recovery verifiers, failed-attempt and lockout values | `FlutterSecureStorage.deleteAll()` |
| 3 | Settings, including language, theme and screenshot choice | `SharedPreferences.clear()` |
| 4 | Files in the app's cache, documents and support folders | Delete everything inside each folder |
| 5 | Memory | OTP cache, account list and selected tags, lock state and auto-lock timer; a code the app copied to the clipboard is cleared; running sync is stopped |

The database goes first: if that step fails, the key and PIN remain, so nothing is half lost and the
user can retry. If any step fails, the user sees a localized error and can retry. Raw exception text
is never shown or logged.

After the delete the running app matches a fresh install: theme and language follow the system, and
screenshot blocking is switched back **on** straight away. App lock is off.

**Limits, to be stated honestly in `docs/security.md` §13.** Flash storage may keep deleted bytes for
a while, but the secrets in them are encrypted and the key is gone. Files the user exported, and the
clipboard after the app is killed, are outside the app's reach. The wrapping key that
`flutter_secure_storage` keeps in Android Keystore may remain; it protects nothing after the delete.

**New text.** About 10 ARB keys (section title, row label and description, warning title and body,
checkbox, delete button, phone-lock reason, PIN purpose, done message, failed message), each with a
real `en`, `ml` and `sa` value and an `@` description in the template. Malayalam and Sanskrit are
flagged for review in the change log. Labels stay short (§8.6).

**Tests.**

- Service: every store is emptied; the database can be used again afterward; one failed step does
  not stop the others and is reported.
- Providers: state returns to defaults; screenshot blocking is back on.
- Screen, one test for each path: right PIN; wrong PIN; PIN during lockout; phone lock success,
  cancel and failure; no lock, with the delete button disabled until the box is ticked.
- All strings pass the existing `test/l10n/` checks.

### Part 2: `PRIVACY.md`

Add it at the repository root, in plain English: what the app stores and where; that nothing is
collected, shared or sold (no analytics, ads, crash reports, accounts or server); each permission and
why; when data leaves the device (only when the user starts a Wi-Fi sync, an optical transfer or a
backup export, encrypted each time); how to delete data (the new action, or uninstall); no special
handling for children because nothing is collected; how changes are announced; and the public support
contact from `docs/PROJECT_PROFILE.md` §1. It must agree with the in-app privacy dialog and with what
the Play Data safety form will say.

The URL is already in `assets/config/app_config.json`, so no code changes. **The link stays broken
until this file is pushed to `main`.** I do not push unless the owner asks.

Clear the `TODO` in `docs/PROJECT_PROFILE.md` §1. This text is a plain description of the app, not
legal advice.

### Part 3: Security sign-off

- Update `docs/security.md`: §3 and §4 where needed; §13 (retention table and purge section now
  describe the real action); §17 (remove the blocker).
- Review every §1.1 and §12 line against the code again, including the new action.
- **I do not write the sign-off itself.** It is a statement by the release owner (`Signed by / date`,
  `docs/release_process.md` §14), and it depends on the phone test below. I leave the list ready and
  the line reading "ready for owner sign-off". When the owner confirms the test passed and says to
  sign, I record the name and date.

Phone test for the owner, on a dev build: try all three check paths; after a delete, confirm the home
screen is empty, restart the app, and confirm no lock is asked for and adding an account works.

### Part 4: Out-of-date docs and old plans

**`docs/features.md`**

- Remove the debug-helper bullet (§2): `generateTimeWindowCodes` and `compareSecrets` no longer exist
  in `lib/`.
- Replace the "older backup formats can still be read" bullet (§5): only the current `v3` format is
  read (`docs/security.md` §6).
- §7: stop quoting a version number. Point to `pubspec.yaml`, so this cannot go stale again.
- Also found: §6a and §8 list `ACCESS_NETWORK_STATE` and `ACCESS_WIFI_STATE`, which the manifest does
  not grant; §3 says bulk delete is "at the data layer", but it has a screen flow now.
- Add "Delete all data" (§4).

**`docs/release_process.md`**

- Rewrite the open-blockers note: Phase 5 and 7 are done; list only what is still true.
- Also found: §6.2 says the rules file has `-dontobfuscate`. It does not (`docs/security.md` §8.2 is
  right).
- §8: drop "once added" from the parity test line. `CLAUDE.md` and `AGENTS.md` have the same words in
  their testing rules.

**`docs/implementation_progress.md` and `docs/architecture.md`:** record the new action and service.

**Old plans: wrong status (13).** Only the status line changes.

| Plan | Now | New | Why |
|---|---|---|---|
| `20260801_202000_steam-guard…` | Approved | `completed` | Change log exists |
| `20260801_204500_fix-home-screen-reorder…` | Approved | `completed` | Change log exists |
| `20260801_204700_brand-icons…` | Proposed | `completed` | Change log exists |
| `20260801_204900_remove-groups…` | Approved — implementing | `completed` | Change log exists |
| `20260801_213000_tag_filtering…` | Approved | `completed` | Change log exists |
| `20260801_213500_mark_completed_roadmap…` | Proposed | `completed` | Change log exists |
| `20260801_214000_optical_airgap_sync` | Proposed | `completed` | Change log exists |
| `20260803_083619_update_features_doc` | Proposed / Pending Approval | `completed` | Change log exists |
| `20260811_214811_bulk_selection…` | Proposed | `completed` | Change log exists |
| `20260811_220600_optical_sync_duration…` | Proposed / Pending Approval | `completed` | Change log exists |
| `20261029_183929_adopt-updated-guidelines` | in_progress | `completed` | All 8 phases are done |
| `20260803_084400_features_doc_critical_analysis` | Proposed | `dropped` | No change log; later audit plan `20260803_084908` did this work |
| `20260811_213330_flutter-3-44-8-upgrade` | Proposed | `partial_completion` | No change log, but the docs did move to 3.44.8; replaced by the later toolchain upgrade |

That is 13 rows that change meaning. **Spelling only (13 more):** these are finished but use a value
the rules do not allow, so they become `completed`:

- `Implemented`: `20260801_201500`, `20260801_212000`, `20260819_184500`, `20260819_202100`,
  `20260820_204500`
- `Completed` or `COMPLETED`: `20260803_084908`, `20260811_213730`, `20260819_190100`,
  `20260819_190300`, `20260824_214800`, `20260829_063800`
- `Approved & Implemented`: `20260811_221103`, `20260812_191954`

## How this is checked

`dart format .`, `flutter gen-l10n`, `flutter analyze` (zero issues) and `flutter test`. By the
learning-first rule, the owner runs these and the phone test unless they ask me to run them.

## Not in this plan

- **Absolute paths in committed files.** 9 plans and 9 change logs contain paths like `<absolute-link>`,
  and the GitHub repo page is public. This breaks workflow rule 3 and shows a local drive letter. It
  needs separate approval, because it edits history files widely. Removing it from new commits does
  not remove it from git history.
- Help or FAQ text about the new action. The Security screen row and its warning explain it.
- Pushing or committing.
