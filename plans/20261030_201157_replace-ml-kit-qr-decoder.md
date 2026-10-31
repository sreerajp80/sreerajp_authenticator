# Replace Google ML Kit with an open source QR decoder

**Status:** completed

**Security impact:** high. This changes dependencies and how camera frames are processed. It should stop
all data sending to Google and remove `ACCESS_NETWORK_STATE` from the final manifest. It adds native
C++ code that parses camera input, which is untrusted (`docs/security.md` §3.1).

## What the issue is

`mobile_scanner` uses closed-source Google ML Kit on Android. This causes two problems:

- A debug build sent `FIREBASE_ML_SDK` events to `firebaselogging.googleapis.com`. This breaks hard rules
  1 and 3 (`docs/security.md` §4).
- In the prod release APK the scanner fails with "An unexpected error occurred", because R8 appears to
  remove code ML Kit needs (`docs/security.md` §17).

## Comparison

Checked from pub.dev data and the published package source. Nothing has been built or run yet.

| Package | Licence | Platforms | Decoder | Latest release | Result |
|---|---|---|---|---|---|
| `flutter_zxing` 3.1.0 | MIT; includes zxing-cpp source | Android, Windows, Linux (also iOS, macOS) | C++ through FFI, in an isolate | 2026-09 | **Recommended** |
| `qr_code_scanner_plus` 2.3.2 | BSD-2 | Android, iOS | ZXing in Java, native view | 2026-10 | Fallback, no desktop |
| `qr_code_dart_scan` 0.14.0 | MIT | Android, iOS | Pure Dart (`zxing_lib`) | 2026-08 | Likely too slow for optical sync (not measured) |
| `zxing2`, `zxing_lib` | BSD-3, Apache 2.0 | All | Pure Dart, decoder only | 2025-06 | Same speed concern |
| `flutter_barcode_sdk` | MIT wrapper | All | Wraps a commercial SDK (from memory, not checked) | 2026-10 | Rejected |
| `simple_barcode_scanner` | MIT | Android, iOS, Windows | Uses a WebView on Windows | 2026-10 | Rejected: WebView |
| `ai_barcode_scanner` | Apache 2.0 | — | Depends on `mobile_scanner` | 2026-09 | Rejected: same ML Kit |
| `scan`, `flutter_qr_reader` | MIT | Android, iOS | Native | 2021 | Rejected: unmaintained |

Why `flutter_zxing`:

- A scan of its Dart, C++, Java, Kotlin, Gradle and XML files, leaving out its example app, found no
  network code, no Firebase or Google Play services, and no permission in its manifest.
- Its dependencies are `camera` (Flutter team), `ffi`, `image` and `image_picker`.
- It supports Flutter 3.41 and later, compiles against API 36, and is the only candidate that decodes
  natively and declares Windows and Linux.

Risks:

- **Optical sync speed is unknown.** It reads moving frames at 12 FPS, and only a real phone can measure it.
- **Native build:** C++ is compiled for each ABI, and the APK size will change. It has not been tried with
  this toolchain (AGP 9.4).
- **`image_picker` comes along** even though the app does not use the gallery. The final manifest must be
  checked for anything it adds.
- **Native parser:** a bug in C++ decoding could crash the app on a crafted QR code. The existing checks on
  decoded text stay as they are.

## Plan for the fix

### Step 1: trial build, stop if it fails

Add `flutter_zxing` and `camera` with exact version pins, and build the dev debug and prod release APKs.
Read the final manifest. If it does not build, or adds a network component, I stop and bring it to you.

### Step 2: new camera widget

New `lib/widgets/qr_camera_view.dart`, using `camera` and `zx.processCameraImage`, with an `onCode` callback
and a small controller for torch and camera switching. I am not using the package's `ReaderWidget`, because
its buttons sit inside the camera view, while the app keeps them in the AppBar with localized tooltips
(engineering standard §7.8).

Keep camera permission handling and errors as they are today. A decoder error never shows raw exception
text.

### Step 3: move the three screens

- `lib/screens/qr_scanner_screen.dart`: one scan, then stop.
- `lib/screens/sync_qr_scanner_screen.dart`: one scan, then stop.
- `lib/screens/optical_sync_screen.dart`: every frame, as fast as it can go.

Remove `mobile_scanner` from `pubspec.yaml`. Add tests for the callback, duplicate handling and error paths.
The decoder itself gets a test that decodes a generated QR image, if the native library can be loaded under
`flutter test`.

### Step 4: prove it

- The final manifest and APK have no `mlkit` or `datatransport`, and no `ACCESS_NETWORK_STATE`.
- On a release APK on an emulator: the scanner opens without an error, and no `firebaselogging` request or
  traffic for the app's UID appears.
- Check that R8 does not break it in release.

### Step 5: correct the text and docs

Remove the ML Kit sentence from the app text in `en`, `ml` and `sa`, and restore the accurate claims. Update
`docs/security.md` §1.1, §3.1, §4, §11, §12, §17; `docs/dependencies.md`; `docs/architecture.md`;
`docs/features.md`; `README.md`; and the licence notes if the app lists them. Run the usual checks, and write
the change log.

## Files to change

- `pubspec.yaml`, `pubspec.lock` (by `flutter pub get`)
- `lib/widgets/qr_camera_view.dart` (new)
- `lib/screens/qr_scanner_screen.dart`, `lib/screens/sync_qr_scanner_screen.dart`,
  `lib/screens/optical_sync_screen.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb`, and generated l10n files
- `android/app/proguard-rules.pro`, only if R8 needs a rule for the new code
- New tests in `test/widgets/`
- `docs/security.md`, `docs/dependencies.md`, `docs/architecture.md`, `docs/features.md`, `README.md`

## Needs the owner

A real phone test, which is what decides this change. Scan an account QR code and a sync QR code, then run
optical sync with a large vault, comparing it with the old build. **If optical sync is too slow to be usable,
I stop and bring you the options before removing anything further.**

## Amendment: remove unused permissions (needs its own approval)

**Security impact:** this only removes permissions. It is a change to a platform file that the plan above
did not list.

The new packages bring permissions the app does not use, and they appear in the final manifest:

| Permission | Comes from | Why it is safe to remove |
|---|---|---|
| `RECORD_AUDIO` | `camera_android_camerax` | The app opens the camera with `enableAudio: false` and never records |
| `ACCESS_NETWORK_STATE` | `androidx.media3:media3-common` | The release `classes.dex` has no `media3` or `ConnectivityManager` code |
| `WRITE_EXTERNAL_STORAGE`, and `READ_EXTERNAL_STORAGE` which the merger implies from it | `camera_android_camerax` | The app takes no photos or videos and saves nothing to shared storage |

### Fix

In `android/app/src/main/AndroidManifest.xml`, add the `tools` namespace and four entries with
`tools:node="remove"`. Extend `test/security/android_manifest_test.dart` so they stay removed. Rebuild, read the
final manifest, and update `docs/security.md` §11 and §17, and `docs/PROJECT_PROFILE.md`.

`USE_FINGERPRINT` stays. `androidx.biometric` adds it, and it was checked in Phase 7.

### Files to change

`android/app/src/main/AndroidManifest.xml`, `test/security/android_manifest_test.dart`, `docs/security.md`,
`docs/PROJECT_PROFILE.md`, `docs/release_process.md`

### What must be retested on the real phone

Scanning, and restoring a backup with the file picker. Android 10 to 12 cannot be tested on this phone, which
runs Android 17, so the picker on those versions needs another device or an emulator.

## Not in this plan

- Camera on Windows and Linux. The `camera` package has no desktop support, and needs `camera_desktop` as
  well. `mobile_scanner`'s desktop support was never confirmed either, so this is not a loss I can point
  to. It stays a desktop blocker in `docs/security.md` §17, with manual entry as the fallback.
- "Delete all data" and `PRIVACY.md`.
