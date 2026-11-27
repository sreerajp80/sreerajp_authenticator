# Change log — Release build script with SHA-256 checksums

Implements plan: [`plans/20261127_200945_release-build-script.md`](../plans/20261127_200945_release-build-script.md)

## What changed

### `tool/build_release.ps1` (new)

A PowerShell script that builds the Android app and prepares the files for publishing:

- Options: `-Name` (required), `-Target apk|aab` (required), `-Flavor prod|dev` (default `prod`),
  `-Mode release|profile|debug` (default `release`), `-NoSplit`, `-NoObfuscate`, `-SymbolsDir`.
- Reads `version: x.y.z+n` from `pubspec.yaml`; stops if `+n` is missing.
- Refuses, before Flutter runs (exit code 1): `-NoObfuscate` for a prod release; `-SymbolsDir`
  when the build is not obfuscated; `-SymbolsDir` outside `build/`.
- Debug mode leaves out the obfuscation flags with a message; `-NoSplit` with `aab` is ignored
  with a message.
- Deletes old Flutter-named outputs first, runs `flutter build`, and stops without renaming or
  hashing if the build fails.
- Renames outputs to `<Name>-[<abi>-]v<x.y.z>_<n>-<flavor>-<mode>.<apk|aab>`, deletes Flutter's
  `.sha1`, and writes `<file>.sha256` in `sha256sum` format (UTF-8, no BOM).
- Default symbols folders: `build/symbols/android-<flavor>-<x.y.z+n>/` (AAB) and
  `build/symbols/android-<flavor>-<x.y.z+n>-apk/` (APK).
- Uses `Push-Location`/`Pop-Location`, and runs `android\gradlew.bat --stop` in `finally`.

**Change from the plan:** the hash is computed with .NET (`SHA256.Create()`) instead of
`Get-FileHash`. Testing showed that Windows PowerShell 5.1, when started from PowerShell 7, can
pick up PowerShell 7's module path and then cannot find `Get-FileHash`. The .NET call has no
module dependency, so it works in both shells.

### `docs/release_process.md`

- §6.1: APK and AAB symbols are separate folders; archive both, and why.
- §8 Security checklist: archive both symbols folders; every APK/AAB has a `.sha256` and no `.sha1`.
- §9 steps 6, 9, 10: use the script; archive both symbols folders; publish `.sha256` files.
- §9: new "Release Build Script" part: what it does, options table, rules, examples, file names,
  how to check a hash (`Get-FileHash`, `sha256sum -c`), and the raw `flutter build` commands it
  runs with defaults (APK symbols folder now ends in `-apk`).
- The `aapt2` and asset-audit examples (§6.4, §6.6, §9) now use the new APK file name. This was
  not listed in the plan, but the old name no longer exists after the script runs.

## Testing

No real build. In a throwaway folder outside the repository: a copy of the script, a
`pubspec.yaml` with `version: 2.8.0+38`, a stand-in `flutter.cmd` (logs its arguments, writes
outputs with Flutter's exact names plus `.sha1` for APKs, can be made to fail), and a stand-in
`gradlew.bat`. Run in both Windows PowerShell 5.1 and PowerShell 7 (which also checks that the
script parses in both). All 16 cases passed in both shells:

- default apk, default aab, dev debug apk, `-NoSplit`, `-NoObfuscate` on dev release, custom
  `-SymbolsDir`, `-NoSplit` with aab, rebuild of the same version (files replaced with a message);
- refused: `-NoObfuscate` on prod release, `-SymbolsDir` with `-NoObfuscate`, `-SymbolsDir` with
  debug, `-SymbolsDir` outside `build/` (relative `..` and absolute), missing `-Name`, bad `-Name`
  — all exit 1 and never call flutter;
- flutter failure: exit 1, nothing renamed or hashed, Gradle stop still runs.

Also checked: every `.sha256` matches the file's SHA-256 and has no BOM; `sha256sum -c` passes;
no `.sha1` or Flutter-named file is left; a `pubspec.yaml` without `+n` stops with exit 1 before
flutter; the caller's folder is unchanged after the script.

## Not changed / notes

- `tool/oldbuild_release.ps1` (untracked reference copy) is left for the user to delete.
- `CLAUDE.md` and `AGENTS.md` still list the raw APK build command with the old symbols folder
  (no `-apk` suffix). Not in this plan; worth a small follow-up so they point to the script.
- `CLAUDE.md` says Flutter 3.47.6; the SDK on the build machine is 3.50.1. Not in this plan.
- `docs/guidelines/` (submodule) not touched.
