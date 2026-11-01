# Save backups with the system save screen

**Status:** completed

**Security impact:** Touches storage and dependencies. The backup stays encrypted with the
user's password. The user now picks one save location instead of handing the file to any app.
No new permission is needed. Removing `share_plus` also removes its `FileProvider` and its
leftover copy of the backup in `cache/share_plus/`.

## Files to change

- `lib/services/export_import_service.dart` — save through the system save screen.
- `lib/screens/home_screen.dart` — keep the app lock from firing during "export selected".
- `pubspec.yaml` and `pubspec.lock` (through `flutter pub get`) — remove `share_plus`.
- `test/services/` — add tests for saved, cancelled and failed results.
- `docs/features.md`, `docs/dependencies.md`, `docs/security.md` — replace the `share_plus` notes.

## The issue

Both problems come from using the Android share sheet (`share_plus`) to save a backup.

1. **The Files app is not offered.** The sheet lists only apps that accept a shared file. On the
   emulator these are apps like Quick Share, Drive and Gmail. The system Files app
   (`com.google.android.documentsui`) does not accept shared files, so it is not in the list.
   Files by Google is not installed on the emulator, so it could not be tested there.
2. **False success message.** Android tells the app only which app was chosen in the sheet. It
   does not tell the app whether that app finished the job.

Tested on the emulator:

| Action | Message shown | Correct? |
|--------|---------------|----------|
| Close the sheet without choosing an app | "Backup canceled or failed" | Yes |
| Choose Drive, then tap Cancel in Drive | "Backup created … saved successfully" | **No** |

The second case is dangerous. The user believes a backup exists when none does, and could later
lose access to their accounts.

The share sheet cannot report this, so a change to the message alone cannot fix it.

## The fix

1. In `exportAccountsEncrypted`, build the encrypted data as now, then call
   `FilePicker.saveFile` (already a dependency, used for restore). On Android this opens the system
   save screen (`ACTION_CREATE_DOCUMENT`). It returns the saved location, or `null` on cancel.
2. Return `true` only when a location comes back. The file is written by then, so "Backup created"
   is now true. The existing "canceled or failed" message covers cancel and errors.
3. Remove the temporary file step, since the data no longer needs to be written to the cache.
4. Add a small `@visibleForTesting` way to replace the save call, so tests can cover all three
   results.
5. Call `setBackupInProgress` around "export selected" on the home screen, as the backup screen
   does, so the app lock does not fire while the save screen is open.
6. Remove `share_plus`; this service is its only user.

## Downsides

- Gmail and Quick Share are no longer offered directly. The user saves first, then shares the file
  from a file manager. I think this is safer for a backup file, but it is one extra step.
- The save screen shows storage locations, not ordinary apps. Files by Google may not appear as a
  location inside it. A file saved to device storage (for example `Download`) can still be opened
  from Files by Google. Drive appears only if it is installed and signed in.

## Testing

- `flutter analyze`, `flutter test` and `dart format .`.
- On the emulator, using the dev flavor with a fake account:
  - save to `Download`: success message, and the file exists;
  - restore that file with its password: the account returns;
  - cancel the save screen: "canceled or failed" message;
  - "export selected" from the home screen: save and cancel, with no app lock during the save.
- After the build, stop the Gradle and Kotlin daemons.
