# Plan: Optical Air-Gap Sync Transfer Duration Estimate & Large Vault Warning

**Status:** Proposed / Pending Approval

## Issue
1. Optical Air-Gap Sync (animated QR stream) displays frame index and percentage progress, but does not inform the user of the estimated transfer duration in seconds.
2. When streaming a large vault (high account/chunk count), optical QR transfer takes longer, but the app does not provide an upfront warning or suggest P2P Wi-Fi Sync for faster transfer.

## Solution
1. **Define Threshold**:
   - Add `AppConstants.opticalLargeVaultChunkThreshold = 60` (roughly >5 seconds of optical streaming at 12 FPS).
2. **Display Estimated Transfer Duration**:
   - **Transmitter (Sender)**: Calculate and display estimated total time (`~X sec` or `~Xm Ys`) based on `totalChunks` and current `fps`.
   - **Receiver (Scanner)**: Calculate and display live remaining time (`~Y sec remaining`) based on unsolved remaining chunks vs target frame rate.
3. **Large Vault Warning Banner**:
   - On the Optical Sync transmitter screen, if `totalChunks >= AppConstants.opticalLargeVaultChunkThreshold`, display a warning banner explaining that the vault payload is large (~X chunks, ~Y seconds) and recommending P2P Wi-Fi Sync for faster transfer.

## Files to Change
- [constants.dart](file:///l:/Android/SreerajP_Authenticator/lib/utils/constants.dart)
- [optical_sync_screen.dart](file:///l:/Android/SreerajP_Authenticator/lib/screens/optical_sync_screen.dart)

## Verification Plan
### Automated Tests
- Run `flutter analyze` (must be 0 issues).
- Run `flutter test` (must pass all unit & widget tests).
