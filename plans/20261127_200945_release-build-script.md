# Release build script with SHA-256 checksums

**Status:** completed

## Files to change

| File | Change |
|------|--------|
| `tool/build_release.ps1` | New. Builds APK/AAB, renames outputs, writes `.sha256`, removes `.sha1`. |
| `docs/release_process.md` | §9: how to use the script (options, rules, examples, file names, checking a hash); §6.1: archive both symbols folders; §8: checklist item; aapt2 example uses the new file name. |
| `change_log/<timestamp>_release-build-script.md` | New, after implementation. |

Not changed: `docs/guidelines/` (submodule, read-only), `android/` (no Gradle change),
`tool/oldbuild_release.ps1` (the untracked reference copy; left for the user to delete).

## The issue

- `flutter build apk` writes a SHA-1 file (`<apk>.sha1`) next to each APK. SHA-1 is weak, and
  Flutter has no SHA-256 option. It writes the file after Gradle ends, so Gradle cannot fix this.
- `flutter build appbundle` writes no checksum at all.
- Flutter's file names (`app-arm64-v8a-prod-release.apk`) do not carry the app name or version.
- §9 says "publish the signed split APKs with checksums", but nothing makes those checksums.

## Checks done against THIS project

- Flavors in `android/app/build.gradle.kts`: `dev` and `prod`. Production flavor = `prod`.
- `pubspec.yaml`: `version: 2.10.6+34` (has `+n`).
- Flutter SDK on this machine is 3.50.1 (CLAUDE.md says 3.47.6 — a doc mismatch, not part of this
  plan). Its `CopyFlutterApksTask.kt` names APKs `app[-<abi>][-<flavor>]-<mode>.apk` (flavor in
  lower case), and `gradle.dart` writes `<apk>.sha1` after Gradle. Matches the background notes.
- AAB path: `build/app/outputs/bundle/<flavor><Mode>/app-<flavor>-<mode>.aab`
  (for us: `bundle/prodRelease/app-prod-release.aab`).
- `build.gradle.kts` has an `applicationVariants.all` block that renames Gradle's own
  single-APK output to `SreerajP_Authenticator_<flavor>_v...apk`. This does **not** affect the
  `flutter-apk/` copies: `CopyFlutterApksTask` reads Gradle's output metadata and always writes
  Flutter's own names. So the script does not depend on it. No Gradle change.
- A `prod` release fails in Gradle if `android/key.properties` is missing. The script just sees a
  non-zero exit code and stops.

## The fix — `tool/build_release.ps1`

Start from the reference copy, with these changes:

1. Options as in the task: `-Name` (required, `^[A-Za-z0-9._-]+$`, no default), `-Target apk|aab`
   (required), `-Flavor prod|dev` (default `prod`), `-Mode release|profile|debug` (default
   `release`), `-NoSplit`, `-NoObfuscate`, `-SymbolsDir`.
2. Read `version: x.y.z+n` first; stop with a clear message if `+n` is missing.
3. Refuse before running Flutter (exit code 1, red message):
   - `-NoObfuscate` with `-Flavor prod -Mode release`;
   - `-SymbolsDir` when the build is not obfuscated (`-NoObfuscate` or debug);
   - **new:** `-SymbolsDir` outside `build/` (the script must write only inside `build/`).
   Debug mode drops `--obfuscate`/`--split-debug-info` with a message. `-NoSplit` with `aab`
   prints "ignored".
4. **Changed:** default symbols folder uses the full version, to match §6.1 of our release doc
   (`<version>` = `2.10.6+34`):
   - aab: `build/symbols/android-<flavor>-<x.y.z+n>/`
   - apk: `build/symbols/android-<flavor>-<x.y.z+n>-apk/`
   APK and AAB use different folders, because they are separate compiles.
5. Delete old Flutter-named outputs and their `.sha1` before building.
6. Run `flutter build apk|appbundle`; on a non-zero exit code stop, rename and hash nothing.
7. Rename to `<Name>-[<abi>-]v<x.y.z>_<n>-<flavor>-<mode>.<apk|aab>`, short ABIs `armeabi`,
   `arm64`, `x86_64`. Replace an existing file (and its `.sha256`) with a message.
8. Delete Flutter's `.sha1`.
9. Write `<file>.sha256`: `<lower-case hash>  <file name>\n`, UTF-8 without BOM via
   `[IO.File]::WriteAllText` + `UTF8Encoding($false)`.
10. Print each file, size and SHA-256, and the symbols folder to archive.
11. `finally`: `android\gradlew.bat --stop`.
12. **Changed:** use `Push-Location`/`Pop-Location` instead of `Set-Location`, so the caller's
    shell is not left in another folder. Never reads `key.properties` or the keystore.
13. Works in Windows PowerShell 5.1 and PowerShell 7.

Example for this app: `.\tool\build_release.ps1 -Name SreerajP_Authenticator -Target aab`
→ `SreerajP_Authenticator-v2.10.6_34-prod-release.aab` (+ `.sha256`).

## Docs — `docs/release_process.md`

- §9: new "Release build script" part: options table, rules, examples, file names, where files
  land, how to check (`Get-FileHash <file> -Algorithm SHA256`, `sha256sum -c <file>.sha256`).
  Keep the raw `flutter build` commands, labelled "what the script runs with defaults", with the
  real symbols folders (`-apk` suffix for APK).
- §9 steps 6, 9, 10: use the script; archive both symbols folders; publish `.sha256` files.
- §6.1: APK and AAB symbols are separate folders; archive both.
- §8 Security / Artifact Validation: "every APK/AAB has a `.sha256` and no `.sha1`".
- aapt2 example: new file name.

## Testing (no real build)

In the scratchpad: `repo/tool/build_release.ps1`, `repo/pubspec.yaml` with `version: 2.8.0+38`,
and a stand-in `flutter.cmd` first on PATH that logs its arguments and creates Flutter-named
outputs (plus `.sha1` for APKs). Cases: default apk, default aab, dev debug apk, `-NoSplit`,
`-NoObfuscate` on dev release, custom `-SymbolsDir`, the refused cases (exit 1, flutter not
called), missing `-Name`, a rebuild of the same version, failing flutter. Check hashes against
`Get-FileHash`, no BOM, no `.sha1` left. Run in both Windows PowerShell 5.1 and PowerShell 7.

## Security impact

Build tooling only. No app code, permissions, network or storage change. The script never reads
signing files; it writes only inside `build/`. SHA-256 replaces the weak SHA-1 checksum for
published files.
