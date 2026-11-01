# Small corrections before the release

**Status:** completed

## Files to change

| Area | Files |
|---|---|
| Speed text | `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb`, generated `lib/l10n/app_localizations*.dart` (by `flutter gen-l10n`, not by hand), `docs/feature_analysis_and_roadmap.md` |
| Speed buttons | `lib/screens/optical_sync_screen.dart` |
| Broken links | `docs/implementation_progress.md`, `docs/security.md` |
| Stale text | `docs/release_process.md`, `docs/implementation_progress.md` |

`docs/guidelines/` is not touched.

**Security impact:** none. No change to network, storage, permissions, dependencies or platform folders.

## The issues

1. **Wrong speed text.** The Sync screen says the optical stream runs at "12–15 FPS", but the sender
   offers 10, 12 and 15 FPS. The roadmap doc says the same on lines 57 and 64.
2. **Button text wraps.** On the optical stream screen, the selected "12 FPS" button wraps onto two
   lines. This was reported in `change_log/20261031_194900_play-closed-testing-docs.md`. The likely
   cause is the tick icon that `SegmentedButton` adds to the selected button, which takes up width.
   This cause comes from reading the code. It has not been seen on a screen yet.
3. **Broken links.** Five links name plan files that do not exist, because the time in the file name
   is wrong:

   | Place | Wrong name | Right name |
   |---|---|---|
   | `docs/implementation_progress.md` line 28 | `20261031_085346_first-release-cleanup.md` | `20261031_185346_first-release-cleanup.md` |
   | `docs/implementation_progress.md` line 43 | `20261031_074327_remove-windows-linux.md` | `20261031_174327_remove-windows-linux.md` |
   | `docs/implementation_progress.md` line 51 | `20261031_081352_android-release-blockers.md` | `20261031_181352_android-release-blockers.md` |
   | `docs/security.md` line 27 (two links) | `20261031_081352_android-release-blockers.md` | `20261031_181352_android-release-blockers.md` |

4. **Stale text.** `docs/release_process.md` line 26 and `docs/implementation_progress.md` line 51 say
   `PRIVACY.md` still has to be pushed. It is already on `origin/main`. The "Last updated" date in
   `docs/implementation_progress.md` is also old.

## The fix

1. Change "12–15 FPS" to "10–15 FPS" in `descOpticalSend` in all three ARB files, and in the two roadmap
   lines. Only the number changes, so no new translation is needed. Run `flutter gen-l10n`.
2. Set `showSelectedIcon: false` on the `SegmentedButton`. The selected button still shows by its fill
   colour, and screen readers still announce it as selected. If the text still wraps after this, stop
   and bring it back to the owner, because moving the "Target FPS:" label above the buttons is a larger
   layout change.
3. Correct the five links.
4. Remove the `PRIVACY.md` push item from both docs. Keep the phone test and §12 sign-off items. Set
   "Last updated" to 2026-10-31.

## Not in this plan

- `docs/implementation_plan.md` still names mOTP. It is a record of an old milestone, so it stays.
- Version number and bundle. These text and button changes are not in the bundle in
  `play_closed_testing/`, so they reach users only with a new build.
- The other release steps in `plans/20261031_185346_first-release-cleanup.md`.

## Checks

The owner runs these, and Claude helps read the results:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Then open the optical stream screen in `en`, `ml` and `sa`, and check that all three speed buttons stay
on one line and the selected one is easy to see.

After that, write the change log.
