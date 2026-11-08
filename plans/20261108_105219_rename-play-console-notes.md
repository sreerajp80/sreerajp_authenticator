# Use the new app name in the Play Console notes

**Status:** completed

Follows: `plans/20261108_104111_rename-app-display-name.md` (the app is now "Authenticator SP" in
English and "മുദ്രിക" / "मुद्रिका" in Malayalam / Sanskrit).

## The issue

The local Play Console notes in `play_closed_testing/` still use the old name
"Sreeraj P Authenticator" (and the Malayalam "ശ്രീരാജ് പി പ്രമാണീകാരി"). The most important
file is `store_listing.md`: its App name and full description are the text the user copies into
Play Console.

This folder is in `.gitignore`. These are local notes only and are never committed.

Important fact from `SUBMISSION_RECORD.md`: the app is **already live in closed testing**
(version 2.10.1 (29), released 31 Oct 2026, with testers). So:

- The store listing name can be changed now in Play Console. Play reviews the change before it
  shows.
- The name under the icon on testers' phones changes only when they install a **new build** that
  has the new `strings.xml`. Version 29 still shows "Sreeraj P Authenticator".
- I am not sure whether a listing change affects the 14-day closed-testing count. I believe it
  does not, because the count is about testers being opted in, not about the listing. The user
  should check Play Console's own message before saving.

## Files to change (all in `play_closed_testing/`, local only)

1. `store_listing.md`
   - Title line → "(Authenticator SP)".
   - §2 English **App name** → `Authenticator SP – Offline 2FA`.
   - §2 English full description, first sentence: "Sreeraj P Authenticator makes…" →
     "Authenticator SP makes…".
   - §3 Malayalam **App name** → `മുദ്രിക – ഓഫ്‌ലൈൻ 2FA`.
   - §3 Malayalam full description, first sentence: "…ശ്രീരാജ് പി പ്രമാണീകാരി നിർമ്മിക്കുന്നു" →
     "…മുദ്രിക നിർമ്മിക്കുന്നു".
   - Fix the §2 default-language note: Play really uses `en-IN` (as `SUBMISSION_RECORD.md` says),
     not `en-US`.
   - Add a short note at the top of §2: the name changed on 8 Nov 2026; the icon label changes
     only with the next build.
2. `PUBLISHING_GUIDE.md`
   - Title line → "(Authenticator SP)".
   - Step 1 "App name" row → `Authenticator SP – Offline 2FA`, with the note "Changed on
     8 Nov 2026; the app was created as Sreeraj P Authenticator".
3. `SUBMISSION_RECORD.md`
   - Title line → "(Authenticator SP)".
   - Submission 1 stays as it is. It is a record of what happened, and it happened under the old
     name. Add one line under "Store listing": "App name at submission: Sreeraj P Authenticator".
4. `app_content_answers.md`, `data_safety_answers.md` — title line only.

Not changed:

- Bundle file names and release names (`SreerajP_Authenticator-v…`). They follow the package id,
  which does not change, and they are already in Play's history.
- Graphics and screenshots. `graphics/app_icon_512.png` has no name on it.
  `docs/images/feature_graphic.png` may still show the old name; redrawing it is the user's job.

## Plan for the fix

1. Make the text edits above by hand (no blind find-and-replace, so the history in
   `SUBMISSION_RECORD.md` stays correct).
2. Search the folder for "Sreeraj P Authenticator" and "ശ്രീരാജ് പി പ്രമാണീകാരി" and check that
   only the intended history lines are left.
3. No code changes, so no build or test run is needed.
4. Write the change log.

## After this (user's steps in Play Console)

- Store presence → Main store listing → en-IN: set App name; update the full description.
- Same for the ml-IN listing.
- Send the change for review.
- The next uploaded build will carry the new icon label.

## Security impact

None. Local text notes only.
