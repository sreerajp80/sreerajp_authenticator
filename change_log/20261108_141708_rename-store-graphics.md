# Change log: new app name on the store graphics

Implements plan: `plans/20261108_141131_rename-store-graphics.md`

## What changed

- `docs/images/feature_graphic.png` — the title now reads "Authenticator SP" on one line. The
  shield, lock and tagline stay. The title and tagline are redrawn in Noto Sans and centered
  next to the shield.
- `docs/images/screenshots/01_accounts.png`, `02_tags.png` — the app bar title now reads
  "Authenticator SP", in Noto Sans Bold with a soft drop shadow like the original.
- `docs/images/feature_graphic_ml.png` — new Malayalam feature graphic for the ml-IN listing:
  title "മുദ്രിക", tagline "ഫോണിൽ എൻക്രിപ്റ്റ് ചെയ്ത ടു-ഫാക്ടർ കോഡുകൾ", in Manjari.
- `play_closed_testing/store_listing.md` (local, gitignored) — §4 Graphics lists the Malayalam
  feature graphic.

## How it was done

- The old text was removed by blending the clean pixel rows just above and below it, column by
  column. The backgrounds are smooth gradients, so no patch shows at normal size.
- English text: Python with Pillow. Sizes were matched to the width of the old text.
- Malayalam text: Pillow on this machine cannot join Malayalam letters (no text-shaping library),
  so the Malayalam text was drawn with Windows' WPF text engine and then placed on the image.
- The scripts were throw-away and live outside the project.

## Checks

- All four images keep their sizes (1024 × 500 and 1080 × 1920) and have no transparency.
- Each result was checked by eye at full size.
- Screenshots 03–08 were checked; they do not show the app name, so they did not change.
- The old images are still in git history.

## Notes

- The font differs a little from the original: the original fonts are not installed here.
- Translation review: the Malayalam tagline is copied from the ml short description. Please check
  that it reads well on a banner.
- Still to do in Play Console (user): upload the new feature graphic and screenshots 01 and 02 to
  the en-IN listing, upload `feature_graphic_ml.png` to the ml-IN listing, and send for review.
