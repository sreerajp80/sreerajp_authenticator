# Update docs/features.md — fill gaps, fix stale claims

**Status:** completed

## Files to change

- `docs/features.md` (only file)

## The issue

I compared `docs/features.md` against the real code in `lib/screens/`,
`lib/services/`, `lib/providers/`, `lib/utils/constants.dart`, and
`pubspec.yaml`. The doc is mostly accurate, but it is missing some features
and has a few claims that are slightly out of date. Also, the "App
description" (Section 1) does not mention some things the app actually does
(AI disclosure on About screen, Help & Support, haptics).

### Things missing from the doc (found in code, not written down)

1. **Haptic feedback** is used across the app (account tile, PIN dialog, FAB,
   add-account form) — not mentioned anywhere.
2. **mOTP needs a PIN**, not just a secret. The PIN is stored in the
   account's `counter` field. This detail is missing from Section 2.
3. **Steam Guard codes are always 5 digits, Blizzard is always 8 digits** —
   these are fixed, not user-chosen. The doc's "digits: 6 or 8" language could
   be read as applying to all types, so this needs a clarifying note.
4. **Settings screen has a "Help & Support" section** — not listed among the
   Settings screen sections in Section 7.
5. **Full Sync vs Selective Sync are different in one more way**: Full Sync
   also carries a settings snapshot (theme, auto-lock timeout, sync host idle
   timeout); Selective Sync never overwrites data the other device already
   has. The doc says "Full/Selective" but doesn't explain this difference.
6. **About screen discloses AI tool usage** ("AI Used: Claude 4.5, 4.6 & 4.8
   and ChatGPT") as part of the Developer section — a real user-facing detail
   missing from Section 7 (UI/settings) or Section 1.
7. **`generateOtpAuthUri` exists in `otp_service.dart`** (builds a plain
   `otpauth://` URI from a decrypted secret) but nothing in the app calls it
   today. Doc should note it as unused/not wired to any screen, so it isn't
   mistaken for a shipped "share as QR" feature.
8. Section 9 ("known gaps") does not mention that the app **cannot import
   from other authenticator apps** (Google Authenticator export QR, Aegis,
   2FAS, etc.) — only its own `.aes` backup format and single `otpauth://` /
   vendor URIs. This is a common feature competitors have; worth listing as a
   known gap.

### Things in the doc that are slightly stale

1. Section 3 says Tags "replaced" Groups, which has been "fully removed from
   the code." That's true for the UI, but the **backup file format and P2P
   sync payload still write an empty `groups: []` field** for backward
   compatibility with old backup files. Worth a one-line clarification so
   nobody is confused when they see `groups` in the JSON.
2. Section 2's digit/period table needs a short note that Steam (5 digits),
   Blizzard (8 digits, fixed), and mOTP (6 hex chars, 10 s period, needs a
   PIN) don't follow the "6 or 8 digits / 30 or 60 s" manual-entry options —
   those options only apply to plain TOTP/HOTP.

## The plan

Edit `docs/features.md` only, in place, section by section:

1. **Section 1 (What this app is)** — no factual change needed; it is
   accurate. Leave as is (already inclusive of platform/db/state info).
2. **Section 2 (OTP types)** — add a short bullet clarifying that Steam (5
   digits), Blizzard (8 digits), and mOTP (6 hex chars, 10 s, needs a PIN)
   have fixed parameters that don't come from the manual-entry dropdown.
   Mention `generateOtpAuthUri` exists in code but is currently unused.
3. **Section 3 (Account management)** — add one line noting the backup/sync
   file formats still carry an empty `groups` field for backward
   compatibility (not a user-facing feature).
4. **Section 4 (Security)** — add a line noting haptic feedback is used for
   key interactions (PIN entry, copy, delete, FAB).
5. **Section 6 (Device-to-device sync)** — clarify that Full Sync also sends
   a settings snapshot (theme, auto-lock timeout, sync host idle timeout),
   while Selective Sync never overwrites existing data on the target device.
6. **Section 7 (UI, theming, settings)** — add "Help & Support" to the list
   of Settings screen sections; add a line noting the About screen discloses
   which AI tools were used in development.
7. **Section 9 (Known gaps)** — add a bullet: no import from other
   authenticator apps' export/migration formats (Google Authenticator,
   Aegis, 2FAS, etc.) — only this app's own `.aes` backup and single-account
   `otpauth://`/vendor URIs are supported.

No code changes. No behavior changes. This is a documentation-accuracy-only
edit.
