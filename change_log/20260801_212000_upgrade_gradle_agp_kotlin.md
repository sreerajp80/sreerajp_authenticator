# Change Log: Upgrade Gradle, AGP, and Kotlin Versions

**Plan Reference:** [plans/20260801_212000_upgrade_gradle_agp_kotlin.md](../plans/20260801_212000_upgrade_gradle_agp_kotlin.md)
**Timestamp:** 2026-08-01 21:20:00

## Summary

Upgraded Gradle wrapper, Android Gradle Plugin (AGP), and Kotlin versions to eliminate Flutter build deprecation warnings.

---

## Detailed Changes

### 1. `android/gradle/wrapper/gradle-wrapper.properties`
- Updated Gradle `distributionUrl` from `gradle-8.12-all.zip` to `gradle-8.14-all.zip`.

### 2. `android/settings.gradle.kts`
- Updated `com.android.application` plugin version from `8.9.1` to `8.11.1`.
- Updated `org.jetbrains.kotlin.android` plugin version from `2.1.0` to `2.2.20`.

---

## Verification

- `flutter analyze`: Passed with zero errors / warnings.
- `flutter test`: Passed cleanly.
