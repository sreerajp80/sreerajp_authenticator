# Phase 6: tooltips and accessibility

**Status:** completed

Phase 6 of `plans/20261029_183929_adopt-updated-guidelines.md` (rule G4). Rules:
`docs/guidelines/flutter_project_engineering_standard.md` §7.

**Security impact:** none. No change to network, storage, sign-in, permissions or dependencies. Screen
readers may now say "show code" and similar labels, but they never read a hidden code aloud.

## What the issue is

I checked every `IconButton`, `InkWell`, `GestureDetector` and floating button in `lib/`.

### Controls with no accessible name (§7.8, mandatory)

| Where | Control | Missing |
|---|---|---|
| `lib/screens/backup_restore_screen.dart` (3), `lib/screens/home_screen.dart` (1) | Show/hide password | Tooltip |
| `lib/widgets/home/home_search_bar.dart`, `lib/widgets/home/home_tag_cloud_view.dart`, `lib/widgets/add_account/browse_tags_bottom_sheet.dart`, `lib/screens/tag_management_screen.dart` | Clear search | Tooltip |
| `lib/widgets/account_tile/otp_code_display.dart` | Eye button (an `InkWell`) | Tooltip and semantics; also only 32 × 32 |
| `lib/widgets/home/home_fab_button.dart` | Add account (a `GestureDetector`) | Tooltip and semantics |

### Harder problems

- **The add button cannot be used without a touch screen.** It is a bare `GestureDetector`, so it takes
  no keyboard focus (§7.5), and Windows and Linux are declared platforms. Manual entry is reachable only
  by long press, so a keyboard user cannot get to it at all.
- **The eye button is too small:** 32 × 32 dp against a 48 × 48 minimum on mobile (§7.1).
- **The "replace tags" text in the bulk tag dialog** (`lib/screens/home_screen.dart`) is a
  `GestureDetector` beside a checkbox, so a screen reader announces them as two unrelated things (§7.3).
- **The account tile does not say what a tap does.** Copying now depends on it (§7.3).
- **Contrast is below the rule in places (§7.2).** The input hint colour `#9CA3AF` on white is about
  2.5 : 1, and `primaryBlue` `#4A90E2` on white is about 3.3 : 1 where 4.5 : 1 is needed. There may be
  more; dark mode has not been measured at all.
- **Nothing tests text scaling at 1.5× and 2×** (§7.4), and there are about 50 fixed sizes in screens and
  widgets. Some will not fit, but I do not know which until the tests run.

## Plan for the fix

### 1. Add the checks first
New `test/accessibility/`, run on the main screens (lock, settings, security, backup, tag management,
sync, optical, add account, about, the account tile, and home if it can be opened in a test), in light
and dark:
- `androidTapTargetGuideline` and `labeledTapTargetGuideline` from `flutter_test`;
- `textContrastGuideline`, plus a table test that works out the ratio for each theme colour pair;
- no overflow at text scale 1.0, 1.5 and 2.0, in `en`, `ml` and `sa`.

The results decide the size of steps 4 and 5.

### 2. Names and semantics (`lib/screens/`, `lib/widgets/`)
- Add the 8 missing tooltips and the eye button's tooltip. Names describe the action, change with the
  state, and come from ARB.
- Eye button: a 48 × 48 tap area, with the visible 32 × 32 box unchanged. It uses the shared
  `IconButton` where it fits.
- Account tile: a semantic hint ("Copy code"). A hidden code is announced as hidden, never read out.
  The countdown is checked so that it does not speak every second.
- `MergeSemantics` for the checkbox and "replace tags" text, so tapping either changes it.

### 3. Add button (`lib/widgets/home/home_fab_button.dart`)
- Replace the bare `GestureDetector` with a focusable control, keeping the same look, haptics and tap
  action.
- Add a tooltip and semantic actions for tap (scan) and long press (more options).
- Right-click and Shift+F10 also open the options menu, so the keyboard and mouse can reach manual entry.

### 4. Contrast (`lib/utils/theme.dart` and any widget colours the tests flag)
Change only the pairs that fail, to the nearest colour that passes, keeping the look as close as
possible. The change log lists each pair with its before and after ratios (§7.7).

### 5. Text scaling
Fix what the tests find, using `Flexible`, wrapping or `minHeight` in place of fixed heights. Text scaling
is never turned off globally (§7.4).

### 6. Text
New keys in `app_en.arb`, `app_ml.arb`, `app_sa.arb`, about 8: show/hide password, clear search, show/hide
code, add account, copy hint, more options. Then `flutter gen-l10n`.

### 7. Docs
- `docs/release_process.md`: a pre-release checklist for what only a person can test (§7.6, §7.7): TalkBack
  on Android, Narrator on Windows, Orca on Linux, and Tab and Enter on desktop.
- `docs/implementation_progress.md`: Phase 6 ticked.
- Change log with the translations and the contrast table.

### 8. Checks
`dart format`, `flutter analyze`, `flutter test`, `flutter build apk --flavor dev --debug`, then stop the
Gradle daemons.

## Files to be changed

- `lib/widgets/account_tile.dart`, `lib/widgets/account_tile/otp_code_display.dart`,
  `lib/widgets/account_tile/timer_indicator.dart`
- `lib/widgets/home/home_fab_button.dart`, `home_search_bar.dart`, `home_tag_cloud_view.dart`
- `lib/widgets/add_account/browse_tags_bottom_sheet.dart`
- `lib/screens/backup_restore_screen.dart`, `lib/screens/home_screen.dart`,
  `lib/screens/tag_management_screen.dart`
- `lib/utils/theme.dart`
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`; generated `app_localizations*.dart`
- New tests in `test/accessibility/`
- `docs/release_process.md`, `docs/implementation_progress.md`
- **Unknown until step 1 runs:** other screens and widgets that fail the contrast, tap target or text scale
  tests. They will be listed in the change log.

## Risks

- **Size is not known yet.** If step 1 finds far more than expected, I will fix the tooltips, the add button
  and the eye button, then stop and show you the rest instead of guessing.
- **Colours will change slightly.** Passing contrast may make some blue text and hints visibly darker. You
  may want to look at this on a phone.
- **Tests cannot replace people.** They find missing labels and small targets, but not whether a screen makes
  sense when spoken. I can't run TalkBack, Narrator or Orca, so that stays on the checklist for you.
- **The automatic checks only see what is on screen.** Parts of a list that have not scrolled into view are
  not checked.

## Not in this plan

- Moving the help screens' copied layout widgets into one shared file.
- A full keyboard shortcut scheme for desktop.
