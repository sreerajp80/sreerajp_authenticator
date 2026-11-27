# Point CLAUDE.md and AGENTS.md to the release build script

**Status:** completed

## Files to change

| File | Change |
|------|--------|
| `CLAUDE.md` | "Build & run commands": release builds use `tool/build_release.ps1`; raw commands fixed. |
| `AGENTS.md` | Same change (it holds the same rules for other AI agents). |
| `change_log/<timestamp>_agent-docs-release-script.md` | New, after the change. |

## The issue

Plan `20261127_200945_release-build-script.md` added `tool/build_release.ps1`. But `CLAUDE.md`
and `AGENTS.md` still show only the raw `flutter build` commands, and the APK command uses the
old symbols folder `build/symbols/android-prod-<version>/`. That is the same folder as the App
Bundle, so following them would overwrite the AAB symbols and leave Flutter's `.sha1` files with
no `.sha256`. An AI agent reading these files would build the old way.

## The fix

In the "Build & run commands" section of both files:

1. Replace the two release blocks with the script:

   ```powershell
   # Production release (renames files, writes .sha256, removes .sha1, stops Gradle)
   .\tool\build_release.ps1 -Name SreerajP_Authenticator -Target aab   # Play Store bundle
   .\tool\build_release.ps1 -Name SreerajP_Authenticator -Target apk   # split APKs
   ```

2. Add a short note: options, rules and file names are in `docs/release_process.md` §9; the raw
   `flutter build` commands are listed there as "what the script runs with defaults", and the APK
   symbols folder ends in `-apk/` so it does not overwrite the AAB symbols.

Nothing else in the two files changes.

Not in this plan: the Flutter SDK line (both files say 3.47.6; the build machine has 3.50.1).
That needs a check of which version the project really targets, so it is left for a separate
change.

## Security impact

Docs only. No code, permission, storage or network change.
