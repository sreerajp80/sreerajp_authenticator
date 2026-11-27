# Change log — split APKs use the same versionCode as the App Bundle

Plan: `plans/20261126_075200_split-apk-version-code.md`

## What changed

1. `android/gradle.properties`
   - Added `force-version-code-ignoring-abi=true` with a comment. Flutter (3.47.6 and later) no
     longer adds 1000/2000/4000 to the versionCode of `--split-per-abi` APKs. Every split APK now
     has the same versionCode as the `.aab`: the `+BUILD` number in `pubspec.yaml`.
2. `docs/release_process.md` (the owner's earlier uncommitted edits in this file are kept)
   - §8 "Store Readiness": new checklist item — split APK versionCode equals the `pubspec.yaml`
     build number, with no 1000/2000/4000 added.
   - §9: note under the build commands on the shared versionCode and how to check it with
     `aapt2 dump badging` (the `.aab` needs `bundletool` or a small script).
   - §12: short paragraph on why (direct APK users can update from Play without an uninstall,
     which would delete the vault; Play's app signing key must match the release keystore).

## Why

Without the switch, a phone with a direct split APK (for example code `1034`) sees each Play
build (`37`) as older, so Play never updates it.

## Security impact

Build config only. No permission, storage, network or signing change.

## Not done here

- No build was run. The owner builds; the results are checked afterwards (aapt2 for each split
  APK, a protobuf read of the `.aab` manifest, then a check for leftover Gradle/Kotlin daemons).
- Still open for the owner: whether any split APKs (codes `1029`–`4032`) were given to other
  people. If yes, the next Play build number needs a one-time jump above the highest code given.
- Shared guidelines note (not edited, read-only submodule): `flutter_build_flavors_guide.md`
  and `platform_store_readiness.md` could mention the ABI offset and this switch.
