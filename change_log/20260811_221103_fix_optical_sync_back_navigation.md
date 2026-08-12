# Fix Optical Air-Gap Stream Back Navigation Bug

**Plan:** [20260811_221103_fix_optical_sync_back_navigation.md](../plans/20260811_221103_fix_optical_sync_back_navigation.md)

## Summary
Resolved a navigation bug where pressing back from the Optical Air-Gap Stream screen left `SyncProvider` in an active optical sync state while returning to `SyncScreen`. Because `SyncScreen._buildBody()` previously rendered `OpticalSyncScreen` inside its own `Scaffold` body for optical sync states, returning to `SyncScreen` displayed a double header ("Sync to another device" and "Optical Air-Gap Stream") with two back buttons.

## Changes Made
1. **`lib/screens/sync_screen.dart`**:
   - Modified `_buildBody()` switch statement to render `_showJoinForm ? _buildJoinForm(context) : _buildMenu(context)` when state is `SyncOpticalTransmitting` or `SyncOpticalReceiving`.
   - Ensures `SyncScreen` only renders its standard options menu when `OpticalSyncScreen` route sits on top or is popped.

2. **`lib/screens/optical_sync_screen.dart`**:
   - Added `_syncProvider` reference in `didChangeDependencies()`.
   - Updated `dispose()` to call `_syncProvider?.reset()` so that exiting `OpticalSyncScreen` (via hardware back gesture, AppBar back button, or pop) resets `SyncProvider` state to `SyncIdle()`.

## Verification
- Code formatted with `dart format .`.
- Static analysis verified zero issues via `flutter analyze`.
- All tests passing.
