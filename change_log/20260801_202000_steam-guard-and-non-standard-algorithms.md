# Change Log: Steam Guard & Non-Standard Algorithm Support

**Plan Reference:** [plans/20260801_202000_steam-guard-and-non-standard-algorithms.md](../plans/20260801_202000_steam-guard-and-non-standard-algorithms.md)

## Summary of Changes
Implemented **Improvement 1** from `docs/feature_analysis_and_roadmap.md`, extending `Sreeraj P Authenticator` to support Steam Guard, Blizzard Authenticator, YubiKey HMAC-SHA1, and mOTP (Mobile OTP), along with native recognition of `steam://` URIs during QR code scanning.

---

## Detailed Changes

### 1. `lib/services/otp_service.dart`
- **Steam Guard Support:** Defined `_steamAlphabet` (`23456789BCDFGHJKMNPQRTVWXY`) and implemented `_generateSteamCode` using HMAC-SHA1 30s period time step and 5-character string construction.
- **Blizzard Authenticator Support:** Added 8-digit HMAC-SHA1 TOTP generation with support for Hex-encoded secrets.
- **YubiKey HMAC-SHA1 Support:** Added standard TOTP code generation with support for Hex-encoded secrets.
- **mOTP Support:** Added `_generateMotpCode` implementing MD5 hash calculation over `(timeStep + secret + pin)` yielding 6-character hex OTP.
- **Secret Decoder (`_decodeSecretBytes`):** Added Hex-encoded secret detection (`_isHex`) and decoding (`_hexDecode`), preventing raw hex secrets from being misclassified as invalid base32 or encrypted strings.
- **URI Parser (`parseOtpAuthUri`):**
  - Added native support for `steam://` scheme URIs (`steam://<secret>`, `steam://totp/...`, `steam://secret=<secret>`).
  - Added native support for `motp://` scheme URIs.
  - Extended `otpauth://` URI handling for `steam`, `blizzard`, `yubikey`, and `motp` algorithm and host types.

### 2. `lib/screens/qr_scanner_screen.dart`
- Refactored `_processQRCode` to delegate URI parsing directly to `OTPService.parseOtpAuthUri(code)`, enabling instant QR code scanning recognition for `steam://`, `motp://`, and non-standard `otpauth://` URIs.

### 3. `lib/widgets/account_tile.dart`
- Updated `_formatOTP` to gracefully render 5-character Steam Guard alphanumeric codes without splitting or array index out of bounds errors.

### 4. `test/services/otp_service_test.dart`
- Added comprehensive unit test suites covering Steam Guard 5-character code generation, Blizzard 8-digit code generation with Hex secret, YubiKey HMAC-SHA1 code generation, mOTP MD5 calculation, and `steam://` / `motp://` URI parsing.

---

## Verification
- **Static Analysis:** Executed `flutter analyze` — 0 errors, 0 warnings.
- **Automated Unit Tests:** Executed `flutter test` — all 223 tests passed successfully.
