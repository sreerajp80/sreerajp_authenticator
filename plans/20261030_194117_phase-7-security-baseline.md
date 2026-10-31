# Phase 7: Security Baseline check

**Status:** completed

Phase 7 of `plans/20261029_183929_adopt-updated-guidelines.md` (rules G11, G12). Rules:
`docs/guidelines/flutter_project_engineering_standard.md` §15.1, §15.2, §15.3.

**Security impact:** high. This plan changes the Android manifest (permissions, backup rules,
cleartext setting), backup import checks, clipboard handling and app startup. It adds no dependency.
It tests whether Google ML Kit sends data off the device.

## What the issue is

`docs/security.md` §1.1, §3.1 and §12 still have `to verify` lines. I read the code and the merged
Android manifests. Some lines already pass, but these gaps need fixing.

### 1. Google ML Kit (closed source, may send data)

`mobile_scanner` brings in ML Kit on Android to decode QR codes. The merged prod manifest includes
`com.google.mlkit` and `com.google.android.datatransport` with `CctBackendFactory`, which is Google's
log-sending system. This conflicts with hard rule 1 (open source only) and may conflict with hard
rule 3 (zero telemetry). `docs/security.md` §4 and text in the app say no data is sent. That is not
proven. Whether ML Kit really sends data has not been tested.

### 2. Backup and transfer settings

- `android:dataExtractionRules` is missing. On API 31+, `allowBackup="false"` does not stop
  device-to-device transfer.
- `android:usesCleartextTraffic="false"` is not set (`docs/release_process.md` §6.5).

### 3. Permissions

**Owner decision: remove these from our manifest if the check shows they are not needed.** Checked:
`lib/`, `android/app/src/`, `pubspec.yaml`, the Android source of all 13 plugins, and the manifest
merge reports (which show who asks for each permission).

| Permission | Who asks for it | Used by our code or plugins? | Result of removing our line |
|---|---|---|---|
| `ACCESS_WIFI_STATE` | Only our manifest | No | Gone from the app |
| `ACCESS_NETWORK_STATE` | Our manifest and ML Kit's `transport-backend-cct` | No | Stays until ML Kit is replaced, then gone |
| `USE_FINGERPRINT` | Our manifest and `androidx.biometric` 1.1.0 | No | Stays, because the library that app lock uses adds it |

So app lock does not depend on our line. The biometric library keeps what it needs, and
`USE_BIOMETRIC` also stays. Optical sync does not call the network code. Wi-Fi sync reads its IP with
`NetworkInterface.list`, and no plugin or our code uses `WifiManager` or `ConnectivityManager`.

Not proven: nothing has been run without these lines yet, and the Dart runtime's own network code was
not read. A real phone test is required (Step 2). `USE_FINGERPRINT` is not stripped from the library's
list, because that would change how the library is meant to work and gains little.

`INTERNET` must stay for Wi-Fi sync. The merge report shows ML Kit's transport library also asks for
it, which supports the concern in section 1.

### 4. Backup import

`ExportImportService.importAccountsEncrypted`:

- reads the whole file with no size check (§15.1 says check size before parsing);
- has no limits on account count or field length, though Wi-Fi sync has them;
- catches its own `BackupPasswordException`, so a wrong password shows the general "no data imported"
  message;
- returns `null` when the user cancels the file picker, so cancelling also shows an error.

### 5. Clipboard

- The recovery key (`lib/screens/security_screen.dart`, `lib/screens/lock_screen.dart`) and the
  pairing code (`lib/screens/send_to_device_screen.dart`) stay on the clipboard with no time limit.
  §15.2 says clipboard use for secrets should be time-bounded or explicitly communicated.
- Copied codes are not marked as sensitive, so Android 13+ can show them in its clipboard preview.

### 6. Startup on Windows and Linux

`lib/main.dart` awaits `ScreenProtector` calls with no guard. `screen_protector` 1.4.2 declares only
Android and iOS, so from reading the code these calls should throw before `runApp` on desktop. This
has not been run. `docs/security.md` §10 also does not record that desktop has no screen protection.

### 7. Wrong text shown to users

These say the app never uses a network or uses a storage permission. Both are wrong:
`descPrivacyPermissions`, `descPrivacySecurity`, `labelNoInternetAccess`, `descNoInternetAccess`,
`descPrivacyStorage`. Any "no analytics" wording (`helpFaq14`, `descFeatures51`) must match the ML Kit
test result.

### 8. Wrong docs

- `docs/security.md` §8.2 says `proguard-rules.pro` has `-dontobfuscate`. It does not.
- `docs/security.md` §4 and `docs/dependencies.md` do not list ML Kit or the Google data transport.

## Already checked by reading the code

These still get a final check during the work, then their status is set in `docs/security.md`.

| Rule | Finding so far |
|---|---|
| Git-tracked key files | Only `android/key.properties.example`; `.gitignore` covers keys and `build/` |
| Network clients | No `HttpClient`, `badCertificateCallback` or `HttpOverrides` in `lib/` |
| Parameterized SQL | All queries use `whereArgs` or `?`; other SQL is fixed text with no input |
| Randomness | `Random.secure()` and `SecureRandom` only |
| Logs | `AppLogger` runs in dev only and logs only the error type |
| Secrets in storage | Device key and verifiers use `flutter_secure_storage` |
| Exported components | Launcher activity, plus `ProfileInstallReceiver` from AndroidX (check that it needs the `DUMP` permission) |
| Debuggable | Not set in the old prod manifest; must be checked on a fresh build |

## Plan for the fix

### Step 1: test ML Kit

1. Build a fresh prod release and read its final manifest and APK contents.
2. Run it on an Android emulator with a full network capture (`emulator -tcpdump`).
3. Scan a test QR code with a made-up secret, then force pending background jobs to run with
   `adb shell cmd jobscheduler run`.
4. Look in the capture for any connection other than the emulator's own system traffic, including
   Google logging hosts.
5. Record what was tested and the result in `docs/security.md` §4.

How to read the result: a capture with no traffic shows only that nothing was sent during that test,
not that nothing will ever be sent. So if the data transport is still in the APK, the app's text will
not claim "no third-party data sending" and M2 and M6 stay open until ML Kit is removed.

Replacing ML Kit is **not** part of this plan. At the end of Phase 7 I write a separate plan for it,
with its own approval. It compares open source decoders (first `flutter_zxing`) on licence, platforms
and optical sync speed.

### Step 2: Android manifest

- Add `android/app/src/main/res/xml/data_extraction_rules.xml`, which excludes everything from
  `<cloud-backup>` and `<device-transfer>`, and link it from the manifest.
- Set `android:usesCleartextTraffic="false"`. Wi-Fi sync uses raw sockets, so this should not affect
  it, but it must be tested.
- Remove `ACCESS_WIFI_STATE`, `ACCESS_NETWORK_STATE` and `USE_FINGERPRINT` from our manifest and
  correct its comment (section 3). Read the new merged manifest and record in `docs/security.md` §11
  what remains and which library adds it.
- Keep these removals easy to undo. If the phone test shows the wrong IP (`127.0.0.1`) or app lock
  fails, the line comes back and the reason is recorded.

### Step 3: backup import

- In `lib/utils/constants.dart`, add a file size limit of 16 MB (the same as the sync payload cap).
- Check the size before reading. Apply the sync limits for account count and field length before
  saving. Reuse the sync code rather than copy it, if the code allows it.
- Separate the results: cancelled (no message), wrong password or damaged file, file too large.
  Show each with a localized message. New text goes into all three ARB files.

### Step 4: clipboard

- New `lib/services/clipboard_service.dart`: copy a secret, mark it as sensitive, and clear it after a
  time limit if it is still the copied value. Codes keep the current 30 seconds. The recovery key and
  pairing code get 60 seconds. Their "copied" messages say the clipboard will be cleared.
- Add a small method channel in
  `android/app/src/main/kotlin/in/sreerajp/sreerajp_authenticator/MainActivity.kt` to set
  `ClipDescription.EXTRA_IS_SENSITIVE`. Other platforms use the normal Flutter clipboard.
- Use this service in `lib/widgets/account_tile.dart`, `lib/screens/security_screen.dart`,
  `lib/screens/lock_screen.dart` and `lib/screens/send_to_device_screen.dart`.

### Step 5: startup

Call `ScreenProtector` only on Android, through a small helper so `lib/main.dart` stays thin. Record in
`docs/security.md` §10 that Windows and Linux have no screen protection today.

### Step 6: user text

Correct the strings in section 7 in `en`, `ml` and `sa`, then run `flutter gen-l10n`. New wording says
data is stored on the device, and that Wi-Fi sync uses only the local network. It says the app uses
the system file picker rather than a storage permission. Translations I am unsure of are flagged for
review in the change log.

### Step 7: tests

- New `test/security/android_manifest_test.dart`: fails if a removed permission returns to our
  manifest, or the backup rules or cleartext setting go missing.
- Backup import: too large, wrong password, damaged file, too many accounts, over-long field.
- Clipboard service: clears after the time limit, and leaves the clipboard alone if the value changed.
- Startup helper: does nothing on non-Android platforms.

### Step 8: fill in the docs

- `docs/security.md`: set each line in §1.1, §3.1, §10, §11, §12 and §17 to `verified`, `n/a`,
  `risk-accepted` or still open, with the reason. Fix §8.2. List ML Kit in §4.
- `docs/dependencies.md`: list ML Kit and the data transport as things that break the rule until
  replaced.
- `docs/PROJECT_PROFILE.md`, `docs/release_process.md` §6.4 and §6.5: remove the `to verify` notes
  this work settles.
- `docs/implementation_progress.md`: mark Phase 7 done.

§12 sign-off stays "not yet signed off". The owner signs it before a release, and it cannot pass
while ML Kit is present.

### Step 9: check and log

Run `dart format .`, `flutter analyze`, `flutter test`. Build the dev APK and stop the Gradle daemons.
Write the change log and the ML Kit replacement plan.

## Files to change

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/data_extraction_rules.xml` (new)
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_authenticator/MainActivity.kt`
- `lib/main.dart`, plus one small startup helper in `lib/utils/` (new)
- `lib/services/export_import_service.dart`, `lib/services/clipboard_service.dart` (new)
- `lib/utils/constants.dart`
- `lib/screens/backup_restore_screen.dart`, `lib/screens/security_screen.dart`,
  `lib/screens/lock_screen.dart`, `lib/screens/send_to_device_screen.dart`,
  `lib/widgets/account_tile.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb`, and generated l10n files
- `test/security/android_manifest_test.dart` (new), plus new tests in `test/services/`
- `docs/security.md`, `docs/dependencies.md`, `docs/PROJECT_PROFILE.md`, `docs/release_process.md`,
  `docs/implementation_progress.md`

Never changed: `docs/guidelines/` (read-only submodule), `pubspec.lock` by hand.

## Needs the owner

- **Prod build for Step 1:** a prod release needs `android/key.properties`. If it is not on this
  machine, I test a `dev` release build instead, which has the same plugins, and say so in the log.
- **Real phone check after the work:** no device is connected now, so these need you. Wi-Fi sync
  between two devices (the host must show its real IP, not `127.0.0.1`), app lock with fingerprint and
  phone lock, optical sync, and QR scanning. The emulator cannot prove these on real Wi-Fi.
- **Translations:** the owner reviews the flagged Malayalam and Sanskrit text.

## Not in this plan

- **Replacing ML Kit:** separate plan, written at the end of this phase.
- **"Delete all data" action:** §15.4 requires it and the app does not have it. It is a destructive
  feature that needs its own design, so it gets its own plan. It stays listed in `docs/security.md`
  §17 as a release blocker.
- **Desktop storage checks:** the Linux keyring fallback and file modes stay `to verify` until there
  is a Linux test run. `sqflite_common_ffi` is only a dev dependency, so the database may not work on
  desktop at all. This is recorded in §17 as a blocker for the first desktop release. It is not fixed
  here.
- **Windows screen capture blocking:** recorded as a gap only.
