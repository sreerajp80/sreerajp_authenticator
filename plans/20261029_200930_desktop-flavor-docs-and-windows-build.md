# Fix desktop flavor docs and the Windows build error

**Status:** completed

Follow-up from `change_log/20261029_200349_remove-undeclared-platforms.md` (part of
`plans/20261029_183929_adopt-updated-guidelines.md`).

**Security impact:** the docs fix stops a wrong release command that would ship a `dev` build
(verbose logging on, dev banner) as a Windows or Linux release. The Windows build change only
silences a compiler deprecation error for two plugins; no app behavior, permission, storage or
network change.

## What the issues are

### 1. Desktop builds use the `dev` flavor by default

`pubspec.yaml` has `default-flavor: dev`. Flutter applies it on Windows too: a plain
`flutter build windows` built into `build/windows/x64/dev` with `FLUTTER_APP_FLAVOR=dev`.

The Phase 2 docs wrongly say Windows and Linux builds without `--flavor` default to `prod`. A
release built from those commands would be a **dev** build (`AppFlavorConfig.isDev`: verbose
logging and the dev banner). Wrong text in:

- `CLAUDE.md` and `AGENTS.md` — build commands block (comment and two commands)
- `docs/release_process.md` — §5 notes, §6.3 size-analysis commands, §11 and §11B build commands
- `docs/architecture.md` — §15 "Flavors used"

`flutter build windows -h` and `flutter build linux -h` both list `--flavor`, so the fix is to
pass `--flavor prod` (and `--flavor dev` for desktop dev runs).

Note: the Windows and Linux runners have no per-flavor native setup (same window title, same
binary name and app identity for dev and prod). Only the Dart side changes with the flavor. That
is recorded in the docs; adding native desktop flavors is not part of this plan.

### 2. The Windows build fails with the current Visual Studio

`flutter build windows` fails in the plugins `local_auth_windows` and
`permission_handler_windows`. Both compile with `/await` (old experimental coroutines). The
installed MSVC 14.51 (Visual Studio 18) now stops with error STL1011 unless
`_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` is defined.

Updating does not help: the newest versions (`local_auth_windows` 2.0.2,
`permission_handler_windows` 0.2.2) still use `/await`. The plugin code is in the pub cache and
must not be edited.

## Files to be changed

- `windows/CMakeLists.txt` — right after `include(flutter/generated_plugins.cmake)`, add a short
  block that defines `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` only for the targets
  `local_auth_windows_plugin` and `permission_handler_windows_plugin` (guarded with
  `if(TARGET ...)`), with a comment that it is temporary and why.
- `CLAUDE.md`, `AGENTS.md` — desktop commands use `--flavor prod`; fix the comment.
- `docs/release_process.md` — §5, §6.3, §11, §11B: `--flavor prod`; state that desktop has no
  native flavor setup and that a build without `--flavor` is `dev`.
- `docs/architecture.md` — §15 flavor line; §21 add the Windows workaround as a known risk
  (remove it when the plugins move to C++20 coroutines; Microsoft says the old support will be
  removed, and then this workaround stops working).

Not changed: plugin code in the pub cache, `pubspec.yaml`, `linux/`.

## Plan for the fix

1. Edit `windows/CMakeLists.txt` as above.
2. Run `flutter build windows --flavor dev --debug`; it must build.
3. Run `flutter build windows --flavor prod --release --obfuscate
   --split-debug-info=build/symbols/windows-prod-<version>/` once, to prove the documented
   release command works and builds into the `prod` folder.
4. Fix the doc lines listed above.
5. `flutter analyze` and `flutter test` (no Dart change expected; run as a check).
6. Linux cannot be built here; the Linux commands are fixed in the docs only, and the change log
   says Linux was not built.
7. Write the change log and set this plan to `completed`.

## Risks

- The workaround hides a deprecation, not a real bug in this app. When Microsoft removes the old
  coroutine headers, the Windows build will fail again unless the plugins are updated first.
  This is recorded in `docs/architecture.md` §21 so it is checked at each dependency update.
- Proposing the fix upstream to the plugin authors is a separate, outward-facing step; it is not
  part of this plan.
