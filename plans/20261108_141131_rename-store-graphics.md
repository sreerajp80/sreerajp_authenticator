# Put the new app name on the store graphics

**Status:** completed

Follows: `plans/20261108_104111_rename-app-display-name.md` and
`plans/20261108_105219_rename-play-console-notes.md`.

## The issue

Three store images still show the old name "Sreeraj P Authenticator":

| Image | Where the old name is |
|---|---|
| `docs/images/feature_graphic.png` (1024 × 500) | The large title text |
| `docs/images/screenshots/01_accounts.png` (1080 × 1920) | The app bar title |
| `docs/images/screenshots/02_tags.png` (1080 × 1920) | The app bar title |

The README on GitHub and the Play listing both use these files. Screenshot 08 is clean. The app icon
has no text.

The Malayalam Play listing is now called "മുദ്രിക – ഓഫ്‌ലൈൻ 2FA", but it has no feature graphic of
its own, so it shows the English one.

## Approach (user's choice: edit the images, do not retake)

Editing is honest here because the app code now shows "Authenticator SP" in the app bar. The edited
screenshots match what a new build really shows. The one difference is the font: the app's own
font is not installed on this PC, so the new title uses the closest installed font. Fonts:

- English: Noto Sans Bold (installed). The original feature graphic font is not installed.
- Malayalam: Manjari Bold (installed).

A Python script (Pillow), kept in the session scratchpad and not in the project, does the edits:

1. **Remove the old text.** For the box around the old text, rebuild each pixel by blending the
   clean row just above the box with the clean row just below it. The backgrounds are smooth
   gradients, so this leaves no visible patch.
2. **Draw the new text** in white, centered in the same place, at a size that matches the old text
   height. In the app bar, the title stays on one line and keeps the same middle line.
3. **Feature graphic layout:** title `Authenticator SP` on one line (about 530 px wide, fits in
   the space to the right of the shield). The tagline "Two-factor codes, encrypted on your phone"
   stays. Both lines are moved up or down a little so the block is centered next to the shield.
4. **New Malayalam feature graphic** `docs/images/feature_graphic_ml.png` (1024 × 500): same
   background and shield, title `മുദ്രിക`, tagline `ഫോണിൽ എൻക്രിപ്റ്റ് ചെയ്ത ടു-ഫാക്ടർ കോഡുകൾ`
   (taken from the Malayalam short description already in the store listing).
5. Check each result by eye at full size. Check that sizes are unchanged and that there is no
   transparency (a Play rule for the feature graphic).
6. Look at screenshots 03–07 too. If any of them shows the old name, stop and tell the user before
   editing it.

## Files to change

- `docs/images/feature_graphic.png` — replaced.
- `docs/images/screenshots/01_accounts.png` — replaced.
- `docs/images/screenshots/02_tags.png` — replaced.
- `docs/images/feature_graphic_ml.png` — new.
- `play_closed_testing/store_listing.md` (local, gitignored) — §4 Graphics: add the Malayalam
  feature graphic for the ml-IN listing.

The old images stay in git history, so they can be brought back if needed.

Not changed: raw screenshots in `play_closed_testing/screenshots/raw/`, the app icon, the README
(it already points at `feature_graphic.png`).

## After this (user's steps)

- Upload the new feature graphic and screenshots 01 and 02 to the en-IN listing in Play Console.
- Upload `feature_graphic_ml.png` to the ml-IN listing.
- Send the changes for review.

## Translation review (flag)

- The Malayalam tagline is copied from the existing ml short description. Please check it reads
  well on a banner.

## Security impact

None. Image files and local notes only.
