# P2P "Send to another device" redesign — tabs, connect-then-choose, settings sync

**Status:** completed

## Summary

Redesign the host (sender) side of P2P LAN sync. Today the host shows a QR + IP/port/code
and, the instant a client authenticates, it *immediately* pushes all accounts+groups and
closes. The new design keeps the connection open after the client connects, shows a
"device connected" status, and lets the **sender choose what to send** from two tabs.

## What the user asked for

"Send to another device" screen must have **two tabs**:

1. **Server Details** — shows the QR code and connection details exactly as now. When a
   client connects, it must show that the client is connected.
2. **Sync** — two sections:
   - **New Client Phone** — a *Full Sync*: send all app settings and data to the client.
     Only device-specific, non-syncable items are omitted. Tapping **Full Sync** performs
     the sync and shows what is synced / syncing.
   - **Sync to a Phone** — an *incremental* sync to a device that already has the app with
     its own settings and data. It lists what can sync (data / settings); the user selects
     items and taps **Sync**. A note must state this will **not override** anything already
     on the client — on any conflict the client's data wins and is retained.

## Decisions (confirmed with the user)

- **Syncable settings:** theme mode, auto-lock timeout, sync-host idle timeout. Everything
  else in `SettingsProvider` (app lock enabled, App PIN, phone-lock / biometric quick
  unlock, recovery key, lockdown, boot-count / adaptive-auth state, last-active/strong-auth
  timestamps) is **device-specific and never sent**.
  - Excluded: `export_format`. Investigation confirmed it is dead: the Backup & Restore
    screen exposes only "Create Encrypted Backup" / "Restore from Backup" (no format
    chooser), the plain-JSON and CSV export methods in `export_import_service.dart` are
    wired to no UI, and nothing reads the `export_format` value. Syncing it would add a
    meaningless "1 setting applied" to the receiver summary, so it is left out.
- **Incremental settings behavior:** *Settings selectable, never overwrite.* In incremental
  sync the client applies a synced setting **only if it has not already set that key**
  (fill-only). In Full Sync (a fresh client) settings are applied outright.
- **Receiver UX:** the client shows "Connected — waiting for the sender", then a receiving
  state, then a **detailed summary** (accounts added/skipped, groups added/skipped, settings
  applied).

## The core problem to solve

The current protocol (`p2p_sync_service.dart`) sends the payload the moment the client
authenticates, then closes. The new flow needs the host to **hold the authenticated
connection open** and push a payload later, when the sender taps Full Sync / Sync. The good
news: the existing wire protocol already sends `accept` and `payload` as two separate lines,
and the merge funnel (`account_provider.importData`) already does "client wins" (skips
duplicate groups by name and duplicate accounts by name+issuer+type). So the changes are:
hold the socket open, send payload on demand, add settings to the payload, extend the
timeouts, and rework the host UI into tabs.

## Files to be changed

**Code**
1. `lib/services/p2p_sync_service.dart` — hold the authenticated socket open instead of
   sending immediately; add `onClientConnected` / `onClientDisconnected` callbacks; add
   `sendToConnectedClient(payload)`; stop accepting further clients once one is connected;
   use a longer "waiting for sender" timeout on the client's payload read.
2. `lib/providers/sync_provider.dart` — split host vs client state; add host states
   (waiting → client-connected → sending → done/error) while keeping the hosting details
   (ip/port/code) available for the Server Details tab; build the payload from selected
   categories (accounts / groups / settings) with a `syncMode` marker; add a client
   "waiting for sender" state; produce a detailed summary.
3. `lib/screens/sync_screen.dart` — keep the Send/Receive menu; route "Send" to the new
   tabbed host screen; extend the client (Receive) flow with the waiting state and the
   detailed summary.
4. `lib/screens/send_to_device_screen.dart` — **NEW**. Tabbed host UI: Tab 1 Server Details
   (QR + IP/port/code + live connection status + Stop hosting); Tab 2 Sync (New Client Phone
   → Full Sync; Sync to a Phone → category checkboxes + client-wins note + Sync), with
   per-item syncing/done progress. Sync actions are disabled until a client is connected.
5. `lib/providers/settings_provider.dart` — add `syncableSettingsSnapshot()` (map of the
   three syncable keys) and `applySyncedSettings(map, {required bool overwrite})` (fill-only
   unless overwrite), returning the count applied. Uses `containsKey` to detect
   already-set keys for the never-override rule.
6. `lib/providers/account_provider.dart` — make `importData` return an `ImportResult`
   (accountsAdded/accountsSkipped/groupsAdded/groupsSkipped); existing callers can ignore
   the return value.
7. `lib/utils/constants.dart` — add: `syncPayloadWaitTimeout` (client wait for the sender,
   e.g. 10 min); `syncMode` strings (`full` / `incremental`); syncable-settings keys /
   category ids; payload keys for `settings` and `syncMode`.

**Docs (mandatory per repo CLAUDE.md)**
8. `docs/security.md` — update the P2P section: connection is now held open after
   authentication and the payload (now optionally including a small settings object) is sent
   on the sender's action; timeouts; confirm no new secret is logged and device-specific
   security settings are never transmitted.
9. `docs/architecture.md` — note settings are now part of the sync payload and the
   connect-then-choose protocol.

**Tests**
10. `test/services/p2p_sync_service_test.dart` — update for the hold-open protocol
    (`onClientConnected`, `sendToConnectedClient`) and settings in the validated payload.
11. `test/providers/settings_provider_test.dart` — add tests for `syncableSettingsSnapshot`
    and `applySyncedSettings` fill-only vs overwrite.
12. `test/providers/account_provider_test.dart` — assert the new `ImportResult` counts.

## Plan for the fix

### 1. Transport (`p2p_sync_service.dart`)
- Keep salt → hello → key-derivation auth exactly as today (unchanged crypto: PBKDF2 +
  AES-256-GCM, wrong code → GCM tag failure).
- On successful auth: fire `onClientConnected()`, cancel the idle timer, **store** the
  socket, key, and reader, and **stop accepting** further connections (single client). Do
  **not** send a payload yet. Watch the socket for close → fire `onClientDisconnected()` and
  return to waiting/accepting.
- New `sendToConnectedClient(String payload)`: on the held socket, write
  `encryptWire(accept)` (if not already sent) then `encryptWire(payload)`, flush, fire
  `onCompleted`, and close.
- Client `connectAndFetch`: after reading `accept`, use `syncPayloadWaitTimeout` (not the
  short socket timeout) for the payload read, so the sender has time to choose. Surface an
  `onConnected` callback so the client UI can show the waiting state.

### 2. Payload (`sync_provider.dart`)
- Extend the backup map with an optional `settings` object and a `syncMode`
  (`full`/`incremental`). Include `accounts` / `groups` / `settings` only for selected
  categories. Secrets are still decrypted only transiently while building the payload and
  never logged.
- Host actions: `sendFullSync()` (accounts + groups + settings, `syncMode=full`) and
  `sendSelectiveSync({accounts, groups, settings})` (`syncMode=incremental`). Both call
  `sendToConnectedClient`.

### 3. Apply on client
- Accounts/groups → existing `importData` (already client-wins), now returning counts.
- Settings → `applySyncedSettings(settings, overwrite: syncMode == full)`. In incremental
  (`overwrite:false`) only keys the client hasn't set are applied.
- Build the summary from the import counts + settings-applied count.

### 4. Host UI (`send_to_device_screen.dart`)
- `TabBar`/`TabBarView` with **Server Details** and **Sync**.
- Server Details: reuse the current QR + IP/port/code layout; add a status row —
  "Waiting for a device…" (spinner) or "Device connected ✓"; Stop hosting.
- Sync tab: **New Client Phone** section with a Full Sync button; **Sync to a Phone**
  section with checkboxes (Accounts / Groups / Settings), the client-wins note card, and a
  Sync button. Both disabled until a client is connected (hint pointing to Server Details).
  While sending, show a per-item list with syncing/done indicators; on completion show the
  summary.

### 5. Client UI (`sync_screen.dart`)
- Add the "Connected — waiting for the sender to choose what to share…" state, then the
  receiving state, then the detailed summary (accounts/groups added & skipped, settings
  applied).

### 6. Docs + tests
- Update `docs/security.md` and `docs/architecture.md` as listed.
- Update/extend the tests listed above; run `flutter test` and `flutter analyze` (zero new
  issues) before writing the change log.

## Risks / notes

- **Protocol compatibility:** the hold-open change is not wire-compatible with the old
  immediate-send host, but both peers are the same app updated together; no cross-version
  sync is expected. Will be called out in the change log.
- **Waiting timeout:** a client will wait up to `syncPayloadWaitTimeout` for the sender.
  Auto-lock stays suppressed on both screens during a session (existing `setSyncInProgress`).
- **Never-override for settings** relies on `SharedPreferences.containsKey` as the
  "user has set this" signal; acceptable given the three syncable keys.
- No change to encryption, key storage, or the pairing-code security model.
