# Plan — Fill remaining gaps in docs/features.md

**Status:** completed

## Files to change

- `docs/features.md` (only this file; no app code changes)

## The issue

The user asked for a critical check that `docs/features.md` lists every
feature and that the app description (Section 1) is inclusive. The file was
already updated once recently, but comparing it line-by-line against the
current code found a few real gaps:

1. **Section 1 ("What this app is") is too thin.** It only says "generates
   OTP codes offline" and lists platform/state-management facts. It does not
   mention, even in summary form, the app's actual breadth: multiple OTP
   algorithm types (not just TOTP/HOTP), tags, brand icons, three separate
   offline sync methods (including optical air-gap), or the two-factor
   App PIN + Phone Screen Lock security model. Someone reading only Section 1
   would come away with an incomplete picture of what the app does.

2. **The app_config.json-driven About/version system is undocumented.**
   `lib/services/config_service.dart` loads `assets/config/app_config.json`
   (app name, description, version, build, and developer details — Author,
   Email, License, "AI used", "IDE used") at runtime for the About screen,
   and does a debug-only warning if the JSON version/build doesn't match the
   real package version. This is a real, current mechanism (added in the
   `app-config-json-migration` change) and isn't mentioned anywhere in
   features.md.

3. **"Reset Recovery Key" is missing.** `security_screen.dart` has a
   dedicated action to regenerate the recovery key at any time (after
   re-entering the current App PIN), separate from the one-time generation
   at initial PIN setup. Section 4 only describes the initial generation.

4. **Lockdown Mode's location isn't documented.** Section 4 mentions
   Lockdown Mode as one of the reasons for forced PIN re-entry, but never
   says it's a manual toggle the user turns on themselves, from
   Settings → Security (only shown once an App PIN is set).

I also checked for a "mandatory PIN migration" code path in
`settings_provider.dart` / `lock_screen.dart` (forces old Phone-Lock-only
users to set up an App PIN). The flag that would trigger it
(`_needsMandatoryPinMigration`) is never actually set to `true` anywhere in
the current code — it looks like inactive/leftover code, not a real feature
today, so it will **not** be added to the doc.

## The fix

Edit `docs/features.md` only, no app behavior changes:

- **Section 1**: rewrite to briefly summarize, in addition to what's already
  there: the range of OTP types supported (TOTP/HOTP plus Steam, Blizzard,
  YubiKey, mOTP), tags for organization, offline brand icons, the three
  device-to-device sync methods (Wi-Fi LAN, optical air-gap, single-account
  QR), and the App PIN / Phone Screen Lock security model — so Section 1
  alone gives a reasonably complete picture, with Sections 2–9 as the
  detailed reference.
- **New short subsection under Section 7 (UI, theming, settings)**: document
  that app name, description, version/build, and the About screen's
  Developer details are loaded from `assets/config/app_config.json` at
  runtime (not hardcoded in Dart), and that a mismatch between that file's
  version and the real package version logs a debug-only warning.
- **Section 4**: add a line noting the recovery key can be regenerated at
  any time from Settings → Security → Reset Recovery Key (requires the
  current App PIN), not just generated once.
- **Section 4**: clarify Lockdown Mode is a manual toggle in
  Settings → Security (visible once an App PIN is set), not just an
  automatic condition.

No code, tests, or behavior change — documentation only.
