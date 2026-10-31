# Remove undeclared platform folders (adoption Phase 4)

**Status:** completed

Part of master plan: `plans/20261029_183929_adopt-updated-guidelines.md` (Phase 4, gap G10).

**Security impact:** removes platform folders only. Smaller attack and maintenance surface. No
change to the Android, Windows or Linux apps, permissions, storage or network.

## What the issue is

`docs/PROJECT_PROFILE.md` §3 declares only Android, Windows and Linux. The guidelines say only
declared platforms are kept and touched (`AI_AGENT_START_HERE.md` §1 rule 4). The repository
still has three undeclared platform folders:

| Folder | Files tracked in git | Files on disk |
|---|---|---|
| `ios/` | 45 | 52 |
| `macos/` | 27 | 31 |
| `web/` | 7 | 7 |

The extra files on disk are generated or ignored files (for example Flutter ephemeral files).

Other leftovers:

- `pubspec.yaml` — the `flutter_launcher_icons` block still has `ios: true` and
  `remove_alpha_ios: true`, and `min_sdk_android: 21` (the app is now `minSdk 29`).
- `analysis_options.yaml` — `ios/**`, `web/**`, `macos/**` in the analyzer exclude list.
- `.gitignore` — iOS, macOS and web entries.
- The docs say the folders are "planned for removal" (Phase 2 text).

No Dart code checks for iOS, macOS or web (`Platform.isIOS`, `Platform.isMacOS`, `kIsWeb`,
`TargetPlatform.iOS/macOS`): nothing found in `lib/` or `test/`.

## Files to be changed

- Delete `ios/`, `macos/`, `web/` with `git rm -r` (tracked files) and remove the leftover
  untracked files in those folders. Git history keeps them; `flutter create --platforms=ios .`
  can bring a platform back later.
- `pubspec.yaml` — `flutter_launcher_icons`: remove `ios: true` and `remove_alpha_ios: true`;
  set `min_sdk_android: 29`.
- `analysis_options.yaml` — remove `ios/**`, `web/**`, `macos/**` from the exclude list (keep
  `build/**`, `android/**`, `windows/**`, `linux/**`).
- `.gitignore` — remove the iOS, macOS and web entries (lines for `ios/Flutter/...`,
  `ios/Pods/`, `ios/.symlinks/`, `macos/Flutter/...`, `web/dart.js`, `web/main.dart.js*`).
- `README.md`, `docs/PROJECT_PROFILE.md`, `docs/architecture.md`, `docs/project_structure.md`,
  `docs/implementation_progress.md` — change "planned for removal" to "removed"; drop the three
  folders from the project tree.
- `CLAUDE.md`, `AGENTS.md` — keep the "never create undeclared platform folders" rule; wording
  only if needed.

Not changed: `.metadata`. It is a Flutter tool file that still lists ios / macos / web from the
original `flutter create`. The stale entries are harmless, and editing tool files by hand is
avoided. `docs/guidelines/` is not touched.

## Plan for the fix

1. Remove the three folders and the leftovers listed above.
2. `flutter pub get`, `flutter analyze`, `flutter test`.
3. Build Android: `flutter build apk --flavor dev --debug`.
4. Build Windows: `flutter build windows --debug`, to prove the declared desktop platform still
   builds (Definition of Done §23.1: the change touched platform folders).
5. Linux cannot be built on this Windows machine. It is not affected by this change (no Linux
   file is touched); this is recorded in the change log as not checked.
6. `android\gradlew --stop` and end any leftover Gradle / Kotlin daemons.
7. Update the docs, write the change log, set this plan to `completed`.

## Risks

- None for the shipped app. If iOS, macOS or web is wanted later, it is re-created from
  `flutter create` and git history, with its own plan and a profile update first.
