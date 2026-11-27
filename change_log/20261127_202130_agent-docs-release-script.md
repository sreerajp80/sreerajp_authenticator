# Change log — Point CLAUDE.md and AGENTS.md to the release build script

Implements plan: [`plans/20261127_201937_agent-docs-release-script.md`](../plans/20261127_201937_agent-docs-release-script.md)

## What changed

In the "Build & run commands" section of `CLAUDE.md` and `AGENTS.md` (same text in both):

- Removed the two raw release commands (`flutter build apk …` and `flutter build appbundle …`).
  The APK one used the same symbols folder as the App Bundle, so it would overwrite the AAB
  symbols, and it left Flutter's `.sha1` files with no `.sha256`.
- Added a PowerShell block with the two `tool/build_release.ps1` commands (`-Target aab` and
  `-Target apk`), and a short note: the raw commands are in `docs/release_process.md` §9, and
  the APK symbols folder ends in `-apk/` so it never overwrites the AAB symbols.

Nothing else in the two files changed.

## Not changed

- The "Flutter SDK 3.47.6" line in both files (the build machine has 3.50.1). Left for a separate
  decision on which version the project targets.
