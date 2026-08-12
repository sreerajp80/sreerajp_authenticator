# Change Log: Audit and Update Features Reference Document

**Plan:** [20260803_084908_audit_features_doc.md](file:///l:/Android/SreerajP_Authenticator/plans/20260803_084908_audit_features_doc.md)  
**Date:** 2026-08-03  
**Author:** Antigravity

## Summary of Changes
Critically analyzed `docs/features.md` against the implementation in `lib/` and updated the feature reference document to ensure complete accuracy and an all-inclusive app description.

## Detailed Changes

### `docs/features.md`
1. **Inclusive Extended App Description (Section 1)**:
   - Expanded description to explicitly include 3D/neumorphic UI design, zero-telemetry architecture, screen data leakage protection (`FLAG_SECURE`), and lockdown mode.
2. **OTP Service Debugging & Time Sync Tools (Section 2)**:
   - Added documentation for dev-flavor `OTPService` features: `generateTimeWindowCodes` (testing TOTP across $\pm 1$ time-step offset windows for clock skew) and `compareSecrets` (byte-level secret comparison helper).
3. **FAB Interaction Menu (Section 3)**:
   - Clarified that long-pressing the Add Account FAB displays a bottom-sheet menu for selecting between camera QR scanning and manual entry.
4. **P2P Sync Hardening (Section 6a)**:
   - Added documentation for P2P LAN sync payload security limits defined in `AppConstants` (16 MB payload size cap, 5,000 max accounts cap, 4 KB field length cap).

## Verification
- Verified all additions against the Dart source code (`lib/services/otp_service.dart`, `lib/services/p2p_sync_service.dart`, `lib/screens/home_screen.dart`, `lib/utils/constants.dart`).
