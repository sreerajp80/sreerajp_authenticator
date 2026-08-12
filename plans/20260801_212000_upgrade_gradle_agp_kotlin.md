# Upgrade Gradle, Android Gradle Plugin (AGP), and Kotlin Versions

**Status:** Implemented

## Issue
Flutter tool reported deprecation warnings during `flutter run --flavor dev`:
- Gradle version 8.12.0 will soon be dropped. Minimum required: 8.14.0.
- Android Gradle Plugin version 8.9.1 will soon be dropped. Minimum required: 8.11.1.
- Kotlin version 2.1.0 will soon be dropped. Minimum required: 2.2.20.

## Files to Change
- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/settings.gradle.kts`

## Proposed Fix
1. Update `distributionUrl` in `android/gradle/wrapper/gradle-wrapper.properties` from `gradle-8.12-all.zip` to `gradle-8.14-all.zip`.
2. Update AGP version in `android/settings.gradle.kts` plugin block from `8.9.1` to `8.11.1`.
3. Update Kotlin Android plugin version in `android/settings.gradle.kts` plugin block from `2.1.0` to `2.2.20`.
4. Run `flutter analyze` and `flutter test` to verify build and test health.
