# Plan: Automate Build Metadata Generation & Display Build Date in About Screen

**Status:** completed

## Overview
Automate build metadata generation (`app_version.g.dart` and `build_date.g.dart`) during Gradle builds (e.g. `flutter build apk`) and display the build date in the About screen.

## Issue
Currently, the app does not automatically generate build timestamp and version constants during build time, and the About screen does not show the build date.

## Proposed Changes

### 1. Build Metadata Generation Scripts
- Create `tool/generate_app_version.dart`:
  - Parse version string from `pubspec.yaml`
  - Output `lib/utils/app_version.g.dart` defining `const String kAppVersion = '<version>';`
  - Print console feedback: `app_version.g.dart updated → <version>`
- Create `tool/generate_build_date.dart`:
  - Extract current date in `YYYY-MM-DD` format
  - Output `lib/utils/build_date.g.dart` defining `const String kBuildDate = '<date>';`
  - Print console feedback: `build_date.g.dart updated → <date>`
- Initialize `lib/utils/app_version.g.dart` and `lib/utils/build_date.g.dart`

### 2. Gradle Integration
- Update `android/app/build.gradle.kts`:
  - Define `generateBuildMetadata` Gradle task that executes the Dart generation scripts using `dartExecutable`
  - Hook task dependencies into `preBuild` and `compileFlutterBuild*` tasks so it automatically runs on `flutter build` and `flutter run`

### 3. About Screen Update
- Update `lib/screens/about_screen.dart`:
  - Import `lib/utils/build_date.g.dart`
  - Add a Build Date chip (`Icons.calendar_today_outlined`, `kBuildDate`) to the header chip badges

### 4. Tests
- Add `test/screens/about_screen_test.dart` to verify About screen widget rendering and build date display.

## Verification Plan
1. Run `dart run tool/generate_app_version.dart` and `dart run tool/generate_build_date.dart`
2. Run `flutter analyze` to ensure zero warnings
3. Run `flutter test` to verify all unit and widget tests pass
4. Test Gradle build metadata generation
