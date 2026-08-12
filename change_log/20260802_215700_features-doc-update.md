# Change log — Update docs/features.md

Implements plan: `plans/20260802_215508_features-doc-update.md`

## What changed

Only `docs/features.md` was edited. No app code changed. No behavior changed.

- **Section 2 (OTP types)**: added a note that the manual-entry dropdowns
  (6/8 digits, 30/60 s) only apply to plain TOTP/HOTP — Steam (5 digits),
  Blizzard (8 digits), and mOTP (6 hex chars, 10 s, needs a PIN) have their
  own fixed values. Also noted that `generateOtpAuthUri` exists in
  `otp_service.dart` but is currently unused by any screen.
- **Section 3 (Account management)**: added a note that backup files and P2P
  sync payloads still carry an empty `groups: []` field, kept only so old
  backup files stay readable — not a real feature in the app anymore.
- **Section 4 (Security)**: added a line about haptic feedback on key
  interactions (PIN entry, copy, delete, FAB).
- **Section 6 (Device sync)**: clarified that Full Sync also carries a
  settings snapshot (theme, auto-lock timeout, sync host idle timeout), and
  that Selective Sync only adds/fills in data, never overwrites.
- **Section 7 (UI, theming, settings)**: added "Help & Support" to the list
  of Settings screen sections, and noted the About screen discloses which AI
  tools were used in development.
- **Section 9 (Known gaps)**: added a bullet that the app cannot import from
  other authenticator apps' own export/migration formats (Google
  Authenticator, Aegis, 2FAS) — only its own `.aes` backup and single-account
  URIs are supported.

## Why

The doc is meant to be ground truth for what the app can do. A review
against the real code (screens, services, providers, constants) found a few
real features it left out, and a couple of places where the wording could be
misread. This change closes those gaps without changing any app behavior.
