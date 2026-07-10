# Change log: sync no-lock + QR pairing

**Implements:** `plans/20260707_202657_sync-no-lock-and-qr-pairing.md`
**Date:** 2026-07-07

## What the user reported

- The app auto-locked in the middle of a "Sync to another device" session, which
  closed the sync screen and stopped the transfer.
- The 64-character pairing code was very hard to type onto the other device; the
  user wanted a QR code they could scan instead.

## What changed

### 1. No auto-lock during a sync session

- `lib/providers/settings_provider.dart`
  - Added `_isSyncInProgress` flag with `isSyncInProgress` getter and
    `setSyncInProgress(bool)` (mirrors the existing `setBackupInProgress`).
  - Added the `if (_isSyncInProgress) return;` guard to the three lock paths:
    `_checkAutoLock`, the `_autoLockTimer` callback in `_startAutoLockTimer`, and
    `onAppPaused`.
- `lib/screens/sync_screen.dart`
  - Sets `setSyncInProgress(true)` when the screen initializes and
    `setSyncInProgress(false)` in `dispose()`, so the app does not idle- or
    background-lock while the sync screen is open.

### 2. QR pairing (scan instead of type)

- `lib/utils/constants.dart`
  - Added the sync-QR URI constants: `syncQrScheme` (`spauth`), `syncQrHost`
    (`sync`), `syncQrVersion` (`1`), and the query keys `v` / `ip` / `port` / `code`.
- `lib/services/p2p_sync_service.dart`
  - Added `buildSyncQrPayload({ipAddress, port, code})` producing
    `spauth://sync?v=1&ip=…&port=…&code=…`.
  - Added `parseSyncQrPayload(raw)` that validates and returns the host IP, port,
    and normalized code, throwing `P2pSyncException` on a foreign scheme/host,
    unsupported version, missing/invalid port, or empty code.
- `lib/screens/sync_qr_scanner_screen.dart` (new)
  - A camera scanner (built on `mobile_scanner`) that parses a sync QR and returns
    the `(ipAddress, port, code)` record to the caller. It only parses/returns data
    and never touches the database.
- `lib/screens/sync_screen.dart`
  - Host view now shows a `QrImageView` of the pairing details above the existing
    IP/port/code text (kept as a manual fallback with "Copy code").
  - Join view now has a "Scan QR code" button that opens the scanner, fills the
    IP/port/code fields, and runs the existing join flow. Manual entry stays as a
    fallback. Menu/instruction wording updated to mention scanning.

### 3. Docs

- `docs/security.md` §5.1 — documented the QR as an out-of-band channel (never on
  the wire, same on-screen secret, screenshots still blocked) and the intentional
  suppression of auto-lock while the sync screen is active.
- `docs/architecture.md` — updated the P2P sync description to mention the scannable
  QR, the new scanner screen, and the mid-sync lock suppression.

## Dependencies / permissions

- None added. `qr_flutter` (generate) and `mobile_scanner` (scan) were already in
  `pubspec.yaml`; the CAMERA permission was already declared for the account QR
  scanner.

## Tests

- `test/services/p2p_sync_service_test.dart` — new "sync QR payload" group:
  build→parse round-trip, code normalization, and rejection of a foreign scheme,
  unsupported version, invalid port, and empty code.
- `test/providers/settings_provider_test.dart` — new test that
  `setSyncInProgress(true)` suppresses idle auto-lock and clearing it restores
  normal locking.

## Verification

- `flutter analyze` — No issues found.
- `flutter test` — All 201 tests pass.

## Security note

The pairing code is still never transmitted over the network. The QR is rendered
only on the host screen and read by the peer's camera (out-of-band), carrying the
same secret already shown on-screen as text, so exposure is unchanged. Auto-lock
suppression is scoped to the sync screen and cleared on exit.
