# Remove Windows and Linux support

**Status:** completed

**Security impact:** Touches platform folders only. Android permissions, storage, network use and
dependencies do not change. It removes the desktop security risks from the list, because those
platforms no longer ship.

## What the issue is

The project owner has decided the app does not need Windows or Linux support. Android is now the
only platform.

The repo still declares both platforms. It keeps their runner folders, build commands and release
steps, and it lists open risks that only apply to them. An audit also found that both desktop apps
very likely cannot run today: the database has no desktop setup, and the camera plugin has no desktop
support. So no working feature is lost.

## Files to be changed

**Delete**
- `windows/` (uncommitted edits in `windows/CMakeLists.txt`, `windows/runner/Runner.rc` and
  `windows/runner/main.cpp` are lost for good; the rest stays in Git history)
- `linux/`

**Edit**
- `docs/PROJECT_PROFILE.md`: §3 sets Windows and Linux to `no`, and the note names the removed folders.
- `CLAUDE.md`, `AGENTS.md`: platform and channel rows, desktop build commands, desktop signing note, and
  the "never create platform folders" list.
- `README.md`: the platforms sentence.
- `analysis_options.yaml`: remove the `windows/**` and `linux/**` excludes.
- `.gitignore`: remove the Windows and Linux sections.
- `docs/architecture.md`: platform list, flavor note, channel rows, the plugin support table columns,
  the release note, and the `local_auth_windows` risk.
- `docs/security.md`: platform list, build rule, §10 Windows and Linux parts, permission rows, uninstall
  notes, the three desktop risks in §17, and the permissions checklist line.
- `docs/release_process.md`: platform list, open blockers, flavor note, size commands, signing note,
  checklist lines, §11 and §11B, channel rows, and the Narrator / Orca / desktop keyboard lines.
- `docs/project_structure.md`: remove the two folder lines.
- `docs/features.md`: replace lines 30-33 with the true platform facts (Android only, minSdk 29).
- `docs/implementation_progress.md`: add this change under Phase 4 — Platforms.

## Plan for the fix

1. Delete `windows/` and `linux/`.
2. Update the files listed above, so that Android is the only declared platform.
3. Run `dart format .`, `flutter analyze` and `flutter test`.
4. Write the change log.

## Left unchanged on purpose

- `sqflite_common_ffi`: the database tests use it to run on the computer. It is a dev dependency and
  never ships in the app.
- `isWindowsHost` in `android/app/build.gradle.kts`, the PowerShell commands in
  `docs/release_process.md`, and `android/gradle.properties`: these are about the computer that does
  the build, not the app's platforms.
- `lib/utils/screen_protection.dart`, `lib/services/clipboard_service.dart` and their tests: the
  Android checks still work and are harmless. Removing them would touch screenshot protection for no
  gain.
- `.metadata`: the file says not to edit it by hand.
- `docs/GUIDELINES_MANIFEST.md` and `docs/guidelines/`: these describe the shared guidelines. The
  submodule is read-only.
- `docs/feature_analysis_and_roadmap.md`: the "Desktop Air-Bridge" idea stays, because it is a future
  idea for pushing codes from the phone to a PC, and it does not need a Windows or Linux build of this
  app.
- Old files in `plans/` and `change_log/`: they are history.

## Risks

- This is a large working tree with many uncommitted changes, so this removal would be hard to review
  alone. It is safer to commit the current work first.
- Bringing desktop back later means restoring the folders from Git history, or running `flutter create`,
  and then doing the desktop work that was never finished.
