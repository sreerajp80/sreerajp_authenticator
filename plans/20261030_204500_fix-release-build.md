# Fix the release build

**Status:** partial_completion

**Security impact:** medium. This updates `screen_protector`, the plugin that sets `FLAG_SECURE`, so
screen capture protection must be re-checked. It adds no new dependency and no permission is expected
to change.

## What the issue is

`flutter build apk --flavor prod --release` fails at `:screen_protector:checkReleaseAarMetadata`, with 15
issues. All 15 say the same thing: `:screen_protector is currently compiled against android-33`, while
its dependencies now need 34 or later. Debug builds do not run this check, so they still work.

No release has been buildable since the toolchain upgrade. This also blocks the checks that Phase 7 left
open: `debuggable=false`, obfuscation and the merged prod manifest.

## Plan for the fix

### Step 1: update the plugin

In `pubspec.yaml`, change `screen_protector: 1.4.2` to `screen_protector: 1.4.3`, keeping the exact
version pin. Run `flutter pub get`, which updates `pubspec.lock`.

Why 1.4.3:

| Version | compileSdk | Licence | Note |
|---|---|---|---|
| 1.4.2 (now) | 33 | MIT | Fails the build |
| 1.4.3 | 36 | MIT | Smallest change; the two calls the app uses keep the same signature |
| 1.5.1 | 36 | Apache 2.0 | Licence change; its screenshot prevention was rewritten, which is more to re-check |

Before building, compare the Android source of 1.4.2 and 1.4.3, to confirm it still sets `FLAG_SECURE` and
adds no network code.

I am not forcing `compileSdk` on all plugins from `android/build.gradle.kts`. That would hide this kind
of problem in future plugins.

### Step 2: build

Run the prod release APK build from `CLAUDE.md`, using the release keystore already set up in
`android/key.properties`. Symbols go in `build/symbols/`. Stop the Gradle daemons afterwards.

This failure may be hiding later ones, such as R8 errors. If the fix is small and within this plan's
files I make it and log it. Anything else, I stop and bring it to you, with no workaround that weakens a
security control.

### Step 3: run the checks Phase 7 could not

On the release APK, using a temporary emulator kept outside your own emulator list:

- Merged prod manifest: no `debuggable`, `allowBackup="false"`, backup rules, cleartext off, and the list
  of permissions and exported components.
- Obfuscation: the build used `--obfuscate`, and the debug symbols were written.
- The app starts in release mode, so R8 did not remove anything it needs at startup.
- `FLAG_SECURE`: a screenshot from `adb` comes out blank.
- ML Kit traffic: repeat the Phase 7 test, to see whether a release build also sends data.

### Step 4: docs and log

- `docs/security.md`: update §1.1 (Release build), §4 (test result), §12 (M7, M8), and remove this
  blocker from §17.
- `docs/release_process.md`: remove this blocker.
- `docs/dependencies.md`: record the new version if it lists one.
- Update the "Depends on" section of `plans/20261030_201157_replace-ml-kit-qr-decoder.md`.
- Run `flutter analyze` and `flutter test`. Write the change log.

## Files to change

- `pubspec.yaml`, `pubspec.lock` (by `flutter pub get`, never by hand)
- `docs/security.md`, `docs/release_process.md`, `docs/dependencies.md`
- `plans/20261030_201157_replace-ml-kit-qr-decoder.md`

## Not in this plan

- Replacing ML Kit, adding "Delete all data", or updating any other package.
- Publishing or uploading anything. The APK stays in `build/`.
- A real phone test of the release APK. That is still yours, and the Phase 7 phone checks still stand.
