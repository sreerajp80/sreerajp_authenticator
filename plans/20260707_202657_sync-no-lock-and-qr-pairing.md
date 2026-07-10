# Sync: stop mid-sync auto-lock and add QR pairing

**Status:** completed

## The issue

Two problems reported by the user on the "Sync to another device" flow:

1. **The app locks in the middle of a sync.** When hosting, the user waits on the
   hosting screen for the other device to connect. During this wait they are not
   touching the screen, so the idle **auto-lock timer** (default 60 s,
   `SettingsProvider._autoLockTimer`) fires and sets `isLocked = true`. The sync
   screen watches this and auto-pops itself
   (`sync_screen.dart` lines 115–122), which calls `SyncProvider.reset()` in
   `dispose()` and **tears down the host listener**. The same thing happens if the
   app is briefly backgrounded (`SettingsProvider.onAppPaused`). Net effect: the
   sync session dies and the accounts get locked mid-transfer.

2. **The 64-character pairing code is very hard to type onto the other device.**
   Today the host shows IP, port, and a 64-char code as text; the receiving device
   must type all three by hand. The user wants a **QR code** on the host that the
   other device can **scan**, instead of typing the long code.

## Key facts that shape the fix

- There is already a proven pattern for "do not auto-lock during a sensitive
  operation": `SettingsProvider._isBackupInProgress` + `setBackupInProgress(bool)`.
  It is checked in the three lock paths: `_checkAutoLock`, the `_autoLockTimer`
  callback, and `onAppPaused`. We mirror this for sync rather than inventing a new
  mechanism.
- Both packages needed for QR are already in `pubspec.yaml`:
  `qr_flutter: ^4.1.0` (generate) and `mobile_scanner: ^7.1.2` (scan). **No new
  dependency is required.**
- Security model (see `docs/security.md` §5.1): the pairing code is "never on the
  wire" and "transferred out-of-band". A QR **shown on the host screen** and
  **scanned by the client camera** is still out-of-band — it is not transmitted over
  the network. The code is *already* displayed as on-screen text today, so encoding
  that same on-screen secret as a QR does **not** increase exposure. Screenshots are
  already blocked app-wide by `screen_protector`, so the QR cannot leak via
  screenshot. The security model is preserved.

## Files to change

**Source**

1. `lib/utils/constants.dart`
   - Add sync-QR URI constants: a versioned scheme/host and the query keys, e.g.
     `syncQrScheme = 'spauth'`, `syncQrHost = 'sync'`, `syncQrVersion = '1'`.

2. `lib/services/p2p_sync_service.dart` (app-agnostic core; unit-tested)
   - Add `static String buildSyncQrPayload({required String ipAddress, required int port, required String code})`
     that returns a compact URI, e.g.
     `spauth://sync?v=1&ip=192.168.1.42&port=54321&code=ABCD...`.
   - Add `static ({String ipAddress, int port, String code}) parseSyncQrPayload(String raw)`
     that parses and validates such a URI, normalizing the code with the existing
     `normalizeCode`. Throws `P2pSyncException` (safe message, no secrets) on any
     malformed/foreign QR (wrong scheme/host/version, bad port, empty code).

3. `lib/providers/settings_provider.dart`
   - Add `bool _isSyncInProgress = false;` with `bool get isSyncInProgress`.
   - Add `void setSyncInProgress(bool value)` mirroring `setBackupInProgress`
     (when clearing to false while unlocked, refresh last-active time and restart
     the auto-lock timer).
   - Add the `if (_isSyncInProgress) return;` guard to the same three places the
     backup flag already guards: `_checkAutoLock`, the `_autoLockTimer` callback in
     `_startAutoLockTimer`, and `onAppPaused`.

4. `lib/screens/sync_qr_scanner_screen.dart` (NEW)
   - A small full-screen scanner built on `mobile_scanner` (mirrors the existing
     `qr_scanner_screen.dart` structure: torch + switch-camera actions, framed
     overlay, `isProcessing` guard). On detect, call
     `P2pSyncService.parseSyncQrPayload`; on success `Navigator.pop` with the parsed
     record; on failure show a SnackBar and keep scanning. It only returns data —
     it does not touch the database.

5. `lib/screens/sync_screen.dart`
   - **Suppress lock while on this screen:** call
     `context.read<SettingsProvider>().setSyncInProgress(true)` when the screen
     initializes and `setSyncInProgress(false)` in `dispose()` (alongside the
     existing `_syncProvider?.reset()`).
   - **Host view (`_buildHosting`):** add a `QrImageView` (from `qr_flutter`)
     encoding `P2pSyncService.buildSyncQrPayload(...)` above/next to the existing
     IP/port/code text. Keep the text + "Copy code" as a fallback for manual entry.
     Add a short caption: "Scan this on the other device".
   - **Join view (`_buildJoinForm`):** add a "Scan QR code" button that pushes
     `SyncQrScannerScreen`; on a returned record, fill the IP/port/code controllers
     and immediately call `_join()`. Manual typing stays available as a fallback.

**Tests**

6. `test/services/p2p_sync_service_test.dart`
   - New group "sync QR payload": `buildSyncQrPayload` → `parseSyncQrPayload`
     round-trips ip/port/normalized-code; parsing rejects a foreign scheme, a
     missing/invalid port, a wrong version, and an empty code.

7. `test/providers/settings_provider_test.dart`
   - Add a test that with app lock enabled and a zero/short auto-lock timeout,
     `setSyncInProgress(true)` prevents `_checkAutoLock`/`checkAndLockApp` from
     locking, and `setSyncInProgress(false)` restores normal behavior (mirroring any
     existing backup-in-progress test).

**Docs**

8. `docs/security.md` §5.1
   - Add a bullet: the pairing details may be transferred out-of-band either by
     typing or by scanning an on-host QR; the QR is not sent over the network and
     carries the same on-screen secret, so the "secret never on the wire" property
     is unchanged. Note that auto-lock is intentionally suppressed while the sync
     screen is active (same rationale as backup), and screenshots remain blocked.

9. `docs/architecture.md`
   - If it enumerates screens under `screens/` path ownership, add
     `sync_qr_scanner_screen.dart`. (Check and update only if such a list exists.)

## Plan for the fix

1. Add constants (file 1).
2. Add `buildSyncQrPayload` / `parseSyncQrPayload` to the service (file 2) and its
   unit tests (file 6). Run `flutter test test/services/p2p_sync_service_test.dart`.
3. Add the `_isSyncInProgress` suppression to `SettingsProvider` (file 3) and its
   test (file 7). Run the settings provider test.
4. Create the sync QR scanner screen (file 4).
5. Wire the host QR display, the join "Scan QR" button, and the
   `setSyncInProgress` calls into `sync_screen.dart` (file 5).
6. Update docs (files 8–9).
7. Run `flutter analyze` and the full `flutter test` suite; fix any issues.

## Notes / decisions

- **No auto-connect surprises:** scanning fills the fields and then triggers the
  existing `_join()` path, so the receive flow is unchanged apart from input method.
- **Fallback preserved:** manual IP/port/code entry and "Copy code" stay, so a
  device without a working camera still works.
- **No dependency or permission changes:** `qr_flutter` and `mobile_scanner` are
  already present; the CAMERA permission is already declared and used by the
  existing account QR scanner.
- **Security posture unchanged:** QR is out-of-band; lock suppression during sync
  matches the existing backup behavior and is documented.
