# Plan: Steam Guard & Non-Standard Algorithm Support

**Status:** Approved

## Context & Objective
Currently, `OTPService` supports standard 6-digit to 8-digit numeric TOTP/HOTP (SHA-1, SHA-256, SHA-512). To expand app compatibility for non-standard authenticator types (Improvement 1 in `docs/feature_analysis_and_roadmap.md`), we need to extend `OTPService` to support:
1. **Steam Guard**: Custom 5-character alphanumeric TOTP (`23456789BCDFGHJKMNPQRTVWXY`).
2. **Blizzard Authenticator**: 8-digit TOTP supporting Hex-encoded secret keys.
3. **YubiKey HMAC-SHA1**: Standard TOTP/HOTP supporting Hex-encoded and Base32 secrets.
4. **mOTP (Mobile OTP)**: MD5-based OTP code generation using secret key and 10-second period.
5. **QR Code & URI Recognition**: Native support for `steam://` URIs and non-standard algorithm URIs in `QrScannerScreen` and `OTPService.parseOtpAuthUri`.

---

## Targeted Files & Changes

### 1. `lib/services/otp_service.dart`
- **Secret Decoder Enhancement**: Update `_decodeSecretBytes` to detect and decode Hex-encoded secrets (0-9, A-F) in addition to standard Base32 secrets when applicable (used by Blizzard, YubiKey, mOTP).
- **Steam Guard Implementation**:
  - Define custom lookup table `_steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY'`.
  - Implement Steam code generator using HMAC-SHA1 30s period time step, truncated to a 31-bit integer, and converting the integer mod 26 across 5 iterations into 5 alphanumeric characters.
- **Blizzard, YubiKey, & mOTP Support**:
  - Handle algorithm tags: `STEAM`, `BLIZZARD`, `YUBIKEY`, `MOTP`.
  - Support `MOTP` code generation (MD5 digest over time step + secret + pin, taking the first 6 characters).
- **URI Parsing (`parseOtpAuthUri`)**:
  - Support `steam://` scheme URIs (e.g. `steam://<secret>`, `steam://totp/...`, `steam://secret=<secret>`).
  - Support `motp://` scheme URIs and `otpauth://` URIs specifying `steam`, `blizzard`, `yubikey`, or `motp`.

### 2. `lib/screens/qr_scanner_screen.dart`
- Update `_processQRCode` to natively recognize `steam://` URIs and leverage `OTPService.parseOtpAuthUri` for unified URI parsing across standard and non-standard formats.

### 3. `lib/widgets/account_tile.dart`
- Update `_formatOTP` to gracefully format 5-character Steam Guard codes (and arbitrary length codes) without throwing index out-of-range errors.

### 4. `test/services/otp_service_test.dart`
- Add unit tests for Steam Guard code generation (with standard test vectors), Blizzard 8-digit generation, YubiKey Hex secret decoding, mOTP MD5 calculation, and `steam://` URI parsing.

---

## Verification Plan

### Automated Verification
- Run `flutter analyze` to ensure zero static analysis warnings.
- Run `flutter test` to verify all existing and new unit tests pass.

### Manual Verification
- Test `OTPService.parseOtpAuthUri` with various `steam://` and `otpauth://` test URIs.
- Verify Steam Guard code generation output against test vectors.
