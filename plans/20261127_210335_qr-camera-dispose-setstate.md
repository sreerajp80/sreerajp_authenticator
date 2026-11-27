# Fix setState() during dispose in the QR camera view

**Status:** completed

## What the issue is

Found while testing the Flutter 3.50.1 / `flutter_zxing` 4 update on a real phone
(Android 10, dev debug build). Leaving a screen with an open QR camera (seen on the
optical-sync scan screen) logs an unhandled error:

```
Failed assertion: '_lifecycleState != _ElementLifecycle.defunct': is not true.
#3 State.setState
#4 _QrCameraViewState._closeCamera (lib/widgets/qr_camera_view.dart:172)
#5 _QrCameraViewState.dispose     (lib/widgets/qr_camera_view.dart:108)
```

Cause: `dispose()` calls `_closeCamera()`. Its first part runs at once (before the first
`await`) and calls `if (mounted) setState(() {});`. During `dispose()` the `State` is still
`mounted`, but the element is already being removed, so `setState` is not allowed.

Effect: debug builds log an unhandled exception. Release builds skip asserts, and the camera
is still stopped and released, so users see nothing. The code is older than today's update;
Flutter 3.50 may check this more strictly, which is why it shows now. It is still a real bug
and must be fixed.

## Files to change

1. `lib/widgets/qr_camera_view.dart`
   - `_closeCamera()` gets a named parameter `{bool rebuild = true}`; the
     `setState(() {})` runs only when `rebuild` is true (and `mounted`).
   - `dispose()` calls `_closeCamera(rebuild: false)`.
   - The other callers (app paused/hidden, switch camera) keep the default and still rebuild.

No other file changes. No new dependency.

## Plan for the fix

1. Make the edit above.
2. Run `dart format .`, `flutter analyze`, `flutter test`.
3. Build the dev debug APK, install it on the connected phones, open and leave the QR
   scanner and the optical-sync scan screen, and check `logcat` shows no Flutter error.
4. Run `android\gradlew --stop` and end leftover Gradle / Kotlin daemons.
5. Write the change log.

Test note: the existing widget tests cannot open a real camera (`_camera` stays null, so
`_closeCamera` returns early), so a widget test would not catch this bug. Building a fake
`CameraController` just for this is more code than the fix; the on-phone check in step 3
is the proof. (Open to a test if the user wants one.)

## Security impact

None. The camera is still stopped and released on dispose exactly as before; only a UI
rebuild call is skipped when the widget is being removed.
