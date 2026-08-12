# Change Log: Feature 1 — Optical Air-Gap Sync (High-Density Animated QR Stream)

**Date:** 2026-08-01 21:40:00

**Plan Reference:** `plans/20260801_214000_optical_airgap_sync.md`

---

## Summary of Changes

Implemented **Optical Air-Gap Sync**, allowing two offline devices to transfer unlimited 2FA accounts via an animated QR code stream (12–15 FPS) powered by a Fountain Code (LT matrix) chunking engine and IEEE 802.3 CRC32 verification.

### 1. New Services & Engine
- **`lib/services/optical_sync_service.dart`**:
  - `Crc32`: Fast IEEE 802.3 polynomial checksum calculation.
  - `OpticalSyncFrame`: Compact JSON frame format carrying `{v, s, i, t, l, c, p, d}` parameters for QR rendering.
  - `OpticalSyncEncoder`: Fountain Code chunking engine splitting vault payload into 128-byte fragments and producing systematic & strided XOR parity frames.
  - `OpticalSyncDecoder`: Dynamic bitmask buffer and queue-based linear elimination solver over $GF(2)$ for out-of-order reconstruction and SHA-256 session verification.

### 2. UI & Providers
- **`lib/providers/sync_provider.dart`**:
  - Added `SyncOpticalTransmitting` and `SyncOpticalReceiving` states to `SyncState`.
  - Added methods `startOpticalTransmitting()`, `setOpticalFps()`, `startOpticalReceiving()`, and `processOpticalFrame()`.
- **`lib/screens/optical_sync_screen.dart`**:
  - `OpticalSyncTransmitterView`: Renders high-speed animated `QrImageView` at 10/12/15 FPS with progress stats and stream session hash.
  - `OpticalSyncReceiverView`: Live camera preview scanner (`MobileScanner`) with frame ingestion and real-time reconstruction progress bar (`Reconstructed X/N Chunks`).
- **`lib/screens/sync_screen.dart`**:
  - Integrated Optical Air-Gap Sync entry options into the main Sync menu alongside P2P LAN sync options.

### 3. Unit Tests & Verification
- **`test/services/optical_sync_service_test.dart`**:
  - 7 unit tests verifying CRC32 checksums, encoder chunking, frame serialization, out-of-order frame receiving, dropped frame recovery via parity solver, CRC corruption rejection, and full payload round-trips.
- **`flutter analyze`**: 0 issues.
- **`flutter test`**: All unit and widget tests passing.

### 4. Roadmap & Documentation
- **`docs/feature_analysis_and_roadmap.md`**:
  - Updated Feature 1 status to **Completed** with implementation details in section 3 and Phase 3 roadmap table.
