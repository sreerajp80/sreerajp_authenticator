# Remove undeclared platform folders (adoption Phase 4)

Implements plan: `plans/20261029_195359_remove-undeclared-platforms.md`
(part of `plans/20261029_183929_adopt-updated-guidelines.md`, Phase 4, gap G10)

## What changed

- Removed `ios/` (45 tracked files), `macos/` (27) and `web/` (7) with `git rm -r`, plus the
  Flutter-generated untracked files left in those folders. Git history keeps them.
- `pubspec.yaml` — `flutter_launcher_icons`: removed `ios: true` and `remove_alpha_ios: true`;
  `min_sdk_android` 21 → 29.
- `analysis_options.yaml` — removed `ios/**`, `web/**`, `macos/**` from the exclude list.
- `.gitignore` — removed the iOS, macOS and web entries.
- `README.md`, `docs/PROJECT_PROFILE.md`, `docs/architecture.md`, `docs/project_structure.md`,
  `docs/implementation_progress.md` — the folders are now described as removed.
- `.metadata` was not changed (Flutter tool file; stale platform entries are harmless).
- No file under `windows/`, `linux/`, `android/` or `lib/` changed.

During the doc edit, a script removed the "## 2. Goals And Non-Goals" heading block in
`docs/architecture.md` by mistake. It was restored right away; the heading count matches the
committed file.

## Checks

- `flutter pub get` — OK.
- `flutter analyze` — no issues.
- `flutter test` — all 229 tests passed.
- `flutter build apk --flavor dev --debug` — built.
- `flutter build windows --debug` — **failed**. Not caused by this change (no Windows file
  changed). The plugins `local_auth_windows` and `permission_handler_windows` use
  `<experimental/coroutine>`, which the installed MSVC 14.51 (Visual Studio 18) now rejects with
  error STL1011.
- Linux — not checked (cannot be built on Windows). No Linux file changed.
- Gradle daemons stopped; none left.

## Found, not fixed here

1. **Windows build is broken** with the current Visual Studio by two plugins (above). Options:
   update those plugins if newer versions fix it, or define
   `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` for those plugin targets in
   `windows/CMakeLists.txt` as a temporary workaround. Needs its own plan.
2. **Desktop builds use the `dev` flavor by default.** `pubspec.yaml` has `default-flavor: dev`,
   and the Windows build used it (`build/windows/x64/dev`, `FLUTTER_APP_FLAVOR=dev`). The Phase 2
   docs wrongly say Windows/Linux builds without `--flavor` default to `prod`. Release commands
   in `CLAUDE.md`, `AGENTS.md`, `docs/release_process.md` §5 / §6.3 / §11 / §11B and
   `docs/architecture.md` §15 must use `--flavor prod`. Needs a small doc-fix plan.
