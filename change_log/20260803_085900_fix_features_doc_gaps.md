# Fix gaps in docs/features.md

Implements: `plans/20260803_085500_fix_features_doc_gaps.md`

## What changed

Edited `docs/features.md` only (no code changes), fixing two wrong
statements and adding two missing features, found by auditing the doc
against the real code:

1. **Section 1** — corrected the platform-runner sentence. It only named
   iOS and Windows; the repo also has fully scaffolded macOS, Linux, and
   Web runner folders (default Flutter scaffolding). The sentence now lists
   all five and still makes clear Android is the only platform that is
   actively developed, built, and shipped.

2. **Section 3** and **Section 6c** — added a note that both QR-scanner
   screens (single-account scan and P2P pairing scan) have a
   flashlight/torch toggle button. This existed in the code
   (`qr_scanner_screen.dart`, `sync_qr_scanner_screen.dart`) but wasn't
   mentioned in the doc.

3. **Section 7** — added a note that tapping the Email row on the About
   screen's Developer list opens the device's mail app (`mailto:` link via
   `url_launcher`). This existed in the code
   (`about_screen.dart`) but wasn't mentioned.

4. **Section 8** — corrected the Permissions-screen description. The old
   text said the screen "shows the status of each permission," which
   overstated the real behavior. The real `permissions_screen.dart` only
   does a live, checked status for Camera; Biometric/Vibration/Secure
   Storage/Local Database are static informational rows with no live check;
   and Internet/Network-state/Wi-Fi-state permissions (used for P2P sync)
   aren't shown on that screen at all, even though they're declared in the
   Android manifest.

## Why

A full audit (agent-assisted read of every screen, service, provider,
model, the app config JSON, pubspec dependencies, and the Android manifest)
found the doc was otherwise accurate — all numeric claims (PBKDF2 rounds,
lockout timings, sync payload caps, recovery-key length, etc.) matched the
code exactly. Only the four items above were out of sync.

## Not changed

No other findings from the audit were added, because they were internal
plumbing, not user-facing features per the doc's own stated purpose (a
ground-truth reference for checking "does this app already have X"):
theme-provider/settings-provider duplication, the two separate
groups-to-tags migration code paths, the About screen's environment/package
chips, and the fallback `AppConfig`/`AppConstants` content drift (only
matters if the bundled config JSON is broken, which doesn't happen in a
shipped build).
