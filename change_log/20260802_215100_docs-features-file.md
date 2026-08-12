# Added docs/features.md — full feature reference

Implements plan: `plans/20260802_214654_docs-features-file.md`

## What changed

Added one new file, `docs/features.md`. It's a full, plain-English list of
everything the app does today: what the app is, OTP types/algorithms
supported, account management (add/edit/delete/reorder/search/tags/brand
icons), security (PIN, phone lock, recovery key, lockout, encryption, screen
protection), backup/restore, the three device-sync methods (P2P Wi-Fi,
Optical Air-Gap, single-account QR), UI/theming/settings, permissions, and a
short "known gaps" section.

No existing files were changed. This is meant to be handed to another LLM (or
read by a person) as ground truth on this app's features before adding
similar features elsewhere, so there's no need to re-read the whole codebase
each time.

The content reflects the current code, including that the old "Groups"
feature has been removed and replaced by a multi-tag system.
