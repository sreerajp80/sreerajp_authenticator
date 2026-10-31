# Upgrade the Android toolchain (adoption Phase 3)

**Status:** completed

Part of master plan: `plans/20261029_183929_adopt-updated-guidelines.md` (Phase 3). Done before
Phase 2 because the project owner asked for it now.

## What the issue is

The project uses old Android build tools:

| Tool | Now | Target (asked by the owner) |
|---|---|---|
| Flutter / Dart | 3.47.6 / 3.13.5 installed; `pubspec.yaml` asks for Dart `^3.12.2` | Flutter 3.47.6 / Dart `^3.13.5` |
| Android Gradle Plugin (AGP) | 8.11.1 | 9.4.1 |
| Gradle | 8.14 | 9.8.0 |
| Kotlin Gradle Plugin | 2.2.20 | 2.4.10 |
| Java target | 11 | 17 (needed by AGP 9) |
| `minSdk` | Flutter default | 29 (profile §3) |

Also:

- `android/app/build.gradle.kts` uses the old `kotlinOptions { }` block. The guidelines
  (engineering standard §5.3) say to use `kotlin { compilerOptions { } }`.
- The build-date script uses `project.exec { }`. Gradle 9 removed it, so the build would fail.
- The custom APK file name block uses `applicationVariants` and an internal AGP class. These are
  old APIs and may not work on AGP 9.

**Note on the guideline.** Engineering standard §5.3 says to use the AGP / Kotlin / Gradle versions
Flutter generates, and not to pick them by hand. Flutter 3.47.6 knows versions up to AGP 9.2,
Gradle 9.3.1 and Kotlin 2.4.0, so it may print a "newer than known" warning. The owner asked for
the newer versions, and two of the owner's other apps already build with AGP 9.4.1 and
Gradle 9.8.0 on this Flutter. So the newer versions are used, and this note records the choice.

## Files to be changed

- `pubspec.yaml` — Dart SDK constraint to `^3.13.5` (then `flutter pub get` updates `pubspec.lock`;
  the lock file is not edited by hand).
- `android/settings.gradle.kts` — AGP `9.4.1`, Kotlin `2.4.10`.
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle `9.8.0`.
- `android/app/build.gradle.kts`:
  - Java 17 in `compileOptions`.
  - Replace `kotlinOptions { }` with a top-level `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }`.
  - Remove `id("kotlin-android")` (the Flutter Gradle plugin applies Kotlin while
    `android.builtInKotlin=false`, as in the Flutter 3.47 template).
  - Replace `project.exec { }` with injected `ExecOperations` (the same pattern the owner's other
    app uses).
  - `minSdk = 29`.
  - Keep the custom APK name block if it still builds on AGP 9. If it does not, I will stop and
    ask you before changing or removing it.
- `android/gradle.properties` — no change (keep the flags the Flutter migrator wrote).
- `CLAUDE.md`, `AGENTS.md` — update the version rows (Flutter, Dart, minSdk). The full rewrite of
  these files stays in Phase 2.

Not in this phase: the `material_ui` migration (moved to its own plan, because it touches 47 Dart
files). Nothing inside `docs/guidelines/` is changed.

## Plan for the fix

1. Make the file changes above.
2. Run `flutter pub get`.
3. Run `flutter analyze` and `flutter test`.
4. Build `flutter build apk --flavor dev --debug` to prove the Android build works.
5. Run `android\gradlew --stop` and end any leftover `GradleDaemon` / `KotlinCompileDaemon`
   processes.
6. Write a change log in `change_log/` and update the master plan.

## Risks

- A plugin may not yet support AGP 9.4.1. If the build fails, I will report the error and ask
  before trying anything else.
- Phones on Android 7–9 can no longer install new versions (`minSdk 29`).
