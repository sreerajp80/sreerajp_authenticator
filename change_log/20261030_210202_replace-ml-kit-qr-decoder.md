# Replace Google ML Kit with flutter_zxing

Implements `plans/20261030_201157_replace-ml-kit-qr-decoder.md`, including its permissions amendment.

## Why

`mobile_scanner` brought in closed-source Google ML Kit. A debug build sent usage events to Google, and in
release builds the scanner failed, because R8 appears to remove code ML Kit needs.

## What changed

- **Dependencies:** removed `mobile_scanner`. Added `flutter_zxing` 3.1.0 (MIT, includes zxing-cpp) and `camera`
  0.12.2, with exact pins.
- **New `lib/widgets/qr_camera_view.dart`:** a shared camera view with torch and camera switching, duplicate
  handling, and a localized error (`errorCameraUnavailable`) when the camera cannot be opened.
- **Screens moved to it:** `qr_scanner_screen.dart`, `sync_qr_scanner_screen.dart`, `optical_sync_screen.dart`.
- **Manifest:** `RECORD_AUDIO`, `WRITE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE` and `ACCESS_NETWORK_STATE`
  removed with `tools:node="remove"`. The new packages brought in the first three and `media3-common` brought
  in the last.
- **User text (`en`, `ml`, `sa`):** removed the ML Kit warning and restored the offline and no-analytics claims.
  Kept the corrected wording from Phase 7 about Wi-Fi sync and where secrets go.
- **Tests:** new `test/widgets/qr_camera_view_test.dart`; extended `test/security/android_manifest_test.dart`.
- **Docs:** `docs/security.md`, `docs/dependencies.md`, `docs/architecture.md`, `docs/features.md`,
  `docs/PROJECT_PROFILE.md`, `docs/release_process.md`, `docs/implementation_progress.md`, `README.md`.

## Final permissions in the prod release APK

`CAMERA`, `USE_BIOMETRIC`, `VIBRATE`, `INTERNET`, and `USE_FINGERPRINT` (added by `androidx.biometric`). There
is also the app's own `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, added by AndroidX.

## Results

| Check | Result |
|---|---|
| ML Kit, Firebase, Google Play services, data transport in `classes.dex` | None found |
| Manifest | No ML Kit or data transport. A disabled `gms.metadata.ModuleDependencies` entry remains, with no Google Play services code behind it |
| Native libraries | Aligned for 16 KB memory pages (16 KB or higher) |
| Account QR scan, release build with R8, real phone | Worked, reported by the owner |
| Network traffic for the app on the real phone, after the scan | None recorded by Android's per-app counter |
| Optical sync, 200 test accounts, emulator window to real phone | Worked, reported by the owner. Very roughly 3 to 5 minutes, timed by eye |
| Restore through the system file picker | Worked, reported by the owner |
| `dart format`, `flutter analyze`, `flutter test` | No changes, no issues, 572 passed |

Gradle daemons were stopped and none were left over. Test files were removed from both devices, and the test
install was removed from the emulator.

## Not done or not checked

- The Dev app is still on the owner's phone. It holds only test accounts, and is safe to uninstall.
- The traffic check on the phone ran after the first scan, on the build before the permissions were removed.
  It was not repeated after the optical sync test.
- The optical sync time is not a measurement, and has no comparison with the old decoder.
- The time estimate shown on the optical sync screen was not compared with a real timing.
- The file picker was not run on Android 10 to 12, because no such image is installed. Recorded in
  `docs/security.md` §17.
- Wi-Fi sync and app lock from the Phase 7 phone checks were not reported in this change.
- No camera on Windows or Linux: the `camera` package has no desktop support. Manual entry is the fallback.
- A bug in the native decoder could crash the app on a crafted QR code. Not tested.
- `docs/security.md` §12 is not signed off. "Delete all data" is still a release blocker.
- Nothing is committed.

## Correction to the plan

The plan said `flutter_zxing` had no network code. It has one path, `readBarcodeImageUrl`, which the first scan
missed. The app never calls it. Recorded in `docs/security.md` §4.

## Translations to review

`errorCameraUnavailable` in `ml` and `sa`, and `helpVault13` in `ml` and `sa`, are drafts.
