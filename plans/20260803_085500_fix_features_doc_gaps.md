# Fix gaps in docs/features.md found by code audit

**Status:** completed

## Files to change

- `docs/features.md`

## The issue

I checked `docs/features.md` against the real app code (screens, services,
providers, models, config, manifest, dependencies). The doc is mostly
accurate, but a code-level audit found two wrong statements and two missing
features:

1. **Wrong (Section 1 — "What this app is"):** the doc says "iOS and Windows
   runners exist in the repo but Android is the main target." In fact the
   repo also has fully scaffolded `macos/`, `linux/`, and `web/` runner
   folders, not just iOS and Windows. The sentence undercounts what's there.

2. **Wrong (Section 8 — Permissions and platform notes):** the doc says "The
   Permissions screen shows the status of each permission." In the real
   `permissions_screen.dart`, only **Camera** gets a live, checked status.
   Biometric/Vibration/Secure Storage/Local Database rows are static
   descriptive text with no live check, and Internet/Network-state/Wi-Fi
   permissions (used for P2P sync) are not shown on that screen at all, even
   though they're declared in the manifest.

3. **Missing (Section 3 or 6c — QR scanning):** both QR-scanner screens
   (`qr_scanner_screen.dart` for single-account scan, and
   `sync_qr_scanner_screen.dart` for P2P pairing) have a flashlight/torch
   toggle button. This is a real, visible feature that isn't mentioned
   anywhere in the doc.

4. **Missing (Section 7 — UI, theming, and settings):** on the About screen,
   tapping the "Email" row in the Developer list opens the device's mail app
   (`mailto:` link via `url_launcher`). The doc says the About screen
   "discloses ... contact email" but doesn't say it's tappable.

## The plan

Edit `docs/features.md` only, in place:

1. In Section 1, change the runner sentence to mention all five non-Android
   runner folders (iOS, Windows, macOS, Linux, Web) and keep the point that
   Android is the only actively developed/shipped target.
2. In Section 8, rewrite the Permissions screen bullet to say precisely:
   Camera gets a live runtime status check; Biometric/Vibration/Secure
   Storage/Local Database are shown as static informational rows with no
   live check; Internet/Network-state/Wi-Fi permissions are not listed on
   that screen at all (they're covered under General notes instead).
3. In Section 3 (account tile / QR scan bullet) or Section 6c (single-account
   QR import), add one short line noting the flashlight/torch toggle on the
   QR-scanner screens.
4. In Section 7, add a short clause to the About-screen bullet noting the
   Email row is tap-to-open (launches the device mail client).

No code changes. No other sections touched.

## Change log

Will write `change_log/` entry after the edit, referencing this plan.
