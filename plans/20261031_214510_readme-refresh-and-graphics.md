# Refresh the README and show the store graphics on GitHub

**Status:** completed

## Files to change

- `README.md` (rewrite)
- `docs/images/feature_graphic.png` (new, copy)
- `docs/images/screenshots/01_accounts.png` to `08_languages.png` (8 new files, copies)
- `docs/project_structure.md` (add `images/` to the `docs/` tree)

**Security impact:** no app code, permission or dependency changes. The images become public. All
of them were checked by eye: they show only demo data (the "maya" sample accounts and a throw-away
transfer code). No real account, secret or personal data is visible.

## The issue

1. The README has a line about undeclared platforms that readers do not need.
2. The README has no pictures, so GitHub visitors cannot see the app.
3. The graphics are in `play_closed_testing/`, which is in `.gitignore`. A README link to that
   folder would show a broken image on GitHub, because the files are never pushed.
4. The README is out of date. It says things that are no longer true:
   - "No network permission": the app declares `INTERNET`, for local Wi-Fi sync only.
   - "Groups": the app now uses tags.
   - "Migration Support" and "older backup formats": only backup format `v3` can be read now.
   - `--dart-define=FLUTTER_APP_FLAVOR=...` in the commands: `docs/release_process.md` says never
     to pass this. Flutter sets it from `--flavor`.
   - The release commands leave out `--obfuscate` and `--split-debug-info`.
5. The README leaves out main features: Steam Guard, Blizzard and YubiKey accounts, Wi-Fi sync,
   optical sync, the three languages, lockdown mode, delete all data.

## The fix

### Images

Copy these from `play_closed_testing/` into a new tracked folder, `docs/images/`:

- `graphics/feature_graphic_1024x500.png`, as `feature_graphic.png`
- the 8 PNG files in `screenshots/`

Not copied: `screenshots/raw/`, `app_icon_512.png`, the `.aab` file and the local notes.
`play_closed_testing/` stays ignored. `.gitignore` does not change. Total added size is about 2.8 MB.

They do not go in `assets/`, because that folder is for files the app ships with.

### README layout

1. Feature graphic as a banner, then the title and a one-line description.
2. Small badges: Android 10+, Flutter, MIT license. These are static, so the page makes no calls to
   a service that tracks anything beyond the badge image itself.
3. Why this app: offline, no account, no tracking, open source.
4. Screenshots: a table of the 8 images at small width, so they fit on the GitHub page.
5. Features, corrected from `docs/features.md`: codes, accounts and tags, security, backup, moving to
   a new phone, languages.
6. Security model, corrected, with links to `docs/security.md` and `PRIVACY.md`. Keeps the
   "out of scope" note about rooted devices.
7. Availability: Android 10 or newer. Google Play closed testing is planned, so there is no store
   badge or store link yet.
8. Short "how to use" steps, updated.
9. Tech stack table, corrected.
10. Building from source: the commands from `CLAUDE.md`, flavors table, no `--dart-define`.
11. Tests, known limits, docs links (as real links), license (MIT).

The undeclared-platforms sentence is removed. "Android 10+" stays, in the availability section.

## Checks

- Every image path and doc link in the README points to a file that exists and is tracked or staged
  (`git check-ignore` reports none of the images).
- Check how the README renders in a Markdown preview, as far as it can be checked locally. The real
  GitHub page can only be checked after a push.
- No app code changes, so `flutter analyze` and `flutter test` are not needed.
- Nothing is committed or pushed unless asked.
