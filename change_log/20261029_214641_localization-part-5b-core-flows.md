# Localization Part 5b — core flows

Implements plan: `plans/20261029_211728_localization-part-5b-core-flows.md`
(Part 5b of `plans/20261029_202317_localization-phase-5.md`)

## What changed

### Screens and widgets (all user-visible text now from ARB)
- `lib/screens/lock_screen.dart`, `home_screen.dart`, `add_account_screen.dart`,
  `qr_scanner_screen.dart`, `permissions_screen.dart`.
- `lib/widgets/pin_verification_dialog.dart`, `account_tile.dart`, `widgets/home/*` (5 files),
  `widgets/add_account/*` (4 files). `widgets/account_tile/*` had no UI text.
- 226 new ARB keys in `app_en.arb`, `app_ml.arb`, `app_sa.arb` (309 in total).
- Existing tooltips in these files now come from ARB (`tooltip…` keys). Adding missing tooltips is
  Phase 6.

### Text moved out of providers and services
- `lib/providers/settings_provider.dart` — new enum `UnlockInstruction`; getter
  `unlockInstruction` replaces `unlockInstructionText`; `pinRequiredMessage` removed. The lock
  screen maps `UnlockInstruction` and `PinRequiredReason` to ARB text.
- `lib/services/auth_service.dart` — `authenticateWithBiometric({required String reason})`,
  `authenticateWithPhoneLock({required String reason})` (and the wrappers
  `authenticateWithDeviceLock` / `authenticate`). Callers pass the localized prompt text:
  `lock_screen.dart`, `home_screen.dart`, `pin_verification_dialog.dart`, and two call sites in
  `security_screen.dart` (Part 5c screen; only those lines changed).

### PIN dialog purpose
`showPinVerificationDialog` built its title as `'Enter App PIN to $purpose'` from English
fragments (and `add_account_screen.dart` joined `'secret key' and 'advanced settings'`). Word order
differs between languages, so the title is now the fixed "Enter App PIN" and `purpose` is one
complete localized sentence shown under it (`descPinPurpose…` keys).

### Friendly errors instead of raw exception text
- `qr_scanner_screen.dart` showed `Error: ${e.toString()}` in two places. It now throws a private
  `_QrCodeError` for an invalid code or a missing secret, shows a localized message, and shows a
  generic localized message for anything else. The error type is logged through `AppLogger`
  (which logs only the type, never the text or the scanned payload).
- `add_account_screen.dart` showed `Error saving account: $e`. It now logs through `AppLogger`
  and shows a localized "Could not save the account" message. (Same class of problem in a 5b
  file; not named in the plan.)

### English text changed
- Sentence case for titles, buttons and tabs (standard §8.6), for example "Delete account",
  "Reassign tags", "QR scanner", "Manual entry", "Browse existing tags", "Clear all".
- Shortened to fit 20 characters: "Unlock with Phone Screen Lock" → "Unlock with phone";
  "Use Phone Screen Lock" → "Use phone lock"; "Checking Phone Screen Lock..." → "Checking phone
  lock…"; "Delete Selected Accounts" → "Delete accounts"; "New App PIN (4-6 digits)" →
  "New App PIN" with helper text "4–6 digits"; "Tags (Comma separated)" → "Tags" with hint
  "Comma separated, e.g. Work, Crypto, VIP"; "Biometric / Device Lock" → "Biometric unlock";
  "Built-in Capabilities" → "Built-in features"; tooltips "Unlock to edit", "Turn on app lock";
  "Apply (2 selected)" → "Apply (2)"; "Search existing tags..." → "Search tags…".
- "Incorrect App PIN. 2 attempts remaining" → "Incorrect App PIN. Attempts left: 2" (no plural
  forms needed in any language).
- The home app-bar title now shows the app name in the active language (it was always English).

### Tests
- `test/providers/settings_provider_test.dart` — checks `UnlockInstruction` values.
- `test/services/auth_service_test.dart` — passes `reason`.
- `test/widgets/security_auth_widgets_test.dart`, `home/home_widgets_test.dart`,
  `add_account/tag_autocomplete_field_test.dart` — localization delegates; updated English text.
- New `test/screens/lock_screen_l10n_test.dart` — the PIN-required lock screen in `en`, `ml`,
  `sa` on a narrow 360 px screen (right texts, no overflow); every reason / instruction has its
  own text.
- `test/l10n/translation_parity_test.dart` — `labelMaskedValue` (`{label}: {value}`, a pure
  pattern) added to the same-as-template allow-list.

### Docs
`CLAUDE.md`, `AGENTS.md` (migration status; providers and services hold no UI text),
`docs/implementation_progress.md` (5b ticked).

## Checks
- `flutter gen-l10n` — OK.
- `dart format` on all changed Dart files. It also reformatted earlier-phase files in the same
  working tree that had older formatting drift (32 files changed in total).
- `flutter analyze` — no issues.
- `flutter test` — all 266 tests passed (262 before).
- `flutter build apk --flavor dev --debug` — built. Gradle daemons stopped; none left.

## Found, not fixed here (need their own plans)
1. **Security bug — bulk delete can skip verification.** In `home_screen.dart`,
   `_verifyBiometricOrPinForBulkDelete()` ends with `return true;` even when the phone-lock check
   failed. With no biometrics and app lock off, deleting selected accounts goes ahead after a
   failed or canceled phone-lock prompt. Fix: return `phoneResult.isSuccess`.
2. **Crash — "Open security" button.** `add_account_screen.dart` calls
   `Navigator.pushNamed(context, '/security')`, but the app defines no named routes, so the button
   throws. Fix: push `SecurityScreen` with `MaterialPageRoute`.
3. The permissions screen card "No internet access / works completely offline" is not accurate:
   the app has the INTERNET permission for Wi-Fi sync on the local network. Kept and translated
   as it was; to correct in Phase 7 with the privacy dialog text.
4. Glossary gaps: the language pack has no terms for PIN, phone lock, unlock, recovery key,
   password. Drafts used here: PIN kept in Latin letters; ml ഫോൺ സ്ക്രീൻ ലോക്ക്, വീണ്ടെടുക്കൽ കീ,
   രഹസ്യവാക്ക്; sa दूरभाषपटलतालकम्, पुनःप्राप्तिकुञ्चिका, गुप्तशब्दः. Note for the owner: these
   could be added to the shared language pack (the submodule is read-only here).
5. **Manual device check needed:** lock screen (PIN and phone-lock paths), home (selection mode,
   batch dialogs, tag cloud), add account, QR scanner, permissions — in `ml` and `sa`, looking
   for clipping, overflow and wrong text.

## Translations — needs native-reader review

All Malayalam and Sanskrit strings below are AI drafts and need review by the translation
reviewer (Developer, Sreeraj P) before release. Least sure: the security terms in item 4 above,
`labelSortManual`, `labelSortIssuer`, `descHomeHint`, `labelEnvProduction`-style register
choices, `errorPinTooShort` (sa), and `titleUseDeviceLock` / `titleUnlockApp` (sa).

| Key | English | Malayalam | Sanskrit |
|---|---|---|---|
| `actionOk` | OK | ശരി | अस्तु |
| `actionCancel` | Cancel | റദ്ദാക്കുക | निरस्यताम् |
| `actionCopy` | Copy | പകർത്തുക | प्रतिलिख्यताम् |
| `errorPhoneLockFailed` | Phone screen lock failed | ഫോൺ സ്ക്രീൻ ലോക്ക് പരാജയപ്പെട്ടു | दूरभाषपटलतालकम् असफलम् |
| `errorPhoneLockCanceled` | Phone screen lock was canceled | ഫോൺ സ്ക്രീൻ ലോക്ക് റദ്ദാക്കി | दूरभाषपटलतालकं निरस्तम् |
| `errorPhoneLockLockedOut` | Phone screen lock is temporarily locked out | ഫോൺ സ്ക്രീൻ ലോക്ക് താൽക്കാലികമായി തടഞ്ഞിരിക്കുന്നു | दूरभाषपटलतालकं तात्कालिकरूपेण अवरुद्धम् |
| `errorPhoneLockUnavailable` | Phone screen lock is not available on this device | ഈ ഉപകരണത്തിൽ ഫോൺ സ്ക്രീൻ ലോക്ക് ലഭ്യമല്ല | अस्मिन् उपकरणे दूरभाषपटलतालकं न उपलभ्यते |
| `errorPhoneLockUnverified` | Unable to verify phone screen lock | ഫോൺ സ്ക്രീൻ ലോക്ക് പരിശോധിക്കാൻ കഴിഞ്ഞില്ല | दूरभाषपटलतालकं परीक्षितुं न शक्तम् |
| `descPinRequiredIdle` | App PIN required after 1 hour | ഒരു മണിക്കൂറിന് ശേഷം ആപ്പ് PIN ആവശ്യമാണ് | एकहोरानन्तरम् अनुप्रयोग-PIN आवश्यकम् |
| `descPinRequiredReboot` | App PIN required after device restart | ഉപകരണം പുനരാരംഭിച്ചതിനാൽ ആപ്പ് PIN ആവശ്യമാണ് | उपकरणस्य पुनरारम्भात् अनुप्रयोग-PIN आवश्यकम् |
| `descPinRequiredFailures` | App PIN required after 3 failed phone lock attempts | ഫോൺ ലോക്ക് 3 തവണ പരാജയപ്പെട്ടതിനാൽ ആപ്പ് PIN ആവശ്യമാണ് | दूरभाषतालकस्य त्रिवारम् असाफल्यात् अनुप्रयोग-PIN आवश्यकम् |
| `descPinRequiredLockdown` | Lockdown mode is on. Enter your App PIN | ലോക്ക്ഡൗൺ മോഡ് സജീവമാണ്. ആപ്പ് PIN നൽകുക | पूर्णावरोधः सक्रियः। अनुप्रयोग-PIN दीयताम् |
| `descUnlockSetUpPin` | Use your phone screen lock to set up your App PIN | ആപ്പ് PIN സജ്ജമാക്കാൻ ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുക | अनुप्रयोग-PIN सज्जीकर्तुं दूरभाषपटलतालकं प्रयुज्यताम् |
| `descUnlockPhoneOnly` | Use your phone screen lock | ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുക | दूरभाषपटलतालकं प्रयुज्यताम् |
| `descUnlockPhoneOrPin` | Use your phone screen lock or enter your App PIN | ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുക, അല്ലെങ്കിൽ ആപ്പ് PIN നൽകുക | दूरभाषपटलतालकं प्रयुज्यताम्, अथवा अनुप्रयोग-PIN दीयताम् |
| `descUnlockPinOnly` | Enter your App PIN | ആപ്പ് PIN നൽകുക | अनुप्रयोग-PIN दीयताम् |
| `descUnlockWithPhone` | Use your phone screen lock to unlock | തുറക്കാൻ ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുക | उद्घाटनाय दूरभाषपटलतालकं प्रयुज्यताम् |
| `errorPinEmpty` | Please enter your App PIN | ദയവായി ആപ്പ് PIN നൽകുക | प्रथमम् अनुप्रयोग-PIN दीयताम् |
| `errorPinLockedOut` | Too many failed attempts. Try again in {seconds} seconds. | നിരവധി തെറ്റായ ശ്രമങ്ങൾ. {seconds} സെക്കൻഡിന് ശേഷം വീണ്ടും ശ്രമിക്കുക. | बहवः विफलप्रयत्नाः। {seconds} क्षणानन्तरं पुनः प्रयत्यताम्। |
| `errorPinIncorrectRemaining` | Incorrect App PIN. Attempts left: {count} | തെറ്റായ ആപ്പ് PIN. ശേഷിക്കുന്ന ശ്രമങ്ങൾ: {count} | अशुद्धम् अनुप्रयोग-PIN। अवशिष्टाः प्रयत्नाः: {count} |
| `errorPinIncorrect` | Incorrect App PIN | തെറ്റായ ആപ്പ് PIN | अशुद्धम् अनुप्रयोग-PIN |
| `titleNoRecoveryKey` | No recovery key | വീണ്ടെടുക്കൽ കീ ഇല്ല | पुनःप्राप्तिकुञ्चिका नास्ति |
| `descNoRecoveryKey` | No recovery key was set up for this App PIN. Unfortunately, there is no way to recover access without it.<br><br>You can reinstall the app, but all accounts will be lost. | ഈ ആപ്പ് PIN-ന് വീണ്ടെടുക്കൽ കീ സജ്ജമാക്കിയിട്ടില്ല. അതില്ലാതെ പ്രവേശനം വീണ്ടെടുക്കാൻ വഴിയില്ല.<br><br>ആപ്പ് വീണ്ടും ഇൻസ്റ്റാൾ ചെയ്യാം, പക്ഷേ എല്ലാ അക്കൗണ്ടുകളും നഷ്ടപ്പെടും. | अस्य अनुप्रयोग-PIN इत्यस्य कृते पुनःप्राप्तिकुञ्चिका न सज्जीकृता। तया विना प्रवेशं पुनः प्राप्तुम् उपायः नास्ति।<br><br>अनुप्रयोगं पुनः स्थापयितुं शक्यते, किन्तु सर्वाणि उपयोक्तृविवरणानि नश्यन्ति। |
| `titleEnterRecoveryKey` | Enter recovery key | വീണ്ടെടുക്കൽ കീ നൽകുക | कुञ्चिकाप्रवेशः |
| `descEnterRecoveryKey` | Enter the recovery key you saved when setting up your App PIN. | ആപ്പ് PIN സജ്ജമാക്കുമ്പോൾ സൂക്ഷിച്ച വീണ്ടെടുക്കൽ കീ നൽകുക. | अनुप्रयोग-PIN सज्जीकरणकाले रक्षिता पुनःप्राप्तिकुञ्चिका दीयताम्। |
| `labelRecoveryKey` | Recovery key | വീണ്ടെടുക്കൽ കീ | पुनःप्राप्तिकुञ्चिका |
| `errorRecoveryKeyInvalid` | Invalid recovery key | അസാധുവായ വീണ്ടെടുക്കൽ കീ | अमान्या पुनःप्राप्तिकुञ्चिका |
| `actionRecover` | Recover | വീണ്ടെടുക്കുക | पुनः प्राप्यताम् |
| `titleSetUpPin` | Set up App PIN | ആപ്പ് PIN സജ്ജീകരണം | अनुप्रयोग-PIN सज्जीकरणम् |
| `descSetUpPin` | Create your App PIN to finish securing the app. App PIN is always required for secret access. | ആപ്പ് സുരക്ഷിതമാക്കൽ പൂർത്തിയാക്കാൻ നിങ്ങളുടെ ആപ്പ് PIN സൃഷ്ടിക്കുക. രഹസ്യങ്ങൾ കാണാൻ ആപ്പ് PIN എപ്പോഴും ആവശ്യമാണ്. | अनुप्रयोगस्य सुरक्षां समापयितुं भवतः अनुप्रयोग-PIN रच्यताम्। रहस्यप्रवेशाय अनुप्रयोग-PIN सदा आवश्यकम्। |
| `labelNewPin` | New App PIN | പുതിയ ആപ്പ് PIN | नूतनम् अनुप्रयोग-PIN |
| `descPinDigitsHint` | 4–6 digits | 4–6 അക്കങ്ങൾ | 4–6 अङ्काः |
| `labelConfirmPin` | Confirm App PIN | ആപ്പ് PIN സ്ഥിരീകരണം | अनुप्रयोग-PIN स्थिरीकरणम् |
| `errorPinTooShort` | App PIN must be at least 4 digits | ആപ്പ് PIN-ൽ കുറഞ്ഞത് 4 അക്കങ്ങൾ വേണം | अनुप्रयोग-PIN न्यूनातिन्यूनं चतुरङ्कात्मकं भवेत् |
| `errorPinMismatch` | App PINs do not match | ആപ്പ് PIN-കൾ പൊരുത്തപ്പെടുന്നില്ല | अनुप्रयोग-PIN-द्वयं न सङ्गच्छते |
| `actionSavePin` | Save App PIN | PIN സൂക്ഷിക്കുക | PIN रक्ष्यताम् |
| `titleSetNewPin` | Set new App PIN | പുതിയ PIN സജ്ജീകരണം | नूतनPIN-सज्जीकरणम् |
| `descSetNewPin` | Your old App PIN has been cleared. Please set a new App PIN. | നിങ്ങളുടെ പഴയ ആപ്പ് PIN നീക്കം ചെയ്തു. ദയവായി പുതിയ ആപ്പ് PIN സജ്ജമാക്കുക. | भवतः पुरातनम् अनुप्रयोग-PIN अपनीतम्। नूतनम् अनुप्रयोग-PIN सज्जीक्रियताम्। |
| `titleRecoveryKey` | Recovery key | വീണ്ടെടുക്കൽ കീ | पुनःप्राप्तिकुञ्चिका |
| `descRecoveryKeySave` | Save this recovery key in a safe place. It is the only way to regain access if you forget your App PIN. | ഈ വീണ്ടെടുക്കൽ കീ സുരക്ഷിതമായ ഒരിടത്ത് സൂക്ഷിക്കുക. ആപ്പ് PIN മറന്നാൽ പ്രവേശനം വീണ്ടെടുക്കാനുള്ള ഏക വഴി ഇതാണ്. | इयं पुनःप्राप्तिकुञ्चिका सुरक्षिते स्थाने रक्ष्यताम्। अनुप्रयोग-PIN विस्मृते सति प्रवेशं पुनः प्राप्तुम् अयम् एव एकः उपायः। |
| `descRecoveryKeyCopied` | Recovery key copied to clipboard | വീണ്ടെടുക്കൽ കീ പകർത്തി | पुनःप्राप्तिकुञ्चिका प्रतिलिखिता |
| `descRecoveryKeyOnce` | This key will NOT be shown again. | ഈ കീ ഇനി കാണിക്കില്ല. | इयं कुञ्चिका पुनः न दर्शयिष्यते। |
| `actionSavedIt` | I've saved it | ഞാൻ സൂക്ഷിച്ചു | मया रक्षिता |
| `titleSetUpYourPin` | Set up your App PIN | ആപ്പ് PIN സജ്ജമാക്കൽ | PIN-सज्जीकरणम् |
| `titleEnterYourPin` | Enter your App PIN | ആപ്പ് PIN നൽകൽ | PIN-प्रवेशः |
| `titleUseDeviceLock` | Unlock with phone | ഫോൺ ലോക്ക് | दूरभाषतालकम् |
| `titleUnlockApp` | Unlock the app | ആപ്പ് തുറക്കൽ | तालकोद्घाटनम् |
| `labelPinLockedFor` | Locked for {seconds} s | {seconds} സെ. തടഞ്ഞു | {seconds} क्षणान् अवरुद्धम् |
| `labelEnterPin` | Enter App PIN | ആപ്പ് PIN നൽകുക | PIN दीयताम् |
| `errorTooManyAttempts` | Too many attempts. Try again in {seconds} s | അധിക ശ്രമങ്ങൾ. {seconds} സെ. കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കുക | अतिप्रयत्नाः। {seconds} क्षणानन्तरं पुनः प्रयत्यताम् |
| `actionUnlockWithPin` | Unlock with App PIN | PIN കൊണ്ട് തുറക്കുക | PIN-द्वारेण उद्घाट्यताम् |
| `actionForgotPin` | Forgot App PIN? | PIN മറന്നോ? | PIN विस्मृतम्? |
| `labelCheckingPhoneLock` | Checking phone lock… | പരിശോധിക്കുന്നു… | परीक्ष्यते… |
| `actionUsePhoneLock` | Use phone lock | ഫോൺ ലോക്ക് ഉപയോഗിക്കുക | दूरभाषतालकं प्रयुज्यताम् |
| `labelOr` | or | അല്ലെങ്കിൽ | अथवा |
| `descAuthReasonBiometric` | Authenticate with biometrics to access your accounts | നിങ്ങളുടെ അക്കൗണ്ടുകൾ തുറക്കാൻ ബയോമെട്രിക് ഉപയോഗിച്ച് സ്ഥിരീകരിക്കുക | उपयोक्तृविवरणानि द्रष्टुं जैवमित्या प्रमाणीक्रियताम् |
| `descAuthReasonPhoneLock` | Unlock the authenticator with your phone screen lock | ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് പ്രമാണീകാരി തുറക്കുക | दूरभाषपटलतालकेन प्रमाणीकारकम् उद्घाट्यताम् |
| `errorAppLockMisconfigured` | App lock is not properly configured. Please re-enable it. | ആപ്പ് ലോക്ക് ശരിയായി ക്രമീകരിച്ചിട്ടില്ല. ദയവായി വീണ്ടും പ്രവർത്തനക്ഷമമാക്കുക. | अनुप्रयोगतालकं सम्यक् न विन्यस्तम्। पुनः सक्रियीक्रियताम्। |
| `errorAppLockNoMethod` | App lock has no unlock method. Please re-enable it. | ആപ്പ് ലോക്കിന് തുറക്കാനുള്ള മാർഗ്ഗമില്ല. ദയവായി വീണ്ടും പ്രവർത്തനക്ഷമമാക്കുക. | अनुप्रयोगतालकस्य उद्घाटनोपायः नास्ति। पुनः सक्रियीक्रियताम्। |
| `titleEnterAppPin` | Enter App PIN | ആപ്പ് PIN നൽകുക | PIN-प्रवेशः |
| `descPinRequiredForSensitive` | App PIN is required for sensitive actions and secret access. | സംവേദനക്ഷമമായ പ്രവർത്തനങ്ങൾക്കും രഹസ്യങ്ങൾ കാണാനും ആപ്പ് PIN ആവശ്യമാണ്. | संवेदनशीलकार्याणां रहस्यप्रवेशस्य च कृते अनुप्रयोग-PIN आवश्यकम्। |
| `labelAppPin` | App PIN | ആപ്പ് PIN | अनुप्रयोग-PIN |
| `actionVerify` | Verify | പരിശോധിക്കുക | परीक्ष्यताम् |
| `descPinPurposeViewSecret` | To view and edit the secret key. | രഹസ്യ കീ കാണാനും തിരുത്താനും. | गुप्तकुञ्चिकां द्रष्टुं सम्पादयितुं च। |
| `descPinPurposeAdvanced` | To view and edit the advanced options. | വിപുലമായ ഓപ്ഷനുകൾ കാണാനും തിരുത്താനും. | उन्नतविकल्पान् द्रष्टुं सम्पादयितुं च। |
| `descPinPurposeSaveChanges` | To save changes to the secret key or advanced options. | രഹസ്യ കീയിലോ വിപുലമായ ഓപ്ഷനുകളിലോ വരുത്തിയ മാറ്റങ്ങൾ സൂക്ഷിക്കാൻ. | गुप्तकुञ्चिकायाम् उन्नतविकल्पेषु वा कृतानि परिवर्तनानि रक्षितुम्। |
| `descPinPurposeDeleteSelected` | To delete the selected accounts. | തിരഞ്ഞെടുത്ത അക്കൗണ്ടുകൾ ഇല്ലാതാക്കാൻ. | चितानि उपयोक्तृविवरणानि लोप्तुम्। |
| `tooltipCancelSelection` | Cancel selection | തിരഞ്ഞെടുപ്പ് റദ്ദാക്കുക | चयनं निरस्यताम् |
| `labelSelectedCount` | {count} selected | {count} തിരഞ്ഞെടുത്തു | {count} चितानि |
| `tabAccounts` | Accounts | അക്കൗണ്ടുകൾ | उपयोक्तृविवरणानि |
| `tabTags` | Tags | അടയാളങ്ങൾ | चिह्नानि |
| `tooltipSelectAll` | Select all | എല്ലാം തിരഞ്ഞെടുക്കുക | सर्वं चीयताम् |
| `tooltipDeselectAll` | Deselect all | എല്ലാം ഒഴിവാക്കുക | सर्वं विमुच्यताम् |
| `tooltipSort` | Sort | ക്രമീകരിക്കുക | क्रमीकरणम् |
| `tooltipSettings` | Settings | ക്രമീകരണങ്ങൾ | विन्यासः |
| `descReorderHint` | Long press and drag to reorder accounts | അക്കൗണ്ടുകളുടെ ക്രമം മാറ്റാൻ അമർത്തിപ്പിടിച്ച് വലിക്കുക | उपयोक्तृविवरणानां क्रमपरिवर्तनाय दीर्घं स्पृश्य कृष्यताम् |
| `labelSortManual` | Manual | സ്വമേധയാ | स्वहस्तेन |
| `labelSortIssuer` | By issuer | നൽകുന്നയാൾ അനുസരിച്ച് | प्रदातृक्रमेण |
| `labelSortAccount` | By account name | അക്കൗണ്ട് പേര് അനുസരിച്ച് | नामक्रमेण |
| `labelSortDate` | By date added | ചേർത്ത തീയതി അനുസരിച്ച് | योजनदिनक्रमेण |
| `descFilteredBy` | Filtered by: {tags} | അരിച്ചെടുത്തത്: {tags} | चिह्नैः परिशोधितम्: {tags} |
| `actionClearFilter` | Clear filter | അരിപ്പ് നീക്കുക | परिशोधनं निरस्यताम् |
| `descHomeHint` | Long press to enter multi-select • Drag to reorder. | ഒന്നിലധികം തിരഞ്ഞെടുക്കാൻ അമർത്തിപ്പിടിക്കുക • ക്രമം മാറ്റാൻ വലിക്കുക. | बहुचयनाय दीर्घं स्पृश्यताम् • क्रमपरिवर्तनाय कृष्यताम्। |
| `actionReassignTags` | Reassign tags | അടയാളങ്ങൾ മാറ്റുക | चिह्नानि परिवर्त्यन्ताम् |
| `actionExportSelected` | Export selected | കയറ്റുമതി ചെയ്യുക | निर्याप्यताम् |
| `actionDeleteSelected` | Delete selected | ഇല്ലാതാക്കുക | लुप्यताम् |
| `actionEdit` | Edit | തിരുത്തുക | सम्पाद्यताम् |
| `actionDelete` | Delete | ഇല്ലാതാക്കുക | लुप्यताम् |
| `titleDeleteAccount` | Delete account | അക്കൗണ്ട് ഇല്ലാതാക്കൽ | विवरणलोपः |
| `descDeleteAccountConfirm` | Are you sure you want to delete {name}? | {name} ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? | {name} इति लोप्तव्यम् इति निश्चयः वा? |
| `descAccountDeleted` | {name} deleted | {name} ഇല്ലാതാക്കി | {name} लुप्तम् |
| `titleReassignTagsCount` | Reassign tags ({count}) | അടയാളങ്ങൾ മാറ്റൽ ({count}) | चिह्नपरिवर्तनम् ({count}) |
| `descReassignTagsHint` | Enter tags separated by commas (e.g. Work, VIP): | കോമ കൊണ്ട് വേർതിരിച്ച് അടയാളങ്ങൾ നൽകുക (ഉദാ. ജോലി, VIP): | अल्पविरामैः पृथक्कृतानि चिह्नानि दीयन्ताम् (यथा कार्यम्, VIP): |
| `labelTags` | Tags | അടയാളങ്ങൾ | चिह्नानि |
| `labelTagsExample` | Work, Personal | ജോലി, വ്യക്തിപരം | कार्यम्, व्यक्तिगतम् |
| `descReplaceTags` | Replace existing tags (instead of appending) | നിലവിലെ അടയാളങ്ങൾ മാറ്റിസ്ഥാപിക്കുക (കൂട്ടിച്ചേർക്കുന്നതിന് പകരം) | विद्यमानचिह्नानां स्थाने स्थाप्यन्ताम् (न तु योज्यन्ताम्) |
| `descTagsUpdated` | Updated tags for {count} accounts | {count} അക്കൗണ്ടുകളുടെ അടയാളങ്ങൾ പുതുക്കി | {count} विवरणानां चिह्नानि नवीकृतानि |
| `actionApplyTags` | Apply tags | പ്രയോഗിക്കുക | प्रयुज्यताम् |
| `titleExportSelectedCount` | Export selected ({count}) | കയറ്റുമതി ({count}) | निर्यापणम् ({count}) |
| `descExportPasswordHint` | Set a password to encrypt this backup file. | ഈ കരുതൽ ഫയൽ സംരക്ഷിക്കാൻ ഒരു രഹസ്യവാക്ക് സജ്ജമാക്കുക. | अस्य प्रतिलिपिसञ्चिकायाः गूढलेखनाय गुप्तशब्दः सज्जीक्रियताम्। |
| `labelPassword` | Password | രഹസ്യവാക്ക് | गुप्तशब्दः |
| `labelConfirmPassword` | Confirm password | രഹസ്യവാക്ക് സ്ഥിരീകരണം | गुप्तशब्दस्थिरीकरणम् |
| `errorPasswordTooShort` | Password must be at least 6 characters | രഹസ്യവാക്കിന് കുറഞ്ഞത് 6 അക്ഷരങ്ങൾ വേണം | गुप्तशब्दे न्यूनातिन्यूनं षड् अक्षराणि भवेयुः |
| `errorPasswordMismatch` | Passwords do not match | രഹസ്യവാക്കുകൾ പൊരുത്തപ്പെടുന്നില്ല | गुप्तशब्दौ न सङ्गच्छेते |
| `descExportedSelected` | Exported {count} selected accounts | തിരഞ്ഞെടുത്ത {count} അക്കൗണ്ടുകൾ കയറ്റുമതി ചെയ്തു | चितानि {count} विवरणानि निर्यापितानि |
| `errorExportSelectedFailed` | Failed to export selected accounts | തിരഞ്ഞെടുത്ത അക്കൗണ്ടുകൾ കയറ്റുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല | चितानि विवरणानि निर्यापयितुं न शक्तम् |
| `actionExport` | Export | കയറ്റുമതി ചെയ്യുക | निर्याप्यताम् |
| `titleDeleteAccounts` | Delete accounts | അക്കൗണ്ടുകൾ ഇല്ലാതാക്കൽ | विवरणलोपः |
| `descDeleteSelectedConfirm` | Are you sure you want to delete {count} accounts? This action cannot be undone. | {count} അക്കൗണ്ടുകൾ ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? ഇത് പിന്നീട് തിരുത്താനാവില്ല. | {count} विवरणानि लोप्तव्यानि इति निश्चयः वा? इदं कार्यं प्रतिवर्तयितुं न शक्यते। |
| `errorAuthFailedDeleteCanceled` | Authentication failed. Deletion canceled. | സ്ഥിരീകരണം പരാജയപ്പെട്ടു. ഇല്ലാതാക്കൽ റദ്ദാക്കി. | प्रमाणीकरणम् असफलम्। लोपः निरस्तः। |
| `descAccountsDeleted` | {count} accounts deleted | {count} അക്കൗണ്ടുകൾ ഇല്ലാതാക്കി | {count} विवरणानि लुप्तानि |
| `actionDeleteCount` | Delete ({count}) | ഇല്ലാതാക്കുക ({count}) | लुप्यताम् ({count}) |
| `emptyNoAccountsFound` | No accounts found | അക്കൗണ്ടുകളൊന്നും കണ്ടെത്തിയില്ല | न किमपि विवरणं प्राप्तम् |
| `emptyNoAccountsYet` | No accounts yet | ഇതുവരെ അക്കൗണ്ടുകളില്ല | अद्यापि विवरणानि न सन्ति |
| `emptyTryDifferentSearch` | Try a different search term | മറ്റൊരു വാക്ക് ഉപയോഗിച്ച് തിരയുക | अन्येन पदेन अन्विष्यताम् |
| `emptyAddFirstAccount` | Tap the + button to add your first account | ആദ്യ അക്കൗണ്ട് ചേർക്കാൻ + ബട്ടൺ അമർത്തുക | प्रथमविवरणं योजयितुं + गण्डः स्पृश्यताम् |
| `emptyLongPressTip` | Tip: Long press + button for more options | സൂചന: കൂടുതൽ ഓപ്ഷനുകൾക്ക് + ബട്ടൺ അമർത്തിപ്പിടിക്കുക | सूचना: अधिकविकल्पेभ्यः + गण्डः दीर्घं स्पृश्यताम् |
| `labelQrScanner` | QR scanner | QR സ്കാനർ | QR-अवलोकनम् |
| `descScanQrCode` | Scan QR code | QR കോഡ് സ്കാൻ ചെയ്യുക | QR-सङ्केतः अवलोक्यताम् |
| `labelManualEntry` | Manual entry | സ്വമേധയാ നൽകൽ | स्वहस्तप्रवेशः |
| `descEnterDetailsManually` | Enter details manually | വിവരങ്ങൾ സ്വയം നൽകുക | विवरणानि स्वयं दीयन्ताम् |
| `labelSearchAccounts` | Search accounts… | അക്കൗണ്ടുകൾ തിരയുക… | विवरणान्वेषणम्… |
| `titleTagCloud` | Tag cloud | അടയാള മേഘം | चिह्नमेघः |
| `descTagCloud` | Tap any tag to view matching accounts | ബന്ധപ്പെട്ട അക്കൗണ്ടുകൾ കാണാൻ ഏതെങ്കിലും അടയാളം അമർത്തുക | सम्बद्धविवरणानि द्रष्टुं किमपि चिह्नं स्पृश्यताम् |
| `actionManageTags` | Manage tags | അടയാളങ്ങൾ ക്രമീകരിക്കുക | चिह्नानि व्यवस्थाप्यन्ताम् |
| `labelSearchTags` | Search tags… | അടയാളങ്ങൾ തിരയുക… | चिह्नान्वेषणम्… |
| `descActiveFilter` | Active filter: {tags} | സജീവ അരിപ്പ്: {tags} | सक्रियपरिशोधनम्: {tags} |
| `actionClear` | Clear | നീക്കുക | अपनीयताम् |
| `emptyNoTagsYet` | No tags created yet | ഇതുവരെ അടയാളങ്ങളില്ല | अद्यापि चिह्नानि न सन्ति |
| `emptyNoTagsMatching` | No tags matching "{query}" | "{query}" എന്നതിന് അടയാളങ്ങളൊന്നുമില്ല | "{query}" इत्यनेन न किमपि चिह्नं मिलितम् |
| `emptyAddTagsHint` | Add tags when creating or editing an account | അക്കൗണ്ട് സൃഷ്ടിക്കുമ്പോഴോ തിരുത്തുമ്പോഴോ അടയാളങ്ങൾ ചേർക്കുക | विवरणस्य रचनाकाले सम्पादनकाले वा चिह्नानि योज्यन्ताम् |
| `emptyTryDifferentKeyword` | Try searching for a different keyword | മറ്റൊരു വാക്ക് ഉപയോഗിച്ച് തിരയുക | अन्येन शब्देन अन्विष्यताम् |
| `labelAllTags` | All tags | എല്ലാ അടയാളങ്ങളും | सर्वचिह्नानि |
| `labelClearCount` | Clear ({count}) | നീക്കുക ({count}) | अपनीयताम् ({count}) |
| `titleAppLockRequired` | App lock required | ആപ്പ് ലോക്ക് ആവശ്യമാണ് | अनुप्रयोगतालकम् आवश्यकम् |
| `descAppLockRequiredSecret` | To edit the secret key, please enable app lock from Security settings first. | രഹസ്യ കീ തിരുത്താൻ, ആദ്യം സുരക്ഷാ ക്രമീകരണങ്ങളിൽ ആപ്പ് ലോക്ക് പ്രവർത്തനക്ഷമമാക്കുക. | गुप्तकुञ्चिकायाः सम्पादनाय प्रथमं सुरक्षाविन्यासे अनुप्रयोगतालकं सक्रियीक्रियताम्। |
| `descAppLockRequiredAdvanced` | To edit advanced options, please enable app lock from Security settings first. | വിപുലമായ ഓപ്ഷനുകൾ തിരുത്താൻ, ആദ്യം സുരക്ഷാ ക്രമീകരണങ്ങളിൽ ആപ്പ് ലോക്ക് പ്രവർത്തനക്ഷമമാക്കുക. | उन्नतविकल्पानां सम्पादनाय प्रथमं सुरक्षाविन्यासे अनुप्रयोगतालकं सक्रियीक्रियताम्। |
| `descAppLockRequiredSave` | To save changes to sensitive fields (secret key or advanced options), please enable app lock from Security settings first. | സംവേദനക്ഷമമായ ഭാഗങ്ങളിലെ (രഹസ്യ കീ അല്ലെങ്കിൽ വിപുലമായ ഓപ്ഷനുകൾ) മാറ്റങ്ങൾ സൂക്ഷിക്കാൻ, ആദ്യം സുരക്ഷാ ക്രമീകരണങ്ങളിൽ ആപ്പ് ലോക്ക് പ്രവർത്തനക്ഷമമാക്കുക. | संवेदनशीलक्षेत्रेषु (गुप्तकुञ्चिकायाम् उन्नतविकल्पेषु वा) परिवर्तनानि रक्षितुं प्रथमं सुरक्षाविन्यासे अनुप्रयोगतालकं सक्रियीक्रियताम्। |
| `actionOpenSecurity` | Open security | സുരക്ഷ തുറക്കുക | सुरक्षा उद्घाट्यताम् |
| `descSecretUnlocked` | Secret key unlocked | രഹസ്യ കീ തുറന്നു | गुप्तकुञ्चिका उद्घाटिता |
| `descAdvancedUnlocked` | Advanced settings unlocked | വിപുലമായ ക്രമീകരണങ്ങൾ തുറന്നു | उन्नतविन्यासः उद्घाटितः |
| `descAccountUpdated` | Account updated successfully | അക്കൗണ്ട് വിജയകരമായി പുതുക്കി | विवरणं सफलतया नवीकृतम् |
| `descAccountAdded` | Account added successfully | അക്കൗണ്ട് വിജയകരമായി ചേർത്തു | विवरणं सफलतया योजितम् |
| `errorSaveAccountFailed` | Could not save the account. Please try again. | അക്കൗണ്ട് സൂക്ഷിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക. | विवरणं रक्षितुं न शक्तम्। पुनः प्रयत्यताम्। |
| `errorSecretRequired` | Secret key is required | രഹസ്യ കീ ആവശ്യമാണ് | गुप्तकुञ्चिका आवश्यकी |
| `errorSecretNotBase32` | Invalid secret key. Must be Base32 encoded | അസാധുവായ രഹസ്യ കീ. Base32 രൂപത്തിലായിരിക്കണം | अमान्या गुप्तकुञ्चिका। Base32-रूपेण भवेत् |
| `errorSecretTooShort` | Secret key is too short | രഹസ്യ കീ വളരെ ചെറുതാണ് | गुप्तकुञ्चिका अतिह्रस्वा |
| `titleEditAccount` | Edit account | അക്കൗണ്ട് തിരുത്തൽ | विवरणसम्पादनम् |
| `titleAddAccount` | Add account | അക്കൗണ്ട് ചേർക്കൽ | विवरणयोजनम् |
| `tooltipScanQr` | Scan QR code | QR കോഡ് സ്കാൻ ചെയ്യുക | QR-अवलोकनम् |
| `actionUpdateAccount` | Update account | അക്കൗണ്ട് പുതുക്കുക | विवरणं नवीक्रियताम् |
| `actionAddAccount` | Add account | അക്കൗണ്ട് ചേർക്കുക | विवरणं योज्यताम् |
| `errorQrInvalid` | This QR code is not a valid authenticator code. | ഈ QR കോഡ് സാധുവായ പ്രാമാണീകരണ കോഡ് അല്ല. | अयं QR-सङ्केतः मान्यः प्रमाणीकरणसङ्केतः न। |
| `errorQrNoSecret` | The secret key is missing from this QR code. | ഈ QR കോഡിൽ രഹസ്യ കീ ഇല്ല. | अस्मिन् QR-सङ्केते गुप्तकुञ्चिका नास्ति। |
| `errorAddAccountFailed` | Could not add the account. Please try again. | അക്കൗണ്ട് ചേർക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക. | विवरणं योजयितुं न शक्तम्। पुनः प्रयत्यताम्। |
| `descAccountAddedName` | Account added: {name} | അക്കൗണ്ട് ചേർത്തു: {name} | विवरणं योजितम्: {name} |
| `titleAddAccountManually` | Add account manually | സ്വമേധയാ ചേർക്കൽ | स्वहस्तयोजनम् |
| `labelAccountNameRequired` | Account name * | അക്കൗണ്ട് പേര് * | विवरणनाम * |
| `descAccountNameHint` | Enter account name | അക്കൗണ്ട് പേര് നൽകുക | विवरणनाम दीयताम् |
| `labelSecretKeyRequired` | Secret key * | രഹസ്യ കീ * | गुप्तकुञ्चिका * |
| `descSecretKeyHint` | Enter secret key | രഹസ്യ കീ നൽകുക | गुप्तकुञ्चिका दीयताम् |
| `labelIssuerOptional` | Issuer (optional) | നൽകുന്നയാൾ (ഐച്ഛികം) | प्रदाता (ऐच्छिकम्) |
| `descIssuerHint` | e.g., Google | ഉദാ. Google | यथा Google |
| `errorNameAndSecretRequired` | Account name and secret key are required | അക്കൗണ്ട് പേരും രഹസ്യ കീയും ആവശ്യമാണ് | विवरणनाम गुप्तकुञ्चिका च आवश्यके |
| `actionAdd` | Add | ചേർക്കുക | योज्यताम् |
| `titleScanQrCode` | Scan QR code | QR കോഡ് സ്കാൻ | QR-अवलोकनम् |
| `tooltipToggleFlash` | Toggle flash | ഫ്ലാഷ് മാറ്റുക | दीपः परिवर्त्यताम् |
| `tooltipSwitchCamera` | Switch camera | ക്യാമറ മാറ്റുക | छायाग्राहकं परिवर्त्यताम् |
| `descPositionQr` | Position QR code within frame | QR കോഡ് ചട്ടക്കൂടിനുള്ളിൽ വയ്ക്കുക | QR-सङ्केतः चतुरस्रान्तः स्थाप्यताम् |
| `actionEnterManually` | Enter manually | സ്വമേധയാ നൽകുക | स्वहस्तेन दीयताम् |
| `titleAccountInformation` | Account information | അക്കൗണ്ട് വിവരങ്ങൾ | विवरणसूचना |
| `labelAccountName` | Account name * | അക്കൗണ്ട് പേര് * | विवरणनाम * |
| `descAccountNameExample` | e.g., john@example.com | ഉദാ. john@example.com | यथा john@example.com |
| `errorAccountNameRequired` | Account name is required | അക്കൗണ്ട് പേര് ആവശ്യമാണ് | विवरणनाम आवश्यकम् |
| `labelIssuer` | Issuer (optional) | നൽകുന്നയാൾ (ഐച്ഛികം) | प्रदाता (ऐच्छिकम्) |
| `descIssuerExample` | e.g., Google, GitHub | ഉദാ. Google, GitHub | यथा Google, GitHub |
| `labelSecretKey` | Secret key * | രഹസ്യ കീ * | गुप्तकुञ्चिका * |
| `labelTapToUnlock` | Tap to unlock | തുറക്കാൻ അമർത്തുക | उद्घाटनाय स्पृश्यताम् |
| `labelEnableAppLock` | Enable app lock | ആപ്പ് ലോക്ക് ഓണാക്കുക | तालकं सक्रियीक्रियताम् |
| `descSecretKeyBase32` | Base32 encoded secret | Base32 രൂപത്തിലുള്ള രഹസ്യം | Base32-रूपं रहस्यम् |
| `titleAdvancedSettings` | Advanced settings | വിപുലമായ ക്രമീകരണങ്ങൾ | उन्नतविन्यासः |
| `tooltipUnlockToEdit` | Unlock to edit | തിരുത്താൻ തുറക്കുക | सम्पादनाय उद्घाट्यताम् |
| `tooltipEnableAppLockFirst` | Turn on app lock | ആപ്പ് ലോക്ക് ഓണാക്കുക | तालकं सक्रियीक्रियताम् |
| `labelDigits` | Digits | അക്കങ്ങൾ | अङ्काः |
| `labelPeriodSeconds` | Period (seconds) | കാലയളവ് (സെക്കൻഡ്) | कालावधिः (क्षणाः) |
| `labelAlgorithm` | Algorithm | അൽഗോരിതം | गणनविधिः |
| `labelMaskedValue` | {label}: {value} | {label}: {value} | {label}: {value} |
| `labelSecondsMasked` | {mask} seconds | {mask} സെക്കൻഡ് | {mask} क्षणाः |
| `descTapToUnlockSettings` | Tap to unlock and view settings | ക്രമീകരണങ്ങൾ കാണാൻ തുറക്കുക | विन्यासं द्रष्टुम् उद्घाट्यताम् |
| `descEnableAppLockToEdit` | Enable app lock to edit | തിരുത്താൻ ആപ്പ് ലോക്ക് ഓണാക്കുക | सम्पादनाय तालकं सक्रियीक्रियताम् |
| `titleBrowseTags` | Browse existing tags | നിലവിലെ അടയാളങ്ങൾ | विद्यमानचिह्नानि |
| `actionClearAll` | Clear all | എല്ലാം നീക്കുക | सर्वम् अपनीयताम् |
| `tooltipClose` | Close | അടയ്ക്കുക | पिधीयताम् |
| `labelSearchExistingTags` | Search tags… | അടയാളങ്ങൾ തിരയുക… | चिह्नान्वेषणम्… |
| `emptyNoExistingTags` | No existing tags found | അടയാളങ്ങളൊന്നുമില്ല | न किमपि चिह्नं प्राप्तम् |
| `emptyTypeNewTags` | Type new tags in the text field to assign them to this entry. | ഈ അക്കൗണ്ടിന് നൽകാൻ പുതിയ അടയാളങ്ങൾ ടെക്സ്റ്റ് ഫീൽഡിൽ ടൈപ്പ് ചെയ്യുക. | अस्मै विवरणाय नूतनानि चिह्नानि लेखक्षेत्रे लिख्यन्ताम्। |
| `emptyNoMatchingTags` | No matching tags | പൊരുത്തപ്പെടുന്ന അടയാളങ്ങളില്ല | अनुरूपचिह्नानि न सन्ति |
| `emptyNoTagsMatchQuery` | No existing tags match "{query}". | "{query}" എന്നതിന് പൊരുത്തപ്പെടുന്ന അടയാളങ്ങളില്ല. | "{query}" इत्यनेन अनुरूपं चिह्नं नास्ति। |
| `actionDone` | Done | പൂർത്തിയായി | समाप्तम् |
| `actionApplySelected` | Apply ({count}) | പ്രയോഗിക്കുക ({count}) | प्रयुज्यताम् ({count}) |
| `descTagsFieldHint` | Comma separated, e.g. Work, Crypto, VIP | കോമ കൊണ്ട് വേർതിരിക്കുക, ഉദാ. ജോലി, ക്രിപ്റ്റോ, VIP | अल्पविरामैः पृथक्, यथा कार्यम्, VIP |
| `labelTapToAdd` | Tap to add | ചേർക്കാൻ അമർത്തുക | योजनाय स्पृश्यताम् |
| `tooltipBrowseTags` | Browse existing tags | നിലവിലെ അടയാളങ്ങൾ | विद्यमानचिह्नानि |
| `labelPermCamera` | Camera | ക്യാമറ | छायाग्राहकम् |
| `descPermCamera` | Used to scan QR codes for adding accounts | അക്കൗണ്ടുകൾ ചേർക്കാൻ QR കോഡുകൾ സ്കാൻ ചെയ്യുന്നതിന് | विवरणयोजनाय QR-सङ्केतावलोकनार्थम् |
| `labelPermBiometric` | Biometric unlock | ബയോമെട്രിക് തുറക്കൽ | जैवमितिकोद्घाटनम् |
| `descPermBiometric` | Used for app lock authentication via fingerprint or device credentials | വിരലടയാളമോ ഉപകരണ ലോക്കോ ഉപയോഗിച്ച് ആപ്പ് ലോക്ക് തുറക്കുന്നതിന് | अङ्गुलिमुद्रया उपकरणतालकेन वा अनुप्रयोगतालकोद्घाटनाय |
| `labelPermVibration` | Vibration | കമ്പനം | कम्पनम् |
| `descPermVibration` | Used for haptic feedback during QR code scanning | QR കോഡ് സ്കാൻ ചെയ്യുമ്പോൾ സ്പർശ പ്രതികരണത്തിന് | QR-सङ्केतावलोकनकाले स्पर्शप्रतिक्रियार्थम् |
| `labelPermSecureStorage` | Secure storage | സുരക്ഷിത സംഭരണം | सुरक्षितसङ्ग्रहः |
| `descPermSecureStorage` | Uses Android Keystore to securely store encryption keys | എൻക്രിപ്ഷൻ കീകൾ സുരക്ഷിതമായി സൂക്ഷിക്കാൻ Android Keystore ഉപയോഗിക്കുന്നു | गूढलेखनकुञ्चिकाः सुरक्षितं रक्षितुम् Android Keystore प्रयुज्यते |
| `labelPermLocalDatabase` | Local database | പ്രാദേശിക ഡാറ്റാബേസ് | स्थानीयदत्तांशकोशः |
| `descPermLocalDatabase` | Stores encrypted account data locally on your device | എൻക്രിപ്റ്റ് ചെയ്ത അക്കൗണ്ട് വിവരങ്ങൾ നിങ്ങളുടെ ഉപകരണത്തിൽ മാത്രം സൂക്ഷിക്കുന്നു | गूढलेखितविवरणदत्तांशः भवतः उपकरणे एव सङ्गृह्यते |
| `descPermissionsIntro` | This app only requests permissions when needed and never collects data. | ആവശ്യമുള്ളപ്പോൾ മാത്രമേ ഈ ആപ്പ് അനുമതികൾ ചോദിക്കുന്നുള്ളൂ, ഒരു വിവരവും ശേഖരിക്കുന്നില്ല. | अयम् अनुप्रयोगः आवश्यकतायाम् एव अनुमतीः याचते, न कदापि दत्तांशं सञ्चिनोति। |
| `titleRuntimePermissions` | Runtime permissions | പ്രവർത്തന അനുമതികൾ | कार्यकालानुमतयः |
| `titleBuiltInCapabilities` | Built-in features | അന്തർനിർമ്മിത സവിശേഷതകൾ | अन्तर्निहितविशेषताः |
| `titlePrivacy` | Privacy | സ്വകാര്യത | गोपनीयता |
| `labelNoInternetAccess` | No internet access | ഇന്റർനെറ്റ് ഇല്ല | अन्तर्जालं नास्ति |
| `descNoInternetAccess` | This app works completely offline. Your data never leaves your device. | ഈ ആപ്പ് പൂർണ്ണമായും ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു. നിങ്ങളുടെ വിവരങ്ങൾ ഒരിക്കലും ഉപകരണം വിട്ടുപോകുന്നില്ല. | अयम् अनुप्रयोगः पूर्णतया अन्तर्जालं विना कार्यं करोति। भवतः दत्तांशः कदापि उपकरणात् बहिः न गच्छति। |
| `labelStatusGranted` | Granted | അനുവദിച്ചു | अनुमतम् |
| `labelStatusDenied` | Denied | നിരസിച്ചു | निषिद्धम् |
| `labelStatusNotGranted` | Not granted | അനുവദിച്ചിട്ടില്ല | न अनुमतम् |
| `labelStatusNotRequested` | Not requested | ചോദിച്ചിട്ടില്ല | न याचितम् |
| `labelBuiltIn` | Built-in | അന്തർനിർമ്മിതം | अन्तर्निहितम् |
| `errorCodeUnavailable` | Code unavailable for {name} | {name}-ന് കോഡ് ലഭ്യമല്ല | {name} इत्यस्य सङ्केतः न उपलभ्यते |
| `descCodeCopied` | Code copied for {name} | {name}-ന്റെ കോഡ് പകർത്തി | {name} इत्यस्य सङ्केतः प्रतिलिखितः |
