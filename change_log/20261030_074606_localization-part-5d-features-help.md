# Localization Part 5d — features and help screens

Implements plan: `plans/20261030_072311_localization-part-5d-features-help.md`
(Part 5d, the last part, of `plans/20261029_202317_localization-phase-5.md`)

With this part, Phase 5 (localization) is complete: no screen shows English literals under
Malayalam or Sanskrit any more.

## What changed

### Screens (all user-visible text now from ARB)
- `lib/screens/features_screen.dart` — the feature list `_categories` is now a function that
  takes `AppLocalizations`, so every category, feature, description and highlight chip is
  localized. The header uses the app name from `AppConfig` (`{appName}` placeholder).
- The 10 files in `lib/screens/help/` — every title, intro, section, bullet, question, answer and
  tip box comes from ARB. Screens that name the app read it from `AppConfig`.
- Menu paths in help text ("Settings → Backup & restore → …") are placeholders filled from the
  **same ARB keys as the real buttons** (`titleSettings`, `titleBackupRestore`,
  `labelCreateEncryptedBackup`, `titleSyncDevice`, `labelSendOverWifi`, `labelOpticalSend`, and
  others). A renamed button can no longer drift from its help text, in any language.
- Layout fix: the category heading on the Features screen and the section heading on the Help
  home screen are now wrapped in `Flexible`. Long headings overflowed on a 360-pixel-wide
  screen (in English too); they now wrap.

### ARB
- 267 new keys in `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (`descFeatures01–103`,
  `helpHome01–25`, `helpStart01–16`, `helpTime01–14`, `helpTags01–15`, `helpLock01–12`,
  `helpVault01–15`, `helpWifi01–15`, `helpOptical01–14`, `helpBackup01–14`, `helpFaq01–24`).
  Every key has an `@key` description saying which screen and what kind of text it is.
- Generated `lib/l10n/app_localizations*.dart` rebuilt with `flutter gen-l10n`.

### English text corrected before translating (owner decisions, 2026-10-30)
The old English help and features text said things the code does not do. Fixed:
1. "100+ built-in brands" → 10 brand icons.
2. HOTP: the app reads HOTP QR codes, but has no counter control yet, so help and features now
   say HOTP counter codes are **not supported yet** and suggest TOTP.
3. Optical speed "250–500 ms per frame" → 10, 12 or 15 frames per second.
4. Optical stream: no longer called "encrypted". Help now warns that the QR frames are not
   encrypted and the screen must be kept away from other people and cameras.
5. Wi-Fi sync: "pairing code" instead of "PIN"; old button names replaced by the current ones.
6. Backup: PBKDF2 with 300,000 iterations (not 100,000); the backup file is `.aes` (not
   `.json`); current button names.
7. Android Keystore: "hardware-backed on phones that support it" instead of always
   "hardware-backed".

### Tests
- New `test/screens/help_screens_l10n_test.dart` — the Features screen and all 10 help screens
  open in `en`, `ml` and `sa` on a 360-pixel-wide screen and are scrolled to the end with no
  overflow or other error (33 tests), plus a check that help menu paths contain the current
  button names.
- `test/l10n/translation_parity_test.dart` — allow-list now holds 4 feature chips that are only
  technical names and are the same in every language: `descFeatures06` (SHA-1/256/512),
  `descFeatures33` (AES-256-GCM), `descFeatures34` (Android Keystore), `descFeatures48`
  (FLAG_SECURE).

### Docs
- `CLAUDE.md`, `AGENTS.md` — the "migration in progress" note is replaced by "localization is
  complete".
- `docs/implementation_progress.md` — Phase 5d ticked.
- `docs/features.md` — HOTP marked as not fully supported (known bug), brand count is 10,
  optical speed and the "not encrypted" warning added.

## Checks

- `dart format` — no changes left.
- `flutter analyze` — no issues.
- `flutter test` — 321 tests pass.
- `flutter build apk --flavor dev --debug` — built. Gradle daemons stopped afterwards; one
  leftover daemon process was ended.

## Found, not fixed here (follow-ups)

- **Optical sync sends account secrets in plain QR frames.** The owner chose a separate plan to
  encrypt the stream. Until then the help text warns the user.
- **HOTP accounts show time-based codes.** The QR parser stores HOTP accounts, but the code
  generator and home screen treat them as TOTP. Needs its own plan (counter display and
  increment, or refuse HOTP at import).
- The 9 help screens each keep their own copy of `_Intro`, `_Section`, `_Bullet`, `_Footer`.
  Merging them into one shared widget file is a clean-up for later.
- While writing Sanskrit, the Hindi-marker gate flagged correct Sanskrit words that only contain
  a marker as letters (`सङ्ग्रहे` has "रहे", `ग्रहीतुं` has "रही", `शक्याः` has "क्या"). They were
  replaced by other correct words (`कोशे`, `सञ्चये`, `प्राप्तुं`, `शक्यन्ते`).

## Translations — needs native-reader review

All Malayalam and Sanskrit text below is a draft by the AI agent and **needs review by the
translation reviewer (the developer)**. Places I am least sure of:
- Sanskrit technical coinages: `गूढलेखनम्` (encryption), `प्रतिलिपिः` (backup),
  `प्रकाशीयवायुविच्छेदः` (optical air gap), `दूरमापनम्` (telemetry), `युग्मनसङ्केतः` (pairing code).
- Malayalam loan words kept in English form where people use them: എൻക്രിപ്റ്റ്, ക്ലിപ്പ്ബോർഡ്,
  സ്കാൻ, ബാക്കപ്പ് is written as കരുതൽ (as in 5c).
- Phone settings names (`Date & time`, `Set time automatically`) are kept in English in all
  languages, because they are the system's own labels, which may be in English on the phone.

| Key | English | Malayalam | Sanskrit |
|---|---|---|---|
| `descFeatures01` | Core 2FA & OTP tools | പ്രധാന 2FA, OTP ഉപകരണങ്ങൾ | मुख्यानि 2FA-OTP-साधनानि |
| `descFeatures02` | Standards-compliant code generation and scanning | മാനദണ്ഡങ്ങൾ പാലിക്കുന്ന കോഡ് സൃഷ്ടിയും സ്കാനിംഗും | मानकानुसारिणी सङ्केतरचना अवलोकनं च |
| `descFeatures03` | TOTP time-based codes | TOTP സമയാധിഷ്ഠിത കോഡുകൾ | TOTP कालाधारितसङ्केताः |
| `descFeatures04` | Generate secure time-based one-time passwords compliant with RFC 6238. Supports 30 or 60 second periods, 6 or 8 digits, and SHA-1, SHA-256 or SHA-512. | RFC 6238 പാലിക്കുന്ന സുരക്ഷിത സമയാധിഷ്ഠിത ഒറ്റത്തവണ പാസ്കോഡുകൾ സൃഷ്ടിക്കുന്നു. 30 അല്ലെങ്കിൽ 60 സെക്കൻഡ് കാലയളവ്, 6 അല്ലെങ്കിൽ 8 അക്കങ്ങൾ, SHA-1, SHA-256, SHA-512 എന്നിവ പിന്തുണയ്ക്കുന്നു. | RFC 6238 अनुसारं सुरक्षिताः कालाधारिताः एकवारिकसङ्केताः रच्यन्ते। 30 अथवा 60 क्षणानां कालावधिः, 6 अथवा 8 अङ्काः, SHA-1, SHA-256, SHA-512 च समर्थिताः। |
| `descFeatures05` | RFC 6238 standard | RFC 6238 മാനദണ്ഡം | RFC 6238 मानकम् |
| `descFeatures06` | SHA-1/256/512 | SHA-1/256/512 | SHA-1/256/512 |
| `descFeatures07` | 30 s or 60 s | 30 സെ. അല്ലെങ്കിൽ 60 സെ. | 30 अथवा 60 क्षणाः |
| `descFeatures08` | Live ring timer | തത്സമയ വലയ ടൈമർ | सजीवं वलयकालमापकम् |
| `descFeatures09` | HOTP counter codes | HOTP കൗണ്ടർ കോഡുകൾ | HOTP गणकसङ्केताः |
| `descFeatures10` | The app can read HOTP QR codes (RFC 4226), but it cannot show or advance HOTP counters yet. Use time-based (TOTP) codes where your service offers them. | ആപ്പിന് HOTP QR കോഡുകൾ (RFC 4226) വായിക്കാനാകും, പക്ഷേ HOTP കൗണ്ടറുകൾ കാണിക്കാനോ മുന്നോട്ട് നീക്കാനോ ഇപ്പോൾ കഴിയില്ല. സേവനം നൽകുന്നുണ്ടെങ്കിൽ സമയാധിഷ്ഠിത (TOTP) കോഡുകൾ ഉപയോഗിക്കുക. | अनुप्रयोगः HOTP-QR-सङ्केतान् (RFC 4226) पठितुं शक्नोति, किन्तु HOTP-गणकान् दर्शयितुं वर्धयितुं वा अधुना न शक्नोति। सेवा यदि ददाति तर्हि कालाधारिताः (TOTP) सङ्केताः प्रयुज्यन्ताम्। |
| `descFeatures11` | Reads HOTP QR codes | HOTP QR വായിക്കുന്നു | HOTP-QR पठति |
| `descFeatures12` | Counter: not yet | കൗണ്ടർ: ഇതുവരെ ഇല്ല | गणकः: अद्यापि न |
| `descFeatures13` | Prefer TOTP | TOTP ആണ് നല്ലത് | TOTP श्रेयः |
| `descFeatures14` | Instant QR code scanner | വേഗത്തിലുള്ള QR സ്കാനർ | शीघ्रं QR-अवलोकनम् |
| `descFeatures15` | Add accounts by pointing your camera at standard 2FA QR codes (otpauth://). Includes a flashlight toggle and instant validation. | സാധാരണ 2FA QR കോഡുകളിലേക്ക് (otpauth://) ക്യാമറ തിരിച്ച് അക്കൗണ്ടുകൾ ചേർക്കുക. ഫ്ലാഷ്‌ലൈറ്റും ഉടനടി പരിശോധനയും ഉണ്ട്. | मानक-2FA-QR-सङ्केतेषु (otpauth://) छायाग्राहकं स्थापयित्वा विवरणानि योज्यन्ताम्। दीपः तत्क्षणपरीक्षणं च अन्तर्भवतः। |
| `descFeatures16` | Fast detection | വേഗത്തിലുള്ള കണ്ടെത്തൽ | शीघ्रं ज्ञानम् |
| `descFeatures17` | Flashlight support | ഫ്ലാഷ്‌ലൈറ്റ് പിന്തുണ | दीपसमर्थनम् |
| `descFeatures18` | Safe input checks | സുരക്ഷിത പരിശോധന | सुरक्षितपरीक्षणम् |
| `descFeatures19` | Brand icons | ബ്രാൻഡ് ഐക്കണുകൾ | चिह्नचित्राणि |
| `descFeatures20` | Shows a brand logo for common services (Apple, AWS, Binance, Discord, GitHub, Google, Microsoft, Nintendo, Proton, Steam) and colorful initials for all others. | സാധാരണ സേവനങ്ങൾക്ക് (Apple, AWS, Binance, Discord, GitHub, Google, Microsoft, Nintendo, Proton, Steam) ബ്രാൻഡ് ലോഗോയും മറ്റുള്ളവയ്ക്ക് നിറമുള്ള ആദ്യാക്ഷരങ്ങളും കാണിക്കുന്നു. | प्रसिद्धसेवानां (Apple, AWS, Binance, Discord, GitHub, Google, Microsoft, Nintendo, Proton, Steam) चिह्नचित्रम्, अन्यासां वर्णमय-आद्याक्षराणि च दर्श्यन्ते। |
| `descFeatures21` | 10 built-in brands | 10 ബ്രാൻഡുകൾ | 10 अन्तर्निहितचिह्नानि |
| `descFeatures22` | Colorful initials | നിറമുള്ള ആദ്യാക്ഷരങ്ങൾ | वर्णमय-आद्याक्षराणि |
| `descFeatures23` | Automatic match | സ്വയം പൊരുത്തപ്പെടുത്തൽ | स्वयं मेलनम् |
| `descFeatures24` | Quick copy & countdown | വേഗത്തിലുള്ള പകർപ്പും സമയവും | शीघ्रप्रतिलेखनं कालगणना च |
| `descFeatures25` | Tap any code to copy it to the clipboard with haptic feedback. A circular timer shows how long the code stays valid. | ഏത് കോഡും അമർത്തിയാൽ സ്പർശ പ്രതികരണത്തോടെ ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തും. കോഡ് എത്ര സമയം സാധുവാണെന്ന് വൃത്താകൃതിയിലുള്ള ടൈമർ കാണിക്കുന്നു. | कमपि सङ्केतं स्पृष्ट्वा स्पर्शप्रतिक्रियया सह प्रतिलिपिफलके प्रतिलिख्यते। सङ्केतः कियत्कालं मान्यः इति वृत्ताकारः कालमापकः दर्शयति। |
| `descFeatures26` | One-tap copy | ഒറ്റ സ്പർശത്തിൽ പകർപ്പ് | एकस्पर्शप्रतिलेखनम् |
| `descFeatures27` | Haptic feedback | സ്പർശ പ്രതികരണം | स्पर्शप्रतिक्रिया |
| `descFeatures28` | Smooth progress ring | സുഗമ പുരോഗതി വലയം | सुगमं प्रगतिवलयम् |
| `descFeatures29` | Vault security & privacy | നിലവറ സുരക്ഷയും സ്വകാര്യതയും | कोशसुरक्षा गोपनीयता च |
| `descFeatures30` | Strong encryption, biometrics and zero tracking | ശക്തമായ എൻക്രിപ്ഷൻ, ബയോമെട്രിക്, ഒട്ടും ട്രാക്കിംഗ് ഇല്ല | दृढं गूढलेखनं, जैवमितिः, अनुसरणं सर्वथा नास्ति |
| `descFeatures31` | AES-256-GCM encryption | AES-256-GCM എൻക്രിപ്ഷൻ | AES-256-GCM गूढलेखनम् |
| `descFeatures32` | All account secrets are encrypted at rest with AES-256-GCM. The device key is kept in the Android Keystore (hardware-backed on phones that support it). | എല്ലാ അക്കൗണ്ട് രഹസ്യങ്ങളും AES-256-GCM ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത് സൂക്ഷിക്കുന്നു. ഉപകരണ കീ Android Keystore-ൽ സൂക്ഷിക്കുന്നു (പിന്തുണയ്ക്കുന്ന ഫോണുകളിൽ ഹാർഡ്‌വെയർ സംരക്ഷണത്തോടെ). | सर्वाणि विवरणरहस्यानि AES-256-GCM-द्वारा गूढलेखितानि रक्ष्यन्ते। उपकरणकुञ्चिका Android Keystore-मध्ये रक्ष्यते (समर्थेषु दूरभाषेषु यन्त्रांशरक्षया)। |
| `descFeatures33` | AES-256-GCM | AES-256-GCM | AES-256-GCM |
| `descFeatures34` | Android Keystore | Android Keystore | Android Keystore |
| `descFeatures35` | No plain text at rest | സംഭരണത്തിൽ തുറന്ന രഹസ്യമില്ല | कोशे अनावृतं रहस्यं नास्ति |
| `descFeatures36` | Biometric & screen app lock | ബയോമെട്രിക്, സ്ക്രീൻ ആപ്പ് ലോക്ക് | जैवमितिः पटलतालकं च |
| `descFeatures37` | Lock the app behind your fingerprint, face unlock, your phone screen lock, or an App PIN. Keeps your codes safe from people who pick up your phone. | വിരലടയാളം, മുഖം, ഫോൺ സ്ക്രീൻ ലോക്ക്, അല്ലെങ്കിൽ ആപ്പ് PIN ഉപയോഗിച്ച് ആപ്പ് പൂട്ടുക. നിങ്ങളുടെ ഫോൺ എടുക്കുന്നവരിൽ നിന്ന് കോഡുകൾ സുരക്ഷിതമായിരിക്കും. | अङ्गुलिमुद्रया, मुखेन, दूरभाषपटलतालकेन, अनुप्रयोग-PIN-द्वारा वा अनुप्रयोगः ताल्यताम्। भवतः दूरभाषं गृह्णद्भ्यः सङ्केताः सुरक्षिताः तिष्ठन्ति। |
| `descFeatures38` | Fingerprint / face | വിരലടയാളം / മുഖം | अङ्गुलिमुद्रा / मुखम् |
| `descFeatures39` | Phone lock fallback | ഫോൺ ലോക്ക് പകരം | दूरभाषतालकविकल्पः |
| `descFeatures40` | Fast unlock | വേഗത്തിൽ തുറക്കൽ | शीघ्रोद्घाटनम् |
| `descFeatures41` | Automatic lock | സ്വയം ലോക്ക് | स्वतालनम् |
| `descFeatures42` | Locks the app and clears decrypted codes from memory when you switch apps, minimize the app, or let the phone sleep. | മറ്റ് ആപ്പിലേക്ക് മാറുമ്പോഴോ ആപ്പ് ചെറുതാക്കുമ്പോഴോ ഫോൺ ഉറങ്ങുമ്പോഴോ ആപ്പ് പൂട്ടുകയും തുറന്ന കോഡുകൾ മെമ്മറിയിൽ നിന്ന് നീക്കുകയും ചെയ്യുന്നു. | अन्यानुप्रयोगं प्रति गमने, लघूकरणे, दूरभाषस्य निद्रायां वा अनुप्रयोगः ताल्यते, विगूढसङ्केताः स्मृतेः अपनीयन्ते च। |
| `descFeatures43` | Background auto-lock | പശ്ചാത്തല ലോക്ക് | पृष्ठभूमितालनम् |
| `descFeatures44` | Memory cleanup | മെമ്മറി വൃത്തിയാക്കൽ | स्मृतिशोधनम् |
| `descFeatures45` | Configurable timeout | മാറ്റാവുന്ന സമയപരിധി | परिवर्तनीया कालसीमा |
| `descFeatures46` | Screenshot guard (FLAG_SECURE) | സ്ക്രീൻഷോട്ട് സംരക്ഷണം (FLAG_SECURE) | पटलचित्ररक्षा (FLAG_SECURE) |
| `descFeatures47` | Blocks screenshots, screen recording and recent-apps thumbnails, so your codes cannot be captured from the screen. | സ്ക്രീൻഷോട്ടുകൾ, സ്ക്രീൻ റെക്കോർഡിംഗ്, സമീപകാല ആപ്പ് ചിത്രങ്ങൾ എന്നിവ തടയുന്നു; അതിനാൽ സ്ക്രീനിൽ നിന്ന് കോഡുകൾ പകർത്താനാവില്ല. | पटलचित्राणि, पटलध्वन्यालेखनं, सद्यःप्रयुक्तानुप्रयोगचित्राणि च निरुध्यन्ते; अतः पटलात् सङ्केताः प्राप्तुं न शक्यन्ते। |
| `descFeatures48` | FLAG_SECURE | FLAG_SECURE | FLAG_SECURE |
| `descFeatures49` | No recents preview | സമീപകാല കാഴ്ചയില്ല | सद्यःदृश्यं नास्ति |
| `descFeatures50` | No screen capture | സ്ക്രീൻ പകർപ്പില്ല | पटलग्रहणं नास्ति |
| `descFeatures51` | Offline & zero telemetry | ഓഫ്‌ലൈൻ, ടെലിമെട്രി ഇല്ല | अन्तर्जालरहितम्, दूरमापनं नास्ति |
| `descFeatures52` | Works fully on your device: no internet backend, cloud login, analytics, crash reporting or tracking. Wi-Fi sync uses only your local network. | പൂർണ്ണമായും ഉപകരണത്തിൽ പ്രവർത്തിക്കുന്നു: ഇന്റർനെറ്റ് സെർവർ, ക്ലൗഡ് ലോഗിൻ, അനലിറ്റിക്സ്, ക്രാഷ് റിപ്പോർട്ട്, ട്രാക്കിംഗ് എന്നിവ ഇല്ല. Wi-Fi സമന്വയം പ്രാദേശിക നെറ്റ്‌വർക്ക് മാത്രം ഉപയോഗിക്കുന്നു. | पूर्णतया उपकरणे एव कार्यं करोति: अन्तर्जालसेवकः, मेघप्रवेशः, विश्लेषणं, दोषप्रतिवेदनम्, अनुसरणं च न सन्ति। Wi-Fi-समन्वयः केवलं स्थानीयजालं प्रयुङ्क्ते। |
| `descFeatures53` | Fully offline | പൂർണ്ണമായും ഓഫ്‌ലൈൻ | पूर्णतया अन्तर्जालरहितम् |
| `descFeatures54` | No analytics | അനലിറ്റിക്സ് ഇല്ല | विश्लेषणं नास्ति |
| `descFeatures55` | No cloud accounts | ക്ലൗഡ് അക്കൗണ്ട് ഇല്ല | मेघविवरणं नास्ति |
| `descFeatures56` | No data leaves | വിവരം പുറത്തുപോകില്ല | दत्तांशः बहिः न गच्छति |
| `descFeatures57` | Organization & productivity | ക്രമീകരണവും ഉൽപ്പാദനക്ഷമതയും | व्यवस्था कार्यक्षमता च |
| `descFeatures58` | Group, search and manage your accounts | അക്കൗണ്ടുകൾ തരംതിരിക്കുക, തിരയുക, നിയന്ത്രിക്കുക | विवरणानि वर्गीक्रियन्ताम्, अन्विष्यन्ताम्, व्यवस्थाप्यन्ताम् |
| `descFeatures59` | Multi-tag labels | ഒന്നിലധികം അടയാളങ്ങൾ | बहुचिह्नव्यवस्था |
| `descFeatures60` | Give any account several tags (for example Work, Personal, Finance). Filter the account list by tag with one tap on the filter bar. | ഏത് അക്കൗണ്ടിനും നിരവധി അടയാളങ്ങൾ നൽകാം (ഉദാ. ജോലി, വ്യക്തിപരം, സാമ്പത്തികം). ഫിൽട്ടർ ബാറിൽ ഒറ്റ സ്പർശത്തിൽ അടയാളം അനുസരിച്ച് അക്കൗണ്ടുകൾ അരിച്ചെടുക്കാം. | कस्मैचित् अपि विवरणाय बहूनि चिह्नानि दीयन्ताम् (यथा कार्यम्, व्यक्तिगतम्, वित्तम्)। परिशोधनपट्टिकायाम् एकस्पर्शेन चिह्नानुसारं विवरणसूची परिशोध्यताम्। |
| `descFeatures61` | Many tags per account | ഒരു അക്കൗണ്ടിന് പല അടയാളം | विवरणे बहूनि चिह्नानि |
| `descFeatures62` | Tag chips | അടയാള ചിപ്പുകൾ | चिह्नपट्टिकाः |
| `descFeatures63` | One-tap filtering | ഒറ്റ സ്പർശ അരിപ്പ് | एकस्पर्शपरिशोधनम् |
| `descFeatures64` | Tag cloud | അടയാള മേഘം | चिह्नमेघः |
| `descFeatures65` | A tag cloud shows all your tags and how many accounts use each. Tap a tag to show only its accounts. | എല്ലാ അടയാളങ്ങളും ഓരോന്നിനും എത്ര അക്കൗണ്ടുകൾ ഉണ്ടെന്നും അടയാള മേഘം കാണിക്കുന്നു. ഒരു അടയാളം അമർത്തിയാൽ അതിന്റെ അക്കൗണ്ടുകൾ മാത്രം കാണാം. | चिह्नमेघः सर्वाणि चिह्नानि, प्रत्येकेन कति विवरणानि सम्बद्धानि इति च दर्शयति। चिह्नं स्पृष्ट्वा तस्य विवरणानि एव दृश्यन्ते। |
| `descFeatures66` | Visual tag view | ദൃശ്യ അടയാള കാഴ്ച | दृश्यचिह्नदर्शनम् |
| `descFeatures67` | Account counts | അക്കൗണ്ട് എണ്ണം | विवरणसङ्ख्या |
| `descFeatures68` | Fast navigation | വേഗത്തിലുള്ള നീക്കം | शीघ्रसञ्चारः |
| `descFeatures69` | Live search | തത്സമയ തിരയൽ | सजीवान्वेषणम् |
| `descFeatures70` | Find any account by typing its name, user name, service or tag; results update as you type. | പേര്, ഉപയോക്തൃനാമം, സേവനം അല്ലെങ്കിൽ അടയാളം ടൈപ്പ് ചെയ്ത് ഏത് അക്കൗണ്ടും കണ്ടെത്തുക; ടൈപ്പ് ചെയ്യുമ്പോൾ ഫലങ്ങൾ മാറും. | नाम, उपयोक्तृनाम, सेवा, चिह्नं वा लिखित्वा कमपि विवरणं प्राप्यताम्; लेखनसमये फलानि परिवर्तन्ते। |
| `descFeatures71` | Real-time search | തത്സമയ തിരയൽ | तत्कालान्वेषणम् |
| `descFeatures72` | Names & tags | പേരുകളും അടയാളങ്ങളും | नामानि चिह्नानि च |
| `descFeatures73` | Instant results | ഉടനടി ഫലം | तत्क्षणफलम् |
| `descFeatures74` | Ordering & editing | ക്രമപ്പെടുത്തലും തിരുത്തലും | क्रमीकरणं सम्पादनं च |
| `descFeatures75` | Put your accounts in the order you like, and change account names, services or code settings when needed. | അക്കൗണ്ടുകൾ ഇഷ്ടമുള്ള ക്രമത്തിൽ വയ്ക്കുക; ആവശ്യമെങ്കിൽ പേര്, സേവനം, കോഡ് ക്രമീകരണങ്ങൾ എന്നിവ മാറ്റുക. | विवरणानि इष्टक्रमेण स्थाप्यन्ताम्; आवश्यकतायां नाम, सेवा, सङ्केतविन्यासः च परिवर्त्यन्ताम्। |
| `descFeatures76` | Drag to reorder | വലിച്ച് ക്രമം മാറ്റുക | कर्षणेन क्रमपरिवर्तनम् |
| `descFeatures77` | Edit details | വിവരങ്ങൾ തിരുത്തുക | विवरणसम्पादनम् |
| `descFeatures78` | Batch actions | കൂട്ട പ്രവർത്തനങ്ങൾ | समूहकार्याणि |
| `descFeatures79` | Sync, air-gap & backups | സമന്വയം, എയർ-ഗ്യാപ്പ്, കരുതൽ | समन्वयः, वायुविच्छेदः, प्रतिलिपयः च |
| `descFeatures80` | Move accounts safely and export encrypted backups | അക്കൗണ്ടുകൾ സുരക്ഷിതമായി മാറ്റുക, എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ കയറ്റുമതി ചെയ്യുക | विवरणानि सुरक्षितं स्थानान्तर्यन्ताम्, गूढलेखिताः प्रतिलिपयः निर्याप्यन्ताम् |
| `descFeatures81` | Wi-Fi sync | Wi-Fi സമന്വയം | Wi-Fi-समन्वयः |
| `descFeatures82` | Move accounts between two devices on your local Wi-Fi. A pairing code shown as a QR code protects the transfer; the data is encrypted with a key made from that code. No internet is used. | പ്രാദേശിക Wi-Fi-ലെ രണ്ട് ഉപകരണങ്ങൾക്കിടയിൽ അക്കൗണ്ടുകൾ മാറ്റുക. QR ആയി കാണിക്കുന്ന ജോടിയാക്കൽ കോഡ് കൈമാറ്റം സംരക്ഷിക്കുന്നു; ആ കോഡിൽ നിന്നുള്ള കീ ഉപയോഗിച്ച് വിവരങ്ങൾ എൻക്രിപ്റ്റ് ചെയ്യുന്നു. ഇന്റർനെറ്റ് ഉപയോഗിക്കുന്നില്ല. | स्थानीय-Wi-Fi-जाले द्वयोः उपकरणयोः मध्ये विवरणानि स्थानान्तर्यन्ताम्। QR-रूपेण दर्शितः युग्मनसङ्केतः प्रेषणं रक्षति; तस्मात् सङ्केतात् निर्मितया कुञ्चिकया दत्तांशः गूढलेखितः भवति। अन्तर्जालं न प्रयुज्यते। |
| `descFeatures83` | Local Wi-Fi only | പ്രാദേശിക Wi-Fi മാത്രം | केवलं स्थानीय-Wi-Fi |
| `descFeatures84` | Encrypted transfer | എൻക്രിപ്റ്റ് ചെയ്ത കൈമാറ്റം | गूढलेखितं प्रेषणम् |
| `descFeatures85` | No cloud | ക്ലൗഡ് ഇല്ല | मेघः नास्ति |
| `descFeatures86` | Optical air-gap sync | ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് | प्रकाशीयवायुविच्छेदः |
| `descFeatures87` | Move accounts to an offline device with an animated series of QR codes, without Wi-Fi or Bluetooth. The QR codes carry your secrets, so keep the screen private. | Wi-Fi-ഓ ബ്ലൂടൂത്തോ ഇല്ലാതെ ചലിക്കുന്ന QR കോഡുകൾ വഴി ഓഫ്‌ലൈൻ ഉപകരണത്തിലേക്ക് അക്കൗണ്ടുകൾ മാറ്റുക. QR കോഡുകളിൽ നിങ്ങളുടെ രഹസ്യങ്ങളുണ്ട്; അതിനാൽ സ്ക്രീൻ മറ്റുള്ളവർ കാണാതെ സൂക്ഷിക്കുക. | Wi-Fi, नीलदन्तं (Bluetooth) वा विना चलत्-QR-सङ्केतश्रेण्या अन्तर्जालरहितम् उपकरणं प्रति विवरणानि स्थानान्तर्यन्ताम्। QR-सङ्केतेषु भवतः रहस्यानि सन्ति; अतः पटलः गोपनीयः रक्ष्यताम्। |
| `descFeatures88` | No network | നെറ്റ്‌വർക്ക് ഇല്ല | जालं नास्ति |
| `descFeatures89` | Animated QR stream | ചലിക്കുന്ന QR | चलत्-QR-प्रवाहः |
| `descFeatures90` | Keep screen private | സ്ക്രീൻ സ്വകാര്യമാക്കുക | पटलः गोपनीयः |
| `descFeatures91` | Encrypted backups | എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ | गूढलेखिताः प्रतिलिपयः |
| `descFeatures92` | Export all your accounts to an encrypted backup file protected by your own password (AES-256 with a PBKDF2 key). | എല്ലാ അക്കൗണ്ടുകളും നിങ്ങളുടെ രഹസ്യവാക്ക് സംരക്ഷിക്കുന്ന എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഫയലിലേക്ക് കയറ്റുമതി ചെയ്യുക (PBKDF2 കീ ഉള്ള AES-256). | सर्वाणि विवरणानि भवतः गुप्तशब्देन रक्षितायां गूढलेखितप्रतिलिपिसञ्चिकायां निर्याप्यन्ताम् (PBKDF2-कुञ्चिकया AES-256)। |
| `descFeatures93` | AES-256 encrypted | AES-256 എൻക്രിപ്ഷൻ | AES-256 गूढलेखितम् |
| `descFeatures94` | Password protected | രഹസ്യവാക്ക് സംരക്ഷണം | गुप्तशब्दरक्षितम् |
| `descFeatures95` | Portable file | കൊണ്ടുപോകാവുന്ന ഫയൽ | वहनीया सञ्चिका |
| `descFeatures96` | Safe import | സുരക്ഷിത ഇറക്കുമതി | सुरक्षितम् आनयनम् |
| `descFeatures97` | Import backups or receive sync data safely. Existing accounts are kept and new ones are added; nothing is overwritten. | കരുതലുകൾ ഇറക്കുമതി ചെയ്യുകയോ സമന്വയ വിവരങ്ങൾ സ്വീകരിക്കുകയോ സുരക്ഷിതമായി ചെയ്യാം. നിലവിലെ അക്കൗണ്ടുകൾ നിലനിർത്തി പുതിയവ ചേർക്കുന്നു; ഒന്നും മാറ്റിയെഴുതില്ല. | प्रतिलिपीनाम् आनयनं समन्वयदत्तांशस्वीकारः च सुरक्षितौ। विद्यमानविवरणानि रक्ष्यन्ते, नूतनानि योज्यन्ते; किमपि न परिवर्त्यते। |
| `descFeatures98` | Add-only merge | ചേർക്കൽ മാത്രം | केवलं योजनम् |
| `descFeatures99` | Duplicate protection | ഇരട്ടിപ്പ് സംരക്ഷണം | द्विरुक्तिरक्षा |
| `descFeatures100` | Import summary | ഇറക്കുമതി സംഗ്രഹം | आनयनसारः |
| `descFeatures101` | Features | സവിശേഷതകൾ | विशेषताः |
| `descFeatures102` | {appName} features | {appName} സവിശേഷതകൾ | {appName} विशेषताः |
| `descFeatures103` | Explore every security safeguard and code tool built into the app. | ആപ്പിലെ എല്ലാ സുരക്ഷാ സംവിധാനങ്ങളും കോഡ് ഉപകരണങ്ങളും പരിചയപ്പെടുക. | अनुप्रयोगे अन्तर्निहिताः सर्वाः सुरक्षाव्यवस्थाः सङ्केतसाधनानि च परिचीयन्ताम्। |
| `helpHome01` | Help center | സഹായ കേന്ദ്രം | साहाय्यकेन्द्रम् |
| `helpHome02` | Authentication & setup | പ്രാമാണീകരണവും സജ്ജീകരണവും | प्रमाणीकरणं सज्जीकरणं च |
| `helpHome03` | Getting started & adding accounts | തുടക്കവും അക്കൗണ്ട് ചേർക്കലും | आरम्भः विवरणयोजनं च |
| `helpHome04` | How to scan QR codes, add secret keys by hand, and use your 2FA codes. | QR കോഡുകൾ സ്കാൻ ചെയ്യുന്നതും രഹസ്യ കീകൾ സ്വയം ചേർക്കുന്നതും 2FA കോഡുകൾ ഉപയോഗിക്കുന്നതും എങ്ങനെ. | QR-सङ्केतावलोकनं, गुप्तकुञ्चिकानां स्वहस्तयोजनं, 2FA-सङ्केतप्रयोगः च कथम्। |
| `helpHome05` | Time sync & code drift | സമയ ക്രമീകരണവും കോഡ് വ്യതിയാനവും | कालसमन्वयः सङ्केतविचलनं च |
| `helpHome06` | Fixing rejected codes, phone clock offsets, and HOTP counter codes. | നിരസിക്കപ്പെട്ട കോഡുകൾ, ഫോൺ ഘടികാര വ്യതിയാനം, HOTP കൗണ്ടർ കോഡുകൾ എന്നിവ പരിഹരിക്കൽ. | निराकृतसङ्केताः, दूरभाषघटिकाविचलनं, HOTP-गणकसङ्केताः च। |
| `helpHome07` | Tags & account organization | അടയാളങ്ങളും അക്കൗണ്ട് ക്രമീകരണവും | चिह्नानि विवरणव्यवस्था च |
| `helpHome08` | Adding tags, filtering accounts, the tag cloud, and managing tags. | അടയാളങ്ങൾ ചേർക്കൽ, അക്കൗണ്ടുകൾ അരിച്ചെടുക്കൽ, അടയാള മേഘം, അടയാള നിർവഹണം. | चिह्नयोजनं, विवरणपरिशोधनं, चिह्नमेघः, चिह्नप्रबन्धनं च। |
| `helpHome09` | Security & vault protection | സുരക്ഷയും നിലവറ സംരക്ഷണവും | सुरक्षा कोशरक्षा च |
| `helpHome10` | Biometric & app lock | ബയോമെട്രിക്, ആപ്പ് ലോക്ക് | जैवमितिः अनुप्रयोगतालकं च |
| `helpHome11` | Fingerprint and face unlock, phone screen lock fallback, and auto-lock rules. | വിരലടയാളം, മുഖം, ഫോൺ സ്ക്രീൻ ലോക്ക്, സ്വയം ലോക്ക് നിയമങ്ങൾ. | अङ्गुलिमुद्रा, मुखोद्घाटनं, दूरभाषपटलतालकविकल्पः, स्वतालननियमाः च। |
| `helpHome12` | Vault & screenshot guard | നിലവറയും സ്ക്രീൻഷോട്ട് സംരക്ഷണവും | कोशः पटलचित्ररक्षा च |
| `helpHome13` | Android Keystore key storage, FLAG_SECURE screen protection, and offline privacy. | Android Keystore കീ സംഭരണം, FLAG_SECURE സ്ക്രീൻ സംരക്ഷണം, ഓഫ്‌ലൈൻ സ്വകാര്യത. | Android Keystore कुञ्चिकासङ्ग्रहः, FLAG_SECURE पटलरक्षा, अन्तर्जालरहिता गोपनीयता च। |
| `helpHome14` | Sync & backups | സമന്വയവും കരുതലും | समन्वयः प्रतिलिपयः च |
| `helpHome15` | Wi-Fi sync | Wi-Fi സമന്വയം | Wi-Fi-समन्वयः |
| `helpHome16` | Direct device-to-device transfer over local Wi-Fi, encrypted with a key from the pairing code. | ജോടിയാക്കൽ കോഡിൽ നിന്നുള്ള കീ ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത്, പ്രാദേശിക Wi-Fi വഴി നേരിട്ടുള്ള ഉപകരണ കൈമാറ്റം. | युग्मनसङ्केतात् निर्मितया कुञ्चिकया गूढलेखितं, स्थानीय-Wi-Fi-द्वारेण साक्षात् उपकरणप्रेषणम्। |
| `helpHome17` | Optical air-gap transfer | ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് കൈമാറ്റം | प्रकाशीयवायुविच्छेदप्रेषणम् |
| `helpHome18` | Move accounts to an offline device with animated QR codes. | ചലിക്കുന്ന QR കോഡുകൾ വഴി ഓഫ്‌ലൈൻ ഉപകരണത്തിലേക്ക് അക്കൗണ്ടുകൾ മാറ്റുക. | चलत्-QR-सङ्केतैः अन्तर्जालरहितम् उपकरणं प्रति विवरणानि स्थानान्तर्यन्ताम्। |
| `helpHome19` | Encrypted backup & restore | എൻക്രിപ്റ്റ് ചെയ്ത കരുതലും പുനഃസ്ഥാപനവും | गूढलेखितप्रतिलिपिः पुनःस्थापनं च |
| `helpHome20` | Making password-protected backup files and restoring accounts on a new phone. | രഹസ്യവാക്ക് സംരക്ഷിത കരുതൽ ഫയലുകൾ ഉണ്ടാക്കലും പുതിയ ഫോണിൽ അക്കൗണ്ടുകൾ പുനഃസ്ഥാപിക്കലും. | गुप्तशब्दरक्षितप्रतिलिपिसञ्चिकारचना, नूतने दूरभाषे विवरणपुनःस्थापनं च। |
| `helpHome21` | Frequently asked questions | പതിവ് ചോദ്യങ്ങൾ | प्रायः पृष्टाः प्रश्नाः |
| `helpHome22` | FAQs & troubleshooting | ചോദ്യങ്ങളും പ്രശ്നപരിഹാരവും | प्रश्नाः समस्यापरिहारः च |
| `helpHome23` | Short answers about codes, backups, permissions and moving to a new phone. | കോഡുകൾ, കരുതൽ, അനുമതികൾ, പുതിയ ഫോണിലേക്ക് മാറൽ എന്നിവയെക്കുറിച്ചുള്ള ലഘു ഉത്തരങ്ങൾ. | सङ्केताः, प्रतिलिपयः, अनुमतयः, नूतनदूरभाषं प्रति स्थानान्तरणं च इति विषये लघूत्तराणि। |
| `helpHome24` | Help center & guides | സഹായ കേന്ദ്രവും മാർഗ്ഗനിർദ്ദേശങ്ങളും | साहाय्यकेन्द्रं मार्गदर्शिकाः च |
| `helpHome25` | Guides and answers for every feature of {appName}. | {appName}-ന്റെ എല്ലാ സവിശേഷതകൾക്കുമുള്ള മാർഗ്ഗനിർദ്ദേശങ്ങളും ഉത്തരങ്ങളും. | {appName} इत्यस्य सर्वविशेषताणां कृते मार्गदर्शिकाः उत्तराणि च। |
| `helpStart01` | Getting started | തുടക്കം | आरम्भः |
| `helpStart02` | {appName} makes two-factor (2FA) codes that protect your online accounts. All codes are made on your device without an internet connection. | ഓൺലൈൻ അക്കൗണ്ടുകൾ സംരക്ഷിക്കുന്ന ടു-ഫാക്ടർ (2FA) കോഡുകൾ {appName} സൃഷ്ടിക്കുന്നു. എല്ലാ കോഡുകളും ഇന്റർനെറ്റ് ഇല്ലാതെ നിങ്ങളുടെ ഉപകരണത്തിൽ തന്നെ ഉണ്ടാക്കുന്നു. | {appName} भवतः अन्तर्जालविवरणानि रक्षन्तः द्विस्तरीयाः (2FA) सङ्केताः रचयति। सर्वे सङ्केताः अन्तर्जालं विना भवतः उपकरणे एव रच्यन्ते। |
| `helpStart03` | Adding an account with a QR code | QR കോഡ് വഴി അക്കൗണ്ട് ചേർക്കൽ | QR-सङ्केतेन विवरणयोजनम् |
| `helpStart04` | On the service (for example Google, GitHub, Amazon), open its security or 2FA settings and choose to set up an authenticator app. | സേവനത്തിൽ (ഉദാ. Google, GitHub, Amazon) സുരക്ഷ അല്ലെങ്കിൽ 2FA ക്രമീകരണങ്ങൾ തുറന്ന് ഓതന്റിക്കേറ്റർ ആപ്പ് സജ്ജമാക്കാൻ തിരഞ്ഞെടുക്കുക. | सेवायां (यथा Google, GitHub, Amazon) सुरक्षा-2FA-विन्यासम् उद्घाट्य प्रमाणीकरणानुप्रयोगस्य सज्जीकरणं चीयताम्। |
| `helpStart05` | In {appName}, tap the “+” button on the home screen and choose “{qrScanner}”. | {appName}-ൽ ഹോം സ്ക്രീനിലെ “+” ബട്ടൺ അമർത്തി “{qrScanner}” തിരഞ്ഞെടുക്കുക. | {appName} इत्यस्मिन् मुख्यपटले “+” गण्डं स्पृष्ट्वा “{qrScanner}” चीयताम्। |
| `helpStart06` | Point the camera at the QR code on your computer or other screen. The account is checked and added right away. | കമ്പ്യൂട്ടറിലോ മറ്റ് സ്ക്രീനിലോ ഉള്ള QR കോഡിലേക്ക് ക്യാമറ തിരിക്കുക. അക്കൗണ്ട് ഉടൻ പരിശോധിച്ച് ചേർക്കും. | सङ्गणके अन्यपटले वा स्थिते QR-सङ्केते छायाग्राहकं स्थाप्यताम्। विवरणं तत्क्षणं परीक्ष्य योज्यते। |
| `helpStart07` | Adding an account by hand | അക്കൗണ്ട് സ്വയം ചേർക്കൽ | स्वहस्तेन विवरणयोजनम् |
| `helpStart08` | If you cannot scan a QR code, choose “{manualEntry}” from the add menu. | QR കോഡ് സ്കാൻ ചെയ്യാനാകില്ലെങ്കിൽ, ചേർക്കൽ മെനുവിൽ നിന്ന് “{manualEntry}” തിരഞ്ഞെടുക്കുക. | QR-सङ्केतः अवलोकयितुं न शक्यते चेत्, योजनसूच्याः “{manualEntry}” चीयताम्। |
| `helpStart09` | Enter the account name (for example your email or user name) and the issuer (for example GitHub, Google). | അക്കൗണ്ട് പേരും (ഉദാ. ഇമെയിൽ അല്ലെങ്കിൽ ഉപയോക്തൃനാമം) നൽകുന്നയാളും (ഉദാ. GitHub, Google) നൽകുക. | विवरणनाम (यथा विद्युत्पत्रम् उपयोक्तृनाम वा) प्रदाता (यथा GitHub, Google) च दीयताम्। |
| `helpStart10` | Paste the secret key (Base32) that the service gives you. | സേവനം നൽകുന്ന രഹസ്യ കീ (Base32) ഒട്ടിക്കുക. | सेवया दत्ता गुप्तकुञ्चिका (Base32) संयोज्यताम्। |
| `helpStart11` | Under advanced settings you can set the algorithm (SHA1, SHA256, SHA512), digits (6 or 8) and period (30 or 60 seconds). | വിപുലമായ ക്രമീകരണങ്ങളിൽ അൽഗോരിതം (SHA1, SHA256, SHA512), അക്കങ്ങൾ (6 അല്ലെങ്കിൽ 8), കാലയളവ് (30 അല്ലെങ്കിൽ 60 സെക്കൻഡ്) എന്നിവ ക്രമീകരിക്കാം. | उन्नतविन्यासे गणनविधिः (SHA1, SHA256, SHA512), अङ्काः (6 अथवा 8), कालावधिः (30 अथवा 60 क्षणाः) च निश्चेतुं शक्यन्ते। |
| `helpStart12` | Using your 2FA codes | 2FA കോഡുകൾ ഉപയോഗിക്കൽ | 2FA-सङ्केतप्रयोगः |
| `helpStart13` | Time-based (TOTP) codes change every 30 seconds by default. The countdown ring shows how long the code stays valid. | സമയാധിഷ്ഠിത (TOTP) കോഡുകൾ സാധാരണയായി ഓരോ 30 സെക്കൻഡിലും മാറും. കോഡ് എത്ര സമയം സാധുവാണെന്ന് കൗണ്ട്ഡൗൺ വലയം കാണിക്കും. | कालाधारिताः (TOTP) सङ्केताः सामान्यतः प्रतिक्षणत्रिंशत् परिवर्तन्ते। सङ्केतः कियत्कालं मान्यः इति गणनावलयं दर्शयति। |
| `helpStart14` | Tap any account to copy its current code to the clipboard. | ഏത് അക്കൗണ്ടും അമർത്തിയാൽ അതിന്റെ നിലവിലെ കോഡ് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തും. | कमपि विवरणं स्पृष्ट्वा तस्य वर्तमानसङ्केतः प्रतिलिपिफलके प्रतिलिख्यते। |
| `helpStart15` | Paste the code into the sign-in screen of the website or service. | വെബ്സൈറ്റിന്റെയോ സേവനത്തിന്റെയോ സൈൻ-ഇൻ സ്ക്രീനിൽ കോഡ് ഒട്ടിക്കുക. | जालस्थानस्य सेवायाः वा प्रवेशपटले सङ्केतः संयोज्यताम्। |
| `helpStart16` | Tip: Always keep the backup recovery codes from your online services in a safe place, in case you lose your phone. | സൂചന: ഫോൺ നഷ്ടപ്പെട്ടാൽ ഉപകരിക്കാൻ, ഓൺലൈൻ സേവനങ്ങൾ നൽകുന്ന വീണ്ടെടുക്കൽ കോഡുകൾ എപ്പോഴും സുരക്ഷിതമായി സൂക്ഷിക്കുക. | सूचना: दूरभाषनाशे उपयोगाय अन्तर्जालसेवाभिः दत्ताः पुनःप्राप्तिसङ्केताः सदा सुरक्षिते स्थाने रक्ष्यन्ताम्। |
| `helpTime01` | Time sync & code drift | സമയ ക്രമീകരണവും വ്യതിയാനവും | कालसमन्वयः विचलनं च |
| `helpTime02` | TOTP codes depend on the exact time on your phone. If the clock is even a few seconds wrong, websites may reject your codes. | TOTP കോഡുകൾ ഫോണിലെ കൃത്യമായ സമയത്തെ ആശ്രയിക്കുന്നു. ഘടികാരം ഏതാനും സെക്കൻഡ് തെറ്റിയാൽ പോലും വെബ്സൈറ്റുകൾ കോഡ് നിരസിച്ചേക്കാം. | TOTP-सङ्केताः दूरभाषस्य यथार्थकालम् आश्रयन्ते। घटिका कतिपयक्षणान् अपि विचलति चेत् जालस्थानानि सङ्केतान् निराकुर्युः। |
| `helpTime03` | How TOTP time works | TOTP സമയം എങ്ങനെ പ്രവർത്തിക്കുന്നു | TOTP-कालः कथं कार्यं करोति |
| `helpTime04` | A time-based code is made from your secret key and the current time, counted in 30-second steps. | നിങ്ങളുടെ രഹസ്യ കീയും 30 സെക്കൻഡ് ഘട്ടങ്ങളായി എണ്ണുന്ന നിലവിലെ സമയവും ചേർത്താണ് സമയാധിഷ്ഠിത കോഡ് ഉണ്ടാക്കുന്നത്. | कालाधारितः सङ्केतः भवतः गुप्तकुञ्चिकया त्रिंशत्क्षणात्मकैः पदैः गणितेन वर्तमानकालेन च रच्यते। |
| `helpTime05` | Your phone and the server must agree on the time in UTC. Changing your time zone does not affect UTC. | ഫോണും സെർവറും UTC സമയത്തിൽ ഒത്തുപോകണം. സമയമേഖല മാറ്റുന്നത് UTC-യെ ബാധിക്കില്ല. | दूरभाषेण सेवकेन च UTC-काले ऐकमत्यं भवेत्। कालक्षेत्रपरिवर्तनं UTC न प्रभावयति। |
| `helpTime06` | Fixing rejected codes | നിരസിക്കപ്പെട്ട കോഡുകൾ പരിഹരിക്കൽ | निराकृतसङ्केतसमाधानम् |
| `helpTime07` | Open your phone settings and go to System → Date & time. | ഫോൺ ക്രമീകരണങ്ങൾ തുറന്ന് System → Date & time എന്നതിലേക്ക് പോകുക. | दूरभाषविन्यासम् उद्घाट्य System → Date & time प्रति गम्यताम्। |
| `helpTime08` | Turn on “Set time automatically” and “Set time zone automatically”. | “Set time automatically”, “Set time zone automatically” എന്നിവ ഓണാക്കുക. | “Set time automatically” “Set time zone automatically” च सक्रियीक्रियेताम्। |
| `helpTime09` | If they are already on, turn them off and on again to make the phone fetch the network time now. | അവ നേരത്തെ ഓണാണെങ്കിൽ, ഓഫാക്കി വീണ്ടും ഓണാക്കുക; അപ്പോൾ ഫോൺ നെറ്റ്‌വർക്ക് സമയം ഉടനെ എടുക്കും. | तानि पूर्वमेव सक्रियाणि चेत्, निष्क्रियीकृत्य पुनः सक्रियीक्रियन्ताम्; तदा दूरभाषः जालकालं तत्क्षणं गृह्णाति। |
| `helpTime10` | HOTP counter codes | HOTP കൗണ്ടർ കോഡുകൾ | HOTP-गणकसङ्केताः |
| `helpTime11` | HOTP codes are based on a counter, not on time. The app can read HOTP QR codes, but it cannot show or advance HOTP counters yet. | HOTP കോഡുകൾ സമയത്തെയല്ല, ഒരു കൗണ്ടറിനെയാണ് ആശ്രയിക്കുന്നത്. ആപ്പിന് HOTP QR കോഡുകൾ വായിക്കാനാകും, പക്ഷേ HOTP കൗണ്ടറുകൾ കാണിക്കാനോ മുന്നോട്ട് നീക്കാനോ ഇപ്പോൾ കഴിയില്ല. | HOTP-सङ्केताः कालं न, गणकम् आश्रयन्ते। अनुप्रयोगः HOTP-QR-सङ्केतान् पठितुं शक्नोति, किन्तु HOTP-गणकान् दर्शयितुं वर्धयितुं वा अधुना न शक्नोति। |
| `helpTime12` | If a service offers both, choose time-based (TOTP) codes in its 2FA settings. | ഒരു സേവനം രണ്ടും നൽകുന്നുവെങ്കിൽ, അതിന്റെ 2FA ക്രമീകരണങ്ങളിൽ സമയാധിഷ്ഠിത (TOTP) കോഡുകൾ തിരഞ്ഞെടുക്കുക. | सेवा उभयं ददाति चेत्, तस्याः 2FA-विन्यासे कालाधारिताः (TOTP) सङ्केताः चीयन्ताम्। |
| `helpTime13` | An account added from an HOTP QR code is saved, but its codes may not match the service until HOTP support is added. | HOTP QR കോഡിൽ നിന്ന് ചേർത്ത അക്കൗണ്ട് സൂക്ഷിക്കും, പക്ഷേ HOTP പിന്തുണ വരുന്നത് വരെ അതിന്റെ കോഡുകൾ സേവനവുമായി പൊരുത്തപ്പെടണമെന്നില്ല. | HOTP-QR-सङ्केतात् योजितं विवरणं रक्ष्यते, किन्तु HOTP-समर्थनं यावत् न योज्यते तावत् तस्य सङ्केताः सेवया सह न मिलेयुः। |
| `helpTime14` | Tip: Most rejected codes come from a wrong phone clock. Automatic network time fixes this for good. | സൂചന: നിരസിക്കപ്പെടുന്ന മിക്ക കോഡുകളും ഫോൺ ഘടികാരം തെറ്റുന്നതുകൊണ്ടാണ്. സ്വയമേവയുള്ള നെറ്റ്‌വർക്ക് സമയം ഇത് സ്ഥിരമായി പരിഹരിക്കും. | सूचना: अधिकांशाः निराकृतसङ्केताः दूरभाषघटिकायाः दोषात् भवन्ति। स्वचालितः जालकालः एतत् स्थिरतया समादधाति। |
| `helpTags01` | Tags & organization | അടയാളങ്ങളും ക്രമീകരണവും | चिह्नानि व्यवस्था च |
| `helpTags02` | Tags put your 2FA accounts into your own groups, such as Work, Personal, Banking or Social, so you can filter them easily. | ജോലി, വ്യക്തിപരം, ബാങ്കിംഗ്, സോഷ്യൽ പോലുള്ള നിങ്ങളുടെ സ്വന്തം ഗ്രൂപ്പുകളിലേക്ക് അടയാളങ്ങൾ 2FA അക്കൗണ്ടുകൾ തരംതിരിക്കുന്നു; അതിനാൽ എളുപ്പത്തിൽ അരിച്ചെടുക്കാം. | चिह्नानि भवतः 2FA-विवरणानि स्वकीयवर्गेषु (यथा कार्यम्, व्यक्तिगतम्, वित्तकोशः, समाजः) स्थापयन्ति, येन सुखेन परिशोधनं भवति। |
| `helpTags03` | Adding tags to accounts | അക്കൗണ്ടുകൾക്ക് അടയാളം നൽകൽ | विवरणेभ्यः चिह्नदानम् |
| `helpTags04` | When adding or editing an account, type tag names separated by commas (for example “Work, Cloud, Tech”). | അക്കൗണ്ട് ചേർക്കുമ്പോഴോ തിരുത്തുമ്പോഴോ, കോമ കൊണ്ട് വേർതിരിച്ച് അടയാളങ്ങൾ ടൈപ്പ് ചെയ്യുക (ഉദാ. “ജോലി, ക്ലൗഡ്, ടെക്”). | विवरणयोजने सम्पादने वा अल्पविरामैः पृथक्कृतानि चिह्ननामानि लिख्यन्ताम् (यथा “कार्यम्, मेघः, तन्त्रम्”)। |
| `helpTags05` | While you type, the app suggests tags you already use, so names stay the same. | ടൈപ്പ് ചെയ്യുമ്പോൾ നിലവിലുള്ള അടയാളങ്ങൾ ആപ്പ് നിർദ്ദേശിക്കും; അതിനാൽ പേരുകൾ ഒരുപോലെ നിലനിൽക്കും. | लेखनसमये अनुप्रयोगः विद्यमानचिह्नानि सूचयति, येन नामानि समानानि तिष्ठन्ति। |
| `helpTags06` | Tap “{browseTags}” to pick from all tags already in use. | ഇതിനകം ഉപയോഗത്തിലുള്ള എല്ലാ അടയാളങ്ങളിൽ നിന്നും തിരഞ്ഞെടുക്കാൻ “{browseTags}” അമർത്തുക. | प्रयुक्तेभ्यः सर्वचिह्नेभ्यः चेतुं “{browseTags}” स्पृश्यताम्। |
| `helpTags07` | Filtering by tag | അടയാളം അനുസരിച്ച് അരിക്കൽ | चिह्नानुसारं परिशोधनम् |
| `helpTags08` | The tag bar on the home screen shows your tags as chips you can tap. | ഹോം സ്ക്രീനിലെ അടയാള ബാർ നിങ്ങളുടെ അടയാളങ്ങൾ അമർത്താവുന്ന ചിപ്പുകളായി കാണിക്കുന്നു. | मुख्यपटलस्य चिह्नपट्टिका भवतः चिह्नानि स्पर्शनीयपट्टिकारूपेण दर्शयति। |
| `helpTags09` | Tap a tag chip to show only its accounts. Tap “{allTags}” to clear the filter. | ഒരു അടയാള ചിപ്പ് അമർത്തിയാൽ അതിന്റെ അക്കൗണ്ടുകൾ മാത്രം കാണാം. അരിപ്പ് നീക്കാൻ “{allTags}” അമർത്തുക. | चिह्नपट्टिकां स्पृष्ट्वा तस्य विवरणानि एव दृश्यन्ते। परिशोधनम् अपनेतुं “{allTags}” स्पृश्यताम्। |
| `helpTags10` | Switch to the tag cloud to see all tags and how many accounts each has. | എല്ലാ അടയാളങ്ങളും ഓരോന്നിനും എത്ര അക്കൗണ്ടുകളുണ്ടെന്നും കാണാൻ അടയാള മേഘത്തിലേക്ക് മാറുക. | सर्वचिह्नानि प्रत्येकस्य विवरणसङ्ख्या च द्रष्टुं चिह्नमेघं प्रति गम्यताम्। |
| `helpTags11` | Managing tags | അടയാള നിർവഹണം | चिह्नप्रबन्धनम् |
| `helpTags12` | Go to {settings} → {manageTags} to rename or delete a tag for all accounts at once. Renaming a tag to an existing name merges the two. | എല്ലാ അക്കൗണ്ടുകളിലും ഒരുമിച്ച് അടയാളം പേരുമാറ്റാനോ ഇല്ലാതാക്കാനോ {settings} → {manageTags} എന്നതിലേക്ക് പോകുക. നിലവിലുള്ള ഒരു പേരിലേക്ക് മാറ്റിയാൽ രണ്ടും ഒന്നാകും. | सर्वविवरणेषु एकदा चिह्ननामपरिवर्तनाय लोपाय वा {settings} → {manageTags} प्रति गम्यताम्। विद्यमानं नाम दत्तं चेत् उभे एकीभवतः। |
| `helpTags13` | Renaming a tag updates every account that has it. | ഒരു അടയാളത്തിന്റെ പേര് മാറ്റുമ്പോൾ അത് ഉള്ള എല്ലാ അക്കൗണ്ടുകളും പുതുക്കും. | चिह्ननामपरिवर्तनेन तद्युक्तानि सर्वविवरणानि नवीक्रियन्ते। |
| `helpTags14` | Deleting a tag removes the label from accounts; the accounts themselves stay. | ഒരു അടയാളം ഇല്ലാതാക്കിയാൽ അക്കൗണ്ടുകളിൽ നിന്ന് ആ ലേബൽ മാത്രം നീങ്ങും; അക്കൗണ്ടുകൾ നിലനിൽക്കും. | चिह्नलोपेन विवरणेभ्यः केवलं चिह्नम् अपनीयते; विवरणानि तिष्ठन्ति। |
| `helpTags15` | Tip: Short tag names (for example “Work”, “Finance”) look best in the filter bar. | സൂചന: ചെറിയ അടയാള പേരുകൾ (ഉദാ. “ജോലി”, “സാമ്പത്തികം”) ഫിൽട്ടർ ബാറിൽ നന്നായി കാണും. | सूचना: लघूनि चिह्ननामानि (यथा “कार्यम्”, “वित्तम्”) परिशोधनपट्टिकायां सुन्दराणि दृश्यन्ते। |
| `helpLock01` | Biometric & app lock | ബയോമെട്രിക്, ആപ്പ് ലോക്ക് | जैवमितिः अनुप्रयोगतालकं च |
| `helpLock02` | {appName} can protect your codes with your fingerprint or face, your phone screen lock, or an App PIN. | {appName}-ന് വിരലടയാളം, മുഖം, ഫോൺ സ്ക്രീൻ ലോക്ക്, അല്ലെങ്കിൽ ആപ്പ് PIN ഉപയോഗിച്ച് കോഡുകൾ സംരക്ഷിക്കാനാകും. | {appName} अङ्गुलिमुद्रया, मुखेन, दूरभाषपटलतालकेन, अनुप्रयोग-PIN-द्वारा वा भवतः सङ्केतान् रक्षितुं शक्नोति। |
| `helpLock03` | How app lock works | ആപ്പ് ലോക്ക് എങ്ങനെ പ്രവർത്തിക്കുന്നു | अनुप्रयोगतालकं कथं कार्यं करोति |
| `helpLock04` | When it is on in {settings} → {security}, the app asks you to unlock whenever you open it or come back to it. | {settings} → {security} എന്നതിൽ ഓണാണെങ്കിൽ, ആപ്പ് തുറക്കുമ്പോഴും തിരികെ വരുമ്പോഴും തുറക്കാൻ ആവശ്യപ്പെടും. | {settings} → {security} इत्यत्र सक्रियं चेत्, अनुप्रयोगस्य उद्घाटने पुनरागमने च उद्घाटनं याच्यते। |
| `helpLock05` | Decrypted codes stay in memory only while the app is open and unlocked. | ആപ്പ് തുറന്നിരിക്കുമ്പോഴും പൂട്ടാത്തപ്പോഴും മാത്രമേ തുറന്ന കോഡുകൾ മെമ്മറിയിലുണ്ടാകൂ. | अनुप्रयोगः उद्घाटितः अतालितः च यावत् तावत् एव विगूढसङ्केताः स्मृतौ तिष्ठन्ति। |
| `helpLock06` | Automatic lock | സ്വയം ലോക്ക് | स्वतालनम् |
| `helpLock07` | As soon as you leave the app, switch apps, or lock the phone screen, the app locks. While it is open, it also locks after the auto-lock timeout. | ആപ്പ് വിടുമ്പോഴോ മറ്റൊരു ആപ്പിലേക്ക് മാറുമ്പോഴോ ഫോൺ സ്ക്രീൻ പൂട്ടുമ്പോഴോ ആപ്പ് ഉടൻ പൂട്ടും. തുറന്നിരിക്കുമ്പോൾ, സ്വയം ലോക്ക് സമയം കഴിഞ്ഞാലും പൂട്ടും. | अनुप्रयोगत्यागे, अन्यानुप्रयोगगमने, दूरभाषपटलतालने वा अनुप्रयोगः तत्क्षणं ताल्यते। उद्घाटितावस्थायां स्वतालनकालानन्तरम् अपि ताल्यते। |
| `helpLock08` | Decrypted codes are removed from memory, so someone who picks up the phone cannot read them. | തുറന്ന കോഡുകൾ മെമ്മറിയിൽ നിന്ന് നീക്കം ചെയ്യുന്നു; അതിനാൽ ഫോൺ എടുക്കുന്നവർക്ക് അവ വായിക്കാനാവില്ല. | विगूढसङ्केताः स्मृतेः अपनीयन्ते, अतः दूरभाषं गृह्णन् तान् पठितुं न शक्नोति। |
| `helpLock09` | Fallback & phone lock | പകരം മാർഗ്ഗവും ഫോൺ ലോക്കും | विकल्पः दूरभाषतालकं च |
| `helpLock10` | If your fingerprint or face is not recognized (for example wet fingers or low light), you can use your phone screen lock PIN, pattern or password. | വിരലടയാളമോ മുഖമോ തിരിച്ചറിയുന്നില്ലെങ്കിൽ (ഉദാ. നനഞ്ഞ വിരലുകൾ, കുറഞ്ഞ വെളിച്ചം), ഫോൺ സ്ക്രീൻ ലോക്കിന്റെ PIN, പാറ്റേൺ, രഹസ്യവാക്ക് എന്നിവ ഉപയോഗിക്കാം. | अङ्गुलिमुद्रा मुखं वा न अभिज्ञायते चेत् (यथा आर्द्राङ्गुलयः, अल्पप्रकाशः), दूरभाषपटलतालकस्य PIN, रेखाचित्रं, गुप्तशब्दः वा प्रयोक्तुं शक्यते। |
| `helpLock11` | The check is done by Android itself. {appName} never sees or stores your biometric data or phone passcode. | പരിശോധന Android തന്നെയാണ് നടത്തുന്നത്. {appName} നിങ്ങളുടെ ബയോമെട്രിക് വിവരങ്ങളോ ഫോൺ പാസ്കോഡോ ഒരിക്കലും കാണുകയോ സൂക്ഷിക്കുകയോ ചെയ്യുന്നില്ല. | परीक्षणम् Android स्वयं करोति। {appName} भवतः जैवमितिदत्तांशं दूरभाषगुप्तसङ्केतं वा कदापि न पश्यति न रक्षति च। |
| `helpLock12` | Tip: Set a secure screen lock in your phone settings for the best protection. | സൂചന: മികച്ച സംരക്ഷണത്തിനായി ഫോൺ ക്രമീകരണങ്ങളിൽ സുരക്ഷിതമായ സ്ക്രീൻ ലോക്ക് സജ്ജമാക്കുക. | सूचना: उत्तमरक्षणाय दूरभाषविन्यासे सुरक्षितं पटलतालकं सज्जीक्रियताम्। |
| `helpVault01` | Vault security & privacy | നിലവറ സുരക്ഷയും സ്വകാര്യതയും | कोशसुरक्षा गोपनीयता च |
| `helpVault02` | {appName} is built to work offline and trust no server. Your secret keys are encrypted on your device and never sent to any remote server. | {appName} ഓഫ്‌ലൈനായി പ്രവർത്തിക്കാനും ഒരു സെർവറിനെയും ആശ്രയിക്കാതിരിക്കാനും നിർമ്മിച്ചതാണ്. രഹസ്യ കീകൾ നിങ്ങളുടെ ഉപകരണത്തിൽ എൻക്രിപ്റ്റ് ചെയ്യുന്നു, ഒരു വിദൂര സെർവറിലേക്കും അയയ്ക്കുന്നില്ല. | {appName} अन्तर्जालं विना कार्याय कस्मिन्नपि सेवके अविश्वासाय च निर्मितम्। भवतः गुप्तकुञ्चिकाः उपकरणे एव गूढलेख्यन्ते, कस्मैचित् अपि दूरसेवकाय न प्रेष्यन्ते। |
| `helpVault03` | AES-256-GCM encryption | AES-256-GCM എൻക്രിപ്ഷൻ | AES-256-GCM गूढलेखनम् |
| `helpVault04` | All secrets and code settings are encrypted with AES-256 in GCM mode, which also detects any change to the data. | എല്ലാ രഹസ്യങ്ങളും കോഡ് ക്രമീകരണങ്ങളും GCM മോഡിലുള്ള AES-256 ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുന്നു; വിവരങ്ങളിലെ ഏത് മാറ്റവും ഇത് കണ്ടെത്തും. | सर्वाणि रहस्यानि सङ्केतविन्यासाः च GCM-विधौ AES-256-द्वारा गूढलेख्यन्ते, यत् दत्तांशस्य कमपि परिवर्तनं ज्ञापयति। |
| `helpVault05` | The encryption key is made on your device and kept in the Android Keystore (hardware-backed on phones that support it). | എൻക്രിപ്ഷൻ കീ നിങ്ങളുടെ ഉപകരണത്തിൽ ഉണ്ടാക്കി Android Keystore-ൽ സൂക്ഷിക്കുന്നു (പിന്തുണയ്ക്കുന്ന ഫോണുകളിൽ ഹാർഡ്‌വെയർ സംരക്ഷണത്തോടെ). | गूढलेखनकुञ्चिका भवतः उपकरणे रच्यते, Android Keystore-मध्ये रक्ष्यते च (समर्थेषु दूरभाषेषु यन्त्रांशरक्षया)। |
| `helpVault06` | No secret is ever written to the database as plain text. | ഒരു രഹസ്യവും ഒരിക്കലും തുറന്ന രൂപത്തിൽ ഡാറ്റാബേസിൽ എഴുതുന്നില്ല. | किमपि रहस्यम् अनावृतरूपेण दत्तांशकोशे कदापि न लिख्यते। |
| `helpVault07` | Screenshot guard (FLAG_SECURE) | സ്ക്രീൻഷോട്ട് സംരക്ഷണം (FLAG_SECURE) | पटलचित्ररक्षा (FLAG_SECURE) |
| `helpVault08` | The app always turns on Android FLAG_SECURE for its window. | ആപ്പ് അതിന്റെ ജാലകത്തിന് എപ്പോഴും Android FLAG_SECURE ഓണാക്കുന്നു. | अनुप्रयोगः स्वगवाक्षाय सदा Android FLAG_SECURE सक्रियीकरोति। |
| `helpVault09` | This blocks screenshots, screen recording and screen-reading apps from capturing your codes. | ഇത് സ്ക്രീൻഷോട്ടുകൾ, സ്ക്രീൻ റെക്കോർഡിംഗ്, സ്ക്രീൻ വായിക്കുന്ന ആപ്പുകൾ എന്നിവ നിങ്ങളുടെ കോഡുകൾ പകർത്തുന്നത് തടയുന്നു. | एतत् पटलचित्राणि, पटलालेखनं, पटलपाठकानुप्रयोगान् च भवतः सङ्केतग्रहणात् निरुणद्धि। |
| `helpVault10` | In the recent-apps view, the app shows a blank screen, so people nearby cannot see your codes. | സമീപകാല ആപ്പുകളുടെ കാഴ്ചയിൽ ആപ്പ് ശൂന്യ സ്ക്രീൻ കാണിക്കുന്നു; അതിനാൽ അടുത്തുള്ളവർക്ക് കോഡുകൾ കാണാനാവില്ല. | सद्यःप्रयुक्तानुप्रयोगदर्शने अनुप्रयोगः रिक्तपटलं दर्शयति, अतः समीपस्थाः सङ्केतान् द्रष्टुं न शक्नुवन्ति। |
| `helpVault11` | No cloud, no telemetry | ക്ലൗഡ് ഇല്ല, ടെലിമെട്രി ഇല്ല | मेघः न, दूरमापनं न |
| `helpVault12` | The app has no server, no login and no advertising or analytics code. | ആപ്പിന് സെർവറോ ലോഗിനോ പരസ്യമോ അനലിറ്റിക്സ് കോഡോ ഇല്ല. | अनुप्रयोगे सेवकः, प्रवेशः, विज्ञापनं, विश्लेषणसङ्केतः वा नास्ति। |
| `helpVault13` | No codes, logs, device IDs or usage data ever leave your device. | കോഡുകൾ, ലോഗുകൾ, ഉപകരണ ID-കൾ, ഉപയോഗ വിവരങ്ങൾ എന്നിവ ഒരിക്കലും നിങ്ങളുടെ ഉപകരണം വിട്ടുപോകുന്നില്ല. | सङ्केताः, अभिलेखाः, उपकरणपरिचयाः, प्रयोगदत्तांशः वा कदापि भवतः उपकरणात् बहिः न गच्छन्ति। |
| `helpVault14` | Everything, including QR scanning, code generation and backup export, runs offline. Only Wi-Fi sync uses your local network. | QR സ്കാനിംഗ്, കോഡ് സൃഷ്ടി, കരുതൽ കയറ്റുമതി എന്നിവ ഉൾപ്പെടെ എല്ലാം ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു. Wi-Fi സമന്വയം മാത്രമാണ് പ്രാദേശിക നെറ്റ്‌വർക്ക് ഉപയോഗിക്കുന്നത്. | QR-अवलोकनं, सङ्केतरचना, प्रतिलिपिनिर्यापणं च सर्वम् अन्तर्जालं विना चलति। केवलं Wi-Fi-समन्वयः स्थानीयजालं प्रयुङ्क्ते। |
| `helpVault15` | Privacy first: your authentication secrets belong to you alone. | സ്വകാര്യതയ്ക്ക് മുൻഗണന: നിങ്ങളുടെ പ്രാമാണീകരണ രഹസ്യങ്ങൾ നിങ്ങളുടേത് മാത്രമാണ്. | गोपनीयता प्रथमा: भवतः प्रमाणीकरणरहस्यानि भवतः एव। |
| `helpWifi01` | Wi-Fi sync | Wi-Fi സമന്വയം | Wi-Fi-समन्वयः |
| `helpWifi02` | Wi-Fi sync moves your 2FA accounts directly between two phones on the same Wi-Fi network. The data is encrypted, and no cloud service is involved. | Wi-Fi സമന്വയം ഒരേ Wi-Fi നെറ്റ്‌വർക്കിലുള്ള രണ്ട് ഫോണുകൾക്കിടയിൽ 2FA അക്കൗണ്ടുകൾ നേരിട്ട് മാറ്റുന്നു. വിവരങ്ങൾ എൻക്രിപ്റ്റ് ചെയ്തതാണ്; ഒരു ക്ലൗഡ് സേവനവും ഉൾപ്പെടുന്നില്ല. | Wi-Fi-समन्वयः एकस्मिन् Wi-Fi-जाले स्थितयोः द्वयोः दूरभाषयोः मध्ये 2FA-विवरणानि साक्षात् स्थानान्तरयति। दत्तांशः गूढलेखितः, कापि मेघसेवा न प्रयुज्यते। |
| `helpWifi03` | How Wi-Fi sync works | Wi-Fi സമന്വയം എങ്ങനെ | Wi-Fi-समन्वयः कथम् |
| `helpWifi04` | Step 1: Connect both devices to the same Wi-Fi network. | ഘട്ടം 1: രണ്ട് ഉപകരണങ്ങളും ഒരേ Wi-Fi നെറ്റ്‌വർക്കിൽ ബന്ധിപ്പിക്കുക. | पदम् 1: उभे उपकरणे एकस्मिन् Wi-Fi-जाले संयुज्येताम्। |
| `helpWifi05` | Step 2: On the sending device, open {settings} → {syncDevices} → “{sendOverWifi}”. It shows a pairing QR code and a pairing code. | ഘട്ടം 2: അയയ്ക്കുന്ന ഉപകരണത്തിൽ {settings} → {syncDevices} → “{sendOverWifi}” തുറക്കുക. അത് ഒരു ജോടിയാക്കൽ QR കോഡും ജോടിയാക്കൽ കോഡും കാണിക്കും. | पदम् 2: प्रेषक-उपकरणे {settings} → {syncDevices} → “{sendOverWifi}” उद्घाट्यताम्। तत् युग्मन-QR-सङ्केतं युग्मनसङ्केतं च दर्शयति। |
| `helpWifi06` | Step 3: On the receiving device, tap “{receiveOverWifi}” and scan the pairing QR code (or type the details). | ഘട്ടം 3: സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ “{receiveOverWifi}” അമർത്തി ജോടിയാക്കൽ QR കോഡ് സ്കാൻ ചെയ്യുക (അല്ലെങ്കിൽ വിവരങ്ങൾ ടൈപ്പ് ചെയ്യുക). | पदम् 3: स्वीकर्तृ-उपकरणे “{receiveOverWifi}” स्पृष्ट्वा युग्मन-QR-सङ्केतः अवलोक्यताम् (अथवा विवरणानि लिख्यन्ताम्)। |
| `helpWifi07` | Step 4: The devices connect, and the sender chooses what to share. | ഘട്ടം 4: ഉപകരണങ്ങൾ ബന്ധിപ്പിക്കും, അയയ്ക്കുന്നയാൾ എന്ത് പങ്കിടണമെന്ന് തിരഞ്ഞെടുക്കും. | पदम् 4: उपकरणे संयुज्येते, प्रेषकः किं वितरणीयम् इति चिनोति। |
| `helpWifi08` | Encryption | എൻക്രിപ്ഷൻ | गूढलेखनम् |
| `helpWifi09` | The data is encrypted with AES-256-GCM, using a key made (with PBKDF2) from the pairing code shown on the screen. | സ്ക്രീനിൽ കാണിക്കുന്ന ജോടിയാക്കൽ കോഡിൽ നിന്ന് (PBKDF2 വഴി) ഉണ്ടാക്കുന്ന കീ ഉപയോഗിച്ച് AES-256-GCM-ൽ വിവരങ്ങൾ എൻക്രിപ്റ്റ് ചെയ്യുന്നു. | पटले दर्शितात् युग्मनसङ्केतात् (PBKDF2-द्वारा) निर्मितया कुञ्चिकया AES-256-GCM-मध्ये दत्तांशः गूढलेख्यते। |
| `helpWifi10` | Someone watching your Wi-Fi traffic cannot read your 2FA secrets without the pairing code. | ജോടിയാക്കൽ കോഡില്ലാതെ, നിങ്ങളുടെ Wi-Fi ട്രാഫിക് നിരീക്ഷിക്കുന്നവർക്ക് 2FA രഹസ്യങ്ങൾ വായിക്കാനാവില്ല. | युग्मनसङ्केतं विना भवतः Wi-Fi-प्रवाहं निरीक्षमाणः 2FA-रहस्यानि पठितुं न शक्नोति। |
| `helpWifi11` | The pairing code is never sent over the network; you move it yourself, by scanning or typing. | ജോടിയാക്കൽ കോഡ് ഒരിക്കലും നെറ്റ്‌വർക്ക് വഴി അയയ്ക്കുന്നില്ല; സ്കാൻ ചെയ്തോ ടൈപ്പ് ചെയ്തോ നിങ്ങൾ തന്നെ കൈമാറുന്നു. | युग्मनसङ्केतः जालेन कदापि न प्रेष्यते; अवलोकनेन लेखनेन वा भवान् एव तं स्थानान्तरयति। |
| `helpWifi12` | Safe merging | സുരക്ഷിത ലയനം | सुरक्षितं संयोजनम् |
| `helpWifi13` | Sync only adds accounts. Nothing on the receiving device is deleted or replaced. | സമന്വയം അക്കൗണ്ടുകൾ ചേർക്കുക മാത്രം ചെയ്യുന്നു. സ്വീകരിക്കുന്ന ഉപകരണത്തിലെ ഒന്നും ഇല്ലാതാക്കുകയോ മാറ്റുകയോ ചെയ്യുന്നില്ല. | समन्वयः केवलं विवरणानि योजयति। स्वीकर्तृ-उपकरणे किमपि न लुप्यते न परिवर्त्यते च। |
| `helpWifi14` | Accounts that already exist on the receiving device are skipped. | സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ ഇതിനകം ഉള്ള അക്കൗണ്ടുകൾ ഒഴിവാക്കും. | स्वीकर्तृ-उपकरणे पूर्वमेव विद्यमानानि विवरणानि त्यज्यन्ते। |
| `helpWifi15` | Tip: Keep both devices awake and on the same Wi-Fi until the transfer finishes. | സൂചന: കൈമാറ്റം കഴിയുന്നത് വരെ രണ്ട് ഉപകരണങ്ങളും ഉണർന്നും ഒരേ Wi-Fi-ലും വയ്ക്കുക. | सूचना: प्रेषणसमाप्तिपर्यन्तम् उभे उपकरणे जागृते एकस्मिन् Wi-Fi-जाले च स्थाप्येताम्। |
| `helpOptical01` | Optical air-gap transfer | ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് | प्रकाशीयवायुविच्छेदः |
| `helpOptical02` | Optical transfer moves your accounts to an offline device with an animated series of QR codes, without Wi-Fi, Bluetooth or cables. | Wi-Fi, ബ്ലൂടൂത്ത്, കേബിൾ എന്നിവ ഇല്ലാതെ, ചലിക്കുന്ന QR കോഡുകൾ വഴി ഒപ്റ്റിക്കൽ കൈമാറ്റം അക്കൗണ്ടുകൾ ഓഫ്‌ലൈൻ ഉപകരണത്തിലേക്ക് മാറ്റുന്നു. | प्रकाशीयप्रेषणं Wi-Fi, नीलदन्तं, तन्तून् वा विना चलत्-QR-सङ्केतश्रेण्या अन्तर्जालरहितम् उपकरणं प्रति विवरणानि स्थानान्तरयति। |
| `helpOptical03` | What is an air gap? | എയർ-ഗ്യാപ്പ് എന്താണ്? | वायुविच्छेदः कः? |
| `helpOptical04` | An air-gapped device has no network connection at all (no Wi-Fi, Bluetooth or mobile data; Airplane Mode on). | എയർ-ഗ്യാപ്പ് ഉപകരണത്തിന് ഒരു നെറ്റ്‌വർക്ക് ബന്ധവും ഇല്ല (Wi-Fi, ബ്ലൂടൂത്ത്, മൊബൈൽ ഡാറ്റ ഇല്ല; എയർപ്ലെയിൻ മോഡ് ഓൺ). | वायुविच्छिन्नस्य उपकरणस्य कोऽपि जालसम्बन्धः नास्ति (Wi-Fi, नीलदन्तः, चलदूरभाषदत्तांशः न; विमानविधिः सक्रियः)। |
| `helpOptical05` | The data travels only as light, from screen to camera, so there is no network to listen to. But anyone who can see or film the screen can copy it. | വിവരങ്ങൾ സ്ക്രീനിൽ നിന്ന് ക്യാമറയിലേക്ക് വെളിച്ചമായി മാത്രം സഞ്ചരിക്കുന്നു; അതിനാൽ ചോർത്താൻ നെറ്റ്‌വർക്ക് ഇല്ല. എന്നാൽ സ്ക്രീൻ കാണാനോ ചിത്രീകരിക്കാനോ കഴിയുന്ന ആർക്കും അത് പകർത്താം. | दत्तांशः पटलात् छायाग्राहकं प्रति केवलं प्रकाशरूपेण गच्छति, अतः श्रवणाय जालं नास्ति। किन्तु पटलं द्रष्टुं चित्रयितुं वा समर्थः कोऽपि तत् प्रतिलेखितुं शक्नोति। |
| `helpOptical06` | How to do an optical transfer | ഒപ്റ്റിക്കൽ കൈമാറ്റം എങ്ങനെ | प्रकाशीयप्रेषणं कथम् |
| `helpOptical07` | Step 1: On the sending device, go to {settings} → {syncDevices} → “{sendOptical}”. | ഘട്ടം 1: അയയ്ക്കുന്ന ഉപകരണത്തിൽ {settings} → {syncDevices} → “{sendOptical}” എന്നതിലേക്ക് പോകുക. | पदम् 1: प्रेषक-उपकरणे {settings} → {syncDevices} → “{sendOptical}” प्रति गम्यताम्। |
| `helpOptical08` | Step 2: The sender shows your accounts as a looping series of QR codes. These QR codes are not encrypted: keep the screen away from other people and cameras. | ഘട്ടം 2: അയയ്ക്കുന്ന ഉപകരണം അക്കൗണ്ടുകൾ ആവർത്തിക്കുന്ന QR കോഡുകളായി കാണിക്കും. ഈ QR കോഡുകൾ എൻക്രിപ്റ്റ് ചെയ്തതല്ല: സ്ക്രീൻ മറ്റുള്ളവരിൽ നിന്നും ക്യാമറകളിൽ നിന്നും അകറ്റി നിർത്തുക. | पदम् 2: प्रेषकः विवरणानि आवर्तमानया QR-सङ्केतश्रेण्या दर्शयति। एते QR-सङ्केताः गूढलेखिताः न: पटलः अन्यजनेभ्यः छायाग्राहकेभ्यः च दूरे रक्ष्यताम्। |
| `helpOptical09` | Step 3: On the receiving device, choose “{scanOptical}” and point the camera at the sending screen. | ഘട്ടം 3: സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ “{scanOptical}” തിരഞ്ഞെടുത്ത് ക്യാമറ അയയ്ക്കുന്ന സ്ക്രീനിലേക്ക് തിരിക്കുക. | पदम् 3: स्वीकर्तृ-उपकरणे “{scanOptical}” चित्वा छायाग्राहकं प्रेषकपटले स्थाप्यताम्। |
| `helpOptical10` | Step 4: The receiver collects all parts. When every part is read and checked, the accounts are imported. | ഘട്ടം 4: സ്വീകരിക്കുന്ന ഉപകരണം എല്ലാ ഭാഗങ്ങളും ശേഖരിക്കും. എല്ലാ ഭാഗങ്ങളും വായിച്ച് പരിശോധിച്ചാൽ അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യും. | पदम् 4: स्वीकर्ता सर्वान् खण्डान् सङ्गृह्णाति। सर्वेषु खण्डेषु पठितेषु परीक्षितेषु च विवरणानि आनीयन्ते। |
| `helpOptical11` | Speed tips | വേഗത്തിനുള്ള സൂചനകൾ | वेगसूचनाः |
| `helpOptical12` | You can set the speed on the sender to 10, 12 or 15 frames per second; use a slower speed if the camera misses frames. | അയയ്ക്കുന്ന ഉപകരണത്തിൽ വേഗം സെക്കൻഡിൽ 10, 12, 15 ഫ്രെയിമുകളായി ക്രമീകരിക്കാം; ക്യാമറ ഫ്രെയിമുകൾ നഷ്ടപ്പെടുത്തുന്നുവെങ്കിൽ കുറഞ്ഞ വേഗം ഉപയോഗിക്കുക. | प्रेषके वेगः प्रतिक्षणं 10, 12, 15 वा चित्रखण्डाः इति निश्चेतुं शक्यते; छायाग्राहकः खण्डान् त्यजति चेत् मन्दवेगः प्रयुज्यताम्। |
| `helpOptical13` | Hold both devices steady in good light, and avoid reflections or glare on the screen. | രണ്ട് ഉപകരണങ്ങളും നല്ല വെളിച്ചത്തിൽ സ്ഥിരമായി പിടിക്കുക; സ്ക്രീനിലെ പ്രതിഫലനങ്ങളും തിളക്കവും ഒഴിവാക്കുക. | उभे उपकरणे सुप्रकाशे स्थिरं ध्रियेताम्; पटले प्रतिबिम्बं दीप्तिं च परिहरतु। |
| `helpOptical14` | Tip: Optical sync suits a dedicated offline backup phone kept in a safe place. | സൂചന: സുരക്ഷിത സ്ഥലത്ത് സൂക്ഷിക്കുന്ന ഓഫ്‌ലൈൻ കരുതൽ ഫോണിന് ഒപ്റ്റിക്കൽ സമന്വയം അനുയോജ്യമാണ്. | सूचना: सुरक्षिते स्थाने रक्षिताय अन्तर्जालरहिताय प्रतिलिपिदूरभाषाय प्रकाशीयसमन्वयः उचितः। |
| `helpBackup01` | Encrypted backup & restore | എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ | गूढलेखितप्रतिलिपिः |
| `helpBackup02` | Backups protect you if your phone is damaged or lost, or when you move to a new phone. Every backup file is encrypted with a password you choose. | ഫോൺ കേടാകുമ്പോഴോ നഷ്ടപ്പെടുമ്പോഴോ പുതിയ ഫോണിലേക്ക് മാറുമ്പോഴോ കരുതൽ നിങ്ങളെ സംരക്ഷിക്കുന്നു. ഓരോ കരുതൽ ഫയലും നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന രഹസ്യവാക്ക് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുന്നു. | दूरभाषस्य क्षतौ नाशे वा नूतनदूरभाषं प्रति गमने वा प्रतिलिपयः भवन्तं रक्षन्ति। प्रत्येका प्रतिलिपिसञ्चिका भवता चितेन गुप्तशब्देन गूढलेख्यते। |
| `helpBackup03` | Creating an encrypted backup | എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഉണ്ടാക്കൽ | गूढलेखितप्रतिलिपिरचना |
| `helpBackup04` | Go to {settings} → {backupRestore} → tap “{createBackup}”. | {settings} → {backupRestore} → “{createBackup}” അമർത്തുക. | {settings} → {backupRestore} → “{createBackup}” स्पृश्यताम्। |
| `helpBackup05` | Choose a strong backup password. The app makes an AES-256 key from it with PBKDF2 (300,000 iterations) to encrypt the file. | ശക്തമായ കരുതൽ രഹസ്യവാക്ക് തിരഞ്ഞെടുക്കുക. ഫയൽ എൻക്രിപ്റ്റ് ചെയ്യാൻ ആപ്പ് അതിൽ നിന്ന് PBKDF2 (300,000 ആവർത്തനങ്ങൾ) ഉപയോഗിച്ച് AES-256 കീ ഉണ്ടാക്കുന്നു. | दृढः प्रतिलिपिगुप्तशब्दः चीयताम्। सञ्चिकायाः गूढलेखनाय अनुप्रयोगः तस्मात् PBKDF2 (300,000 आवृत्तयः) इत्यनेन AES-256-कुञ्चिकां रचयति। |
| `helpBackup06` | Save the encrypted .aes backup file on your device, a USB drive, or your own offline archive. | എൻക്രിപ്റ്റ് ചെയ്ത .aes കരുതൽ ഫയൽ ഉപകരണത്തിലോ USB ഡ്രൈവിലോ നിങ്ങളുടെ ഓഫ്‌ലൈൻ ശേഖരത്തിലോ സൂക്ഷിക്കുക. | गूढलेखिता .aes प्रतिलिपिसञ्चिका उपकरणे, USB-धारके, स्वकीये अन्तर्जालरहिते सञ्चये वा रक्ष्यताम्। |
| `helpBackup07` | Password safety & recovery | രഹസ്യവാക്ക് സുരക്ഷയും വീണ്ടെടുക്കലും | गुप्तशब्दसुरक्षा पुनःप्राप्तिः च |
| `helpBackup08` | Your backup password is never stored or sent anywhere. You must remember it or keep it written down safely. | നിങ്ങളുടെ കരുതൽ രഹസ്യവാക്ക് എവിടെയും സൂക്ഷിക്കുകയോ അയയ്ക്കുകയോ ചെയ്യുന്നില്ല. അത് ഓർമ്മിക്കുകയോ സുരക്ഷിതമായി എഴുതി വയ്ക്കുകയോ ചെയ്യണം. | भवतः प्रतिलिपिगुप्तशब्दः कुत्रापि न रक्ष्यते न प्रेष्यते च। सः स्मर्तव्यः सुरक्षितं लिखित्वा रक्षणीयः वा। |
| `helpBackup09` | Because {appName} works fully offline, there is no “forgot password” or server reset. A lost backup password cannot be recovered. | {appName} പൂർണ്ണമായും ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നതിനാൽ “രഹസ്യവാക്ക് മറന്നോ” അല്ലെങ്കിൽ സെർവർ പുനഃസജ്ജീകരണം ഇല്ല. നഷ്ടപ്പെട്ട കരുതൽ രഹസ്യവാക്ക് വീണ്ടെടുക്കാനാവില്ല. | {appName} पूर्णतया अन्तर्जालं विना चलति, अतः “गुप्तशब्दविस्मरणम्” सेवकपुनःसज्जीकरणं वा नास्ति। नष्टः प्रतिलिपिगुप्तशब्दः पुनः प्राप्तुं न शक्यते। |
| `helpBackup10` | Restoring a backup | കരുതൽ പുനഃസ്ഥാപിക്കൽ | प्रतिलिपिपुनःस्थापनम् |
| `helpBackup11` | Go to {settings} → {backupRestore} → tap “{restoreBackup}”. | {settings} → {backupRestore} → “{restoreBackup}” അമർത്തുക. | {settings} → {backupRestore} → “{restoreBackup}” स्पृश्यताम्। |
| `helpBackup12` | Pick your backup file and enter the password you used when you made it. | കരുതൽ ഫയൽ തിരഞ്ഞെടുത്ത് അത് ഉണ്ടാക്കിയപ്പോൾ ഉപയോഗിച്ച രഹസ്യവാക്ക് നൽകുക. | प्रतिलिपिसञ्चिकां चित्वा तस्याः रचनाकाले प्रयुक्तः गुप्तशब्दः दीयताम्। |
| `helpBackup13` | The app checks the file and adds new accounts to the ones you have; nothing you have is deleted. | ആപ്പ് ഫയൽ പരിശോധിച്ച് പുതിയ അക്കൗണ്ടുകൾ നിലവിലുള്ളവയോട് ചേർക്കും; നിലവിലുള്ള ഒന്നും ഇല്ലാതാക്കില്ല. | अनुप्रयोगः सञ्चिकां परीक्ष्य नूतनविवरणानि विद्यमानेषु योजयति; विद्यमानं किमपि न लुप्यते। |
| `helpBackup14` | Tip: Make a fresh backup whenever you add important new 2FA accounts. | സൂചന: പ്രധാനപ്പെട്ട പുതിയ 2FA അക്കൗണ്ടുകൾ ചേർക്കുമ്പോഴെല്ലാം പുതിയ കരുതൽ ഉണ്ടാക്കുക. | सूचना: महत्त्वपूर्णानि नूतनानि 2FA-विवरणानि योज्यन्ते यदा यदा तदा तदा नूतना प्रतिलिपिः रच्यताम्। |
| `helpFaq01` | FAQs & troubleshooting | ചോദ്യങ്ങളും പരിഹാരവും | प्रश्नाः समाधानं च |
| `helpFaq02` | Quick answers about 2FA codes, recovery, security and common problems. | 2FA കോഡുകൾ, വീണ്ടെടുക്കൽ, സുരക്ഷ, സാധാരണ പ്രശ്നങ്ങൾ എന്നിവയെക്കുറിച്ചുള്ള വേഗത്തിലുള്ള ഉത്തരങ്ങൾ. | 2FA-सङ्केताः, पुनःप्राप्तिः, सुरक्षा, सामान्यसमस्याः च इति विषये शीघ्रोत्तराणि। |
| `helpFaq03` | 2FA codes | 2FA കോഡുകൾ | 2FA-सङ्केताः |
| `helpFaq04` | Why do websites reject my codes? | വെബ്സൈറ്റുകൾ എന്റെ കോഡുകൾ നിരസിക്കുന്നത് എന്തുകൊണ്ട്? | जालस्थानानि मम सङ्केतान् किमर्थं निराकुर्वन्ति? |
| `helpFaq05` | Usually the phone clock is wrong. Open your phone settings → Date & time and turn on “Set time automatically”, so the clock matches UTC. | സാധാരണയായി ഫോൺ ഘടികാരം തെറ്റായിരിക്കും. ഫോൺ ക്രമീകരണങ്ങൾ → Date & time തുറന്ന് “Set time automatically” ഓണാക്കുക; അപ്പോൾ ഘടികാരം UTC-യുമായി ഒത്തുപോകും. | प्रायः दूरभाषघटिका अशुद्धा भवति। दूरभाषविन्यासः → Date & time उद्घाट्य “Set time automatically” सक्रियीक्रियताम्, येन घटिका UTC-अनुसारिणी भवति। |
| `helpFaq06` | Can I copy a code with one tap? | ഒറ്റ സ്പർശത്തിൽ കോഡ് പകർത്താമോ? | एकस्पर्शेन सङ्केतः प्रतिलेखितुं शक्यते वा? |
| `helpFaq07` | Yes. Tap the account on the home screen; its code is copied to the clipboard and a short message confirms it. | അതെ. ഹോം സ്ക്രീനിലെ അക്കൗണ്ട് അമർത്തുക; കോഡ് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തുകയും ഒരു ചെറിയ സന്ദേശം അത് ഉറപ്പിക്കുകയും ചെയ്യും. | आम्। मुख्यपटले विवरणं स्पृश्यताम्; तस्य सङ्केतः प्रतिलिपिफलके प्रतिलिख्यते, लघुसन्देशः तत् दृढीकरोति च। |
| `helpFaq08` | How are HOTP codes different from TOTP codes? | HOTP കോഡുകൾ TOTP-യിൽ നിന്ന് എങ്ങനെ വ്യത്യസ്തമാണ്? | HOTP-सङ्केताः TOTP-सङ्केतेभ्यः कथं भिन्नाः? |
| `helpFaq09` | TOTP codes change every 30 seconds based on time. HOTP codes change when a counter moves on. This app does not support advancing HOTP counters yet, so use TOTP where the service offers it. | TOTP കോഡുകൾ സമയം അനുസരിച്ച് ഓരോ 30 സെക്കൻഡിലും മാറും. HOTP കോഡുകൾ ഒരു കൗണ്ടർ മുന്നോട്ട് നീങ്ങുമ്പോൾ മാറും. ഈ ആപ്പ് ഇതുവരെ HOTP കൗണ്ടർ മുന്നോട്ട് നീക്കുന്നത് പിന്തുണയ്ക്കുന്നില്ല; അതിനാൽ സേവനം നൽകുന്നുവെങ്കിൽ TOTP ഉപയോഗിക്കുക. | TOTP-सङ्केताः कालानुसारं प्रतिक्षणत्रिंशत् परिवर्तन्ते। HOTP-सङ्केताः गणके वर्धिते परिवर्तन्ते। अयम् अनुप्रयोगः अद्यापि HOTP-गणकवर्धनं न समर्थयते, अतः सेवा ददाति चेत् TOTP प्रयुज्यताम्। |
| `helpFaq10` | Security & privacy | സുരക്ഷയും സ്വകാര്യതയും | सुरक्षा गोपनीयता च |
| `helpFaq11` | Why is the app blank when I switch apps? | ആപ്പ് മാറുമ്പോൾ ഇത് ശൂന്യമാകുന്നത് എന്തുകൊണ്ട്? | अनुप्रयोगपरिवर्तने अयं रिक्तः किमर्थम्? |
| `helpFaq12` | The screenshot guard turns on Android FLAG_SECURE. It stops screen recorders and the recent-apps view from capturing your codes. | സ്ക്രീൻഷോട്ട് സംരക്ഷണം Android FLAG_SECURE ഓണാക്കുന്നു. സ്ക്രീൻ റെക്കോർഡറുകളും സമീപകാല ആപ്പ് കാഴ്ചയും കോഡുകൾ പകർത്തുന്നത് ഇത് തടയുന്നു. | पटलचित्ररक्षा Android FLAG_SECURE सक्रियीकरोति। एतत् पटलालेखकान् सद्यःप्रयुक्तानुप्रयोगदर्शनं च सङ्केतग्रहणात् निरुणद्धि। |
| `helpFaq13` | Does {appName} send any data online? | {appName} എന്തെങ്കിലും വിവരം ഓൺലൈനായി അയയ്ക്കുന്നുണ്ടോ? | {appName} किमपि दत्तांशम् अन्तर्जाले प्रेषयति वा? |
| `helpFaq14` | No. {appName} works offline. It has no analytics, tracking or cloud service. Your data leaves the device only when you start a Wi-Fi sync on your local network, an optical transfer, or a backup export. | ഇല്ല. {appName} ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു. അനലിറ്റിക്സോ ട്രാക്കിംഗോ ക്ലൗഡ് സേവനമോ ഇല്ല. പ്രാദേശിക നെറ്റ്‌വർക്കിൽ Wi-Fi സമന്വയം, ഒപ്റ്റിക്കൽ കൈമാറ്റം, കരുതൽ കയറ്റുമതി എന്നിവ നിങ്ങൾ ആരംഭിക്കുമ്പോൾ മാത്രമേ വിവരങ്ങൾ ഉപകരണം വിടുകയുള്ളൂ. | न। {appName} अन्तर्जालं विना चलति। विश्लेषणम्, अनुसरणं, मेघसेवा वा नास्ति। स्थानीयजाले Wi-Fi-समन्वयं, प्रकाशीयप्रेषणं, प्रतिलिपिनिर्यापणं वा भवान् आरभते तदा एव दत्तांशः उपकरणात् बहिः गच्छति। |
| `helpFaq15` | What if my fingerprint or face is not recognized? | വിരലടയാളമോ മുഖമോ തിരിച്ചറിയുന്നില്ലെങ്കിൽ? | अङ्गुलिमुद्रा मुखं वा न अभिज्ञायते चेत् किम्? |
| `helpFaq16` | You can unlock with your phone screen lock PIN, pattern or password, or with your App PIN. | ഫോൺ സ്ക്രീൻ ലോക്കിന്റെ PIN, പാറ്റേൺ, രഹസ്യവാക്ക്, അല്ലെങ്കിൽ ആപ്പ് PIN ഉപയോഗിച്ച് തുറക്കാം. | दूरभाषपटलतालकस्य PIN, रेखाचित्रेण, गुप्तशब्देन, अनुप्रयोग-PIN-द्वारा वा उद्घाटयितुं शक्यते। |
| `helpFaq17` | Backups & moving phones | കരുതലും ഫോൺ മാറ്റവും | प्रतिलिपयः दूरभाषपरिवर्तनं च |
| `helpFaq18` | How do I move my accounts to a new phone? | അക്കൗണ്ടുകൾ പുതിയ ഫോണിലേക്ക് എങ്ങനെ മാറ്റാം? | विवरणानि नूतनदूरभाषं प्रति कथं स्थानान्तर्यन्ते? |
| `helpFaq19` | Use “{syncDevices}” over local Wi-Fi, scan an optical QR stream, or export an encrypted backup on the old phone and restore it on the new one. | പ്രാദേശിക Wi-Fi വഴി “{syncDevices}” ഉപയോഗിക്കുക, ഒപ്റ്റിക്കൽ QR സ്ട്രീം സ്കാൻ ചെയ്യുക, അല്ലെങ്കിൽ പഴയ ഫോണിൽ എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ കയറ്റുമതി ചെയ്ത് പുതിയതിൽ പുനഃസ്ഥാപിക്കുക. | स्थानीय-Wi-Fi-द्वारेण “{syncDevices}” प्रयुज्यताम्, प्रकाशीय-QR-प्रवाहः अवलोक्यताम्, अथवा पुरातने दूरभाषे गूढलेखितप्रतिलिपिं निर्याप्य नूतने पुनःस्थाप्यताम्। |
| `helpFaq20` | What if I forget my backup password? | കരുതൽ രഹസ്യവാക്ക് മറന്നാൽ? | प्रतिलिपिगुप्तशब्दः विस्मृतः चेत् किम्? |
| `helpFaq21` | Backups use AES-256 encryption and there is no server, so a lost backup password cannot be recovered. Keep it written down safely. | കരുതലുകൾ AES-256 എൻക്രിപ്ഷൻ ഉപയോഗിക്കുന്നു, സെർവർ ഇല്ല; അതിനാൽ നഷ്ടപ്പെട്ട കരുതൽ രഹസ്യവാക്ക് വീണ്ടെടുക്കാനാവില്ല. അത് സുരക്ഷിതമായി എഴുതി വയ്ക്കുക. | प्रतिलिपयः AES-256-गूढलेखनं प्रयुञ्जते, सेवकः च नास्ति, अतः नष्टः प्रतिलिपिगुप्तशब्दः पुनः प्राप्तुं न शक्यते। सः सुरक्षितं लिखित्वा रक्ष्यताम्। |
| `helpFaq22` | Will restoring a backup erase my accounts? | കരുതൽ പുനഃസ്ഥാപിക്കുന്നത് എന്റെ അക്കൗണ്ടുകൾ മായ്ക്കുമോ? | प्रतिलिपिपुनःस्थापनं मम विवरणानि मार्क्ष्यति वा? |
| `helpFaq23` | No. {appName} only adds accounts. Your existing accounts stay, and duplicates are skipped. | ഇല്ല. {appName} അക്കൗണ്ടുകൾ ചേർക്കുക മാത്രം ചെയ്യുന്നു. നിലവിലുള്ളവ നിലനിൽക്കും, ഇരട്ടിപ്പുകൾ ഒഴിവാക്കും. | न। {appName} केवलं विवरणानि योजयति। विद्यमानानि तिष्ठन्ति, द्विरुक्तानि त्यज्यन्ते। |
| `helpFaq24` | Need more help? Read the other guides in Help, or check your permissions in {settings} → {permissions}. | കൂടുതൽ സഹായം വേണോ? സഹായത്തിലെ മറ്റ് മാർഗ്ഗനിർദ്ദേശങ്ങൾ വായിക്കുക, അല്ലെങ്കിൽ {settings} → {permissions} എന്നതിൽ അനുമതികൾ പരിശോധിക്കുക. | अधिकसाहाय्यम् अपेक्षितं वा? साहाय्ये अन्याः मार्गदर्शिकाः पठ्यन्ताम्, अथवा {settings} → {permissions} इत्यत्र अनुमतयः परीक्ष्यन्ताम्। |
