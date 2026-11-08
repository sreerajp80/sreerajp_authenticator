# Change log: new app name in the Play Console notes

Implements plan: `plans/20261108_105219_rename-play-console-notes.md`

All changes are in `play_closed_testing/`, which is in `.gitignore` (local notes, never committed).

## What changed

- `store_listing.md`
  - Title line now says "Authenticator SP".
  - English App name: `Authenticator SP – Offline 2FA`.
  - English full description starts "Authenticator SP makes…".
  - Malayalam App name: `മുദ്രിക – ഓഫ്‌ലൈൻ 2FA`.
  - Malayalam full description now names the app "മുദ്രിക".
  - §2 heading and note now say the default listing language is `en-IN`, matching
    `SUBMISSION_RECORD.md`.
  - New note: the name changed on 8 Nov 2026, and testers see the new icon label only after a new
    build.
- `PUBLISHING_GUIDE.md` — title line; Step 1 "App name" row shows the new title and records the
  original name.
- `SUBMISSION_RECORD.md` — title line; one new row "App name at submission: Sreeraj P
  Authenticator". Submission 1 is otherwise unchanged.
- `app_content_answers.md`, `data_safety_answers.md` — title line only.

## Checks

- A search of the folder for the old English and Malayalam names finds only the three history
  lines that are meant to keep it.
- No code changed, so no build or test run was needed.

## Left as it is (noted for the user)

- `PUBLISHING_GUIDE.md` Step 1 still says "Default language: en-US" (the advice given at create
  time), and the release-notes block uses `<en-US>` tags. Play's real default is `en-IN`.
  Play Console will show the right tag when release notes are pasted.
- Bundle file names and release names keep `SreerajP_Authenticator`, which follows the package id.
- The user still has to change both listings in Play Console and send them for review.
