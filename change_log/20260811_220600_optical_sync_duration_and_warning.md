# Change Log: Optical Air-Gap Sync Transfer Duration Estimate & Large Vault Warning

**Plan Reference:** `plans/20260811_220600_optical_sync_duration_and_warning.md`

## Summary of Changes
1. **Added `opticalLargeVaultChunkThreshold` Constant**:
   - Added `AppConstants.opticalLargeVaultChunkThreshold = 60` in `lib/utils/constants.dart` to mark vault payloads requiring 60+ optical chunks (~5+ seconds of QR streaming) as large.
2. **Added Duration Estimation UI**:
   - **Transmitter (Sender)**: Displays dynamic `Est. Transfer Duration` (e.g. `~4s` or `~1m 10s`) based on `totalChunks` and current streaming `fps`.
   - **Receiver (Scanner)**: Displays live remaining duration (e.g. `Captured: 8 / 18 chunks (~2s remaining)`) based on unsolved remaining chunks.
3. **Added Large Vault Warning Banner**:
   - Added a prominent warning card on `OpticalSyncScreen` transmitter view when `totalChunks >= 60`, warning the user about the large stream size and recommending P2P Wi-Fi Sync for faster transfer.

## Files Modified
- `lib/utils/constants.dart`
- `lib/screens/optical_sync_screen.dart`

## Verification
- Ran `flutter analyze` — 0 warnings / 0 issues.
- Ran `flutter test` — All unit and widget tests passing.
