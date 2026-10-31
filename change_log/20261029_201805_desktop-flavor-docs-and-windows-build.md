# Fix desktop flavor docs and the Windows build error

Implements plan: `plans/20261029_200930_desktop-flavor-docs-and-windows-build.md`
(follow-up from `change_log/20261029_200349_remove-undeclared-platforms.md`)

## What changed

### Windows build
- `windows/CMakeLists.txt` — after `include(flutter/generated_plugins.cmake)`, defines
  `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` only for the targets
  `local_auth_windows_plugin` and `permission_handler_windows_plugin` (guarded with
  `if(TARGET ...)`), with a comment that it is temporary. Both plugins still compile with
  `/await`, and MSVC 14.51 rejected it with error STL1011. Their newest versions
  (`local_auth_windows` 2.0.2, `permission_handler_windows` 0.2.2) still use `/await`, so updating
  would not help. No plugin code was edited.

### Desktop flavor docs
`pubspec.yaml` sets `default-flavor: dev`, and Flutter applies it on Windows too, so a desktop
build without `--flavor` is a dev build. The Phase 2 docs said the opposite. Fixed:

- `CLAUDE.md`, `AGENTS.md` — Windows and Linux commands now pass `--flavor prod`; the comment
  explains why.
- `docs/release_process.md` — §5 explains `default-flavor: dev` and that desktop has no
  per-flavor native setup; §6.3, §11 and §11B commands pass `--flavor prod`; the Windows output
  path is now `build\windows\x64\prod\runner\Release\`; the Linux packaging note also requires
  `--flavor prod`.
- `docs/architecture.md` — §15 flavor line corrected; §21 adds the Windows workaround as a known
  risk with when to remove it.

## Checks
- `flutter build windows --flavor dev --debug` — built.
- `flutter build windows --flavor prod --release --obfuscate --split-debug-info=build/symbols/windows-prod-2.9.3+27/`
  — built into `build\windows\x64\prod\runner\Release\`; `FLUTTER_APP_FLAVOR=prod` in the
  generated config; `app.windows-x64.symbols` written.
- `flutter analyze` — no issues.
- `flutter test` — all 229 tests passed.
- Linux — not built (cannot be built on Windows); only the documented commands changed.
- No Gradle build ran in this change, so no Gradle daemons to stop.

## Not done
- The Windows app was built but not launched. Running it would show whether the plugins work at
  runtime on Windows (`docs/architecture.md` §15, Platform Differences, still `to verify`).
- Reporting the `/await` problem to the plugin authors is a separate, outward-facing step.
