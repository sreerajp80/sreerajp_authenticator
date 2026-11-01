# Keep the store images in one place

**Status:** completed

## Files to change

- `play_closed_testing/PUBLISHING_GUIDE.md` (local only, ignored by git)
- `play_closed_testing/store_listing.md` (local only, ignored by git)
- Delete from `play_closed_testing/` (local only, ignored by git):
  - `graphics/feature_graphic_1024x500.png`
  - `screenshots/01_accounts.png` to `08_languages.png`

No tracked file changes except this plan and its change log.

**Security impact:** none. No app code changes. `docs/images/` is already planned to be public.

## The issue

The feature graphic and the 8 screenshots now exist in two folders. If one copy is retaken, the
other goes out of date without any warning, and GitHub could show old images.

## The fix

`docs/images/` becomes the only home of these 9 images, as it is the one git tracks.

1. Before deleting anything, `docs/images/` must be committed. The Play folder is ignored by git, so
   its files have no history. After the delete, the git commit is the backup. The user commits, or
   tells Claude to.
2. Compare the copies again by hash, just before deleting. All 9 matched when this plan was written.
3. Delete the 9 duplicates listed above.
4. Update the image paths in the two local guides, so they say to upload from
   `docs/images/screenshots/` and `docs/images/feature_graphic.png`. Add one line: "Replace an image
   in `docs/images/` only, then commit it."

### What stays in the Play folder

- `graphics/app_icon_512.png`: only Play uses it, and the README does not.
- `screenshots/raw/`: the raw captures. They are not published, and they are not duplicates.

### Why the guides point to the folder, and not a symbolic link

A symbolic link (a file that acts as a shortcut to another file) needs extra rights on Windows, and
Play Console's file picker gains nothing from it. The Play folder is only used by hand, so a written
path is enough.

## Checks

- `git status` shows no change to `docs/images/`, and the 9 images are in the last commit.
- Every image path in the two guides exists on disk.
- The 9 duplicates are gone, and `graphics/app_icon_512.png` and `screenshots/raw/` are still there.
