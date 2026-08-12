# Fix Optical Air-Gap Stream Back Navigation Bug

**Status:** Approved & Implemented

## Problem
When pressing back from the Optical Air-Gap Stream screen, it displays the same screen with "Sync to another device" heading added above it. Two back buttons and two headings appear. Pressing back again goes to the settings screen.

## Root Cause
1. `OpticalSyncScreen` is navigated to via `Navigator.push(...)` as a standalone route with its own `Scaffold` and `AppBar`.
2. When active, `SyncProvider` state changes to `SyncOpticalTransmitting` or `SyncOpticalReceiving`.
3. `SyncScreen` (sitting below `OpticalSyncScreen` in the navigator stack) listens to `SyncProvider`. Its `_buildBody` method returned `const OpticalSyncScreen(...)` when state was `SyncOpticalTransmitting` or `SyncOpticalReceiving`, rendering `OpticalSyncScreen` inside `SyncScreen`'s own `Scaffold`.
4. When `OpticalSyncScreen` was popped, `SyncProvider` state remained in `SyncOpticalTransmitting`/`SyncOpticalReceiving` because `dispose()` did not call `reset()`. Thus, `SyncScreen` rendered `OpticalSyncScreen` inside its body, causing nested headers and double back buttons.

## Proposed Fix
1. In `lib/screens/sync_screen.dart`: Update `_buildBody` so `SyncOpticalTransmitting` and `SyncOpticalReceiving` states return `_showJoinForm ? _buildJoinForm(context) : _buildMenu(context)`.
2. In `lib/screens/optical_sync_screen.dart`: Store `_syncProvider` in `didChangeDependencies()` and call `_syncProvider?.reset()` in `dispose()`.

## Files to Change
- `lib/screens/sync_screen.dart`
- `lib/screens/optical_sync_screen.dart`

## Verification
- `flutter analyze`
- `flutter test`
