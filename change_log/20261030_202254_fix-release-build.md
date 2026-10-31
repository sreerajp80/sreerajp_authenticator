# Fix the release build (partly done)

Implements part of `plans/20261030_204500_fix-release-build.md`. Plan status: `partial_completion`.

## What changed

- `pubspec.yaml`, `pubspec.lock`: `screen_protector` 1.4.2 to 1.4.3. The plugin's Android source is the
  same in both versions; its build settings moved to compileSdk 36.
- Docs: `docs/security.md` §1.1, §4, §10, §12, §17; `docs/release_process.md`. Also the "Depends on"
  section of `plans/20261030_201157_replace-ml-kit-qr-decoder.md`.

## Results

The prod release APK now builds and is signed. On an Android 15 emulator:

| Check | Result |
|---|---|
| Debuggable | No |
| `--obfuscate` | Used; debug symbols written |
| Backup rules, cleartext off | Present in the merged prod manifest |
| Exported | Launcher activity, and `ProfileInstallReceiver` (needs `DUMP`) |
| App starts in release mode | Yes |
| `FLAG_SECURE` | Set; an `adb` screenshot comes out black |
| **QR scanner** | **Fails: "An unexpected error occurred"** |
| ML Kit traffic | No request seen, but only because the scanner failed |

## New problem: QR scanning fails in the release APK

The log shows `NoSuchMethodException` on the constructors of ML Kit's `CommonComponentRegistrar`,
`BarcodeRegistrar` and `VisionCommonRegistrar`, then a `NullPointerException` in `mobile_scanner`. R8 appears
to remove code that ML Kit needs. Debug builds work. The link between the log lines and the failure is
strongly suggested but not proven by a fix.

This affects anything using the camera scanner in a release build: adding an account by QR code, the Wi-Fi
sync QR code, and optical sync receive.

It was not fixed, because `android/app/proguard-rules.pro` is outside the approved plan, and a keep rule
would very likely also restore ML Kit's data sending. That is the owner's decision.

## Checks

- `dart format`: no changes needed. `flutter analyze`: no issues. `flutter test`: 566 passed.
- Gradle daemons stopped, none left over. The temporary emulator was deleted.

## Not done

- Real phone test of the release APK.
- A working release-build ML Kit traffic test. It is not possible until the scanner runs in release.
