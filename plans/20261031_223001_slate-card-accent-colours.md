# Slate account card, cleaner home screen, and accent colours

**Status:** completed

**Security impact:** Storage only. One new non-secret value (the accent name) is saved in
SharedPreferences. No change to permissions, network, encryption, `FLAG_SECURE` or dependencies.

## Issue

The home screen looks like a toy. The causes are the line pattern and blurred gradients on the
card, the glossy avatar and eye button, the large blue gradient header, the white-to-blue page
background, and too many colours on one card. The user chose design "A, Slate" from the mocks.

The app also has one fixed colour set. The user wants to choose an accent colour in Settings.

## Design decisions

**Card layout**

```
[avatar]  Issuer                         (timer ring)
          account name
-----------------------------------------------------
482 913 [eye]                       #Work  +1
```

- The eye icon sits right next to the code, not at the far right of the card as in the mock.
  This was the user's request after the mock.
- The card is a solid surface with soft layered shadows and a thin light top edge. This keeps the
  3D look. The press effect stays.
- Only the code and timer use the accent. The avatar is a plain light tint of the accent with no
  shine. Brand icons still show when an account has one.
- The eye keeps its 48 x 48 tap area (standard §7.1), but its glossy box is removed.
- The tag row shows the first tag and then `+N` if there are more, because a long row of tags
  would not fit beside an 8-digit code. All tags are still reachable from the Tags tab.
- HOTP accounts keep the refresh button in place of the timer. Selection mode keeps its check icon.

**Timer**

- It uses the accent, and turns red for the last 5 seconds. The current green, amber and red
  steps are removed. A timer with a period other than 30 seconds follows the same rule.

**Home screen**

- The header becomes a plain surface with dark text, and the active tab uses the accent. Selection
  mode gets a light accent tint on the header, so it still looks different from normal mode.
- The page background becomes one flat colour. The search bar becomes a plain surface with a
  hairline border. The add button uses the accent.

**Accent colours**

| Name | Light theme | Dark theme |
|------|-------------|------------|
| Blue (default) | `#2456C9` | `#7AA2FF` |
| Teal | `#0F766E` | `#4FD1C0` |
| Indigo | `#5B45C4` | `#A99BFF` |
| Green | `#2E7D4F` | `#6FCF97` |
| Copper | `#A8521E` | `#E9A26E` |
| Graphite | `#3D4656` | `#AEB8C8` |

- A fixed list, not a free colour picker, so every choice can be tested for readable contrast.
- No red, because red means "code about to expire" and errors.
- The choice applies at once with no restart, and is saved by name, so adding or reordering
  colours later cannot change someone's choice. An unknown saved name falls back to Blue.
- The accent stays on the device. It is not added to Wi-Fi sync settings, to keep this change small.
- The "secondary" theme colour will come from the accent too. Otherwise, gradients on other
  screens would mix, for example, copper with today's mint green.

## Out of scope

Other screens (lock screen, splash, settings, help) get the new accent colours where they already
use theme colours, but their layouts and hard-coded gradients are not redesigned here. If they
look out of place next to the new home screen, that is a separate plan.

## Files to change

**Theme and state**
- `lib/utils/theme.dart`: add the accent list; build light and dark themes from an accent; add a
  shared card decoration; keep `lightTheme` / `darkTheme` as the Blue default.
- `lib/providers/theme_provider.dart`: load, save and expose the accent; `reload()` covers it too.
- `lib/main.dart`: build `theme` and `darkTheme` from the chosen accent.

**Card**
- `lib/widgets/account_tile.dart`: new layout and surface; remove the pattern and gradient layers.
- `lib/widgets/account_tile/otp_code_display.dart`: plain eye icon next to the code.
- `lib/widgets/account_tile/account_avatar.dart`: flat tinted avatar.
- `lib/widgets/account_tile/timer_indicator.dart`: accent colour, red for the last 5 seconds.
- `lib/widgets/account_tile/pattern_painter.dart`: delete (only the card uses it).

**Home screen**
- `lib/screens/home_screen.dart`: plain header, flat background, banners use theme colours.
- `lib/widgets/home/home_search_bar.dart`, `home_fab_button.dart`, `home_empty_state.dart`,
  `home_tag_cloud_view.dart`: replace fixed blue and mint with theme colours.

**Fixed colours that should follow the accent**
- `lib/screens/tag_management_screen.dart`, `lib/screens/permissions_screen.dart`,
  `lib/screens/settings_screen.dart`: replace `AppTheme` blue and mint uses with theme colours.

**Settings**
- `lib/screens/accent_color_settings_screen.dart` (new): list of colour swatches with names and a
  check mark on the current one, built like `theme_mode_settings_screen.dart`.
- `lib/screens/appearance_screen.dart`: add an "Accent colour" row that opens the new screen.

**Text**
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`: new keys for the row title, screen title and
  six colour names, with real Malayalam and Sanskrit translations. Then run `flutter gen-l10n`.
  Translations I am unsure of will be flagged in the change log.

**Tests and docs**
- `test/accessibility/theme_contrast_test.dart`: run the contrast pairs for every accent in both themes.
- `test/providers/theme_provider_test.dart`: save, load, unknown name falls back to Blue.
- `test/widgets/account_tile_*_test.dart`: update if the new layout needs it; add a check that the
  eye sits beside the code, and that extra tags show as `+N`.
- `docs/features.md`, `docs/architecture.md`: describe the accent setting and the new provider field.

## Checks

- `dart format .`, `flutter analyze`, `flutter test`.
- The user runs the dev flavor and checks light mode, dark mode, each accent, 6- and 8-digit codes,
  HOTP, selection mode, several tags, and Malayalam and Sanskrit text.

## Known risk

The accent loads when the app starts, like the theme mode does today. A person with a non-default
accent could see Blue for a moment. I will check this and read it before the first frame if needed.
