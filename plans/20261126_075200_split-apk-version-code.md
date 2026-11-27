# Split APKs use the same versionCode as the App Bundle

**Status:** completed

## Issue

`flutter build apk --split-per-abi` adds an offset to the build number from `pubspec.yaml`:
1000 for `armeabi-v7a`, 2000 for `arm64-v8a`, 4000 for `x86_64`. The App Bundle (`.aab`) for
Google Play has no offset.

Example: `2.10.4+32` gives versionCode `1032` / `2032` / `4032` in the split APKs, but `32` in the
bundle. A phone that has a split APK sees every later Play build (for example `+35`) as older.
Play then never updates it. The only fix for that phone is to uninstall, which deletes the
vault (all accounts), because `android:allowBackup="false"`.

## What was checked

- Flutter version: CI and `CLAUDE.md` pin **3.47.6** (`.github/workflows/ci.yml`). The local SDK is
  newer (3.50.1). The switch `force-version-code-ignoring-abi` exists in **both**
  (`FlutterPluginUtils.kt`, constant `PROP_FORCE_VERSION_CODE_IGNORING_ABI`). In 3.47.6
  `FlutterPlugin.kt` skips the `abi * 1000 + versionCode` override when the switch is true.
- `android/app/build.gradle.kts` sets `versionCode = flutter.versionCode` and
  `versionName = flutter.versionName`. Nothing else sets a per-ABI code.
- Output names: the custom `outputFileName` code only renames single-output builds. Split APKs
  keep Flutter's own names (`app-<abi>-prod-release.apk`), which have no version in them.
- Release history: tags `Release_20261031` … `Release_20261108` (`+29` … `+32`). Both connected
  test phones run `2.10.4`, versionCode `32`, installer `com.android.vending` (Play). So these
  phones are safe. The repo has no record of split APKs given to other people; the owner must
  confirm this (see "Open question").

## Files to change

1. `android/gradle.properties` — add:
   ```properties
   # Give every --split-per-abi APK the same versionCode as the App Bundle (no 1000/2000/4000
   # ABI offset), so a phone with a direct APK can later update from Google Play.
   force-version-code-ignoring-abi=true
   ```
2. `docs/release_process.md` (this app's own copy; the file already has uncommitted edits, which
   are kept):
   - §9 Android build commands: a note under the split APK build that all split APKs share the
     bundle's versionCode, and how to check it (`aapt2 dump badging <apk>`, first line).
   - §12 Distribution channels: a short paragraph on why (direct APK → Play update path, no
     uninstall, no data loss).
   - §8 checklist, "Store Readiness": new item "Split APK versionCode equals the `pubspec.yaml`
     build number (no 1000/2000/4000 added)".

No change to `docs/guidelines/` (read-only submodule). See the note below.

## Security impact

Build config only. No permission, storage, network, or signing change. The update path also
protects user data: users no longer need to uninstall (and lose the vault) to move to Play.

## Risks

- Different ABIs now share one versionCode. This is fine for direct APKs (a phone installs one).
  It would matter only if split APKs were uploaded to Play as multiple APKs; this app uploads the
  bundle only.
- If a split APK with code `1xxx`/`2xxx`/`4xxx` is already on someone's phone, that phone still
  cannot update. See below.

## Open question (owner)

Were any split APKs (versionCode `1029`–`4032`) given to other people? If yes, the next Play
build number must jump above the highest code given out (for example `+4100`), once. Also, Play
only updates a sideloaded app when Play's app signing key equals the release keystore key
(check Play Console → App integrity).

## Note for the shared guidelines (not edited here)

`docs/guidelines/flutter_build_flavors_guide.md` (split APK output section) and
`docs/guidelines/platform_store_readiness.md` (versionCode row) could mention the 1000/2000/4000
offset and `force-version-code-ignoring-abi=true`. To be done in the guidelines repository.

## After approval

Make the two edits, write the change log, set this plan to `completed`. No build here; the owner
runs the build commands and then the results are checked (aapt2 for APKs, a small Python
protobuf reader for the `.aab` manifest).
