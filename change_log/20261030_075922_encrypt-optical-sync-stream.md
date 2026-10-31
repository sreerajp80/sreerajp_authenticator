# Encrypt the optical sync stream

Implements plan: `plans/20261030_074848_encrypt-optical-sync-stream.md`
(follow-up from `plans/20261030_072311_localization-part-5d-features-help.md`, owner decision 4)

**Security impact:** the optical QR stream no longer carries account secrets in plain text. It
carries only AES-256-GCM ciphertext; the key comes from a one-time transfer code that is never
shown on the sending screen. No new permission, network use or dependency.

## What changed

### Service — `lib/services/optical_sync_service.dart`
- New `OpticalSyncCrypto`:
  - `generateTransferCode()` — 12 characters from the pairing alphabet (about 59 bits).
  - `formatTransferCode()` (`ABCD-EFGH-JKMN`) and `parseTransferCode()` (normalizes typed input;
    `null` for a wrong length).
  - `seal(json, code)` — PBKDF2-HMAC-SHA256 (300,000 iterations, fresh 16-byte salt) and
    AES-256-GCM (fresh nonce). Layout: `salt | nonce | ciphertext + tag`.
  - `open(sealed, code)` — a wrong code or a changed byte fails the GCM check and throws the new
    `OpticalSyncErrorCode.wrongTransferCode`.
- `OpticalSyncEncoder` now takes the sealed bytes instead of JSON text. The session hash is taken
  over the ciphertext.
- Frame version is now 2. Version 1 (plaintext) frames are refused with `unsupportedVersion`.
- `OpticalSyncDecoder.getReconstructedSealed()` returns the sealed bytes;
  `getReconstructedPayload(code)` opens them and runs the existing schema check.

### Service — `lib/services/p2p_sync_service.dart`, `lib/utils/constants.dart`
- `generatePairingCode({length})` and `formatPairingCode(code, {group})` take optional sizes;
  the secure random helper is now public as `randomBytes`. Wi-Fi sync behaves as before.
- New constants: `opticalTransferCodeLength = 12`, `opticalTransferCodeGroup = 4`,
  `opticalFrameVersion = 2`.

### Provider — `lib/providers/sync_provider.dart`
- `startOpticalReceiving()` makes the transfer code (memory only). `SyncOpticalReceiving` now has
  `transferCode` and `scanning`; new `beginOpticalScanning()`. Frames are ignored until scanning
  starts.
- `startOpticalTransmitting(..., transferCode:)` refuses a badly formed code
  (new `SyncErrorCode.opticalCodeInvalid`) and seals the payload before streaming.
- PBKDF2 for sealing and opening runs in a background isolate (`Isolate.run`), so the screen does
  not freeze.
- `reset()` clears the code.
- **Bug fixed on the way:** `startOpticalReceiving()` called `reset()` without waiting for it.
  `reset()` ends by setting the idle state, so it overwrote the new receiving state a moment
  later. The old code hid this by setting the state again on the first frame; the new code view
  needs the right state from the start. It now waits for `reset()`.
- The sender no longer shows the receiver's "Reconstructing…" text while it seals; it shows a
  plain spinner.

### Screens and text
- `lib/screens/optical_sync_screen.dart`:
  - Receiver: first a **transfer code** view (large code, instruction, "Start scanning" button),
    then the camera as before. The code is plain text, not selectable, so it is never copied to
    the clipboard.
  - Sender: a dialog asks for the code before the stream starts (field with an inline error for a
    wrong length, "Cancel" closes the screen, "Start sending").
  - The scanner accepts only frames that start with the version 2 header.
- `lib/widgets/sync_error_text.dart` — text for `wrongTransferCode` and `opticalCodeInvalid`.
- `lib/screens/help/optical_sync_help_screen.dart` — the steps now follow the new order
  (receiver first), with button names from the same ARB keys.
- ARB (`app_en.arb`, `app_ml.arb`, `app_sa.arb`), generated files rebuilt:
  - 8 new keys: `titleTransferCode`, `descTransferCodeShow`, `actionStartScanning`,
    `descTransferCodeEnter`, `actionStartSending`, `errorTransferCodeLength`,
    `errorOpticalWrongCode`, `errorOpticalCodeInvalid`.
  - Changed text (all three languages): `descFeatures87`, `descFeatures90`, `helpOptical05`,
    `helpOptical07`–`helpOptical10`, `descPointReceiver`. The "not encrypted, keep the screen
    private" warnings from Part 5d are replaced by the truth. `helpOptical07`/`08`/`09` have new
    placeholders.

### Tests
- `test/services/optical_sync_service_test.dart` — rewritten for sealed payloads. New checks: right
  code round trip, wrong code, one changed byte, too-short data, fresh salt and nonce, transfer
  code format and parsing, **no frame (text or bytes) contains a secret or account data**, and
  version 1 frames refused. The Fountain-code tests (in order, out of order, dropped frames with
  parity, CRC tamper) now run on the sealed bytes.
- New `test/providers/sync_provider_optical_test.dart` — frames ignored before scanning; right
  code imports; wrong code gives `wrongTransferCode` and imports nothing; sender refuses a badly
  formed code. (This test found the `reset()` bug above.)
- `test/services/sync_error_codes_test.dart` already loops over every code, so it covers the two
  new codes in every language.

### Docs
- `docs/security.md` — new §5.2 "Optical Air-Gap Sync Security Model"; §3.1 entry-point row
  updated.
- `docs/features.md` — optical section describes the transfer code instead of the warning.
- `docs/architecture.md` — one line on the optical seal step.

## Checks

- `dart format` — no changes left.
- `flutter analyze` — no issues.
- `flutter test` — 337 tests pass.
- `flutter build apk --flavor dev --debug` — built. Gradle daemons stopped afterwards; one
  leftover daemon process was ended.
- Not checked on a real phone: the camera scan and the dialog flow between two devices.

## Effects on users

- Both devices need this version. A new receiver refuses an old sender's plain stream, and an old
  receiver cannot read a new sender's stream.
- One extra step: type a 12-character code on the sending device.

## Translations — needs native-reader review

Draft by the AI agent; please review. Least sure: `प्रेषणसङ्केतः` (transfer code),
`एकवारिक` (one-time), and `गण्डम्` (button), which is reused from earlier parts.

| Key | English | Malayalam | Sanskrit |
|---|---|---|---|
| `titleTransferCode` | Transfer code | കൈമാറ്റ കോഡ് | प्रेषणसङ्केतः |
| `descTransferCodeShow` | Type this code on the sending device, then tap the button below. Do not show this code to anyone else. | ഈ കോഡ് അയയ്ക്കുന്ന ഉപകരണത്തിൽ ടൈപ്പ് ചെയ്യുക, തുടർന്ന് താഴെയുള്ള ബട്ടൺ അമർത്തുക. ഈ കോഡ് മറ്റാരെയും കാണിക്കരുത്. | अयं सङ्केतः प्रेषक-उपकरणे लिख्यताम्, ततः अधःस्थं गण्डं स्पृश्यताम्। अयं सङ्केतः अन्यस्मै न दर्शनीयः। |
| `actionStartScanning` | Start scanning | സ്കാൻ ആരംഭിക്കുക | अवलोकनम् आरभ्यताम् |
| `descTransferCodeEnter` | Type the transfer code shown on the receiving device. The QR stream is encrypted with it. | സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ കാണിക്കുന്ന കൈമാറ്റ കോഡ് ടൈപ്പ് ചെയ്യുക. QR സ്ട്രീം അത് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യും. | स्वीकर्तृ-उपकरणे दर्शितः प्रेषणसङ्केतः लिख्यताम्। QR-प्रवाहः तेन गूढलेख्यते। |
| `actionStartSending` | Start sending | അയയ്ക്കൽ ആരംഭിക്കുക | प्रेषणम् आरभ्यताम् |
| `errorTransferCodeLength` | Type all {count} characters of the code. | കോഡിന്റെ എല്ലാ {count} അക്ഷരങ്ങളും ടൈപ്പ് ചെയ്യുക. | सङ्केतस्य सर्वाणि {count} अक्षराणि लिख्यन्ताम्। |
| `errorOpticalWrongCode` | The code did not match. On the sending device, stop and type the code again. | കോഡ് പൊരുത്തപ്പെട്ടില്ല. അയയ്ക്കുന്ന ഉപകരണത്തിൽ നിർത്തി കോഡ് വീണ്ടും ടൈപ്പ് ചെയ്യുക. | सङ्केतः न समानः। प्रेषक-उपकरणे स्थगयित्वा सङ्केतः पुनः लिख्यताम्। |
| `errorOpticalCodeInvalid` | The transfer code is not valid. Start again and type the code shown on the receiving device. | കൈമാറ്റ കോഡ് സാധുവല്ല. വീണ്ടും ആരംഭിച്ച് സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ കാണിക്കുന്ന കോഡ് ടൈപ്പ് ചെയ്യുക. | प्रेषणसङ्केतः अमान्यः। पुनः आरभ्य स्वीकर्तृ-उपकरणे दर्शितः सङ्केतः लिख्यताम्। |
| `descFeatures87` | Move accounts to an offline device with an animated series of QR codes, without Wi-Fi or Bluetooth. The QR codes are encrypted with a one-time code that you type. | Wi-Fi-ഓ ബ്ലൂടൂത്തോ ഇല്ലാതെ ചലിക്കുന്ന QR കോഡുകൾ വഴി ഓഫ്‌ലൈൻ ഉപകരണത്തിലേക്ക് അക്കൗണ്ടുകൾ മാറ്റുക. നിങ്ങൾ ടൈപ്പ് ചെയ്യുന്ന ഒറ്റത്തവണ കോഡ് ഉപയോഗിച്ച് QR കോഡുകൾ എൻക്രിപ്റ്റ് ചെയ്യുന്നു. | Wi-Fi, नीलदन्तं (Bluetooth) वा विना चलत्-QR-सङ्केतश्रेण्या अन्तर्जालरहितम् उपकरणं प्रति विवरणानि स्थानान्तर्यन्ताम्। QR-सङ्केताः भवता लिखितेन एकवारिकसङ्केतेन गूढलेख्यन्ते। |
| `descFeatures90` | Encrypted stream | എൻക്രിപ്റ്റ് ചെയ്ത സ്ട്രീം | गूढलेखितप्रवाहः |
| `helpOptical05` | The data travels only as light, from screen to camera, so there is no network to listen to. The QR codes are encrypted, and the key comes from a code that is never shown on the sending screen. | വിവരങ്ങൾ സ്ക്രീനിൽ നിന്ന് ക്യാമറയിലേക്ക് വെളിച്ചമായി മാത്രം സഞ്ചരിക്കുന്നു; അതിനാൽ ചോർത്താൻ നെറ്റ്‌വർക്ക് ഇല്ല. QR കോഡുകൾ എൻക്രിപ്റ്റ് ചെയ്തതാണ്; അതിന്റെ കീ അയയ്ക്കുന്ന സ്ക്രീനിൽ ഒരിക്കലും കാണിക്കാത്ത ഒരു കോഡിൽ നിന്നാണ് വരുന്നത്. | दत्तांशः पटलात् छायाग्राहकं प्रति केवलं प्रकाशरूपेण गच्छति, अतः श्रवणाय जालं नास्ति। QR-सङ्केताः गूढलेखिताः, तेषां कुञ्चिका च प्रेषकपटले कदापि अदर्शितात् सङ्केतात् निर्मीयते। |
| `helpOptical07` | Step 1: On the receiving device, go to {settings} → {syncDevices} → “{scanOptical}”. It shows a one-time transfer code. | ഘട്ടം 1: സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ {settings} → {syncDevices} → “{scanOptical}” എന്നതിലേക്ക് പോകുക. അത് ഒരു ഒറ്റത്തവണ കൈമാറ്റ കോഡ് കാണിക്കും. | पदम् 1: स्वीकर्तृ-उपकरणे {settings} → {syncDevices} → “{scanOptical}” प्रति गम्यताम्। तत् एकवारिकं प्रेषणसङ्केतं दर्शयति। |
| `helpOptical08` | Step 2: On the sending device, choose “{sendOptical}” and type that code. Your accounts are encrypted with it and shown as a looping series of QR codes. | ഘട്ടം 2: അയയ്ക്കുന്ന ഉപകരണത്തിൽ “{sendOptical}” തിരഞ്ഞെടുത്ത് ആ കോഡ് ടൈപ്പ് ചെയ്യുക. അക്കൗണ്ടുകൾ അത് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത് ആവർത്തിക്കുന്ന QR കോഡുകളായി കാണിക്കും. | पदम् 2: प्रेषक-उपकरणे “{sendOptical}” चित्वा सः सङ्केतः लिख्यताम्। विवरणानि तेन गूढलेखितानि आवर्तमानया QR-सङ्केतश्रेण्या दर्श्यन्ते। |
| `helpOptical09` | Step 3: On the receiving device, tap “{startScanning}” and point the camera at the sending screen. | ഘട്ടം 3: സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ “{startScanning}” അമർത്തി ക്യാമറ അയയ്ക്കുന്ന സ്ക്രീനിലേക്ക് തിരിക്കുക. | पदम् 3: स्वीकर्तृ-उपकरणे “{startScanning}” स्पृष्ट्वा छायाग्राहकं प्रेषकपटले स्थाप्यताम्। |
| `helpOptical10` | Step 4: The receiver collects all parts. When every part is read and the code matches, the accounts are imported. With a wrong code, nothing is imported. | ഘട്ടം 4: സ്വീകരിക്കുന്ന ഉപകരണം എല്ലാ ഭാഗങ്ങളും ശേഖരിക്കും. എല്ലാ ഭാഗങ്ങളും വായിക്കുകയും കോഡ് ശരിയാവുകയും ചെയ്താൽ അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യും. കോഡ് തെറ്റാണെങ്കിൽ ഒന്നും ഇറക്കുമതി ചെയ്യില്ല. | पदम् 4: स्वीकर्ता सर्वान् खण्डान् सङ्गृह्णाति। सर्वेषु खण्डेषु पठितेषु सङ्केते च शुद्धे विवरणानि आनीयन्ते। सङ्केते अशुद्धे किमपि न आनीयते। |
| `descPointReceiver` | Point the receiving device camera at this animated QR stream. The data is encrypted with the transfer code; no network is used. | സ്വീകരിക്കുന്ന ഉപകരണത്തിന്റെ ക്യാമറ ഈ ചലിക്കുന്ന QR സ്ട്രീമിലേക്ക് തിരിക്കുക. വിവരങ്ങൾ കൈമാറ്റ കോഡ് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്തതാണ്; നെറ്റ്‌വർക്ക് ഉപയോഗിക്കുന്നില്ല. | स्वीकर्तृ-उपकरणस्य छायाग्राहकम् अस्मिन् चलत्-QR-प्रवाहे स्थाप्यताम्। दत्तांशः प्रेषणसङ्केतेन गूढलेखितः; जालं न प्रयुज्यते। |
