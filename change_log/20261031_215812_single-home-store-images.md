# Keep the store images in one place

Implements `plans/20261031_215621_single-home-store-images.md`.

## What changed

`docs/images/` is now the only home of the feature graphic and the 8 screenshots.

- Deleted the 9 duplicate images from the local, git-ignored Play folder.
- Updated the local publishing guide and store listing notes, so they say to upload from
  `docs/images/` and to replace an image only there, then commit it.
- Kept the store icon and the raw captures in the Play folder. They are not duplicates.

No tracked file changed, except this change log and its plan.

## Checks

- `docs/images/` was committed before the delete: 9 tracked files, no local changes.
- Each duplicate was compared by hash with its copy in `docs/images/` before it was deleted. All
  matched.
- The cleanup ran in two steps, because a script mistake skipped the feature graphic in the first
  run. It was compared and deleted in a second run. No other file was affected.
- The store icon and all 8 raw captures are still there.
