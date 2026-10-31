# Remove Windows and Linux support

Implements `plans/20261031_174327_remove-windows-linux.md`. Plan status: `completed`.

The owner decided the app does not need Windows or Linux. Android is now the only declared platform.

## What changed

- **Deleted:** `windows/` and `linux/`. Uncommitted edits to `windows/CMakeLists.txt`,
  `windows/runner/Runner.rc` and `windows/runner/main.cpp` were lost, as the plan warned. The
  committed versions of both folders stay in Git history.
- **Config:** removed the desktop excludes from `analysis_options.yaml` and the desktop sections from
  `.gitignore`.
- **Project files:** `docs/PROJECT_PROFILE.md` §3 now says `no` for both platforms. `CLAUDE.md`,
  `AGENTS.md` and `README.md` say Android only, and the desktop build commands and signing note are gone.
- **`docs/architecture.md`:** removed the desktop channel rows, the "Platform Differences" table and the
  `local_auth_windows` risk.
- **`docs/security.md`:** removed the Windows and Linux parts of §10, the permission rows, the uninstall
  notes and the desktop risks in §17.
- **`docs/release_process.md`:** §11 and §11B now say "Not a declared platform", and the desktop
  commands, gates and checklist lines are gone.
- **Other docs:** `docs/project_structure.md`, `docs/implementation_progress.md`, and the platform lines
  in `docs/features.md` (these now also give the correct minSdk, 29).

No Dart code, Android file, dependency or permission changed.

## Left unchanged on purpose

- `sqflite_common_ffi`: the database tests use it. It is a dev dependency and never ships.
- `isWindowsHost` in `android/app/build.gradle.kts` and the PowerShell commands in
  `docs/release_process.md`: these are about the computer that does the build.
- The Android checks in `lib/utils/screen_protection.dart` and `lib/services/clipboard_service.dart`, and
  their tests.
- `.metadata`, `docs/GUIDELINES_MANIFEST.md`, `docs/feature_analysis_and_roadmap.md`, and old plans and
  change logs.
- `*.msix` in `.gitignore`: a general release-file rule that does no harm.

## Checks

- `dart format`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: 558 passed.

No Android build was run, because no Android file changed.

## Translations

No text was added, so no translation needs review.
