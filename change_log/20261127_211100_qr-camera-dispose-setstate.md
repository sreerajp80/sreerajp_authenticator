# Change log: fix setState() during dispose in the QR camera view

Implements plan: `plans/20261127_210335_qr-camera-dispose-setstate.md`

## What changed

`lib/widgets/qr_camera_view.dart`:

- `_closeCamera()` now takes `{bool rebuild = true}`. The `setState(() {})` that refreshes the
  view after the camera is closed runs only when `rebuild` is true (and the widget is mounted).
- `dispose()` calls `_closeCamera(rebuild: false)`, with a comment saying why.
- The other callers (app paused or hidden, switch camera) are unchanged and still rebuild.

The camera is still stopped and released on dispose exactly as before.

## Why

On a real phone (Android 10, dev debug build), leaving a screen with an open QR camera
logged an unhandled assertion error: `setState` was called from `dispose()` through
`_closeCamera()`, while the element was already being removed. Release builds skip
asserts, so users saw nothing, but it was a real bug. Found during the on-phone checks of
the Flutter 3.50.1 / `flutter_zxing` 4 update.

## Checks

- `dart format` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 753 tests pass.
- Dev debug APK built and installed on two Android 10 phones. Opened the camera (QR
  scanner on both phones, optical-sync scan screen on one), waited until the camera
  stream had started, then left the screen. The camera was released and `logcat` showed
  no Flutter error. Before the fix, the same steps logged the assertion error.
- Gradle daemon stopped; no leftover daemon processes.

No widget test was added: the widget tests cannot open a real camera, so they cannot reach
this code path (as noted in the plan).
