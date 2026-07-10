# Change log — P2P "Send to another device" redesign (tabs, connect-then-choose, settings sync)

**Implements:** [`plans/20260708_085718_p2p-send-redesign-tabs.md`](../plans/20260708_085718_p2p-send-redesign-tabs.md)
**Date:** 2026-07-08

## What changed

Redesigned the host (sender) side of P2P LAN sync so the sender chooses what to share **after** a
device connects, instead of the old behaviour of pushing all accounts+groups the instant a client
authenticated.

### Behaviour now

- **"Send to another device" is a two-tab screen:**
  - **Server Details** — the QR code and IP / port / pairing code (as before), plus a live status:
    "Waiting for the other device to connect…" → "A device is connected."
  - **Sync** — two sections:
    - **New client phone → Full Sync:** sends all accounts, groups, and the syncable settings.
    - **Sync to a phone → selective Sync:** checkboxes for Accounts / Groups / Settings, with a note
      that it will not override anything already on the other device (client wins, data retained).
  - Both sync actions are disabled until a device is connected, and show a per-item "syncing" list
    while sending.
- **Receiver** shows "Connected — waiting for the sender to choose…", then "Receiving…", then a
  detailed summary (accounts/groups added, duplicates kept, settings applied).
- **Syncable settings:** theme mode, auto-lock timeout, sync-host idle timeout. All security /
  device-specific state (app lock, App PIN, phone-lock / biometric unlock, recovery key, lockdown,
  boot / adaptive-auth state) is never transmitted. `export_format` was intentionally excluded — it
  is dead/unused in the app (no format chooser exists; nothing reads it).
- **Merge semantics:** accounts/groups remain add-only (client-wins, existing import funnel). On the
  receiver, Full Sync applies settings outright (fresh device); an incremental sync applies a setting
  only if the receiver has not already set it (fill-only), so the receiver is never overridden.

### Protocol

The transport now holds the authenticated connection open. On auth the host sends the encrypted
accept immediately (peer shows "connected") and waits; the payload is pushed later via the new
`P2pSyncService.sendToConnectedClient`. The client waits for the payload up to a new
`syncPayloadWaitTimeout` (10 min). Only one client is held at a time; drops before a send are
detected and the host returns to waiting. The crypto model is unchanged (PBKDF2 + AES-256-GCM keyed
by the out-of-band pairing code). This is **not wire-compatible** with the previous immediate-send
host, but both devices run the same updated app.

## Files changed

**Code**
- `lib/utils/constants.dart` — added `syncPayloadWaitTimeout`, `syncMode*` markers, payload keys, and
  syncable-settings keys / category ids.
- `lib/providers/settings_provider.dart` — added `syncableSettingsSnapshot()` and
  `applySyncedSettings(map, {overwrite})` (fill-only unless overwrite; clamps idle timeout; ignores
  unknown keys / bad types).
- `lib/providers/account_provider.dart` — `importData` now returns `ImportResult`
  (accounts/groups added & skipped); added the `ImportResult` class.
- `lib/services/p2p_sync_service.dart` — hold-open host protocol: `onClientConnected` /
  `onClientDisconnected` callbacks, `sendToConnectedClient`, single-client guard, drop detection
  (`_BoundedLineReader.closed`); client `connectAndFetch` now takes `onConnected` and waits for the
  payload with `syncPayloadWaitTimeout`; `validateAndParse` surfaces `settings` and `syncMode` and
  only includes category keys actually present.
- `lib/providers/sync_provider.dart` — reworked state model (`SyncHosting` carries connection +
  send progress; new `SyncWaitingForSender`; `SyncSummary`); host `sendFullSync` /
  `sendSelectiveSync`; payload build from selected categories; client `joinSync` now takes
  `importData` + `applySettings` callbacks and builds the summary.
- `lib/screens/send_to_device_screen.dart` — **new** tabbed host view (Server Details + Sync).
- `lib/screens/sync_screen.dart` — routes hosting to the tabbed view; added waiting + summary UI;
  updated join wiring.

**Docs**
- `docs/security.md` — documented connect-then-choose, the held-open connection, the payload wait
  timeout, and that only non-sensitive settings sync (fill-only on incremental).
- `docs/architecture.md` — updated the P2P sync description (tabbed send UI, settings in payload,
  `ImportResult`, fill-only settings apply).

**Tests**
- `test/services/p2p_sync_service_test.dart` — rewrote the loopback tests for the hold-open protocol;
  added settings/syncMode parsing, category-key omission, and a "send without a client throws" test.
- `test/providers/settings_provider_test.dart` — added snapshot + apply (overwrite, fill-only, clamp,
  bad-input) tests.
- `test/providers/account_provider_test.dart` — added an `importData` counts / client-wins test.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 210 tests pass (including the new/updated sync tests).
- Cross-device (real two-phone) transfer is verified manually, per `docs/security.md`.
