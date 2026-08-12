# Change log — Fill remaining gaps in docs/features.md

Implements plan: `plans/20260802_220034_features-doc-completeness-review.md`

## What changed

Only `docs/features.md` was edited. No app code changed. No behavior changed.

- **Section 1 ("What this app is")**: added a summary paragraph covering the
  app's full breadth — extra OTP types (Steam, Blizzard, YubiKey, mOTP),
  tags, brand icons, the App PIN / Phone Screen Lock security model with
  recovery key, encrypted backup/restore, and all three device sync methods
  (Wi-Fi LAN, optical air-gap, single-account QR) — so the top of the doc
  alone gives a reasonably complete picture, not just a one-line pitch.
- **Section 4 (Security)**: noted that the recovery key can be regenerated
  at any time from Settings → Security → "Reset Recovery Key" (not just
  generated once at initial PIN setup), and clarified that Lockdown Mode is
  a manual toggle in Settings → Security, not only an automatic condition.
- **Section 7 (UI, theming, settings)**: added a new bullet documenting that
  app name, description, version/build, and the About screen's Developer
  details are loaded at runtime from `assets/config/app_config.json`
  (`lib/services/config_service.dart`), with a safe fallback if the file is
  missing/invalid, and a debug-only version-mismatch warning.

## Why

A critical review of the doc against the current code (screens, providers,
`security_screen.dart`, `settings_provider.dart`, `config_service.dart`)
found real, currently-working features that weren't written down: the
config-driven About screen, the "Reset Recovery Key" action, and Lockdown
Mode's manual toggle. Section 1 was also too thin to count as an "inclusive"
app description on its own. This change closes those gaps without touching
any app behavior.

One thing was deliberately **not** added: a "mandatory PIN migration" code
path exists in `settings_provider.dart` / `lock_screen.dart`, but the flag
that would trigger it (`_needsMandatoryPinMigration`) is never actually set
to `true` anywhere in the current code, so it isn't a real, reachable
feature today — it looks like inactive/leftover code and documenting it
would be misleading.
