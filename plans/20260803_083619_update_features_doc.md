# Plan: Update docs/features.md with Inclusive Description & Complete Feature List

**Status:** Proposed / Pending Approval

## Files to change
- [docs/features.md](file:///l:/Android/SreerajP_Authenticator/docs/features.md)

## Issue
`docs/features.md` was missing key implementation details present in the codebase:
1. **Account Description / Notes field**: The `description` property in `Account` model (`lib/models/account.dart`) allowing optional per-account notes in add/edit screens was omitted from Section 3.
2. **Canonical App Description**: The canonical app description from `assets/config/app_config.json` ("Privacy-first, offline-first TOTP/HOTP authenticator app with AES-256-GCM vault encryption.") was not highlighted in the introductory summary.
3. **HOTP UI Behavior & Fallback Display**: Manual counter increment for HOTP tiles and placeholder error code display (`'------'`) when secrets fail decryption were not explicitly documented in Sections 2 & 3.
4. **Backup & System Integration Details**: The use of system `file_picker` for imports and exact `ImportResult` feedback (reporting added vs skipped duplicates based on name + issuer + type) were partially unspecified in Section 5.
5. **Config & Version Metadata**: Specific app version `2.7.11` (build `20`) reference from `assets/config/app_config.json` was missing in Section 7.

## Proposed Fix
Update `docs/features.md` to:
1. Update **Section 1 (What this app is)** to incorporate the canonical description string from `app_config.json` and ensure the summary comprehensively highlights all core capabilities (multi-algorithm OTP, vault security, tags & description notes, offline brand icons, encrypted backups, and 3 P2P/optical sync modes).
2. Update **Section 2 (OTP types & algorithms)** to mention placeholder fallback display (`'------'`) on decryption errors and clarify HOTP manual generation mechanics.
3. Update **Section 3 (Account management)** to include the optional Account `description` (notes) field, search matching criteria (name, issuer, tags), and HOTP tile interaction details.
4. Update **Section 5 (Backup and restore)** to document `file_picker` integration and exact `ImportResult` reporting (`accountsAdded` vs `accountsSkipped`).
5. Update **Section 6 (Device-to-device sync)** to document the out-of-band QR scheme (`spauth://sync?...`).
6. Update **Section 7 (UI, theming, and settings)** to reference version `2.7.11` (build `20`) from `app_config.json`.
