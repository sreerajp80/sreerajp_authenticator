# Plan: Audit and Update Features Reference Document

**Status:** Completed

## Target Files
- `docs/features.md`

## Issue
A critical audit of `docs/features.md` against the implementation in `lib/` revealed that while the document is highly accurate and detailed, a few codebase features and technical refinements are missing or could be made more inclusive:
1. **Extended App Description Inclusivity**: Does not explicitly mention the 3D neumorphic UI design, screen data leakage protection (`FLAG_SECURE`), lockdown mode, and zero-telemetry architecture.
2. **OTP Service Debugging & Time Sync Tools**: Does not mention dev-flavor time-window TOTP code generation (`generateTimeWindowCodes`) and secret comparison helpers (`compareSecrets`) used for testing clock skew.
3. **Dual-Action FAB Menu**: Does not mention that long-pressing the main Add Account FAB presents a bottom-sheet menu to choose between QR scanning and manual entry.
4. **P2P Sync Hardening & Safety Caps**: Does not mention the P2P LAN sync payload security limits (16 MB max payload size, 5,000 max accounts limit) defined in `AppConstants`.

## Proposed Fix
Update `docs/features.md` with the following enhancements:
1. **Section 1**: Expand the inclusive extended app description to include 3D/neumorphic UI, screen data leakage protection (`FLAG_SECURE`), lockdown mode, and zero-telemetry architecture.
2. **Section 2**: Add details regarding dev-flavor time-window code generation (`generateTimeWindowCodes`) and secret comparison testing.
3. **Section 3**: Clarify the FAB long-press bottom-sheet selection menu.
4. **Section 6**: Add P2P LAN sync payload security limits (16 MB cap, 5,000 account limit).

---

## Plan Verification
1. Verify `docs/features.md` renders cleanly and remains fully accurate against all files in `lib/`.
