# Small corrections before the release

**Plan:** `plans/20261031_221201_small-release-corrections.md`

## What changed

### Speed text

- `descOpticalSend` in `lib/l10n/app_en.arb`, `app_ml.arb` and `app_sa.arb` now says "10–15 FPS", which
  matches the 10, 12 and 15 FPS the sender offers. `flutter gen-l10n` updated the generated files.
- `docs/feature_analysis_and_roadmap.md`: the same number on two lines.

### Speed buttons

- `lib/screens/optical_sync_screen.dart`: `showSelectedIcon: false` on the speed `SegmentedButton`, so
  the selected button has no tick icon taking up width. It now shows as selected by its fill colour.

### Docs

- `docs/implementation_progress.md` and `docs/security.md`: five links now name the right plan files.
- `docs/release_process.md` and `docs/implementation_progress.md`: removed the "push `PRIVACY.md`" item,
  because the file is on `origin/main`. The phone test and §12 sign-off items stay.
- `docs/implementation_progress.md`: "Last updated" is now 2026-10-31.

## Checks

- Done: `dart format` on the changed screen made no changes. Every plan link in `docs/*.md` now points
  to a file that exists.
- **Not done, for the owner:** `flutter analyze` and `flutter test`.
- **Not done, for the owner:** opening the optical stream screen in `en`, `ml` and `sa`. It is not yet
  proven that the tick icon caused the wrapping, or that the buttons now stay on one line.
- Not checked: that the public `PRIVACY.md` URL opens. Only its presence on `origin/main` was checked.

## Other notes

- No new translation: only a number changed in the `ml` and `sa` text.
- These changes are not in the bundle in `play_closed_testing/`. They need a new build.
