# Localization Part 5c — security, backup and sync

Implements plan: `plans/20261029_215230_localization-part-5c-security-backup-sync.md`
(Part 5c of `plans/20261029_202317_localization-phase-5.md`)

## What changed

### Error codes instead of English text (lower layers)
- `lib/services/p2p_sync_service.dart` — new enum `P2pSyncErrorCode` (17 values).
  `P2pSyncException(code, message)`: the code is for the UI, the English `message` stays for
  logs and tests only. All 24 throw sites set a code. The host error callback now passes a
  `P2pSyncException` instead of the string `'Server error: $e'`.
- `lib/services/optical_sync_service.dart` — new enum `OpticalSyncErrorCode` (7 values);
  `OpticalSyncException(code, message)`; all 12 throw sites set a code.
- `lib/providers/sync_provider.dart` — new enum `SyncErrorCode` (7 values).
  `SyncError(code, {p2pCode, opticalCode})` replaces `SyncError(String message)`. No `$e` text
  any more (`'Sync failed: $e'`, `'Could not start hosting: $e'`, `'Optical sync decoding failed:
  $e'` are gone); the cause is logged through `AppLogger` (type only).
- `lib/services/export_import_service.dart` — new `BackupPasswordException` replaces
  `Exception('Invalid password or corrupted file')`. Note: the service catches it itself and
  returns `null`, and the screen already shows a localized "check your password" message for
  `null`, so the user sees no change.
- New `lib/widgets/sync_error_text.dart` — `syncErrorText`, `p2pSyncErrorText`,
  `opticalSyncErrorText` turn the codes into localized text (the most specific cause wins).

### Screens (all user-visible text now from ARB)
- `lib/screens/security_screen.dart` — reuses the 5b keys for PIN, recovery key and phone-lock
  errors; its own copy of the phone-lock error mapping now uses the same keys. Auto-lock options
  are built from numbers (`labelSecondsCount`, `labelMinutesCount`).
- `lib/screens/backup_restore_screen.dart` — `'Error creating backup: $e'` and
  `'Error restoring backup: $e'` replaced by localized messages; errors logged by type.
- `lib/screens/tag_management_screen.dart` — `'Failed to rename tag: $e'` and
  `'Failed to delete tag: $e'` replaced the same way.
- `lib/screens/sync_screen.dart`, `send_to_device_screen.dart`, `optical_sync_screen.dart`,
  `sync_qr_scanner_screen.dart` — `state.message` / `e.message` replaced by the code-to-text
  helpers; summary lines and durations built from numbers.
- 215 new ARB keys (524 in total).

### English text changed
- Sentence case, and shorter labels for the 20-character budget, for example: "Sync to another
  device" → "Sync devices" (existing key); "Send over Wi-Fi / LAN" → "Send over Wi-Fi";
  "Optical Air-Gap Stream (Send)" → "Send optical stream"; "Create Encrypted Backup" →
  "Create backup file"; "Enter Current App PIN" → "Current App PIN"; "Optical Air-Gap Sync
  Complete" → "Optical sync done".
- Counts without plural forms: "Successfully restored 3 account(s)" → "Accounts restored: 3";
  "Added 2 account(s) (1 already present, kept)" → "Accounts added: 2 (1 already present,
  kept)"; "3 accounts" (tag row) → "Accounts: 3".
- Plain words for technical terms the user does not need: "vault" → "accounts"; "Fountain
  Codes" → "error-tolerant chunks"; "P2P LAN Sync" → "Wi-Fi sync".
- Sync errors now have one clear sentence each, for example "Could not connect to the other
  device. Check the IP address, port and Wi-Fi."

### Tests
- New `test/services/sync_error_codes_test.dart` — the sync QR parser throws the right code for
  each bad input; a bad optical frame gives `invalidFrame`; every `P2pSyncErrorCode`,
  `OpticalSyncErrorCode` and `SyncErrorCode` has distinct, non-empty text in `en`, `ml`, `sa`;
  the most specific cause wins.
- New `test/screens/security_screen_l10n_test.dart` — the Security screen (app lock on, PIN
  set) in all three languages on a 360 px screen, no overflow.
- `test/screens/tag_management_screen_test.dart` — localization delegates; "Manage tags".
- `test/l10n/translation_parity_test.dart` — `labelFps` (`{fps} FPS`, a number and a unit)
  added to the same-as-template allow-list.
- The existing sync tests (wrong pairing code, payload caps, loopback transfer) pass unchanged.

### Docs
`CLAUDE.md`, `AGENTS.md` (migration status; codes not text; never show raw exception text),
`docs/implementation_progress.md` (5c ticked).

## Checks
- `flutter gen-l10n` — OK.
- `dart format` on all changed Dart files.
- `flutter analyze` — no issues.
- `flutter test` — all 287 tests passed (274 before).
- `flutter build apk --flavor dev --debug` — built. Gradle daemons stopped; none left.

## Found, not fixed here
- Two minimum backup-password lengths: the home screen's "Export selected" asks for 6
  characters, the Backup screen for 8. Worth making them the same (8) in a small follow-up.
- `ExportImportService.importAccountsEncrypted` reads the picked file without a size check
  (already listed for Phase 7).
- **Manual device check needed** in `ml` and `sa`: Security (all switches and dialogs), Backup &
  restore (both flows), Manage tags, Wi-Fi sync (host and join), optical sync (send and
  receive).

## Translations — needs native-reader review

All Malayalam and Sanskrit strings below are AI drafts and need review by the translation
reviewer (Developer, Sreeraj P) before release. Least sure: network terms (host = ml ഹോസ്റ്റ്,
sa आतिथेयः; port = ml പോർട്ട്, sa द्वारसङ्ख्या; pairing code = ml ജോടിയാക്കൽ കോഡ്, sa
युग्मनसङ्केतः), optical-stream terms (stream, frame, chunk), "lockdown" (sa पूर्णावरोधः), and the
backup-tips bullet lists. Glossary gaps (not in the language pack): host, port, pairing code,
stream, frame, chunk, lockdown, auto-lock.

| Key | English | Malayalam | Sanskrit |
|---|---|---|---|
| `descAppLockEnabledPin` | App lock enabled with App PIN | ആപ്പ് PIN ഉപയോഗിച്ച് ആപ്പ് ലോക്ക് ഓണാക്കി | अनुप्रयोग-PIN सहितम् अनुप्रयोगतालकं सक्रियम् |
| `descAppLockEnabledPhone` | App lock enabled with phone screen lock | ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് ആപ്പ് ലോക്ക് ഓണാക്കി | दूरभाषपटलतालकेन अनुप्रयोगतालकं सक्रियम् |
| `titleDisableAppLock` | Disable app lock | ആപ്പ് ലോക്ക് ഓഫാക്കൽ | तालकनिष्क्रियीकरणम् |
| `descDisableAppLock` | Disabling app lock removes your App PIN, quick unlock preference, and recovery key. | ആപ്പ് ലോക്ക് ഓഫാക്കിയാൽ നിങ്ങളുടെ ആപ്പ് PIN, ദ്രുത തുറക്കൽ ക്രമീകരണം, വീണ്ടെടുക്കൽ കീ എന്നിവ നീക്കം ചെയ്യപ്പെടും. | अनुप्रयोगतालकस्य निष्क्रियीकरणेन भवतः अनुप्रयोग-PIN, शीघ्रोद्घाटनरुचिः, पुनःप्राप्तिकुञ्चिका च अपनीयन्ते। |
| `descAppLockDisabled` | App lock disabled | ആപ്പ് ലോക്ക് ഓഫാക്കി | अनुप्रयोगतालकं निष्क्रियम् |
| `titleChooseUnlockMethod` | Choose unlock method | തുറക്കൽ രീതി | उद्घाटनविधिचयनम् |
| `descChooseUnlockMethod` | Pick how you want to unlock the app. App PIN is more secure; phone screen lock is more convenient. | ആപ്പ് എങ്ങനെ തുറക്കണമെന്ന് തിരഞ്ഞെടുക്കുക. ആപ്പ് PIN കൂടുതൽ സുരക്ഷിതമാണ്; ഫോൺ സ്ക്രീൻ ലോക്ക് കൂടുതൽ സൗകര്യപ്രദമാണ്. | अनुप्रयोगः कथम् उद्घाटनीयः इति चीयताम्। अनुप्रयोग-PIN अधिकसुरक्षितम्; दूरभाषपटलतालकम् अधिकसुकरम्। |
| `actionPhoneLock` | Phone lock | ഫോൺ ലോക്ക് | दूरभाषतालकम् |
| `actionAppPin` | App PIN | ആപ്പ് PIN | अनुप्रयोग-PIN |
| `descAppPinEnabled` | App PIN enabled | ആപ്പ് PIN ഓണാക്കി | अनुप्रयोग-PIN सक्रियम् |
| `errorEnablePhoneLockFirst` | Enable phone screen lock first, or disable app lock instead. | ആദ്യം ഫോൺ സ്ക്രീൻ ലോക്ക് ഓണാക്കുക, അല്ലെങ്കിൽ ആപ്പ് ലോക്ക് ഓഫാക്കുക. | प्रथमं दूरभाषपटलतालकं सक्रियीक्रियताम्, अथवा अनुप्रयोगतालकं निष्क्रियीक्रियताम्। |
| `titleRemoveAppPin` | Remove App PIN | ആപ്പ് PIN നീക്കൽ | PIN-अपनयनम् |
| `descRemoveAppPin` | Your App PIN and recovery key will be deleted. You will unlock the app with phone screen lock only. | നിങ്ങളുടെ ആപ്പ് PIN-ഉം വീണ്ടെടുക്കൽ കീയും ഇല്ലാതാക്കും. ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് മാത്രമേ ആപ്പ് തുറക്കാനാകൂ. | भवतः अनुप्रयोग-PIN पुनःप्राप्तिकुञ्चिका च लुप्येते। अनुप्रयोगः केवलं दूरभाषपटलतालकेन उद्घाटयिष्यते। |
| `descAppPinRemoved` | App PIN removed | ആപ്പ് PIN നീക്കി | अनुप्रयोग-PIN अपनीतम् |
| `errorSetAppPinFirst` | Set an App PIN first, or disable app lock instead. | ആദ്യം ഒരു ആപ്പ് PIN സജ്ജമാക്കുക, അല്ലെങ്കിൽ ആപ്പ് ലോക്ക് ഓഫാക്കുക. | प्रथमम् अनुप्रयोग-PIN सज्जीक्रियताम्, अथवा अनुप्रयोगतालकं निष्क्रियीक्रियताम्। |
| `descQuickUnlockDisabled` | Phone screen lock quick unlock disabled | ഫോൺ സ്ക്രീൻ ലോക്ക് ദ്രുത തുറക്കൽ ഓഫാക്കി | दूरभाषपटलतालकेन शीघ्रोद्घाटनं निष्क्रियम् |
| `descQuickUnlockEnabled` | Phone screen lock quick unlock enabled | ഫോൺ സ്ക്രീൻ ലോക്ക് ദ്രുത തുറക്കൽ ഓണാക്കി | दूरभाषपटलतालकेन शीघ्रोद्घाटनं सक्रियम् |
| `descPhoneLockEnabled` | Phone screen lock enabled | ഫോൺ സ്ക്രീൻ ലോക്ക് ഓണാക്കി | दूरभाषपटलतालकं सक्रियम् |
| `titleAutoLockTimeout` | Auto-lock timeout | സ്വയം ലോക്ക് സമയം | स्वतालनकालः |
| `labelLockImmediately` | Immediately | ഉടൻ | तत्क्षणम् |
| `labelMinutesCount` | {minutes} min | {minutes} മിനിറ്റ് | {minutes} निमेषाः |
| `titleCurrentPin` | Current App PIN | നിലവിലെ ആപ്പ് PIN | वर्तमानम् अनुप्रयोग-PIN |
| `descAppPinChanged` | App PIN changed successfully | ആപ്പ് PIN വിജയകരമായി മാറ്റി | अनुप्रयोग-PIN सफलतया परिवर्तितम् |
| `titleSetAppPin` | Set App PIN | ആപ്പ് PIN സജ്ജീകരണം | PIN-सज्जीकरणम् |
| `titleChangeAppPin` | Change App PIN | ആപ്പ് PIN മാറ്റൽ | PIN-परिवर्तनम् |
| `descPinRequiredForProtection` | App PIN is required for app protection and all secret access. | ആപ്പ് സംരക്ഷണത്തിനും എല്ലാ രഹസ്യങ്ങളും കാണാനും ആപ്പ് PIN ആവശ്യമാണ്. | अनुप्रयोगरक्षणाय सर्वरहस्यप्रवेशाय च अनुप्रयोग-PIN आवश्यकम्। |
| `actionConfirm` | Confirm | സ്ഥിരീകരിക്കുക | स्थिरीक्रियताम् |
| `titleAppLockSection` | App lock | ആപ്പ് ലോക്ക് | अनुप्रयोगतालकम् |
| `titleAppPinSection` | App PIN | ആപ്പ് PIN | अनुप्रयोग-PIN |
| `titlePhoneLockSection` | Phone screen lock | ഫോൺ സ്ക്രീൻ ലോക്ക് | दूरभाषपटलतालकम् |
| `titleLockdownSection` | Lockdown | ലോക്ക്ഡൗൺ | पूर्णावरोधः |
| `descEnableAppLock` | Protect the app with your App PIN and optional phone screen lock quick unlock | ആപ്പ് PIN-ഉം ഐച്ഛികമായ ഫോൺ സ്ക്രീൻ ലോക്ക് ദ്രുത തുറക്കലും ഉപയോഗിച്ച് ആപ്പ് സംരക്ഷിക്കുക | अनुप्रयोग-PIN ऐच्छिकेन दूरभाषपटलतालकशीघ्रोद्घाटनेन च अनुप्रयोगः रक्ष्यताम् |
| `labelUseAppPin` | Use App PIN | ആപ്പ് PIN ഉപയോഗിക്കുക | PIN-प्रयोगः |
| `descAppPinIsSet` | App PIN is set | ആപ്പ് PIN സജ്ജമാണ് | अनुप्रयोग-PIN सज्जम् |
| `descSetPinHint` | Set a 4–6 digit PIN for app protection | ആപ്പ് സംരക്ഷണത്തിന് 4–6 അക്ക PIN സജ്ജമാക്കുക | अनुप्रयोगरक्षणाय 4–6 अङ्कात्मकं PIN सज्जीक्रियताम् |
| `descUpdateAppPin` | Update your App PIN | നിങ്ങളുടെ ആപ്പ് PIN പുതുക്കുക | अनुप्रयोग-PIN नवीक्रियताम् |
| `labelResetRecoveryKey` | Reset recovery key | വീണ്ടെടുക്കൽ കീ പുതുക്കൽ | कुञ्चिकानवीकरणम् |
| `descResetRecoveryKey` | Generate a new recovery key for your App PIN | നിങ്ങളുടെ ആപ്പ് PIN-ന് പുതിയ വീണ്ടെടുക്കൽ കീ സൃഷ്ടിക്കുക | अनुप्रयोग-PIN कृते नूतना पुनःप्राप्तिकुञ्चिका रच्यताम् |
| `labelUsePhoneLock` | Use phone lock | ഫോൺ ലോക്ക് ഉപയോഗം | दूरभाषतालकप्रयोगः |
| `descPhoneLockOptional` | Optional quick unlock for opening the app | ആപ്പ് തുറക്കാനുള്ള ഐച്ഛിക ദ്രുത മാർഗ്ഗം | अनुप्रयोगोद्घाटनाय ऐच्छिकं शीघ्रोद्घाटनम् |
| `descPhoneLockOnly` | Unlock the app with your phone screen lock | ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് ആപ്പ് തുറക്കുക | दूरभाषपटलतालकेन अनुप्रयोगः उद्घाट्यताम् |
| `labelLockdownMode` | Lockdown mode | ലോക്ക്ഡൗൺ മോഡ് | पूर्णावरोधविधिः |
| `descLockdownMode` | Disable quick unlock and require your App PIN until you turn this off | ഇത് ഓഫാക്കുന്നത് വരെ ദ്രുത തുറക്കൽ ഒഴിവാക്കി ആപ്പ് PIN ആവശ്യപ്പെടുക | एतत् यावत् न निष्क्रियीक्रियते तावत् शीघ्रोद्घाटनं निरुध्य अनुप्रयोग-PIN याच्यताम् |
| `descInfoPhoneOptional` | Phone screen lock is optional quick unlock. App PIN is required for revealing secrets. | ഫോൺ സ്ക്രീൻ ലോക്ക് ഐച്ഛികമായ ദ്രുത തുറക്കലാണ്. രഹസ്യങ്ങൾ കാണാൻ ആപ്പ് PIN ആവശ്യമാണ്. | दूरभाषपटलतालकम् ऐच्छिकं शीघ्रोद्घाटनम्। रहस्यप्रकाशनाय अनुप्रयोग-PIN आवश्यकम्। |
| `descInfoPhoneOnly` | Phone screen lock is your only unlock method. Set an App PIN for stronger protection. | ഫോൺ സ്ക്രീൻ ലോക്ക് മാത്രമാണ് നിങ്ങളുടെ തുറക്കൽ മാർഗ്ഗം. കൂടുതൽ സംരക്ഷണത്തിന് ഒരു ആപ്പ് PIN സജ്ജമാക്കുക. | दूरभाषपटलतालकम् एव भवतः एकमात्रः उद्घाटनोपायः। दृढतररक्षणाय अनुप्रयोग-PIN सज्जीक्रियताम्। |
| `descInfoPhoneLockTypes` | Phone screen lock may use fingerprint, face, pattern, PIN, or password depending on your device. | നിങ്ങളുടെ ഉപകരണം അനുസരിച്ച് ഫോൺ സ്ക്രീൻ ലോക്ക് വിരലടയാളം, മുഖം, പാറ്റേൺ, PIN, രഹസ്യവാക്ക് എന്നിവ ഉപയോഗിച്ചേക്കാം. | उपकरणानुसारं दूरभाषपटलतालकम् अङ्गुलिमुद्रां, मुखं, रेखाचित्रं, PIN, गुप्तशब्दं वा प्रयुङ्क्ते। |
| `descFinishPinSetup` | Finish your one-time App PIN setup from the lock screen before using the app normally. | ആപ്പ് സാധാരണ ഉപയോഗിക്കുന്നതിന് മുമ്പ് ലോക്ക് സ്ക്രീനിൽ നിന്ന് ഒറ്റത്തവണ ആപ്പ് PIN സജ്ജീകരണം പൂർത്തിയാക്കുക. | अनुप्रयोगस्य सामान्यप्रयोगात् पूर्वं तालकपटलात् एकवारिकम् अनुप्रयोग-PIN सज्जीकरणं समाप्यताम्। |
| `titleSetBackupPassword` | Set backup password | കരുതൽ രഹസ്യവാക്ക് | प्रतिलिपिगुप्तशब्दः |
| `descSetBackupPassword` | Create a strong password to encrypt your backup. You will need this password to restore your accounts. | കരുതൽ ഫയൽ സംരക്ഷിക്കാൻ ശക്തമായ ഒരു രഹസ്യവാക്ക് സൃഷ്ടിക്കുക. അക്കൗണ്ടുകൾ പുനഃസ്ഥാപിക്കാൻ ഈ രഹസ്യവാക്ക് ആവശ്യമാണ്. | प्रतिलिपेः गूढलेखनाय दृढः गुप्तशब्दः रच्यताम्। विवरणानां पुनःस्थापनाय अयं गुप्तशब्दः आवश्यकः। |
| `descPasswordMin8` | Minimum 8 characters | കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ | न्यूनातिन्यूनम् अष्ट अक्षराणि |
| `errorPasswordEmpty` | Password cannot be empty | രഹസ്യവാക്ക് ശൂന്യമാകരുത് | गुप्तशब्दः रिक्तः न भवेत् |
| `errorPasswordTooShort8` | Password must be at least 8 characters | രഹസ്യവാക്കിന് കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ വേണം | गुप्तशब्दे न्यूनातिन्यूनम् अष्ट अक्षराणि भवेयुः |
| `actionCreateBackup` | Create backup | കരുതൽ സൃഷ്ടിക്കുക | प्रतिलिपिः रच्यताम् |
| `errorNoAccountsToBackup` | No accounts to back up | കരുതലിന് അക്കൗണ്ടുകളില്ല | प्रतिलिपये विवरणानि न सन्ति |
| `descBackupCreated` | Encrypted backup created successfully | എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ വിജയകരമായി സൃഷ്ടിച്ചു | गूढलेखिता प्रतिलिपिः सफलतया रचिता |
| `errorBackupCanceledOrFailed` | Backup canceled or failed | കരുതൽ റദ്ദാക്കി അല്ലെങ്കിൽ പരാജയപ്പെട്ടു | प्रतिलिपिः निरस्ता असफला वा |
| `errorBackupFailed` | Could not create the backup. Please try again. | കരുതൽ സൃഷ്ടിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക. | प्रतिलिपिं रचयितुं न शक्तम्। पुनः प्रयत्यताम्। |
| `titleRestoreAccounts` | Restore accounts | അക്കൗണ്ട് പുനഃസ്ഥാപനം | विवरणपुनःस्थापनम् |
| `descRestoreAccounts` | Import accounts from an encrypted backup file. Existing accounts will not be affected. | എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഫയലിൽ നിന്ന് അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യുക. നിലവിലെ അക്കൗണ്ടുകളെ ഇത് ബാധിക്കില്ല. | गूढलेखितप्रतिलिपिसञ्चिकातः विवरणानि आनीयन्ताम्। विद्यमानविवरणेषु प्रभावः न भविष्यति। |
| `titleEnterBackupPassword` | Backup password | കരുതൽ രഹസ്യവാക്ക് | प्रतिलिपिगुप्तशब्दः |
| `descEnterBackupPassword` | Enter the password you used when creating this backup: | ഈ കരുതൽ സൃഷ്ടിക്കുമ്പോൾ ഉപയോഗിച്ച രഹസ്യവാക്ക് നൽകുക: | अस्याः प्रतिलिपेः रचनाकाले प्रयुक्तः गुप्तशब्दः दीयताम्: |
| `actionRestore` | Restore | പുനഃസ്ഥാപിക്കുക | पुनःस्थाप्यताम् |
| `errorNoDataImported` | No data imported. Check your password and try again. | ഒന്നും ഇറക്കുമതി ചെയ്തില്ല. രഹസ്യവാക്ക് പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക. | न किमपि आनीतम्। गुप्तशब्दं परीक्ष्य पुनः प्रयत्यताम्। |
| `errorNoAccountsInBackup` | No accounts found in backup. Check your password and try again. | കരുതലിൽ അക്കൗണ്ടുകളൊന്നുമില്ല. രഹസ്യവാക്ക് പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക. | प्रतिलिपौ न किमपि विवरणं प्राप्तम्। गुप्तशब्दं परीक्ष्य पुनः प्रयत्यताम्। |
| `descAccountsRestored` | Accounts restored: {count} | പുനഃസ്ഥാപിച്ച അക്കൗണ്ടുകൾ: {count} | पुनःस्थापितानि विवरणानि: {count} |
| `errorRestoreFailed` | Could not restore the backup. Please try again. | കരുതൽ പുനഃസ്ഥാപിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക. | प्रतिलिपिं पुनःस्थापयितुं न शक्तम्। पुनः प्रयत्यताम्। |
| `titleBackupCreated` | Backup created | കരുതൽ സൃഷ്ടിച്ചു | प्रतिलिपिः रचिता |
| `descBackupSaved` | Your encrypted backup has been saved successfully. | നിങ്ങളുടെ എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ വിജയകരമായി സൂക്ഷിച്ചു. | भवतः गूढलेखिता प्रतिलिपिः सफलतया रक्षिता। |
| `titleImportant` | Important: | പ്രധാനം: | मुख्यम्: |
| `descBackupTips` | • Store your backup file in a safe location<br>• Remember your backup password<br>• Without the password, you cannot restore | • കരുതൽ ഫയൽ സുരക്ഷിതമായ സ്ഥലത്ത് സൂക്ഷിക്കുക<br>• കരുതൽ രഹസ്യവാക്ക് ഓർമ്മിക്കുക<br>• രഹസ്യവാക്ക് ഇല്ലാതെ പുനഃസ്ഥാപിക്കാനാവില്ല | • प्रतिलिपिसञ्चिका सुरक्षिते स्थाने रक्ष्यताम्<br>• प्रतिलिपिगुप्तशब्दः स्मर्यताम्<br>• गुप्तशब्दं विना पुनःस्थापनं न शक्यम् |
| `actionGotIt` | Got it | ശരി | अवगतम् |
| `actionContinue` | Continue | തുടരുക | अनुवर्त्यताम् |
| `descBackupsEncrypted` | All backups are encrypted with a password for maximum security | പരമാവധി സുരക്ഷയ്ക്കായി എല്ലാ കരുതലുകളും രഹസ്യവാക്ക് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുന്നു | परमसुरक्षायै सर्वाः प्रतिलिपयः गुप्तशब्देन गूढलेखिताः |
| `titleCreateBackupSection` | Create backup | കരുതൽ സൃഷ്ടിക്കൽ | प्रतिलिपिरचना |
| `labelCreateEncryptedBackup` | Create backup file | എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ | गूढलेखिता प्रतिलिपिः |
| `descCreateEncryptedBackup` | Export all accounts with password protection | രഹസ്യവാക്ക് സംരക്ഷണത്തോടെ എല്ലാ അക്കൗണ്ടുകളും കയറ്റുമതി ചെയ്യുക | गुप्तशब्दरक्षया सर्वाणि विवरणानि निर्याप्यन्ताम् |
| `titleRestoreBackupSection` | Restore backup | കരുതൽ പുനഃസ്ഥാപനം | प्रतिलिपिपुनःस्थापनम् |
| `labelRestoreFromBackup` | Restore from backup | കരുതലിൽ നിന്ന് പുനഃസ്ഥാപിക്കൽ | प्रतिलिपेः पुनःस्थापनम् |
| `descRestoreFromBackup` | Import accounts from encrypted backup file | എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഫയലിൽ നിന്ന് അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യുക | गूढलेखितप्रतिलिपिसञ्चिकातः विवरणानि आनीयन्ताम् |
| `titleBestPractices` | Best practices | മികച്ച രീതികൾ | उत्तमाचाराः |
| `descBestPractices` | • Create backups regularly<br>• Use a strong, unique password<br>• Store backups in multiple secure locations<br>• Keep your password in a password manager<br>• Test your backups by restoring them | • പതിവായി കരുതലുകൾ സൃഷ്ടിക്കുക<br>• ശക്തവും അനന്യവുമായ രഹസ്യവാക്ക് ഉപയോഗിക്കുക<br>• കരുതലുകൾ പല സുരക്ഷിത സ്ഥലങ്ങളിൽ സൂക്ഷിക്കുക<br>• രഹസ്യവാക്ക് ഒരു രഹസ്യവാക്ക് സൂക്ഷിപ്പുകാരനിൽ വയ്ക്കുക<br>• പുനഃസ്ഥാപിച്ച് കരുതലുകൾ പരീക്ഷിക്കുക | • नियमितं प्रतिलिपयः रच्यन्ताम्<br>• दृढः अनन्यः गुप्तशब्दः प्रयुज्यताम्<br>• प्रतिलिपयः बहुषु सुरक्षितस्थानेषु रक्ष्यन्ताम्<br>• गुप्तशब्दः गुप्तशब्दप्रबन्धके रक्ष्यताम्<br>• पुनःस्थापनेन प्रतिलिपयः परीक्ष्यन्ताम् |
| `descNeverShareBackups` | Never share your backup files or passwords. Anyone with access to both can generate your authentication codes. | കരുതൽ ഫയലുകളോ രഹസ്യവാക്കുകളോ ഒരിക്കലും പങ്കിടരുത്. രണ്ടും ലഭിക്കുന്ന ആർക്കും നിങ്ങളുടെ പ്രാമാണീകരണ കോഡുകൾ സൃഷ്ടിക്കാനാകും. | प्रतिलिपिसञ्चिकाः गुप्तशब्दान् वा कदापि मा वितरतु। उभयं प्राप्तवान् कोऽपि भवतः प्रमाणीकरणसङ्केतान् रचयितुं शक्नोति। |
| `titleRenameTag` | Rename tag | അടയാളം പുനർനാമകരണം | चिह्ननामपरिवर्तनम् |
| `labelTagName` | Tag name | അടയാളത്തിന്റെ പേര് | चिह्ननाम |
| `descTagNameExample` | e.g. Work, Personal | ഉദാ. ജോലി, വ്യക്തിപരം | यथा कार्यम्, व्यक्तिगतम् |
| `errorTagNameEmpty` | Please enter a tag name | ദയവായി അടയാളത്തിന്റെ പേര് നൽകുക | चिह्ननाम दीयताम् |
| `errorTagNameSame` | New tag name must be different | പുതിയ പേര് വ്യത്യസ്തമായിരിക്കണം | नूतनं नाम भिन्नं भवेत् |
| `actionRename` | Rename | പേര് മാറ്റുക | नाम परिवर्त्यताम् |
| `descTagRenamed` | Renamed #{oldTag} to #{newTag} | #{oldTag} എന്നത് #{newTag} എന്നാക്കി | #{oldTag} इति #{newTag} इति परिवर्तितम् |
| `errorRenameTagFailed` | Could not rename the tag. Please try again. | അടയാളത്തിന്റെ പേര് മാറ്റാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക. | चिह्ननाम परिवर्तयितुं न शक्तम्। पुनः प्रयत्यताम्। |
| `titleDeleteTag` | Delete tag | അടയാളം ഇല്ലാതാക്കൽ | चिह्नलोपः |
| `descDeleteTagUsed` | Remove tag "#{tag}" from {count} accounts? | {count} അക്കൗണ്ടുകളിൽ നിന്ന് "#{tag}" നീക്കണോ? | {count} विवरणेभ्यः "#{tag}" अपनेतव्यं वा? |
| `descDeleteTagUnused` | Delete unused tag "#{tag}"? | ഉപയോഗിക്കാത്ത "#{tag}" ഇല്ലാതാക്കണോ? | अप्रयुक्तं "#{tag}" लोप्तव्यं वा? |
| `descTagDeleted` | Deleted tag #{tag} | #{tag} ഇല്ലാതാക്കി | #{tag} लुप्तम् |
| `errorDeleteTagFailed` | Could not delete the tag. Please try again. | അടയാളം ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക. | चिह्नं लोप्तुं न शक्तम्। पुनः प्रयत्यताम्। |
| `labelTotalTags` | Total tags | ആകെ അടയാളങ്ങൾ | सर्वचिह्नसङ्ख्या |
| `labelAccountsTagged` | Accounts tagged | അടയാളമുള്ള അക്കൗണ്ടുകൾ | चिह्नितविवरणानि |
| `emptyNoTagsFound` | No tags found | അടയാളങ്ങളൊന്നുമില്ല | न किमपि चिह्नं प्राप्तम् |
| `emptyTagsAppearHere` | Tags added to accounts will appear here | അക്കൗണ്ടുകളിൽ ചേർത്ത അടയാളങ്ങൾ ഇവിടെ കാണാം | विवरणेषु योजितानि चिह्नानि अत्र दृश्यन्ते |
| `emptyTryDifferentQuery` | Try a different search query | മറ്റൊരു തിരയൽ ശ്രമിക്കുക | अन्यत् अन्वेषणं प्रयत्यताम् |
| `labelAccountCount` | Accounts: {count} | അക്കൗണ്ടുകൾ: {count} | विवरणानि: {count} |
| `tooltipRenameTag` | Rename tag | പേര് മാറ്റുക | नाम परिवर्त्यताम् |
| `tooltipDeleteTag` | Delete tag | ഇല്ലാതാക്കുക | लुप्यताम् |
| `errorSyncHostTimeout` | No device connected in time; hosting stopped. | സമയത്തിനുള്ളിൽ ഒരു ഉപകരണവും ബന്ധിപ്പിച്ചില്ല; ഹോസ്റ്റിംഗ് നിർത്തി. | काले किमपि उपकरणं न संयुक्तम्; आतिथ्यं स्थगितम्। |
| `errorSyncHostStartFailed` | Could not start hosting. Check that Wi-Fi is on. | ഹോസ്റ്റിംഗ് ആരംഭിക്കാൻ കഴിഞ്ഞില്ല. Wi-Fi ഓണാണെന്ന് ഉറപ്പാക്കുക. | आतिथ्यम् आरब्धुं न शक्तम्। Wi-Fi सक्रियम् इति परीक्ष्यताम्। |
| `errorSyncNoDevice` | No device is connected to sync with. | സമന്വയിപ്പിക്കാൻ ഒരു ഉപകരണവും ബന്ധിപ്പിച്ചിട്ടില്ല. | समन्वयाय किमपि उपकरणं न संयुक्तम्। |
| `errorSyncNothingSelected` | Select at least one item to sync. | സമന്വയിപ്പിക്കാൻ കുറഞ്ഞത് ഒന്ന് തിരഞ്ഞെടുക്കുക. | समन्वयाय न्यूनातिन्यूनम् एकं चीयताम्। |
| `errorSyncFailed` | Sync failed. Please try again. | സമന്വയം പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക. | समन्वयः असफलः। पुनः प्रयत्यताम्। |
| `errorOpticalStartFailed` | Could not start the optical stream. | ഒപ്റ്റിക്കൽ സ്ട്രീം ആരംഭിക്കാൻ കഴിഞ്ഞില്ല. | प्रकाशीयप्रवाहम् आरब्धुं न शक्तम्। |
| `errorOpticalDecodeFailed` | Could not read the optical stream. | ഒപ്റ്റിക്കൽ സ്ട്രീം വായിക്കാൻ കഴിഞ്ഞില്ല. | प्रकाशीयप्रवाहं पठितुं न शक्तम्। |
| `errorSyncNotSyncQr` | This is not a sync QR code. | ഇത് ഒരു സമന്വയ QR കോഡ് അല്ല. | अयं समन्वय-QR-सङ्केतः न। |
| `errorSyncUnsupportedVersion` | This sync QR code is from a different app version. | ഈ സമന്വയ QR കോഡ് മറ്റൊരു ആപ്പ് പതിപ്പിൽ നിന്നുള്ളതാണ്. | अयं समन्वय-QR-सङ्केतः भिन्नसंस्करणात् आगतः। |
| `errorSyncMissingHost` | The sync QR code has no host address. | സമന്വയ QR കോഡിൽ ഹോസ്റ്റ് വിലാസമില്ല. | समन्वय-QR-सङ्केते आतिथेयसङ्केतः नास्ति। |
| `errorSyncInvalidPort` | The sync QR code has an invalid port. | സമന്വയ QR കോഡിലെ പോർട്ട് അസാധുവാണ്. | समन्वय-QR-सङ्केते द्वारसङ्ख्या अमान्या। |
| `errorSyncMissingCode` | The sync QR code has no pairing code. | സമന്വയ QR കോഡിൽ ജോടിയാക്കൽ കോഡില്ല. | समन्वय-QR-सङ्केते युग्मनसङ्केतः नास्ति। |
| `errorSyncMalformed` | The other device sent data this app cannot read. | മറ്റേ ഉപകരണം അയച്ച വിവരങ്ങൾ ഈ ആപ്പിന് വായിക്കാനാവില്ല. | अपरेण उपकरणेन प्रेषितः दत्तांशः अनेन अनुप्रयोगेण पठितुं न शक्यः। |
| `errorSyncTooManyAccounts` | The other device sent too many accounts. | മറ്റേ ഉപകരണം വളരെയധികം അക്കൗണ്ടുകൾ അയച്ചു. | अपरेण उपकरणेन अत्यधिकानि विवरणानि प्रेषितानि। |
| `errorSyncFieldTooLarge` | The other device sent a value that is too large. | മറ്റേ ഉപകരണം വളരെ വലിയ ഒരു മൂല്യം അയച്ചു. | अपरेण उपकरणेन अतिबृहत् मूल्यं प्रेषितम्। |
| `errorSyncPeerGone` | The other device is no longer connected. | മറ്റേ ഉപകരണം ഇപ്പോൾ ബന്ധിപ്പിച്ചിട്ടില്ല. | अपरम् उपकरणम् इदानीं न संयुक्तम्। |
| `errorSyncSendFailed` | Could not send the data. | വിവരങ്ങൾ അയയ്ക്കാൻ കഴിഞ്ഞില്ല. | दत्तांशं प्रेषयितुं न शक्तम्। |
| `errorSyncNoResponse` | No response from the other device. | മറ്റേ ഉപകരണത്തിൽ നിന്ന് മറുപടിയില്ല. | अपरस्मात् उपकरणात् प्रत्युत्तरं नास्ति। |
| `errorSyncInvalidResponse` | Unexpected response from the other device. | മറ്റേ ഉപകരണത്തിൽ നിന്ന് അപ്രതീക്ഷിത മറുപടി. | अपरस्मात् उपकरणात् अप्रत्याशितं प्रत्युत्तरम्। |
| `errorSyncConnectionClosed` | The other device closed the connection. | മറ്റേ ഉപകരണം ബന്ധം അവസാനിപ്പിച്ചു. | अपरेण उपकरणेन सम्बन्धः समापितः। |
| `errorSyncWrongCode` | Incorrect pairing code. | തെറ്റായ ജോടിയാക്കൽ കോഡ്. | अशुद्धः युग्मनसङ्केतः। |
| `errorSyncTimedOut` | The connection timed out. | ബന്ധത്തിന്റെ സമയപരിധി കഴിഞ്ഞു. | सम्बन्धस्य कालसीमा अतीता। |
| `errorSyncConnectFailed` | Could not connect to the other device. Check the IP address, port and Wi-Fi. | മറ്റേ ഉപകരണവുമായി ബന്ധിപ്പിക്കാൻ കഴിഞ്ഞില്ല. IP വിലാസം, പോർട്ട്, Wi-Fi എന്നിവ പരിശോധിക്കുക. | अपरेण उपकरणेन सह संयोक्तुं न शक्तम्। IP-सङ्केतः, द्वारसङ्ख्या, Wi-Fi च परीक्ष्यन्ताम्। |
| `errorSyncConnectionError` | Connection error. | ബന്ധത്തിൽ പിശക്. | सम्बन्धदोषः। |
| `errorOpticalInvalidFrame` | This is not an optical sync code. | ഇത് ഒരു ഒപ്റ്റിക്കൽ സമന്വയ കോഡ് അല്ല. | अयं प्रकाशीयसमन्वयसङ्केतः न। |
| `errorOpticalUnsupportedVersion` | This optical sync code is from a different app version. | ഈ ഒപ്റ്റിക്കൽ കോഡ് മറ്റൊരു ആപ്പ് പതിപ്പിൽ നിന്നുള്ളതാണ്. | अयं प्रकाशीयसङ्केतः भिन्नसंस्करणात् आगतः। |
| `errorOpticalCorruptedChunk` | A frame was damaged. Keep the camera steady. | ഒരു ഫ്രെയിം കേടായി. ക്യാമറ സ്ഥിരമായി പിടിക്കുക. | एकं चित्रखण्डं दूषितम्। छायाग्राहकं स्थिरं ध्रियताम्। |
| `errorOpticalChecksum` | A frame failed its check. Keep the camera steady. | ഒരു ഫ്രെയിം പരിശോധനയിൽ പരാജയപ്പെട്ടു. ക്യാമറ സ്ഥിരമായി പിടിക്കുക. | एकं चित्रखण्डं परीक्षायाम् असफलम्। छायाग्राहकं स्थिरं ध्रियताम्। |
| `errorOpticalEmpty` | There is nothing to send. | അയയ്ക്കാൻ ഒന്നുമില്ല. | प्रेषणाय किमपि नास्ति। |
| `errorOpticalIncomplete` | Not all frames were received. | എല്ലാ ഫ്രെയിമുകളും ലഭിച്ചില്ല. | सर्वाणि चित्रखण्डानि न प्राप्तानि। |
| `errorOpticalIntegrity` | The received data failed its integrity check. | ലഭിച്ച വിവരങ്ങൾ സമഗ്രതാ പരിശോധനയിൽ പരാജയപ്പെട്ടു. | प्राप्तः दत्तांशः अखण्डतापरीक्षायाम् असफलः। |
| `errorEnterHostIp` | Enter the host IP address | ഹോസ്റ്റ് IP വിലാസം നൽകുക | आतिथेय-IP-सङ्केतः दीयताम् |
| `errorEnterPort` | Enter the port shown on the other device | മറ്റേ ഉപകരണത്തിൽ കാണുന്ന പോർട്ട് നൽകുക | अपरस्मिन् उपकरणे दृश्यमाना द्वारसङ्ख्या दीयताम् |
| `errorEnterPairingCode` | Enter the pairing code | ജോടിയാക്കൽ കോഡ് നൽകുക | युग्मनसङ्केतः दीयताम् |
| `titleSendToDevice` | Send to device | ഉപകരണത്തിലേക്ക് അയയ്ക്കൽ | उपकरणं प्रति प्रेषणम् |
| `descConnectingToHost` | Connecting to host… | ഹോസ്റ്റുമായി ബന്ധിപ്പിക്കുന്നു… | आतिथेयेन सह संयुज्यते… |
| `descReceiving` | Receiving… | സ്വീകരിക്കുന്നു… | स्वीक्रियते… |
| `descP2pInfo` | Wi-Fi sync: both devices on the same Wi-Fi or hotspot. The pairing code never leaves your device. | Wi-Fi സമന്വയം: രണ്ട് ഉപകരണങ്ങളും ഒരേ Wi-Fi-ലോ ഹോട്ട്സ്പോട്ടിലോ ആയിരിക്കണം. ജോടിയാക്കൽ കോഡ് ഒരിക്കലും നിങ്ങളുടെ ഉപകരണം വിട്ടുപോകില്ല. | Wi-Fi-समन्वयः: उभे उपकरणे एकस्मिन् एव Wi-Fi-जाले भवेताम्। युग्मनसङ्केतः कदापि भवतः उपकरणात् बहिः न गच्छति। |
| `labelSendOverWifi` | Send over Wi-Fi | Wi-Fi വഴി അയയ്ക്കുക | Wi-Fi-द्वारेण प्रेषणम् |
| `descSendOverWifi` | Host: share your accounts and settings over local Wi-Fi | ഹോസ്റ്റ്: പ്രാദേശിക Wi-Fi വഴി അക്കൗണ്ടുകളും ക്രമീകരണങ്ങളും പങ്കിടുക | आतिथेयः: स्थानीय-Wi-Fi-द्वारेण विवरणानि विन्यासं च वितीर्यताम् |
| `labelReceiveOverWifi` | Receive over Wi-Fi | Wi-Fi വഴി സ്വീകരിക്കുക | Wi-Fi-द्वारेण स्वीकारः |
| `descReceiveOverWifi` | Join: scan the host QR or enter host IP | ചേരുക: ഹോസ്റ്റ് QR സ്കാൻ ചെയ്യുക അല്ലെങ്കിൽ ഹോസ്റ്റ് IP നൽകുക | संयोगः: आतिथेय-QR अवलोक्यताम् अथवा आतिथेय-IP दीयताम् |
| `descOpticalSectionHeader` | Optical air-gap sync (no Wi-Fi, no network) | ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് സമന്വയം (Wi-Fi ഇല്ല, നെറ്റ്‌വർക്ക് ഇല്ല) | प्रकाशीयवायुविच्छेदसमन्वयः (Wi-Fi न, जालं न) |
| `labelOpticalSend` | Send optical stream | ഒപ്റ്റിക്കൽ സ്ട്രീം അയയ്ക്കുക | प्रकाशीयप्रवाहप्रेषणम् |
| `descOpticalSend` | Transmit your accounts as an animated QR stream (12–15 FPS) | അക്കൗണ്ടുകൾ ചലിക്കുന്ന QR സ്ട്രീമായി അയയ്ക്കുക (12–15 FPS) | विवरणानि चलत्-QR-प्रवाहरूपेण प्रेष्यन्ताम् (12–15 FPS) |
| `labelOpticalReceive` | Scan optical stream | ഒപ്റ്റിക്കൽ സ്ട്രീം സ്കാൻ | प्रकाशीयप्रवाहावलोकनम् |
| `descOpticalReceive` | Capture an animated QR stream with the camera | ക്യാമറ ഉപയോഗിച്ച് ചലിക്കുന്ന QR സ്ട്രീം പകർത്തുക | छायाग्राहकेण चलत्-QR-प्रवाहः गृह्यताम् |
| `descScanOtherQrHeader` | Scan the QR on the other device | മറ്റേ ഉപകരണത്തിലെ QR സ്കാൻ ചെയ്യുക | अपरस्मिन् उपकरणे स्थितम् QR अवलोक्यताम् |
| `actionScanQrCode` | Scan QR code | QR സ്കാൻ ചെയ്യുക | QR अवलोक्यताम् |
| `labelOrEnterManually` | or enter manually | അല്ലെങ്കിൽ സ്വയം നൽകുക | अथवा स्वयं दीयताम् |
| `labelHostIp` | Host IP address | ഹോസ്റ്റ് IP വിലാസം | आतिथेय-IP-सङ्केतः |
| `labelPort` | Port | പോർട്ട് | द्वारसङ्ख्या |
| `labelPairingCode` | Pairing code | ജോടിയാക്കൽ കോഡ് | युग्मनसङ्केतः |
| `actionConnectReceive` | Connect & receive | ബന്ധിപ്പിച്ച് സ്വീകരിക്കുക | संयुज्य स्वीक्रियताम् |
| `actionBack` | Back | പിന്നോട്ട് | प्रत्यागमनम् |
| `titleConnected` | Connected | ബന്ധിപ്പിച്ചു | संयुक्तम् |
| `descWaitingForSender` | Waiting for the sender to choose what to share… | എന്ത് പങ്കിടണമെന്ന് അയയ്ക്കുന്നയാൾ തിരഞ്ഞെടുക്കുന്നതിനായി കാത്തിരിക്കുന്നു… | किं वितरणीयम् इति प्रेषकस्य चयनं प्रतीक्ष्यते… |
| `titleSyncComplete` | Sync complete | സമന്വയം പൂർത്തിയായി | समन्वयः समाप्तः |
| `descSentAccounts` | Accounts sent: {count} | അയച്ച അക്കൗണ്ടുകൾ: {count} | प्रेषितानि विवरणानि: {count} |
| `descSentSettings` | Settings sent: {count} | അയച്ച ക്രമീകരണങ്ങൾ: {count} | प्रेषिताः विन्यासाः: {count} |
| `descAddedAccounts` | Accounts added: {count} | ചേർത്ത അക്കൗണ്ടുകൾ: {count} | योजितानि विवरणानि: {count} |
| `descAddedAccountsSkipped` | Accounts added: {count} ({skipped} already present, kept) | ചേർത്ത അക്കൗണ്ടുകൾ: {count} ({skipped} എണ്ണം നേരത്തെ ഉണ്ടായിരുന്നു, നിലനിർത്തി) | योजितानि विवरणानि: {count} ({skipped} पूर्वमेव विद्यमानानि, रक्षितानि) |
| `descAppliedSettings` | Settings applied: {count} | പ്രയോഗിച്ച ക്രമീകരണങ്ങൾ: {count} | प्रयुक्ताः विन्यासाः: {count} |
| `descNothingToSync` | Nothing to sync. | സമന്വയിപ്പിക്കാൻ ഒന്നുമില്ല. | समन्वयाय किमपि नास्ति। |
| `titleSyncFailed` | Sync failed | സമന്വയം പരാജയപ്പെട്ടു | समन्वयः असफलः |
| `tabServerDetails` | Server details | സെർവർ വിവരങ്ങൾ | सेवकविवरणम् |
| `tabSync` | Sync | സമന്വയം | समन्वयः |
| `descReceiveHint` | On the other device, choose “Receive over Wi-Fi” → “Scan QR code” | മറ്റേ ഉപകരണത്തിൽ “Wi-Fi വഴി സ്വീകരിക്കുക” → “QR സ്കാൻ ചെയ്യുക” തിരഞ്ഞെടുക്കുക | अपरस्मिन् उपकरणे “Wi-Fi-द्वारेण स्वीकारः” → “QR अवलोक्यताम्” चीयताम् |
| `descEnterManuallyHint` | Or enter these manually | അല്ലെങ്കിൽ ഇവ സ്വയം നൽകുക | अथवा एतानि स्वयं दीयन्ताम् |
| `labelHostIpShort` | Host IP | ഹോസ്റ്റ് IP | आतिथेय-IP |
| `actionCopyCode` | Copy code | കോഡ് പകർത്തുക | सङ्केतः प्रतिलिख्यताम् |
| `descPairingCodeCopied` | Pairing code copied | ജോടിയാക്കൽ കോഡ് പകർത്തി | युग्मनसङ्केतः प्रतिलिखितः |
| `actionStopHosting` | Stop hosting | ഹോസ്റ്റിംഗ് നിർത്തുക | आतिथ्यं स्थग्यताम् |
| `descClientConnected` | A device is connected. Open the Sync tab to choose what to share. | ഒരു ഉപകരണം ബന്ധിപ്പിച്ചു. എന്ത് പങ്കിടണമെന്ന് തിരഞ്ഞെടുക്കാൻ സമന്വയം ടാബ് തുറക്കുക. | एकम् उपकरणं संयुक्तम्। किं वितरणीयम् इति चेतुं समन्वयपृष्ठम् उद्घाट्यताम्। |
| `descWaitingForClient` | Waiting for the other device to connect… | മറ്റേ ഉപകരണം ബന്ധിപ്പിക്കുന്നതിനായി കാത്തിരിക്കുന്നു… | अपरस्य उपकरणस्य संयोगः प्रतीक्ष्यते… |
| `descNoClientYet` | No device is connected yet. Open the Server details tab and let the other device scan the QR or enter the code. | ഇതുവരെ ഒരു ഉപകരണവും ബന്ധിപ്പിച്ചിട്ടില്ല. സെർവർ വിവരങ്ങൾ ടാബ് തുറന്ന് മറ്റേ ഉപകരണത്തിൽ QR സ്കാൻ ചെയ്യുകയോ കോഡ് നൽകുകയോ ചെയ്യുക. | अद्यापि किमपि उपकरणं न संयुक्तम्। सेवकविवरणपृष्ठम् उद्घाट्य अपरेण उपकरणेन QR अवलोक्यताम् सङ्केतः वा दीयताम्। |
| `titleNewClientPhone` | New phone | പുതിയ ഫോൺ | नूतनदूरभाषः |
| `descFullSync` | Send everything — all accounts and app settings — to a phone that is setting up for the first time. Device-specific items (app lock, PIN, phone-lock unlock, recovery key) are not sent. | ആദ്യമായി സജ്ജീകരിക്കുന്ന ഫോണിലേക്ക് എല്ലാം — എല്ലാ അക്കൗണ്ടുകളും ആപ്പ് ക്രമീകരണങ്ങളും — അയയ്ക്കുക. ഉപകരണത്തിന് മാത്രമുള്ളവ (ആപ്പ് ലോക്ക്, PIN, ഫോൺ ലോക്ക്, വീണ്ടെടുക്കൽ കീ) അയയ്ക്കില്ല. | प्रथमवारं सज्जीक्रियमाणं दूरभाषं प्रति सर्वं — सर्वाणि विवरणानि अनुप्रयोगविन्यासाः च — प्रेष्यताम्। उपकरणविशिष्टानि (अनुप्रयोगतालकं, PIN, दूरभाषतालकं, पुनःप्राप्तिकुञ्चिका) न प्रेष्यन्ते। |
| `actionFullSync` | Full sync | പൂർണ്ണ സമന്വയം | पूर्णसमन्वयः |
| `titleSyncToPhone` | Sync to a phone | ഒരു ഫോണിലേക്ക് | दूरभाषं प्रति |
| `descSelectiveSync` | For a phone that already has the app with its own data. Choose what to add: | സ്വന്തം വിവരങ്ങളോടെ ആപ്പ് ഇതിനകം ഉള്ള ഫോണിന്. എന്ത് ചേർക്കണമെന്ന് തിരഞ്ഞെടുക്കുക: | स्वदत्तांशसहितम् अनुप्रयोगं पूर्वमेव धारयतः दूरभाषस्य कृते। किं योजनीयम् इति चीयताम्: |
| `labelSyncAccounts` | Accounts | അക്കൗണ്ടുകൾ | विवरणानि |
| `labelSyncSettings` | Settings | ക്രമീകരണങ്ങൾ | विन्यासाः |
| `descSyncSettings` | Theme, auto-lock, and sync timeouts | തീം, സ്വയം ലോക്ക്, സമന്വയ സമയപരിധികൾ | रूपविन्यासः, स्वतालनं, समन्वयकालसीमाः |
| `descNoOverride` | This will not override anything already on the other device. If something matches, the other device keeps its own version — its data is retained. | ഇത് മറ്റേ ഉപകരണത്തിൽ ഉള്ള ഒന്നും മാറ്റിയെഴുതില്ല. എന്തെങ്കിലും പൊരുത്തപ്പെട്ടാൽ മറ്റേ ഉപകരണം സ്വന്തം പതിപ്പ് നിലനിർത്തും — അതിലെ വിവരങ്ങൾ നിലനിൽക്കും. | अपरस्मिन् उपकरणे विद्यमानं किमपि न परिवर्त्यते। किमपि साम्ये सति अपरम् उपकरणं स्वसंस्करणं रक्षति — तस्य दत्तांशः तिष्ठति। |
| `actionSync` | Sync | സമന്വയിപ്പിക്കുക | समन्वीयताम् |
| `descSyncing` | Syncing… | സമന്വയിപ്പിക്കുന്നു… | समन्वीयते… |
| `labelDurationSeconds` | ~{seconds} s | ~{seconds} സെ. | ~{seconds} क्षणाः |
| `labelDurationMinutes` | ~{minutes} min | ~{minutes} മിനി. | ~{minutes} निमेषाः |
| `labelDurationMinSec` | ~{minutes} min {seconds} s | ~{minutes} മിനി. {seconds} സെ. | ~{minutes} निमेषाः {seconds} क्षणाः |
| `titleOpticalSend` | Optical stream | ഒപ്റ്റിക്കൽ സ്ട്രീം | प्रकाशीयप्रवाहः |
| `titleOpticalScan` | Scan optical stream | ഒപ്റ്റിക്കൽ സ്കാൻ | प्रकाशीयावलोकनम् |
| `descReconstructing` | Reconstructing accounts… | അക്കൗണ്ടുകൾ പുനർനിർമ്മിക്കുന്നു… | विवरणानि पुनर्निर्मीयन्ते… |
| `titleLargeVaultWarning` | Large data warning | വലിയ ഡാറ്റ മുന്നറിയിപ്പ് | बृहद्दत्तांशपूर्वसूचना |
| `descLargeVault` | This transfer has {chunks} chunks ({duration} estimated). Streaming a lot of data over camera QR can be slow. Consider Wi-Fi sync for a faster transfer. | ഈ കൈമാറ്റത്തിൽ {chunks} ഭാഗങ്ങളുണ്ട് (ഏകദേശം {duration}). ക്യാമറ QR വഴി ധാരാളം വിവരങ്ങൾ അയയ്ക്കാൻ സമയമെടുക്കും. വേഗത്തിന് Wi-Fi സമന്വയം പരിഗണിക്കുക. | अस्मिन् प्रेषणे {chunks} खण्डाः सन्ति (प्रायः {duration})। छायाग्राहक-QR-द्वारेण बहुदत्तांशप्रेषणं मन्दं भवति। शीघ्रप्रेषणाय Wi-Fi-समन्वयः विचार्यताम्। |
| `descPointReceiver` | Point the receiving device camera at this animated QR stream. The data is split into error-tolerant chunks; no network is used. | സ്വീകരിക്കുന്ന ഉപകരണത്തിന്റെ ക്യാമറ ഈ ചലിക്കുന്ന QR സ്ട്രീമിലേക്ക് തിരിക്കുക. വിവരങ്ങൾ പിശക് സഹിക്കുന്ന ഭാഗങ്ങളായി അയയ്ക്കുന്നു; നെറ്റ്‌വർക്ക് ഉപയോഗിക്കുന്നില്ല. | स्वीकर्तृ-उपकरणस्य छायाग्राहकम् अस्मिन् चलत्-QR-प्रवाहे स्थाप्यताम्। दत्तांशः दोषसहिष्णुखण्डेषु विभज्यते; जालं न प्रयुज्यते। |
| `labelStreamHash` | Stream hash: | സ്ട്രീം ഹാഷ്: | प्रवाहचिह्नम्: |
| `labelEstDuration` | Estimated time: | ഏകദേശ സമയം: | अनुमितकालः: |
| `labelFramesRendered` | Frames shown: | കാണിച്ച ഫ്രെയിമുകൾ: | दर्शितखण्डाः: |
| `labelFramesValue` | {frame} (chunks: {total}) | {frame} (ഭാഗങ്ങൾ: {total}) | {frame} (खण्डाः: {total}) |
| `labelTargetFps` | Target FPS: | ലക്ഷ്യ FPS: | लक्ष्य-FPS: |
| `labelFps` | {fps} FPS | {fps} FPS | {fps} FPS |
| `labelRemaining` | {time} remaining | {time} ബാക്കി | {time} अवशिष्टम् |
| `descAlignCamera` | Align the camera with the sending screen… | ക്യാമറ അയയ്ക്കുന്ന സ്ക്രീനിലേക്ക് നേരെയാക്കുക… | छायाग्राहकं प्रेषकपटलेन सह संरेख्यताम्… |
| `descReconstructingStream` | Reconstructing the stream… | സ്ട്രീം പുനർനിർമ്മിക്കുന്നു… | प्रवाहः पुनर्निर्मीयते… |
| `descCaptured` | Captured: {solved} / {total} chunks | ലഭിച്ചത്: {solved} / {total} ഭാഗങ്ങൾ | गृहीताः: {solved} / {total} खण्डाः |
| `labelSession` | Session: {hash} | സെഷൻ: {hash} | सत्रम्: {hash} |
| `titleOpticalComplete` | Optical sync done | ഒപ്റ്റിക്കൽ സമന്വയം പൂർത്തി | प्रकाशीयसमन्वयः समाप्तः |
| `descOpticalComplete` | The accounts were rebuilt from the optical QR stream. | ഒപ്റ്റിക്കൽ QR സ്ട്രീമിൽ നിന്ന് അക്കൗണ്ടുകൾ പുനർനിർമ്മിച്ചു. | प्रकाशीय-QR-प्रवाहात् विवरणानि पुनर्निर्मितानि। |
| `titleOpticalFailed` | Optical sync failed | ഒപ്റ്റിക്കൽ സമന്വയം പരാജയം | प्रकाशीयसमन्वयः असफलः |
| `titleScanSyncQr` | Scan sync QR code | സമന്വയ QR സ്കാൻ | समन्वय-QR-अवलोकनम् |
| `descScanSenderQr` | Scan the QR shown on the sending device | അയയ്ക്കുന്ന ഉപകരണത്തിൽ കാണുന്ന QR സ്കാൻ ചെയ്യുക | प्रेषक-उपकरणे दृश्यमानम् QR अवलोक्यताम् |
