# First release cleanup: Part 1

**Plan:** `plans/20261031_185346_first-release-cleanup.md` (still `in_progress`; Parts 2 and 3 are not done)

## What changed

### Build

- `android/app/build.gradle.kts`: removed the deleted `tool/generate_app_version.dart` and
  `lib/utils/app_version.g.dart` from `generateBuildMetadata`, and removed the template `TODO`.

### mOTP removed

- `lib/services/otp_service.dart`: removed mOTP code generation. `motp://` and `otpauth://motp/` links,
  and links with `algorithm=MOTP`, are now rejected. The `pin` link value is no longer read as a counter.
- An mOTP account left from an old version gets no code, so it can never show a wrong one.
- `lib/services/p2p_sync_service.dart`: a backup or sync file with an mOTP account is rejected through
  the existing error path. The whole file is rejected, not only that account.
- Tests and docs were updated (`docs/features.md`, `docs/architecture.md`,
  `docs/implementation_progress.md`, `docs/feature_analysis_and_roadmap.md`).

### Load error

- `AccountsProvider.loadFailed` is new. The home screen shows a clear message when loading fails,
  instead of looking like an empty vault.
- New ARB key `errorAccountsLoadFailed` in `en`, `ml` and `sa`, and a new provider test.

### Share text

- The backup share no longer adds fixed English text.

### Cleanup

- 20 old plans and change logs: local paths replaced with relative links or placeholders, and a sample
  LAN address replaced with a placeholder. Only those values changed. Some old links point to files
  that no longer exist.
- `CLAUDE.md`, `AGENTS.md`: removed "(once added)" from the parity test line.

## Differences from the plan

- The plan said 18 files, plus one to check. 20 needed the change, including the release-blockers plan.
- `docs/implementation_plan.md` still names mOTP. It is a record of an old milestone, so it was left.

## Checks

- `dart format` on the changed Dart files: no changes. `flutter gen-l10n` ran.
- `flutter analyze`, `flutter test` and a build have **not** been run. They are Part 2 and Part 3, for
  the owner. The new tests have never run.

## Translations to review

`errorAccountsLoadFailed` in `ml` and `sa` is a draft and needs the translation reviewer.
