# Feature Plan: Optical Air-Gap Sync (High-Density Animated QR Stream)

**Status:** Proposed

**Date:** 2026-08-01 21:40:00

---

## 1. Overview & Objective

Traditional 2FA migration between two offline devices requires either a single static QR code (which fails or gets truncated when vault has >15 accounts due to QR density limits) or an active local Wi-Fi/LAN connection (which fails in high-security air-gapped facilities, public Wi-Fi with AP isolation, or cellular-only environments).

**Optical Air-Gap Sync** transfers an unlimited number of 2FA accounts between two mobile phones using a high-speed animated QR code stream (RaptorQ / Fountain Code matrix).
- **Transmitter Device:** Packs the encrypted/plaintext JSON vault into binary/JSON chunks, appends CRC32 checksums, and renders an animated QR video stream on screen at 12–15 FPS.
- **Receiver Device:** Uses camera live preview (`MobileScanner`) to continuously capture frames, reconstructs missing fragments out-of-order via a Fountain Code / Linear Elimination Solver, and decodes the full vault completely offline without Bluetooth, local Wi-Fi, socket binding, or cables.

---

## 2. Target Files to Modify & Create

### New Files
- `lib/services/optical_sync_service.dart`: Core Fountain Code encoder/decoder engine, chunking logic, CRC32 checksum calculation, frame serialization/deserialization, and out-of-order reconstruction solver.
- `lib/screens/optical_sync_screen.dart`: UI for Optical Air-Gap Sync transmitter (animated QR video stream at 12–15 FPS with speed selector) and receiver (live camera frame scanner with continuous dynamic reconstruction progress bar).
- `test/services/optical_sync_service_test.dart`: Unit test suite verifying Fountain Code chunking, frame CRC32 verification, out-of-order reconstruction, parity frame solving, corrupted frame rejection, and payload round-trips.

### Modified Files
- `lib/providers/sync_provider.dart`: Add state management methods for Optical Air-Gap sync (transmitting & receiving stream states, frame processing, reconstruction callbacks).
- `lib/screens/sync_screen.dart`: Integrate Optical Air-Gap Sync option into the sync menu alongside LAN P2P sync.
- `docs/feature_analysis_and_roadmap.md`: Update Feature 1 status from `Planned` to `Completed`.

---

## 3. Detailed Technical Architecture & Implementation Steps

### Step 1: Fountain Code Engine (`lib/services/optical_sync_service.dart`)
- **Chunking:** Split JSON payload bytes into fixed size $K$ (128 bytes). Total original chunks $N = \lceil |bytes| / K \rceil$.
- **Frame Schema:**
  `{"v":1,"s":"<session_hash>","i":idx,"t":N,"l":total_len,"c":crc32,"p":[indices],"d":"<base64_chunk>"}`
- **Systematic Frames ($0 \le i < N$):** Carry raw chunk $i$.
- **Parity Fountain Frames ($i \ge N$):** Carry XOR linear combinations of original chunks ($C_{a} \oplus C_{b}$).
- **Decoder & Solver:**
  - Dynamic bitmask buffer for received original chunks and parity combinations.
  - Out-of-order frame absorption.
  - Gaussian elimination / XOR substitution over $GF(2)$ to resolve missing chunks from parity frames.
  - SHA-256 session hash verification upon 100% reconstruction.

### Step 2: Sync Provider State Management (`lib/providers/sync_provider.dart`)
- Extend `SyncState` with `SyncOpticalTransmitting` and `SyncOpticalReceiving`.
- Provide high-level methods: `startOpticalTransmitting()` and `processOpticalFrame()`.

### Step 3: UI Implementation (`lib/screens/optical_sync_screen.dart` & `lib/screens/sync_screen.dart`)
- `OpticalSyncTransmitterView`: Renders animated `QrImageView` updating at configurable 10–15 FPS using a periodic `Timer`. Shows frame counter, total chunks, and session status.
- `OpticalSyncReceiverView`: Uses `MobileScanner` with frame processing. Displays real-time progress bar (e.g. "8 / 12 chunks reconstructed (66%)") and transitions automatically to completed summary screen once decoded.
- Update `SyncScreen` to provide prominent entry point for "Optical Air-Gap Sync (Animated QR)".

### Step 4: Unit Testing & Verification
- Create `test/services/optical_sync_service_test.dart` to verify:
  1. Systematic frame encoding and decoding.
  2. Parity frame reconstruction when camera drops up to 50% of systematic frames.
  3. CRC32 corruption detection and rejection.
  4. Session hash mismatch rejection.
  5. Payload size scaling (>15 accounts, >50 accounts).
- Run `flutter analyze` and `flutter test`.

### Step 5: Roadmap Document Update
- Mark Feature 1 as **Completed** in `docs/feature_analysis_and_roadmap.md`.

---

## 4. Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure 0 lint errors or warnings.
- Run `flutter test` to ensure all unit and widget tests pass.

### Manual Verification
- Test optical stream generation and frame decoding end-to-end within unit test environment and UI components.
