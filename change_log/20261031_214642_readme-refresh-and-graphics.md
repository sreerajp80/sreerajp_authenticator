# Refresh the README and show the store graphics on GitHub

Implements `plans/20261031_214510_readme-refresh-and-graphics.md`.

## What changed

- `README.md`: rewritten.
  - Removed the sentence about undeclared platforms.
  - Added the feature graphic as a banner, badges, a "Why This App" section and a screenshots table.
  - Added missing features: Steam Guard, Blizzard and YubiKey accounts, Wi-Fi sync, optical sync,
    languages, lockdown mode and delete all data.
  - Corrected out-of-date facts: the `INTERNET` permission is now stated and explained, groups became
    tags, and the old migration and older backup format claims are gone.
  - Build commands now match `CLAUDE.md`: no `--dart-define`, and release commands use `--obfuscate`
    and `--split-debug-info`.
  - Added an Availability section. There is no store badge, because Google Play closed testing is
    only planned.
- `docs/images/feature_graphic.png`: new, copied from the local Play folder.
- `docs/images/screenshots/01_accounts.png` to `08_languages.png`: new, copied from the local Play
  folder.
- `docs/project_structure.md`: added `images/` to the `docs/` tree.

`play_closed_testing/` stays ignored and `.gitignore` was not changed by this work.

## Checks

- Every image and document path in the README exists.
- `git check-ignore` confirms the images are not ignored.
- All images were checked by eye. They show demo data only.
- App code did not change, so `flutter analyze` and `flutter test` were not run.
- Not checked: how the page looks on GitHub. No Markdown preview was run, and this can only be
  confirmed after a push. The badges load from `img.shields.io` when the page is viewed.
