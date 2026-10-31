# Phase 6: tooltips and accessibility

Implements plan: `plans/20261030_191550_phase-6-accessibility.md`
(Phase 6 of `plans/20261029_183929_adopt-updated-guidelines.md`)

**Security impact:** none. A hidden code is announced as "Code hidden" and never read out.

## What changed

### Names (engineering standard §7.3, §7.8)
- Tooltips added to 4 show/hide password buttons (`backup_restore_screen.dart`, `home_screen.dart`) and 4
  clear search buttons (`home_search_bar.dart`, `home_tag_cloud_view.dart`,
  `browse_tags_bottom_sheet.dart`, `tag_management_screen.dart`).
- `otp_code_display.dart`: the eye button has a tooltip and a screen reader name that follow its state.
- `account_tile.dart`: a screen reader hint says a tap copies the code. It is not given in selection mode.
- `timer_indicator.dart`: the countdown number is read as "N seconds".
- `home_screen.dart`: the checkbox and "replace tags" text are one item for a screen reader. The whole-screen
  activity detector is hidden from screen readers; it was an unnamed full-screen button.

### Add button (`home_fab_button.dart`)
It looks the same. It now takes keyboard focus, shows a focus ring and has a name. Enter scans. Shift+F10 and
right-click open the options menu, so manual entry can be reached without a touch screen. The scan now runs
on a completed tap.

### Tap target (§7.1)
The eye button keeps its 32 x 32 look inside a 48 x 48 tap area. **Tiles are slightly taller as a result.**

### Contrast (§7.2, §7.7)

| Pair | Before | Ratio | After | Ratio |
|---|---|---|---|---|
| `primaryBlue` text on white | #4A90E2 | 3.29 : 1 | #2B6CB8 | 5.33 : 1 |
| White text on `primaryBlue` | #4A90E2 | 3.29 : 1 | #2B6CB8 | 5.33 : 1 |
| `primaryBlue` text on the light page | #4A90E2 | 3.07 : 1 | #2B6CB8 | 4.97 : 1 |
| Input hint on white | #9CA3AF | 2.54 : 1 | #6B7280 | 4.83 : 1 |
| Tag summary label on white | #757575 | 4.61 : 1 | #4B5563 | 7.56 : 1 |

- `primaryBlue` in `lib/utils/theme.dart` is **visibly darker everywhere in the light theme**, including
  gradients and borders. Changing the one constant was cleaner than patching each use. The dark theme has its
  own colours, and all its measured pairs already passed.
- The tag summary label also went from 11 to 12 size and medium weight. At 11 thin text the automatic check
  measured below 4.5 : 1 even after the colour change, because small letters are drawn with soft edges.

### Text scaling (§7.4)
Every overflow came from 5 places, now fixed: `otp_code_display.dart` (the code scales down to stay on one
line), `about_screen.dart`, `tag_management_screen.dart`, `backup_restore_screen.dart` and
`advanced_settings_card.dart` (dropdowns).

### Text
8 new keys in `lib/l10n/app_{en,ml,sa}.arb`; generated files rebuilt.

### Tests
- New `test/accessibility/screen_accessibility_test.dart` and `screen_harness.dart`, on 16 screens: tap target,
  label and contrast checks in light and dark; no layout errors at 1.0, 1.5 and 2.0 in `en`, `ml`, `sa`. They
  use the app's real fonts, because the default test font would make widths meaningless.
- New `test/accessibility/theme_contrast_test.dart`: computed ratios for the main colour pairs in both themes.
- New `test/widgets/home/home_fab_button_a11y_test.dart`: tap, Tab + Enter, Shift+F10, right-click.
- `test/widgets/account_tile_copy_test.dart`: a hidden code is announced as hidden, never read out.

### Docs
- `docs/release_process.md`: a pre-release checklist for what only a person can test.
- `docs/implementation_progress.md`: Phase 6 ticked.

## Checks

- `dart format`: no changes left.
- `flutter analyze`: no issues.
- `flutter test`: all tests pass.
- `flutter build apk --flavor dev --debug`: built. Gradle daemons stopped afterwards.

## Not checked

- No real screen reader (TalkBack, Narrator, Orca) and no real phone. These are on the new checklist.
- Camera screens (QR scanner, optical receive) and the optical send screen are not in the automatic checks.
- The tap, label and contrast checks see only what is on screen at first, because they do not scroll. The layout
  checks do scroll. Help screens other than Help home and FAQ were not run through these checks.
- Keyboard order across whole screens was not tested; only the add button was.
- Dialogs were not opened by the checks, so a dialog's own layout at 2x is not covered.

## Translations: needs native-reader review

Draft by the AI agent. Least sure: `गोप्यताम्` (hide), `योजनविकल्पाः` (more ways to add).

| Key | English | Malayalam | Sanskrit |
|---|---|---|---|
| `tooltipShowPassword` | Show password | രഹസ്യവാക്ക് കാണിക്കുക | गुप्तशब्दः दर्श्यताम् |
| `tooltipHidePassword` | Hide password | രഹസ്യവാക്ക് മറയ്ക്കുക | गुप्तशब्दः गोप्यताम् |
| `tooltipClearSearch` | Clear search | തിരയൽ മായ്ക്കുക | अन्वेषणं मार्ज्यताम् |
| `tooltipShowCode` | Show code | കോഡ് കാണിക്കുക | सङ्केतः दर्श्यताम् |
| `tooltipHideCode` | Hide code | കോഡ് മറയ്ക്കുക | सङ्केतः गोप्यताम् |
| `tooltipAddAccount` | Add account | അക്കൗണ്ട് ചേർക്കുക | विवरणं योज्यताम् |
| `tooltipAddOptions` | More ways to add | ചേർക്കാനുള്ള വഴികൾ | योजनविकल्पाः |
| `descCodeHidden` | Code hidden | കോഡ് മറച്ചിരിക്കുന്നു | सङ्केतः गुप्तः |
