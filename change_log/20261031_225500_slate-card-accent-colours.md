# Slate account card, cleaner home screen, and accent colours

Implements `plans/20261031_223001_slate-card-accent-colours.md`.

## What changed

**Account card** (`lib/widgets/account_tile.dart` and `lib/widgets/account_tile/`)
- New solid raised card with layered soft shadows and a thin light top edge.
- The eye icon now sits right next to the code, with a plain icon and the same 48 x 48 tap area.
- Flat tinted avatar. Brand icons sit on a white tile, so dark icons stay visible in the dark theme.
- The first tag shows, then `+N`. A screen reader hears all the tags.
- The timer uses the accent and turns red for the last 5 seconds.
- `pattern_painter.dart` is deleted, since nothing else used it.

**Gestures kept, with no change in behaviour**
- Tap to copy, or to select in selection mode.
- Eye button to show or hide the code.
- Long press to start selection, and long press to toggle in selection mode.
- Swipe for Edit and Delete (the Edit action now uses the accent colour).
- Drag to reorder in manual sort.
- Refresh button for HOTP accounts.
- Press-down scale effect.

**Home screen**
- Plain header with the accent on the active tab, and a light accent tint in selection mode.
- Status bar icons now match the light or dark header.
- Flat page background, plain search bar, and an add button in the accent colour.
- Banners, empty state, tag cloud and tag summary use theme colours. Selected tags in the tag
  cloud now use `onPrimary` instead of white, so they stay readable in the dark theme.

**Accent colours**
- `AppAccent` in `lib/utils/theme.dart`: Blue, Teal, Indigo, Green, Copper, Graphite, each with a
  light and a dark shade. The theme is built from the accent and cached per accent.
- `ThemeProvider` saves the choice by name as `accent_color`. An unknown name falls back to Blue.
- New `lib/screens/accent_color_settings_screen.dart`, opened from a new row in Appearance.

**Text**
- New keys in all three ARB files for the row, the section label and the six colour names.
- `descVisualDesign` is reworded in all three languages, since it described the old glowing
  neumorphic look. This was not listed in the plan.

**Tests and docs**
- The contrast test now runs for every accent in both themes.
- New tests: saving and loading the accent, fallback to Blue, the eye beside the code, `+N` tags,
  and long press.
- `docs/features.md` and `docs/architecture.md` are updated.

## Differences from the plan

- `lib/screens/settings_screen.dart` and `lib/screens/permissions_screen.dart` needed no change.
  Their `AppTheme` uses are the shared decoration and status colours, not fixed blue or mint.

## Checks

- `flutter gen-l10n`, `dart format`: done.
- `flutter analyze`: no issues.
- `flutter test`: all 698 tests pass.
- Not checked on a device or emulator. The look in light and dark, each accent, and swipe and drag
  on a real screen still need a person to check them.
- Not checked: whether a non-default accent shows Blue for a moment at app start (the plan's known
  risk). The accent loads the same way as the theme mode.

## Translations to review

These are my own translations. Please have them reviewed:
- Malayalam: `titleAccentColor` (പ്രധാന നിറം), `labelAccentTeal` (നീലപ്പച്ച), `labelAccentIndigo`
  (കരിനീല), `labelAccentGraphite` (ഗ്രാഫൈറ്റ്), and the new `descVisualDesign`.
- Sanskrit: `titleAccentColor` (प्रधानवर्णः), `labelAccentTeal` (हरितनीलः), `labelAccentIndigo`
  (श्यामनीलः), `labelAccentGraphite` (धूसरः, which means grey), and the new `descVisualDesign`.
