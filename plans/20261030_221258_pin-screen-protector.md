# Pin screen_protector to 1.5.1 so its Android code compiles

**Status:** dropped

Dropped: replaced by `plans/20261030_221513_built-in-kotlin.md`, the option chosen instead.

## Files to change

- `pubspec.yaml` (one line)
- `pubspec.lock` (generated, by `flutter pub get`; not edited by hand)

## Issue

The prod release build fails with "cannot find symbol: ScreenProtectorPlugin".

`screen_protector` 1.5.3 keeps this class in a Kotlin file. Its `android/build.gradle` applies the
Kotlin plugin only when the Android Gradle Plugin (AGP) is older than 9, because it assumes AGP 9
compiles Kotlin by itself. This project uses AGP 9.4.1 with `android.builtInKotlin=false`, the value
the Flutter migrator wrote. So nothing compiles the Kotlin file, and the class is missing.

Other plugins, such as `share_plus`, read `android.builtInKotlin` before they decide. `screen_protector`
does not. Flutter's Gradle code has a fallback that applies Kotlin to such plugins, but this failure
shows it did not take effect here. The exact reason for that was not traced.

## Fix

In `pubspec.yaml`, change:

```yaml
screen_protector: ^1.5.3  # Prevent screenshots and screen recording
```

to an exact version:

```yaml
# Exact: 1.5.2+ skips Kotlin on AGP 9, which breaks with android.builtInKotlin=false.
screen_protector: 1.5.1  # Prevent screenshots and screen recording
```

Then run `flutter pub get`.

Version 1.5.1 always applies the Kotlin plugin. A comparison of the two versions shows its Android
folder differs from 1.5.3 only in `build.gradle`, so the Android `FLAG_SECURE` code is the same.
The `CHANGELOG.md` entries for 1.5.2 and 1.5.3 otherwise cover iOS only, which this project does
not ship.

## Options not chosen

- **Turn on built-in Kotlin (`android.builtInKotlin=true`).** This is the long-term direction, but
  `docs/guidelines/flutter_build_flavors_guide.md` treats it as a separate migration, with every
  Android plugin checked first. It is too large for a build fix.
- **Force Kotlin onto this plugin from `android/build.gradle.kts`.** This keeps 1.5.3 but adds a
  custom Gradle workaround that is harder to understand and remove than a version pin.

## Later

When the project moves to built-in Kotlin, this pin must be removed, because 1.5.1 always applies
the Kotlin plugin.

## Security impact

Dependency change on a security control (screenshot blocking). The Android code stays the same and
the setting still defaults to on. No new permission.

## Verification

1. `flutter analyze` and `flutter test`.
2. Build the prod release again, then stop the Gradle daemons.
3. On a real phone, confirm screenshots are blocked, then do the rest of the checklist in
   `plans/20261030_220101_file-picker-13-api.md`.
