# Clean up, fix the last bugs and release

**Status:** in_progress

## What the issue is

The owner decided the current features are enough. This plan freezes the features, fixes what a
read-only audit found and lists the release steps. No new features.

The audit read the build files, backup, encryption, database and account code, and the release docs.
It was not a full review of every file: sync, lock and screen code were not read line by line. The
phone test in Part 3 covers those flows by hand.

### Bugs found

| # | Problem | How it was checked | Harm |
|---|---|---|---|
| 1 | `android/app/build.gradle.kts` still uses `tool/generate_app_version.dart` and `lib/utils/app_version.g.dart`. The stale-code cleanup deleted both. The last APK was built before that cleanup | Read the files. Not yet proven by a build | Android builds are expected to fail |
| 2 | The mOTP PIN is kept as a number, so `0123` becomes `123` and the code is wrong. It is also stored without encryption in the `counter` column, which breaks hard rule 5 | Read `lib/services/otp_service.dart` | Wrong codes; an unencrypted secret on disk |
| 3 | If accounts fail to load, `AccountsProvider.loadAccounts` sets an empty list and gives no error. The home screen then looks like an empty vault | Read the provider and the home screen check | The user may think all accounts are lost |
| 4 | The backup share adds fixed English text from a service (`subject`, `text`), and services must hold no UI text | Read `lib/services/export_import_service.dart` | Small: English text in a shared message |

### Cleanup found

| # | Problem |
|---|---|
| 5 | 18 old plans and change logs contain local drive paths. One old plan has a sample LAN address. The rules ban both, and these files go public when pushed. (A 19th match is the newest release-blockers plan; it will be checked and changed only if it has a real path.) |
| 6 | Stale text: the Flutter template `TODO` in the Gradle file, and "(once added)" for the parity test in `CLAUDE.md` and `AGENTS.md` |

### Checked and found fine

- Keystore and `key.properties` are ignored by git and not tracked.
- The `.aes` file filter in the file picker does not fail. The installed version falls back to no
  filter for an unknown type. This was read in the plugin source, not run on a phone.
- No raw exception text is shown in widgets by the patterns searched. Logging goes through
  `AppLogger`.

### Known and left as they are

- Restoring a backup is not one single database transaction. If it stops midway, some accounts stay.
  Running it again is safe, because duplicates are skipped. No data is lost.
- An install older than database version 4 can no longer upgrade, because the cleanup removed that
  code on purpose. This only matters if someone still has a very old APK.
- The `.aes` filter does not limit what the picker shows. A wrong file gets the existing friendly
  error.
- Git history already pushed may hold old local paths. Rewriting public history is not part of this
  plan.

**Security impact:** removes a place where a secret was stored without encryption. Changes the
Android build file. Adds no permission, dependency or network use.

## Files to be changed

| Area | Files |
|---|---|
| Build | `android/app/build.gradle.kts` |
| mOTP removal | `lib/services/otp_service.dart`, `lib/models/account.dart` if needed, add-account widgets and screen, sync and backup validation if needed, help and features screens, `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`, generated `lib/l10n/`, related tests, `docs/features.md`, `docs/PROJECT_PROFILE.md` if needed |
| Load error | `lib/providers/account_provider.dart`, `lib/screens/home_screen.dart`, ARB files, tests |
| Share text | `lib/services/export_import_service.dart` |
| Cleanup | the old files in `plans/` and `change_log/` that contain local details, `CLAUDE.md`, `AGENTS.md`, `docs/implementation_progress.md`, `docs/release_process.md` |

`docs/guidelines/` is not touched.

## Plan for the fix

### Part 1: Claude makes the code changes

1. **Build:** remove the deleted script and file from `generateBuildMetadata`, and remove the
   template `TODO`.
2. **mOTP:** remove mOTP from the app. It is old, uses MD5 and is rarely used. A correct fix needs a
   new way to store the PIN in the encrypted field, through the add form, backup and sync, which
   means more new code just before a release. mOTP accounts in a backup or sync file, or in an
   `motp://` QR code, get the existing friendly "not valid" handling and never cause a crash.
   Alternative if the owner uses mOTP: keep it and do the larger fix.
3. **Load error:** add a `loadFailed` state to the provider. The home screen shows a clear error
   instead of the empty vault. One new ARB key in `en`, `ml` and `sa`, with a test.
4. **Share text:** remove `subject` and `text` from the share call.
5. **Cleanup:** replace local paths and the LAN address in old files with relative paths or
   placeholders, and fix the stale text.

### Part 2: checks

The owner runs these and reads the results with Claude:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

### Part 3: release, done by the owner with Claude's help

1. Commit all the work. More than 300 changed files are not committed yet. Do this before anything
   else, so work cannot be lost.
2. Increase `+BUILD` in `pubspec.yaml`, because build 28 already exists as an APK.
3. Build the hardened APK and bundle (`docs/release_process.md` §9), then stop the Gradle daemons.
4. Run the manifest and asset checks (`docs/release_process.md` §6.4 to §6.7).
5. Install on a real phone and test: scan a QR code, add an account, unlock, back up, restore, Wi-Fi
   sync, optical sync, and Delete all data. Also TalkBack and all three languages.
6. Review the draft `ml` and `sa` text, including the About badge.
7. Sign off `docs/security.md` §12 and archive the debug symbols outside the repository.
8. Push to `main`, so `PRIVACY.md` is live, and check that CI is green.
9. Release as a signed APK on GitHub first, then go through the Play Console checks. New personal
   Play accounts may have to run a closed test with testers before going public. Check the current
   Play rules and Android developer verification before starting.
10. Tag `vX.Y.Z`.

### After the release

Write the change log. New feature ideas wait for the next release.
