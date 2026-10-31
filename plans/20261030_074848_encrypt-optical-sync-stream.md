# Encrypt the optical sync stream

**Status:** completed

Follow-up chosen by the owner during Part 5d (`plans/20261030_072311_localization-part-5d-features-help.md`,
"Decisions during implementation", item 4). Master plan: `plans/20261029_183929_adopt-updated-guidelines.md`.

**Security impact:** high, and positive. The optical stream today carries every account secret in
plain QR frames. After this change the frames carry only AES-256-GCM ciphertext; the key comes from
a one-time code that never appears on the sending screen. No new permission, no network use, no new
dependency.

## What the issue is

"Send optical stream" (`lib/services/optical_sync_service.dart`) turns the full sync payload
(all accounts with their secrets, plus settings) into JSON, cuts it into 128-byte chunks and shows
them as a looping series of QR codes. Nothing is encrypted:

- Anyone who can see or film the sending screen (a person behind you, a CCTV camera, a video call)
  can rebuild the whole payload with any QR reader and get every 2FA secret.
- The CRC32 and the 8-character SHA-256 "session hash" only catch broken frames. They do not hide
  anything and do not prove who sent the stream.

Wi-Fi sync does not have this problem: it seals the payload with AES-256-GCM, using a key made with
PBKDF2 from a pairing code (`P2pSyncService.deriveKey`, `encryptWire`, `decryptWire`). The optical
path should get the same protection.

## The idea

Encrypt the whole payload **once** before it is cut into frames. The frames then carry only
ciphertext. The key comes from a short one-time **transfer code** that the user moves by hand.

**Where the code is shown — the receiving phone (recommended).** The risk is someone filming the
*sending* screen while the QR stream runs. If the code were shown on that same screen, the same
video would capture both the code and the stream. So:

1. On the **receiving** phone, the user taps "Scan optical stream". It shows a new random transfer
   code (12 characters, shown as `ABCD-EFGH-JKMN`) and the text "Type this code on the sending
   phone". Then the user taps "Start scanning".
2. On the **sending** phone, the user taps "Send optical stream". A dialog asks for the transfer
   code. Only after a valid code is typed does the QR stream start.
3. When the receiver has all frames, it decrypts with the code. A wrong code fails the GCM check
   and shows a clear error ("The code did not match. On the sending phone, stop and type the code
   again."). Nothing is imported.

(The other order — code shown on the sender, typed on the receiver — is simpler to build but weaker,
for the reason above. I recommend the receiver order; tell me if you prefer the other.)

**Code strength.** 12 characters from the existing 31-symbol pairing alphabet
(`AppConstants.syncPairingAlphabet`, no look-alike characters) is about 59 bits. Each guess costs
PBKDF2-HMAC-SHA256 with 300,000 iterations (`AppConstants.pbkdf2Iterations`, the same as backups and
Wi-Fi sync). Someone with a recording would need on the order of 10^23 hash steps to try all codes,
which is far out of reach. The code is used once and then thrown away.

## Plan for the fix

### 1. Crypto (service layer, no UI text)
- `lib/services/optical_sync_service.dart`
  - New `OpticalSyncCrypto` (static helpers, in the same file):
    - `generateTransferCode()` — 12 characters from the pairing alphabet, secure random.
    - `seal(String payloadJson, String code) → Uint8List` — layout
      `salt (16) | nonce (12) | ciphertext + GCM tag`. Fresh salt and nonce every time. Key from
      PBKDF2 (same function and settings as Wi-Fi sync).
    - `open(Uint8List sealed, String code) → String` — throws `OpticalSyncException` with a new code
      `wrongTransferCode` when the GCM tag check fails, and `invalidFrame` when the data is too short.
  - The encoder takes the **sealed bytes** instead of the JSON text. Chunking, parity frames, CRC32
    and the session hash work as now (the session hash is now taken over the ciphertext, so it says
    nothing about the content).
  - Frame version goes from `1` to `2`. Version 1 (plain) frames are refused with
    `unsupportedVersion`, so an old sender can never feed plain secrets into a new receiver.
  - The decoder returns the sealed bytes; `getReconstructedPayload(code)` opens them, then runs the
    existing `P2pSyncService.validateAndParse` check as now.
- `lib/services/p2p_sync_service.dart` — make the PBKDF2 key function and the secure random helper
  usable by the optical service (no change in behaviour for Wi-Fi sync). Code normalizing
  (`normalizeCode`: upper case, drop spaces and dashes) is reused for the typed transfer code.
- `lib/utils/constants.dart` — `opticalTransferCodeLength = 12`, `opticalTransferCodeGroup = 4`.

### 2. Provider
- `lib/providers/sync_provider.dart`
  - `startOpticalReceiving()` makes the transfer code and keeps it in memory only; the
    `SyncOpticalReceiving` state exposes it so the screen can show it, plus a flag "scanning
    started".
  - `startOpticalTransmitting(..., transferCode)` takes the typed code, seals the payload, then
    starts the stream. A badly formed code gives a new `SyncErrorCode.opticalCodeInvalid`.
  - `processOpticalFrame` opens the payload with the stored code. A wrong code gives
    `SyncError(opticalDecodeFailed, opticalCode: wrongTransferCode)`.
  - `reset()` clears the code. The code is never logged (`AppLogger` already logs the exception
    type only).

### 3. Screens and text (all from ARB, en / ml / sa)
- `lib/screens/optical_sync_screen.dart`
  - Receiver: first a "transfer code" view (big code, a short instruction, "Start scanning"
    button), then the scanner as now.
  - Sender: a code entry dialog before the stream starts (text field, "Start" and "Cancel"
    buttons, inline error for a code of the wrong length).
- `lib/widgets/sync_error_text.dart` — text for `wrongTransferCode` and `opticalCodeInvalid`.
- New ARB keys (about 8) in `app_en.arb`, `app_ml.arb`, `app_sa.arb`, with `@key` descriptions.
- Help and features text that now says "not encrypted, keep the screen private" changes back to
  the truth: `helpOptical05`, `helpOptical08`, `descFeatures87`, `descFeatures90` (all three
  languages), and the help steps `helpOptical07`/`09` get the "type the code" step.

### 4. Tests
- `test/services/optical_sync_service_test.dart` — update the round-trip tests to use a code; add:
  - right code → same JSON back;
  - wrong code → `wrongTransferCode`, nothing parsed;
  - one changed byte in the ciphertext → fails;
  - **no frame string contains any secret or account name** from the payload (checks the
    whole point of the change);
  - a version 1 frame is refused;
  - two seals of the same payload give different bytes (fresh salt and nonce).
- `test/services/sync_error_codes_test.dart` — the two new codes have text in every language.
- Existing l10n tests (parity, length, Hindi markers) cover the new keys.

### 5. Docs and checks
- `docs/security.md` — §3.1 entry-point row for optical frames (now: "AES-256-GCM, key from a
  one-time transfer code"), and the Sensitive Data notes.
- `docs/features.md` — optical section: remove the "not encrypted" warning, describe the code.
- `docs/architecture.md` — one line on the optical seal step, if the sync section describes the
  frame format.
- `flutter gen-l10n`, `dart format`, `flutter analyze`, `flutter test`,
  `flutter build apk --flavor dev --debug`, then stop the Gradle daemons.
- Change log with the new translations marked for review.

## Files to be changed

- `lib/services/optical_sync_service.dart`, `lib/services/p2p_sync_service.dart`,
  `lib/utils/constants.dart`
- `lib/providers/sync_provider.dart`
- `lib/screens/optical_sync_screen.dart`, `lib/widgets/sync_error_text.dart`
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`; generated `app_localizations*.dart`
- `test/services/optical_sync_service_test.dart`, `test/services/sync_error_codes_test.dart`
- `docs/security.md`, `docs/features.md`, maybe `docs/architecture.md`

## Effects on users

- Both phones need the new app version. An old sender's plain stream is refused by a new receiver
  (on purpose), and a new sender's stream cannot be read by an old receiver.
- One extra step: type a 12-character code on the sending phone.
- Sealing and opening add about one second each (PBKDF2), the same as Wi-Fi sync.
- The stream gets slightly longer: 28 bytes of salt and nonce plus a 16-byte tag — less than one
  extra frame.

## Not in this plan

- The HOTP code bug (separate plan).
- Hiding or blurring the QR stream on the sender (not needed once the frames are ciphertext).
