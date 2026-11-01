// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get descSplashLoading => 'നിങ്ങളുടെ അക്കൗണ്ടുകൾ സുരക്ഷിതമാക്കുന്നു...';

  @override
  String get titleSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get titleAppearance => 'രൂപഭംഗി';

  @override
  String get titleSecurity => 'സുരക്ഷ';

  @override
  String get titleExploreSupport => 'പരിചയവും സഹായവും';

  @override
  String get titleLanguage => 'ഭാഷ';

  @override
  String get titleSecuritySettings => 'സുരക്ഷാ ക്രമീകരണങ്ങൾ';

  @override
  String get descSecuritySettingsEntry =>
      'ആപ്പ് ലോക്കും ബയോമെട്രിക്കും ക്രമീകരിക്കുക';

  @override
  String get titleBackupRestore => 'കരുതലും പുനഃസ്ഥാപനവും';

  @override
  String get descBackupRestoreEntry =>
      'നിങ്ങളുടെ അക്കൗണ്ടുകൾ കയറ്റുമതിയോ ഇറക്കുമതിയോ ചെയ്യുക';

  @override
  String get titleManageTags => 'അടയാള നിർവഹണം';

  @override
  String get descManageTagsEntry =>
      'അക്കൗണ്ട് അടയാളങ്ങൾ തിരുത്തുക, പേരുമാറ്റുക, വൃത്തിയാക്കുക';

  @override
  String get titleSyncDevice => 'ഉപകരണ സമന്വയം';

  @override
  String get descSyncDeviceEntry =>
      'Wi-Fi വഴിയോ ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് വഴിയോ അക്കൗണ്ടുകൾ കൈമാറുക';

  @override
  String get titleSyncHostTimeout => 'സമന്വയ ഹോസ്റ്റ് സമയപരിധി';

  @override
  String descSyncHostTimeoutEntry(int seconds) {
    return '$seconds സെക്കൻഡിനുള്ളിൽ ഒരു ഉപകരണവും ബന്ധിപ്പിച്ചില്ലെങ്കിൽ ഹോസ്റ്റിംഗ് നിർത്തും';
  }

  @override
  String labelSecondsCount(int seconds) {
    return '$seconds സെക്കൻഡ്';
  }

  @override
  String get titlePermissions => 'അനുമതികൾ';

  @override
  String get descPermissionsEntry => 'ആപ്പ് അനുമതികളും അവയുടെ നിലയും കാണുക';

  @override
  String get titleFeatures => 'സവിശേഷതകൾ';

  @override
  String descFeaturesEntry(String appName) {
    return '$appName-ന്റെ എല്ലാ സവിശേഷതകളും അറിയുക';
  }

  @override
  String get titleHelp => 'സഹായം';

  @override
  String get descHelpEntry =>
      'മാർഗ്ഗനിർദ്ദേശങ്ങൾ, പ്രശ്നപരിഹാരം, സമന്വയ വിവരങ്ങൾ';

  @override
  String get titleAbout => 'ആപ്പിനെക്കുറിച്ച്';

  @override
  String get descAboutEntry => 'പതിപ്പ്, രചയിതാവ്, ലൈസൻസ് വിവരങ്ങൾ';

  @override
  String descAppearanceThemeMode(String mode) {
    return 'തീം രീതി: $mode';
  }

  @override
  String get titleThemeMode => 'തീം രീതി';

  @override
  String get titleAccentColor => 'പ്രധാന നിറം';

  @override
  String get titleSelectAccentColor => 'നിറം തിരഞ്ഞെടുക്കുക';

  @override
  String get labelAccentBlue => 'നീല';

  @override
  String get labelAccentTeal => 'നീലപ്പച്ച';

  @override
  String get labelAccentIndigo => 'കരിനീല';

  @override
  String get labelAccentGreen => 'പച്ച';

  @override
  String get labelAccentCopper => 'ചെമ്പ്';

  @override
  String get labelAccentGraphite => 'ഗ്രാഫൈറ്റ്';

  @override
  String get titleThemeInformation => 'തീം വിവരങ്ങൾ';

  @override
  String get titleVisualDesign => 'ദൃശ്യ രൂപകൽപ്പന';

  @override
  String descVisualDesign(String appName) {
    return '$appName ഉയർന്നുനിൽക്കുന്ന കാർഡുകളും വ്യക്തമായ കൗണ്ട്ഡൗൺ വലയങ്ങളും ഉയർന്ന വർണ്ണവ്യത്യാസമുള്ള എഴുത്തുമുള്ള വൃത്തിയുള്ള ഓഫ്‌ലൈൻ രൂപകൽപ്പന ഉപയോഗിക്കുന്നു.';
  }

  @override
  String get descThemeSummarySystem =>
      'സിസ്റ്റം സ്വതവേ (ഉപകരണ ക്രമീകരണം പിന്തുടരുന്നു)';

  @override
  String get descThemeSummaryLight => 'തെളിഞ്ഞ തീം';

  @override
  String get descThemeSummaryDark => 'ഇരുണ്ട തീം';

  @override
  String get titleSelectThemeMode => 'തീം തിരഞ്ഞെടുപ്പ്';

  @override
  String get labelThemeSystem => 'സിസ്റ്റം സ്വതവേ';

  @override
  String get descThemeSystem => 'ഉപകരണത്തിന്റെ സിസ്റ്റം തീം സ്വയം പിന്തുടരുക';

  @override
  String get labelThemeLight => 'തെളിഞ്ഞ തീം';

  @override
  String get descThemeLight =>
      'വൃത്തിയുള്ള, ഉയർന്ന വർണ്ണവ്യത്യാസമുള്ള തെളിഞ്ഞ രൂപം';

  @override
  String get labelThemeDark => 'ഇരുണ്ട തീം';

  @override
  String get descThemeDark =>
      'കുറഞ്ഞ വെളിച്ചത്തിൽ കണ്ണിന് സുഖകരമായ ഇരുണ്ട രൂപം';

  @override
  String get titleCurrentStatus => 'നിലവിലെ നില';

  @override
  String get labelActiveDark => 'സജീവം: ഇരുണ്ടത്';

  @override
  String get labelActiveLight => 'സജീവം: തെളിഞ്ഞത്';

  @override
  String get descThemeStatusSystem =>
      'ഉപകരണത്തിലെ ഇരുണ്ട രൂപ ക്രമീകരണം പിന്തുടരുന്നു.';

  @override
  String get descThemeStatusLight => 'എപ്പോഴും തെളിഞ്ഞ രൂപത്തിൽ തുടരും.';

  @override
  String get descThemeStatusDark => 'എപ്പോഴും ഇരുണ്ട രൂപത്തിൽ തുടരും.';

  @override
  String get titleSelectLanguage => 'ഭാഷ തിരഞ്ഞെടുപ്പ്';

  @override
  String get labelLanguageSystem => 'സിസ്റ്റം സ്വതവേ';

  @override
  String get descLanguageSystem =>
      'ഉപകരണ ഭാഷ ഇംഗ്ലീഷോ മലയാളമോ സംസ്കൃതമോ ആണെങ്കിൽ അത് ഉപയോഗിക്കും; അല്ലെങ്കിൽ ഇംഗ്ലീഷ്';

  @override
  String get labelLanguageNameEn => 'ഇംഗ്ലീഷ്';

  @override
  String get labelLanguageNameMl => 'മലയാളം';

  @override
  String get labelLanguageNameSa => 'സംസ്കൃതം';

  @override
  String descLanguageRowA11y(String value) {
    return 'ഭാഷ: $value';
  }

  @override
  String labelVersionNumber(String version) {
    return 'പതിപ്പ് $version';
  }

  @override
  String get labelEnvProduction => 'ഔദ്യോഗിക പതിപ്പ്';

  @override
  String get labelEnvDevelopment => 'വികസന പതിപ്പ്';

  @override
  String get descFeatureQr => 'QR കോഡ് സ്കാനിംഗ്';

  @override
  String get descFeatureEncrypted => 'എൻക്രിപ്റ്റ് ചെയ്ത സംഭരണം';

  @override
  String get descFeatureBackup => 'കരുതലും പുനഃസ്ഥാപനവും';

  @override
  String get descFeatureOrganize => 'അക്കൗണ്ടുകൾ ചിട്ടപ്പെടുത്തൽ';

  @override
  String get descFeatureBiometric => 'ബയോമെട്രിക് പ്രാമാണീകരണം';

  @override
  String get descFeatureDarkMode => 'ഇരുണ്ട രൂപ പിന്തുണ';

  @override
  String get titleDeveloper => 'വികസിപ്പിച്ചയാൾ';

  @override
  String get titleLinks => 'ലിങ്കുകൾ';

  @override
  String get titlePrivacyPolicy => 'സ്വകാര്യതാ നയം';

  @override
  String get titlePrivacyStorage => 'വിവര സംഭരണം';

  @override
  String get descPrivacyStorage =>
      'നിങ്ങളുടെ എല്ലാ അക്കൗണ്ട് വിവരങ്ങളും നിങ്ങളുടെ ഉപകരണത്തിൽ എൻക്രിപ്റ്റ് ചെയ്ത് സൂക്ഷിക്കുന്നു. ആപ്പിന് സെർവർ ഇല്ല, അക്കൗണ്ടും ആവശ്യമില്ല.';

  @override
  String get titlePrivacyPermissions => 'അനുമതികൾ';

  @override
  String get descPrivacyPermissions =>
      '• ക്യാമറ: QR കോഡുകൾ സ്കാൻ ചെയ്യാൻ\n• പ്രാദേശിക നെറ്റ്‌വർക്ക്: നിങ്ങളുടെ ഉപകരണങ്ങൾ തമ്മിലുള്ള Wi-Fi സമന്വയത്തിന് മാത്രം\n• ബയോമെട്രിക്: ഐച്ഛികം, ആപ്പ് ലോക്ക് തുറക്കാൻ\n\nകരുതൽ ഫയലുകൾ സിസ്റ്റം ഫയൽ പിക്കർ വഴി തിരഞ്ഞെടുക്കുന്നതിനാൽ സംഭരണ അനുമതി ആവശ്യമില്ല.';

  @override
  String get titlePrivacySecurity => 'സുരക്ഷ';

  @override
  String get descPrivacySecurity =>
      'നിങ്ങളുടെ രഹസ്യങ്ങൾ AES-256 എൻക്രിപ്ഷൻ ഉപയോഗിച്ച് സംരക്ഷിക്കുന്നു. Wi-Fi സമന്വയം, ഒപ്റ്റിക്കൽ കൈമാറ്റം, കരുതൽ കയറ്റുമതി എന്നിവ നിങ്ങൾ ആരംഭിക്കുമ്പോൾ മാത്രമേ അവ ഉപകരണം വിടുകയുള്ളൂ; ഓരോ തവണയും അവ എൻക്രിപ്റ്റ് ചെയ്തിരിക്കും.';

  @override
  String get actionClose => 'അടയ്ക്കുക';

  @override
  String get titleOpenSourceLicenses => 'ഓപ്പൺ സോഴ്സ് ലൈസൻസുകൾ';

  @override
  String get descCopyright =>
      '© 2026 ശ്രീരാജ് പി. എല്ലാ അവകാശങ്ങളും നിക്ഷിപ്തം.';

  @override
  String get aboutDetailAuthor => 'രചയിതാവ്';

  @override
  String get aboutDetailEmail => 'ഇമെയിൽ';

  @override
  String get aboutDetailWebsite => 'വെബ്സൈറ്റ്';

  @override
  String get aboutDetailPrivacyPolicy => 'സ്വകാര്യതാ നയം';

  @override
  String get aboutDetailLicense => 'ലൈസൻസ്';

  @override
  String get aboutDetailAiUsed => 'ഉപയോഗിച്ച AI';

  @override
  String get aboutDetailIdeUsed => 'ഉപയോഗിച്ച IDE';

  @override
  String madeWithLove(String heart) {
    return 'സ്നേഹത്തോടെ $heart ഇന്ത്യയിൽ നിർമ്മിച്ചത്';
  }

  @override
  String get madeWithLoveA11y => 'സ്നേഹത്തോടെ ഇന്ത്യയിൽ നിർമ്മിച്ചത്';

  @override
  String get actionOk => 'ശരി';

  @override
  String get actionCancel => 'റദ്ദാക്കുക';

  @override
  String get actionCopy => 'പകർത്തുക';

  @override
  String get errorPhoneLockFailed => 'ഫോൺ സ്ക്രീൻ ലോക്ക് പരാജയപ്പെട്ടു';

  @override
  String get errorPhoneLockCanceled => 'ഫോൺ സ്ക്രീൻ ലോക്ക് റദ്ദാക്കി';

  @override
  String get errorPhoneLockLockedOut =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് താൽക്കാലികമായി തടഞ്ഞിരിക്കുന്നു';

  @override
  String get errorPhoneLockUnavailable =>
      'ഈ ഉപകരണത്തിൽ ഫോൺ സ്ക്രീൻ ലോക്ക് ലഭ്യമല്ല';

  @override
  String get errorPhoneLockUnverified =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് പരിശോധിക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get descPinRequiredIdle => 'ഒരു മണിക്കൂറിന് ശേഷം ആപ്പ് PIN ആവശ്യമാണ്';

  @override
  String get descPinRequiredReboot =>
      'ഉപകരണം പുനരാരംഭിച്ചതിനാൽ ആപ്പ് PIN ആവശ്യമാണ്';

  @override
  String get descPinRequiredFailures =>
      'ഫോൺ ലോക്ക് 3 തവണ പരാജയപ്പെട്ടതിനാൽ ആപ്പ് PIN ആവശ്യമാണ്';

  @override
  String get descPinRequiredLockdown =>
      'ലോക്ക്ഡൗൺ മോഡ് സജീവമാണ്. ആപ്പ് PIN നൽകുക';

  @override
  String get descUnlockPhoneOnly => 'ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുക';

  @override
  String get descUnlockPhoneOrPin =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുക, അല്ലെങ്കിൽ ആപ്പ് PIN നൽകുക';

  @override
  String get descUnlockPinOnly => 'ആപ്പ് PIN നൽകുക';

  @override
  String get descUnlockWithPhone => 'തുറക്കാൻ ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിക്കുക';

  @override
  String get errorPinEmpty => 'ദയവായി ആപ്പ് PIN നൽകുക';

  @override
  String errorPinLockedOut(int seconds) {
    return 'നിരവധി തെറ്റായ ശ്രമങ്ങൾ. $seconds സെക്കൻഡിന് ശേഷം വീണ്ടും ശ്രമിക്കുക.';
  }

  @override
  String errorPinIncorrectRemaining(int count) {
    return 'തെറ്റായ ആപ്പ് PIN. ശേഷിക്കുന്ന ശ്രമങ്ങൾ: $count';
  }

  @override
  String get errorPinIncorrect => 'തെറ്റായ ആപ്പ് PIN';

  @override
  String get titleNoRecoveryKey => 'വീണ്ടെടുക്കൽ കീ ഇല്ല';

  @override
  String get descNoRecoveryKey =>
      'ഈ ആപ്പ് PIN-ന് വീണ്ടെടുക്കൽ കീ സജ്ജമാക്കിയിട്ടില്ല. അതില്ലാതെ പ്രവേശനം വീണ്ടെടുക്കാൻ വഴിയില്ല.\n\nആപ്പ് വീണ്ടും ഇൻസ്റ്റാൾ ചെയ്യാം, പക്ഷേ എല്ലാ അക്കൗണ്ടുകളും നഷ്ടപ്പെടും.';

  @override
  String get titleEnterRecoveryKey => 'വീണ്ടെടുക്കൽ കീ നൽകുക';

  @override
  String get descEnterRecoveryKey =>
      'ആപ്പ് PIN സജ്ജമാക്കുമ്പോൾ സൂക്ഷിച്ച വീണ്ടെടുക്കൽ കീ നൽകുക.';

  @override
  String get labelRecoveryKey => 'വീണ്ടെടുക്കൽ കീ';

  @override
  String get errorRecoveryKeyInvalid => 'അസാധുവായ വീണ്ടെടുക്കൽ കീ';

  @override
  String get actionRecover => 'വീണ്ടെടുക്കുക';

  @override
  String get labelNewPin => 'പുതിയ ആപ്പ് PIN';

  @override
  String get descPinDigitsHint => '4–6 അക്കങ്ങൾ';

  @override
  String get labelConfirmPin => 'ആപ്പ് PIN സ്ഥിരീകരണം';

  @override
  String get errorPinTooShort => 'ആപ്പ് PIN-ൽ കുറഞ്ഞത് 4 അക്കങ്ങൾ വേണം';

  @override
  String get errorPinMismatch => 'ആപ്പ് PIN-കൾ പൊരുത്തപ്പെടുന്നില്ല';

  @override
  String get actionSavePin => 'PIN സൂക്ഷിക്കുക';

  @override
  String get titleSetNewPin => 'പുതിയ PIN സജ്ജീകരണം';

  @override
  String get descSetNewPin =>
      'നിങ്ങളുടെ പഴയ ആപ്പ് PIN നീക്കം ചെയ്തു. ദയവായി പുതിയ ആപ്പ് PIN സജ്ജമാക്കുക.';

  @override
  String get titleRecoveryKey => 'വീണ്ടെടുക്കൽ കീ';

  @override
  String get descRecoveryKeySave =>
      'ഈ വീണ്ടെടുക്കൽ കീ സുരക്ഷിതമായ ഒരിടത്ത് സൂക്ഷിക്കുക. ആപ്പ് PIN മറന്നാൽ പ്രവേശനം വീണ്ടെടുക്കാനുള്ള ഏക വഴി ഇതാണ്.';

  @override
  String get descRecoveryKeyCopied =>
      'വീണ്ടെടുക്കൽ കീ പകർത്തി. 60 സെക്കൻഡ് കഴിഞ്ഞ് ഇത് ക്ലിപ്പ്ബോർഡിൽ നിന്ന് മായ്ക്കും.';

  @override
  String get descRecoveryKeyOnce => 'ഈ കീ ഇനി കാണിക്കില്ല.';

  @override
  String get actionSavedIt => 'ഞാൻ സൂക്ഷിച്ചു';

  @override
  String get titleEnterYourPin => 'ആപ്പ് PIN നൽകൽ';

  @override
  String get titleUseDeviceLock => 'ഫോൺ ലോക്ക്';

  @override
  String get titleUnlockApp => 'ആപ്പ് തുറക്കൽ';

  @override
  String labelPinLockedFor(int seconds) {
    return '$seconds സെ. തടഞ്ഞു';
  }

  @override
  String get labelEnterPin => 'ആപ്പ് PIN നൽകുക';

  @override
  String errorTooManyAttempts(int seconds) {
    return 'അധിക ശ്രമങ്ങൾ. $seconds സെ. കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കുക';
  }

  @override
  String get actionUnlockWithPin => 'PIN കൊണ്ട് തുറക്കുക';

  @override
  String get actionForgotPin => 'PIN മറന്നോ?';

  @override
  String get labelCheckingPhoneLock => 'പരിശോധിക്കുന്നു…';

  @override
  String get actionUsePhoneLock => 'ഫോൺ ലോക്ക് ഉപയോഗിക്കുക';

  @override
  String get labelOr => 'അല്ലെങ്കിൽ';

  @override
  String get descAuthReasonBiometric =>
      'നിങ്ങളുടെ അക്കൗണ്ടുകൾ തുറക്കാൻ ബയോമെട്രിക് ഉപയോഗിച്ച് സ്ഥിരീകരിക്കുക';

  @override
  String get descAuthReasonPhoneLock =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് പ്രമാണീകാരി തുറക്കുക';

  @override
  String get errorAppLockMisconfigured =>
      'ആപ്പ് ലോക്ക് ശരിയായി ക്രമീകരിച്ചിട്ടില്ല. ദയവായി വീണ്ടും പ്രവർത്തനക്ഷമമാക്കുക.';

  @override
  String get errorAppLockNoMethod =>
      'ആപ്പ് ലോക്കിന് തുറക്കാനുള്ള മാർഗ്ഗമില്ല. ദയവായി വീണ്ടും പ്രവർത്തനക്ഷമമാക്കുക.';

  @override
  String get titleEnterAppPin => 'ആപ്പ് PIN നൽകുക';

  @override
  String get descPinRequiredForSensitive =>
      'സംവേദനക്ഷമമായ പ്രവർത്തനങ്ങൾക്കും രഹസ്യങ്ങൾ കാണാനും ആപ്പ് PIN ആവശ്യമാണ്.';

  @override
  String get labelAppPin => 'ആപ്പ് PIN';

  @override
  String get actionVerify => 'പരിശോധിക്കുക';

  @override
  String get descPinPurposeViewSecret => 'രഹസ്യ കീ കാണാനും തിരുത്താനും.';

  @override
  String get descPinPurposeAdvanced => 'വിപുലമായ ഓപ്ഷനുകൾ കാണാനും തിരുത്താനും.';

  @override
  String get descPinPurposeSaveChanges =>
      'രഹസ്യ കീയിലോ വിപുലമായ ഓപ്ഷനുകളിലോ വരുത്തിയ മാറ്റങ്ങൾ സൂക്ഷിക്കാൻ.';

  @override
  String get descPinPurposeDeleteSelected =>
      'തിരഞ്ഞെടുത്ത അക്കൗണ്ടുകൾ ഇല്ലാതാക്കാൻ.';

  @override
  String get tooltipCancelSelection => 'തിരഞ്ഞെടുപ്പ് റദ്ദാക്കുക';

  @override
  String labelSelectedCount(int count) {
    return '$count തിരഞ്ഞെടുത്തു';
  }

  @override
  String get tabAccounts => 'അക്കൗണ്ടുകൾ';

  @override
  String get tabTags => 'അടയാളങ്ങൾ';

  @override
  String get tooltipSelectAll => 'എല്ലാം തിരഞ്ഞെടുക്കുക';

  @override
  String get tooltipDeselectAll => 'എല്ലാം ഒഴിവാക്കുക';

  @override
  String get tooltipSort => 'ക്രമീകരിക്കുക';

  @override
  String get tooltipSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get descReorderHint =>
      'അക്കൗണ്ടുകളുടെ ക്രമം മാറ്റാൻ അമർത്തിപ്പിടിച്ച് വലിക്കുക';

  @override
  String get labelSortManual => 'സ്വമേധയാ';

  @override
  String get labelSortIssuer => 'നൽകുന്നയാൾ അനുസരിച്ച്';

  @override
  String get labelSortAccount => 'അക്കൗണ്ട് പേര് അനുസരിച്ച്';

  @override
  String get labelSortDate => 'ചേർത്ത തീയതി അനുസരിച്ച്';

  @override
  String descFilteredBy(String tags) {
    return 'അരിച്ചെടുത്തത്: $tags';
  }

  @override
  String get actionClearFilter => 'അരിപ്പ് നീക്കുക';

  @override
  String get descHomeHint =>
      'ഒന്നിലധികം തിരഞ്ഞെടുക്കാൻ അമർത്തിപ്പിടിക്കുക • ക്രമം മാറ്റാൻ വലിക്കുക.';

  @override
  String get actionReassignTags => 'അടയാളങ്ങൾ മാറ്റുക';

  @override
  String get actionExportSelected => 'കയറ്റുമതി ചെയ്യുക';

  @override
  String get actionDeleteSelected => 'ഇല്ലാതാക്കുക';

  @override
  String get actionEdit => 'തിരുത്തുക';

  @override
  String get actionDelete => 'ഇല്ലാതാക്കുക';

  @override
  String get titleDeleteAccount => 'അക്കൗണ്ട് ഇല്ലാതാക്കൽ';

  @override
  String descDeleteAccountConfirm(String name) {
    return '$name ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ?';
  }

  @override
  String descAccountDeleted(String name) {
    return '$name ഇല്ലാതാക്കി';
  }

  @override
  String titleReassignTagsCount(int count) {
    return 'അടയാളങ്ങൾ മാറ്റൽ ($count)';
  }

  @override
  String get descReassignTagsHint =>
      'കോമ കൊണ്ട് വേർതിരിച്ച് അടയാളങ്ങൾ നൽകുക (ഉദാ. ജോലി, VIP):';

  @override
  String get labelTags => 'അടയാളങ്ങൾ';

  @override
  String get labelTagsExample => 'ജോലി, വ്യക്തിപരം';

  @override
  String get descReplaceTags =>
      'നിലവിലെ അടയാളങ്ങൾ മാറ്റിസ്ഥാപിക്കുക (കൂട്ടിച്ചേർക്കുന്നതിന് പകരം)';

  @override
  String descTagsUpdated(int count) {
    return '$count അക്കൗണ്ടുകളുടെ അടയാളങ്ങൾ പുതുക്കി';
  }

  @override
  String get actionApplyTags => 'പ്രയോഗിക്കുക';

  @override
  String titleExportSelectedCount(int count) {
    return 'കയറ്റുമതി ($count)';
  }

  @override
  String get descExportPasswordHint =>
      'ഈ കരുതൽ ഫയൽ സംരക്ഷിക്കാൻ ഒരു രഹസ്യവാക്ക് സജ്ജമാക്കുക.';

  @override
  String get labelPassword => 'രഹസ്യവാക്ക്';

  @override
  String get labelConfirmPassword => 'രഹസ്യവാക്ക് സ്ഥിരീകരണം';

  @override
  String get errorPasswordTooShort => 'രഹസ്യവാക്കിന് കുറഞ്ഞത് 6 അക്ഷരങ്ങൾ വേണം';

  @override
  String get errorPasswordMismatch => 'രഹസ്യവാക്കുകൾ പൊരുത്തപ്പെടുന്നില്ല';

  @override
  String descExportedSelected(int count) {
    return 'തിരഞ്ഞെടുത്ത $count അക്കൗണ്ടുകൾ കയറ്റുമതി ചെയ്തു';
  }

  @override
  String get errorExportSelectedFailed =>
      'തിരഞ്ഞെടുത്ത അക്കൗണ്ടുകൾ കയറ്റുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String get actionExport => 'കയറ്റുമതി ചെയ്യുക';

  @override
  String get titleDeleteAccounts => 'അക്കൗണ്ടുകൾ ഇല്ലാതാക്കൽ';

  @override
  String descDeleteSelectedConfirm(int count) {
    return '$count അക്കൗണ്ടുകൾ ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? ഇത് പിന്നീട് തിരുത്താനാവില്ല.';
  }

  @override
  String get errorAuthFailedDeleteCanceled =>
      'സ്ഥിരീകരണം പരാജയപ്പെട്ടു. ഇല്ലാതാക്കൽ റദ്ദാക്കി.';

  @override
  String descAccountsDeleted(int count) {
    return '$count അക്കൗണ്ടുകൾ ഇല്ലാതാക്കി';
  }

  @override
  String actionDeleteCount(int count) {
    return 'ഇല്ലാതാക്കുക ($count)';
  }

  @override
  String get emptyNoAccountsFound => 'അക്കൗണ്ടുകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get emptyNoAccountsYet => 'ഇതുവരെ അക്കൗണ്ടുകളില്ല';

  @override
  String get emptyTryDifferentSearch => 'മറ്റൊരു വാക്ക് ഉപയോഗിച്ച് തിരയുക';

  @override
  String get emptyAddFirstAccount => 'ആദ്യ അക്കൗണ്ട് ചേർക്കാൻ + ബട്ടൺ അമർത്തുക';

  @override
  String get emptyLongPressTip =>
      'സൂചന: കൂടുതൽ ഓപ്ഷനുകൾക്ക് + ബട്ടൺ അമർത്തിപ്പിടിക്കുക';

  @override
  String get labelQrScanner => 'QR സ്കാനർ';

  @override
  String get descScanQrCode => 'QR കോഡ് സ്കാൻ ചെയ്യുക';

  @override
  String get labelManualEntry => 'സ്വമേധയാ നൽകൽ';

  @override
  String get descEnterDetailsManually => 'വിവരങ്ങൾ സ്വയം നൽകുക';

  @override
  String get labelSearchAccounts => 'അക്കൗണ്ടുകൾ തിരയുക…';

  @override
  String get titleTagCloud => 'അടയാള മേഘം';

  @override
  String get descTagCloud =>
      'ബന്ധപ്പെട്ട അക്കൗണ്ടുകൾ കാണാൻ ഏതെങ്കിലും അടയാളം അമർത്തുക';

  @override
  String get actionManageTags => 'അടയാളങ്ങൾ ക്രമീകരിക്കുക';

  @override
  String get labelSearchTags => 'അടയാളങ്ങൾ തിരയുക…';

  @override
  String descActiveFilter(String tags) {
    return 'സജീവ അരിപ്പ്: $tags';
  }

  @override
  String get actionClear => 'നീക്കുക';

  @override
  String get emptyNoTagsYet => 'ഇതുവരെ അടയാളങ്ങളില്ല';

  @override
  String emptyNoTagsMatching(String query) {
    return '\"$query\" എന്നതിന് അടയാളങ്ങളൊന്നുമില്ല';
  }

  @override
  String get emptyAddTagsHint =>
      'അക്കൗണ്ട് സൃഷ്ടിക്കുമ്പോഴോ തിരുത്തുമ്പോഴോ അടയാളങ്ങൾ ചേർക്കുക';

  @override
  String get emptyTryDifferentKeyword => 'മറ്റൊരു വാക്ക് ഉപയോഗിച്ച് തിരയുക';

  @override
  String get labelAllTags => 'എല്ലാ അടയാളങ്ങളും';

  @override
  String get titleAppLockRequired => 'ആപ്പ് ലോക്ക് ആവശ്യമാണ്';

  @override
  String get descAppLockRequiredSecret =>
      'രഹസ്യ കീ തിരുത്താൻ, ആദ്യം സുരക്ഷാ ക്രമീകരണങ്ങളിൽ ആപ്പ് ലോക്ക് പ്രവർത്തനക്ഷമമാക്കുക.';

  @override
  String get descAppLockRequiredAdvanced =>
      'വിപുലമായ ഓപ്ഷനുകൾ തിരുത്താൻ, ആദ്യം സുരക്ഷാ ക്രമീകരണങ്ങളിൽ ആപ്പ് ലോക്ക് പ്രവർത്തനക്ഷമമാക്കുക.';

  @override
  String get descAppLockRequiredSave =>
      'സംവേദനക്ഷമമായ ഭാഗങ്ങളിലെ (രഹസ്യ കീ അല്ലെങ്കിൽ വിപുലമായ ഓപ്ഷനുകൾ) മാറ്റങ്ങൾ സൂക്ഷിക്കാൻ, ആദ്യം സുരക്ഷാ ക്രമീകരണങ്ങളിൽ ആപ്പ് ലോക്ക് പ്രവർത്തനക്ഷമമാക്കുക.';

  @override
  String get actionOpenSecurity => 'സുരക്ഷ തുറക്കുക';

  @override
  String get descSecretUnlocked => 'രഹസ്യ കീ തുറന്നു';

  @override
  String get descAdvancedUnlocked => 'വിപുലമായ ക്രമീകരണങ്ങൾ തുറന്നു';

  @override
  String get descAccountUpdated => 'അക്കൗണ്ട് വിജയകരമായി പുതുക്കി';

  @override
  String get descAccountAdded => 'അക്കൗണ്ട് വിജയകരമായി ചേർത്തു';

  @override
  String get errorSaveAccountFailed =>
      'അക്കൗണ്ട് സൂക്ഷിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorSecretRequired => 'രഹസ്യ കീ ആവശ്യമാണ്';

  @override
  String get errorSecretNotBase32 =>
      'അസാധുവായ രഹസ്യ കീ. Base32 രൂപത്തിലായിരിക്കണം';

  @override
  String get errorSecretTooShort => 'രഹസ്യ കീ വളരെ ചെറുതാണ്';

  @override
  String get titleEditAccount => 'അക്കൗണ്ട് തിരുത്തൽ';

  @override
  String get titleAddAccount => 'അക്കൗണ്ട് ചേർക്കൽ';

  @override
  String get tooltipScanQr => 'QR കോഡ് സ്കാൻ ചെയ്യുക';

  @override
  String get actionUpdateAccount => 'അക്കൗണ്ട് പുതുക്കുക';

  @override
  String get actionAddAccount => 'അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get errorQrInvalid => 'ഈ QR കോഡ് സാധുവായ പ്രാമാണീകരണ കോഡ് അല്ല.';

  @override
  String get errorQrNoSecret => 'ഈ QR കോഡിൽ രഹസ്യ കീ ഇല്ല.';

  @override
  String get errorAddAccountFailed =>
      'അക്കൗണ്ട് ചേർക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String descAccountAddedName(String name) {
    return 'അക്കൗണ്ട് ചേർത്തു: $name';
  }

  @override
  String get titleAddAccountManually => 'സ്വമേധയാ ചേർക്കൽ';

  @override
  String get labelAccountNameRequired => 'അക്കൗണ്ട് പേര് *';

  @override
  String get descAccountNameHint => 'അക്കൗണ്ട് പേര് നൽകുക';

  @override
  String get labelSecretKeyRequired => 'രഹസ്യ കീ *';

  @override
  String get descSecretKeyHint => 'രഹസ്യ കീ നൽകുക';

  @override
  String get labelIssuerOptional => 'നൽകുന്നയാൾ (ഐച്ഛികം)';

  @override
  String get descIssuerHint => 'ഉദാ. Google';

  @override
  String get errorNameAndSecretRequired =>
      'അക്കൗണ്ട് പേരും രഹസ്യ കീയും ആവശ്യമാണ്';

  @override
  String get actionAdd => 'ചേർക്കുക';

  @override
  String get titleScanQrCode => 'QR കോഡ് സ്കാൻ';

  @override
  String get tooltipToggleFlash => 'ഫ്ലാഷ് മാറ്റുക';

  @override
  String get tooltipSwitchCamera => 'ക്യാമറ മാറ്റുക';

  @override
  String get descPositionQr => 'QR കോഡ് ചട്ടക്കൂടിനുള്ളിൽ വയ്ക്കുക';

  @override
  String get actionEnterManually => 'സ്വമേധയാ നൽകുക';

  @override
  String get titleAccountInformation => 'അക്കൗണ്ട് വിവരങ്ങൾ';

  @override
  String get labelAccountName => 'അക്കൗണ്ട് പേര് *';

  @override
  String get descAccountNameExample => 'ഉദാ. john@example.com';

  @override
  String get errorAccountNameRequired => 'അക്കൗണ്ട് പേര് ആവശ്യമാണ്';

  @override
  String get labelIssuer => 'നൽകുന്നയാൾ (ഐച്ഛികം)';

  @override
  String get descIssuerExample => 'ഉദാ. Google, GitHub';

  @override
  String get labelSecretKey => 'രഹസ്യ കീ *';

  @override
  String get labelTapToUnlock => 'തുറക്കാൻ അമർത്തുക';

  @override
  String get labelEnableAppLock => 'ആപ്പ് ലോക്ക് ഓണാക്കുക';

  @override
  String get descSecretKeyBase32 => 'Base32 രൂപത്തിലുള്ള രഹസ്യം';

  @override
  String get titleAdvancedSettings => 'വിപുലമായ ക്രമീകരണങ്ങൾ';

  @override
  String get tooltipUnlockToEdit => 'തിരുത്താൻ തുറക്കുക';

  @override
  String get tooltipEnableAppLockFirst => 'ആപ്പ് ലോക്ക് ഓണാക്കുക';

  @override
  String get labelDigits => 'അക്കങ്ങൾ';

  @override
  String get labelPeriodSeconds => 'കാലയളവ് (സെക്കൻഡ്)';

  @override
  String get labelAlgorithm => 'അൽഗോരിതം';

  @override
  String labelMaskedValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String labelSecondsMasked(String mask) {
    return '$mask സെക്കൻഡ്';
  }

  @override
  String get descTapToUnlockSettings => 'ക്രമീകരണങ്ങൾ കാണാൻ തുറക്കുക';

  @override
  String get descEnableAppLockToEdit => 'തിരുത്താൻ ആപ്പ് ലോക്ക് ഓണാക്കുക';

  @override
  String get titleBrowseTags => 'നിലവിലെ അടയാളങ്ങൾ';

  @override
  String get actionClearAll => 'എല്ലാം നീക്കുക';

  @override
  String get tooltipClose => 'അടയ്ക്കുക';

  @override
  String get labelSearchExistingTags => 'അടയാളങ്ങൾ തിരയുക…';

  @override
  String get emptyNoExistingTags => 'അടയാളങ്ങളൊന്നുമില്ല';

  @override
  String get emptyTypeNewTags =>
      'ഈ അക്കൗണ്ടിന് നൽകാൻ പുതിയ അടയാളങ്ങൾ ടെക്സ്റ്റ് ഫീൽഡിൽ ടൈപ്പ് ചെയ്യുക.';

  @override
  String get emptyNoMatchingTags => 'പൊരുത്തപ്പെടുന്ന അടയാളങ്ങളില്ല';

  @override
  String emptyNoTagsMatchQuery(String query) {
    return '\"$query\" എന്നതിന് പൊരുത്തപ്പെടുന്ന അടയാളങ്ങളില്ല.';
  }

  @override
  String get actionDone => 'പൂർത്തിയായി';

  @override
  String actionApplySelected(int count) {
    return 'പ്രയോഗിക്കുക ($count)';
  }

  @override
  String get descTagsFieldHint =>
      'കോമ കൊണ്ട് വേർതിരിക്കുക, ഉദാ. ജോലി, ക്രിപ്റ്റോ, VIP';

  @override
  String get labelTapToAdd => 'ചേർക്കാൻ അമർത്തുക';

  @override
  String get tooltipBrowseTags => 'നിലവിലെ അടയാളങ്ങൾ';

  @override
  String get labelPermCamera => 'ക്യാമറ';

  @override
  String get descPermCamera =>
      'അക്കൗണ്ടുകൾ ചേർക്കാൻ QR കോഡുകൾ സ്കാൻ ചെയ്യുന്നതിന്';

  @override
  String get labelPermBiometric => 'ബയോമെട്രിക് തുറക്കൽ';

  @override
  String get descPermBiometric =>
      'വിരലടയാളമോ ഉപകരണ ലോക്കോ ഉപയോഗിച്ച് ആപ്പ് ലോക്ക് തുറക്കുന്നതിന്';

  @override
  String get labelPermVibration => 'കമ്പനം';

  @override
  String get descPermVibration =>
      'QR കോഡ് സ്കാൻ ചെയ്യുമ്പോൾ സ്പർശ പ്രതികരണത്തിന്';

  @override
  String get labelPermSecureStorage => 'സുരക്ഷിത സംഭരണം';

  @override
  String get descPermSecureStorage =>
      'എൻക്രിപ്ഷൻ കീകൾ സുരക്ഷിതമായി സൂക്ഷിക്കാൻ Android Keystore ഉപയോഗിക്കുന്നു';

  @override
  String get labelPermLocalDatabase => 'പ്രാദേശിക ഡാറ്റാബേസ്';

  @override
  String get descPermLocalDatabase =>
      'എൻക്രിപ്റ്റ് ചെയ്ത അക്കൗണ്ട് വിവരങ്ങൾ നിങ്ങളുടെ ഉപകരണത്തിൽ മാത്രം സൂക്ഷിക്കുന്നു';

  @override
  String get descPermissionsIntro =>
      'ആവശ്യമുള്ളപ്പോൾ മാത്രമേ ഈ ആപ്പ് അനുമതികൾ ചോദിക്കുന്നുള്ളൂ, ഒരു വിവരവും ശേഖരിക്കുന്നില്ല.';

  @override
  String get titleRuntimePermissions => 'പ്രവർത്തന അനുമതികൾ';

  @override
  String get titleBuiltInCapabilities => 'അന്തർനിർമ്മിത സവിശേഷതകൾ';

  @override
  String get titlePrivacy => 'സ്വകാര്യത';

  @override
  String get labelNoCloudService => 'ക്ലൗഡ് സേവനമില്ല';

  @override
  String get descNoCloudService =>
      'ആപ്പിന് സെർവറോ ക്ലൗഡ് അക്കൗണ്ടോ ഇല്ല. Wi-Fi സമന്വയം പ്രാദേശിക നെറ്റ്‌വർക്ക് മാത്രം ഉപയോഗിക്കുന്നു.';

  @override
  String get labelStatusGranted => 'അനുവദിച്ചു';

  @override
  String get labelStatusDenied => 'നിരസിച്ചു';

  @override
  String get labelStatusNotGranted => 'അനുവദിച്ചിട്ടില്ല';

  @override
  String get labelStatusNotRequested => 'ചോദിച്ചിട്ടില്ല';

  @override
  String get labelBuiltIn => 'അന്തർനിർമ്മിതം';

  @override
  String errorCodeUnavailable(String name) {
    return '$name-ന് കോഡ് ലഭ്യമല്ല';
  }

  @override
  String descCodeCopied(String name) {
    return '$name-ന്റെ കോഡ് പകർത്തി';
  }

  @override
  String get descAppLockEnabledPin =>
      'ആപ്പ് PIN ഉപയോഗിച്ച് ആപ്പ് ലോക്ക് ഓണാക്കി';

  @override
  String get descAppLockEnabledPhone =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് ആപ്പ് ലോക്ക് ഓണാക്കി';

  @override
  String get titleDisableAppLock => 'ആപ്പ് ലോക്ക് ഓഫാക്കൽ';

  @override
  String get descDisableAppLock =>
      'ആപ്പ് ലോക്ക് ഓഫാക്കിയാൽ നിങ്ങളുടെ ആപ്പ് PIN, ദ്രുത തുറക്കൽ ക്രമീകരണം, വീണ്ടെടുക്കൽ കീ എന്നിവ നീക്കം ചെയ്യപ്പെടും.';

  @override
  String get descAppLockDisabled => 'ആപ്പ് ലോക്ക് ഓഫാക്കി';

  @override
  String get titleChooseUnlockMethod => 'തുറക്കൽ രീതി';

  @override
  String get descChooseUnlockMethod =>
      'ആപ്പ് എങ്ങനെ തുറക്കണമെന്ന് തിരഞ്ഞെടുക്കുക. ആപ്പ് PIN കൂടുതൽ സുരക്ഷിതമാണ്; ഫോൺ സ്ക്രീൻ ലോക്ക് കൂടുതൽ സൗകര്യപ്രദമാണ്.';

  @override
  String get actionPhoneLock => 'ഫോൺ ലോക്ക്';

  @override
  String get actionAppPin => 'ആപ്പ് PIN';

  @override
  String get descAppPinEnabled => 'ആപ്പ് PIN ഓണാക്കി';

  @override
  String get errorEnablePhoneLockFirst =>
      'ആദ്യം ഫോൺ സ്ക്രീൻ ലോക്ക് ഓണാക്കുക, അല്ലെങ്കിൽ ആപ്പ് ലോക്ക് ഓഫാക്കുക.';

  @override
  String get titleRemoveAppPin => 'ആപ്പ് PIN നീക്കൽ';

  @override
  String get descRemoveAppPin =>
      'നിങ്ങളുടെ ആപ്പ് PIN-ഉം വീണ്ടെടുക്കൽ കീയും ഇല്ലാതാക്കും. ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് മാത്രമേ ആപ്പ് തുറക്കാനാകൂ.';

  @override
  String get descAppPinRemoved => 'ആപ്പ് PIN നീക്കി';

  @override
  String get errorSetAppPinFirst =>
      'ആദ്യം ഒരു ആപ്പ് PIN സജ്ജമാക്കുക, അല്ലെങ്കിൽ ആപ്പ് ലോക്ക് ഓഫാക്കുക.';

  @override
  String get descQuickUnlockDisabled =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് ദ്രുത തുറക്കൽ ഓഫാക്കി';

  @override
  String get descQuickUnlockEnabled =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് ദ്രുത തുറക്കൽ ഓണാക്കി';

  @override
  String get descPhoneLockEnabled => 'ഫോൺ സ്ക്രീൻ ലോക്ക് ഓണാക്കി';

  @override
  String get titleAutoLockTimeout => 'സ്വയം ലോക്ക് സമയം';

  @override
  String get labelLockImmediately => 'ഉടൻ';

  @override
  String labelMinutesCount(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String get titleCurrentPin => 'നിലവിലെ ആപ്പ് PIN';

  @override
  String get descAppPinChanged => 'ആപ്പ് PIN വിജയകരമായി മാറ്റി';

  @override
  String get titleSetAppPin => 'ആപ്പ് PIN സജ്ജീകരണം';

  @override
  String get titleChangeAppPin => 'ആപ്പ് PIN മാറ്റൽ';

  @override
  String get descPinRequiredForProtection =>
      'ആപ്പ് സംരക്ഷണത്തിനും എല്ലാ രഹസ്യങ്ങളും കാണാനും ആപ്പ് PIN ആവശ്യമാണ്.';

  @override
  String get actionConfirm => 'സ്ഥിരീകരിക്കുക';

  @override
  String get titleAppLockSection => 'ആപ്പ് ലോക്ക്';

  @override
  String get titleAppPinSection => 'ആപ്പ് PIN';

  @override
  String get titlePhoneLockSection => 'ഫോൺ സ്ക്രീൻ ലോക്ക്';

  @override
  String get titleLockdownSection => 'ലോക്ക്ഡൗൺ';

  @override
  String get descEnableAppLock =>
      'ആപ്പ് PIN-ഉം ഐച്ഛികമായ ഫോൺ സ്ക്രീൻ ലോക്ക് ദ്രുത തുറക്കലും ഉപയോഗിച്ച് ആപ്പ് സംരക്ഷിക്കുക';

  @override
  String get labelUseAppPin => 'ആപ്പ് PIN ഉപയോഗിക്കുക';

  @override
  String get descAppPinIsSet => 'ആപ്പ് PIN സജ്ജമാണ്';

  @override
  String get descSetPinHint => 'ആപ്പ് സംരക്ഷണത്തിന് 4–6 അക്ക PIN സജ്ജമാക്കുക';

  @override
  String get descUpdateAppPin => 'നിങ്ങളുടെ ആപ്പ് PIN പുതുക്കുക';

  @override
  String get labelResetRecoveryKey => 'വീണ്ടെടുക്കൽ കീ പുതുക്കൽ';

  @override
  String get descResetRecoveryKey =>
      'നിങ്ങളുടെ ആപ്പ് PIN-ന് പുതിയ വീണ്ടെടുക്കൽ കീ സൃഷ്ടിക്കുക';

  @override
  String get labelUsePhoneLock => 'ഫോൺ ലോക്ക് ഉപയോഗം';

  @override
  String get descPhoneLockOptional => 'ആപ്പ് തുറക്കാനുള്ള ഐച്ഛിക ദ്രുത മാർഗ്ഗം';

  @override
  String get descPhoneLockOnly =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് ഉപയോഗിച്ച് ആപ്പ് തുറക്കുക';

  @override
  String get labelLockdownMode => 'ലോക്ക്ഡൗൺ മോഡ്';

  @override
  String get descLockdownMode =>
      'ഇത് ഓഫാക്കുന്നത് വരെ ദ്രുത തുറക്കൽ ഒഴിവാക്കി ആപ്പ് PIN ആവശ്യപ്പെടുക';

  @override
  String get descInfoPhoneOptional =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് ഐച്ഛികമായ ദ്രുത തുറക്കലാണ്. രഹസ്യങ്ങൾ കാണാൻ ആപ്പ് PIN ആവശ്യമാണ്.';

  @override
  String get descInfoPhoneOnly =>
      'ഫോൺ സ്ക്രീൻ ലോക്ക് മാത്രമാണ് നിങ്ങളുടെ തുറക്കൽ മാർഗ്ഗം. കൂടുതൽ സംരക്ഷണത്തിന് ഒരു ആപ്പ് PIN സജ്ജമാക്കുക.';

  @override
  String get descInfoPhoneLockTypes =>
      'നിങ്ങളുടെ ഉപകരണം അനുസരിച്ച് ഫോൺ സ്ക്രീൻ ലോക്ക് വിരലടയാളം, മുഖം, പാറ്റേൺ, PIN, രഹസ്യവാക്ക് എന്നിവ ഉപയോഗിച്ചേക്കാം.';

  @override
  String get titleSetBackupPassword => 'കരുതൽ രഹസ്യവാക്ക്';

  @override
  String get descSetBackupPassword =>
      'കരുതൽ ഫയൽ സംരക്ഷിക്കാൻ ശക്തമായ ഒരു രഹസ്യവാക്ക് സൃഷ്ടിക്കുക. അക്കൗണ്ടുകൾ പുനഃസ്ഥാപിക്കാൻ ഈ രഹസ്യവാക്ക് ആവശ്യമാണ്.';

  @override
  String get descPasswordMin8 => 'കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ';

  @override
  String get errorPasswordEmpty => 'രഹസ്യവാക്ക് ശൂന്യമാകരുത്';

  @override
  String get errorPasswordTooShort8 =>
      'രഹസ്യവാക്കിന് കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ വേണം';

  @override
  String get actionCreateBackup => 'കരുതൽ സൃഷ്ടിക്കുക';

  @override
  String get errorNoAccountsToBackup => 'കരുതലിന് അക്കൗണ്ടുകളില്ല';

  @override
  String get descBackupCreated =>
      'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ വിജയകരമായി സൃഷ്ടിച്ചു';

  @override
  String get errorBackupCanceledOrFailed =>
      'കരുതൽ റദ്ദാക്കി അല്ലെങ്കിൽ പരാജയപ്പെട്ടു';

  @override
  String get errorBackupFailed =>
      'കരുതൽ സൃഷ്ടിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get titleRestoreAccounts => 'അക്കൗണ്ട് പുനഃസ്ഥാപനം';

  @override
  String get descRestoreAccounts =>
      'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഫയലിൽ നിന്ന് അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യുക. നിലവിലെ അക്കൗണ്ടുകളെ ഇത് ബാധിക്കില്ല.';

  @override
  String get titleEnterBackupPassword => 'കരുതൽ രഹസ്യവാക്ക്';

  @override
  String get descEnterBackupPassword =>
      'ഈ കരുതൽ സൃഷ്ടിക്കുമ്പോൾ ഉപയോഗിച്ച രഹസ്യവാക്ക് നൽകുക:';

  @override
  String get actionRestore => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get errorBackupPassword =>
      'രഹസ്യവാക്ക് തെറ്റാണ്, അല്ലെങ്കിൽ കരുതൽ ഫയൽ കേടായി.';

  @override
  String get errorBackupInvalid =>
      'ഈ കരുതലിലെ ഉള്ളടക്കം സാധുവല്ല, അതിനാൽ ഒന്നും പുനഃസ്ഥാപിച്ചില്ല.';

  @override
  String get errorCameraUnavailable =>
      'ക്യാമറ ലഭ്യമല്ല. വിവരങ്ങൾ നിങ്ങൾക്ക് നേരിട്ട് നൽകാം.';

  @override
  String get errorBackupTooLarge => 'ഈ ഫയൽ കരുതൽ ഫയലാകാൻ വളരെ വലുതാണ്.';

  @override
  String get errorNoAccountsInBackup =>
      'കരുതലിൽ അക്കൗണ്ടുകളൊന്നുമില്ല. രഹസ്യവാക്ക് പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String descAccountsRestored(int count) {
    return 'പുനഃസ്ഥാപിച്ച അക്കൗണ്ടുകൾ: $count';
  }

  @override
  String get errorAccountsLoadFailed =>
      'നിങ്ങളുടെ അക്കൗണ്ടുകൾ തുറക്കാൻ കഴിഞ്ഞില്ല. ആപ്പോ അതിലെ വിവരങ്ങളോ ഇപ്പോൾ ഇല്ലാതാക്കരുത്. ആപ്പ് അടച്ച് വീണ്ടും തുറക്കുക.';

  @override
  String get errorRestoreFailed =>
      'കരുതൽ പുനഃസ്ഥാപിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get titleBackupCreated => 'കരുതൽ സൃഷ്ടിച്ചു';

  @override
  String get descBackupSaved =>
      'നിങ്ങളുടെ എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ വിജയകരമായി സൂക്ഷിച്ചു.';

  @override
  String get titleImportant => 'പ്രധാനം:';

  @override
  String get descBackupTips =>
      '• കരുതൽ ഫയൽ സുരക്ഷിതമായ സ്ഥലത്ത് സൂക്ഷിക്കുക\n• കരുതൽ രഹസ്യവാക്ക് ഓർമ്മിക്കുക\n• രഹസ്യവാക്ക് ഇല്ലാതെ പുനഃസ്ഥാപിക്കാനാവില്ല';

  @override
  String get actionGotIt => 'ശരി';

  @override
  String get actionContinue => 'തുടരുക';

  @override
  String get descBackupsEncrypted =>
      'പരമാവധി സുരക്ഷയ്ക്കായി എല്ലാ കരുതലുകളും രഹസ്യവാക്ക് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുന്നു';

  @override
  String get titleCreateBackupSection => 'കരുതൽ സൃഷ്ടിക്കൽ';

  @override
  String get labelCreateEncryptedBackup => 'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ';

  @override
  String get descCreateEncryptedBackup =>
      'രഹസ്യവാക്ക് സംരക്ഷണത്തോടെ എല്ലാ അക്കൗണ്ടുകളും കയറ്റുമതി ചെയ്യുക';

  @override
  String get titleRestoreBackupSection => 'കരുതൽ പുനഃസ്ഥാപനം';

  @override
  String get labelRestoreFromBackup => 'കരുതലിൽ നിന്ന് പുനഃസ്ഥാപിക്കൽ';

  @override
  String get descRestoreFromBackup =>
      'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഫയലിൽ നിന്ന് അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യുക';

  @override
  String get titleBestPractices => 'മികച്ച രീതികൾ';

  @override
  String get descBestPractices =>
      '• പതിവായി കരുതലുകൾ സൃഷ്ടിക്കുക\n• ശക്തവും അനന്യവുമായ രഹസ്യവാക്ക് ഉപയോഗിക്കുക\n• കരുതലുകൾ പല സുരക്ഷിത സ്ഥലങ്ങളിൽ സൂക്ഷിക്കുക\n• രഹസ്യവാക്ക് ഒരു രഹസ്യവാക്ക് സൂക്ഷിപ്പുകാരനിൽ വയ്ക്കുക\n• പുനഃസ്ഥാപിച്ച് കരുതലുകൾ പരീക്ഷിക്കുക';

  @override
  String get descNeverShareBackups =>
      'കരുതൽ ഫയലുകളോ രഹസ്യവാക്കുകളോ ഒരിക്കലും പങ്കിടരുത്. രണ്ടും ലഭിക്കുന്ന ആർക്കും നിങ്ങളുടെ പ്രാമാണീകരണ കോഡുകൾ സൃഷ്ടിക്കാനാകും.';

  @override
  String get titleRenameTag => 'അടയാളം പുനർനാമകരണം';

  @override
  String get labelTagName => 'അടയാളത്തിന്റെ പേര്';

  @override
  String get descTagNameExample => 'ഉദാ. ജോലി, വ്യക്തിപരം';

  @override
  String get errorTagNameEmpty => 'ദയവായി അടയാളത്തിന്റെ പേര് നൽകുക';

  @override
  String get errorTagNameSame => 'പുതിയ പേര് വ്യത്യസ്തമായിരിക്കണം';

  @override
  String get actionRename => 'പേര് മാറ്റുക';

  @override
  String descTagRenamed(String oldTag, String newTag) {
    return '#$oldTag എന്നത് #$newTag എന്നാക്കി';
  }

  @override
  String get errorRenameTagFailed =>
      'അടയാളത്തിന്റെ പേര് മാറ്റാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get titleDeleteTag => 'അടയാളം ഇല്ലാതാക്കൽ';

  @override
  String descDeleteTagUsed(String tag, int count) {
    return '$count അക്കൗണ്ടുകളിൽ നിന്ന് \"#$tag\" നീക്കണോ?';
  }

  @override
  String descDeleteTagUnused(String tag) {
    return 'ഉപയോഗിക്കാത്ത \"#$tag\" ഇല്ലാതാക്കണോ?';
  }

  @override
  String descTagDeleted(String tag) {
    return '#$tag ഇല്ലാതാക്കി';
  }

  @override
  String get errorDeleteTagFailed =>
      'അടയാളം ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get labelTotalTags => 'ആകെ അടയാളങ്ങൾ';

  @override
  String get labelAccountsTagged => 'അടയാളമുള്ള അക്കൗണ്ടുകൾ';

  @override
  String get emptyNoTagsFound => 'അടയാളങ്ങളൊന്നുമില്ല';

  @override
  String get emptyTagsAppearHere =>
      'അക്കൗണ്ടുകളിൽ ചേർത്ത അടയാളങ്ങൾ ഇവിടെ കാണാം';

  @override
  String get emptyTryDifferentQuery => 'മറ്റൊരു തിരയൽ ശ്രമിക്കുക';

  @override
  String labelAccountCount(int count) {
    return 'അക്കൗണ്ടുകൾ: $count';
  }

  @override
  String get tooltipRenameTag => 'പേര് മാറ്റുക';

  @override
  String get tooltipDeleteTag => 'ഇല്ലാതാക്കുക';

  @override
  String get errorSyncHostTimeout =>
      'സമയത്തിനുള്ളിൽ ഒരു ഉപകരണവും ബന്ധിപ്പിച്ചില്ല; ഹോസ്റ്റിംഗ് നിർത്തി.';

  @override
  String get errorSyncHostStartFailed =>
      'ഹോസ്റ്റിംഗ് ആരംഭിക്കാൻ കഴിഞ്ഞില്ല. Wi-Fi ഓണാണെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get errorSyncNoDevice =>
      'സമന്വയിപ്പിക്കാൻ ഒരു ഉപകരണവും ബന്ധിപ്പിച്ചിട്ടില്ല.';

  @override
  String get errorSyncNothingSelected =>
      'സമന്വയിപ്പിക്കാൻ കുറഞ്ഞത് ഒന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get errorSyncFailed => 'സമന്വയം പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorOpticalStartFailed =>
      'ഒപ്റ്റിക്കൽ സ്ട്രീം ആരംഭിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorOpticalDecodeFailed =>
      'ഒപ്റ്റിക്കൽ സ്ട്രീം വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorSyncNotSyncQr => 'ഇത് ഒരു സമന്വയ QR കോഡ് അല്ല.';

  @override
  String get errorSyncUnsupportedVersion =>
      'ഈ സമന്വയ QR കോഡ് മറ്റൊരു ആപ്പ് പതിപ്പിൽ നിന്നുള്ളതാണ്.';

  @override
  String get errorSyncMissingHost => 'സമന്വയ QR കോഡിൽ ഹോസ്റ്റ് വിലാസമില്ല.';

  @override
  String get errorSyncInvalidPort => 'സമന്വയ QR കോഡിലെ പോർട്ട് അസാധുവാണ്.';

  @override
  String get errorSyncMissingCode => 'സമന്വയ QR കോഡിൽ ജോടിയാക്കൽ കോഡില്ല.';

  @override
  String get errorSyncMalformed =>
      'മറ്റേ ഉപകരണം അയച്ച വിവരങ്ങൾ ഈ ആപ്പിന് വായിക്കാനാവില്ല.';

  @override
  String get errorSyncTooManyAccounts =>
      'മറ്റേ ഉപകരണം വളരെയധികം അക്കൗണ്ടുകൾ അയച്ചു.';

  @override
  String get errorSyncFieldTooLarge =>
      'മറ്റേ ഉപകരണം വളരെ വലിയ ഒരു മൂല്യം അയച്ചു.';

  @override
  String get errorSyncPeerGone => 'മറ്റേ ഉപകരണം ഇപ്പോൾ ബന്ധിപ്പിച്ചിട്ടില്ല.';

  @override
  String get errorSyncSendFailed => 'വിവരങ്ങൾ അയയ്ക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorSyncNoResponse => 'മറ്റേ ഉപകരണത്തിൽ നിന്ന് മറുപടിയില്ല.';

  @override
  String get errorSyncInvalidResponse =>
      'മറ്റേ ഉപകരണത്തിൽ നിന്ന് അപ്രതീക്ഷിത മറുപടി.';

  @override
  String get errorSyncConnectionClosed => 'മറ്റേ ഉപകരണം ബന്ധം അവസാനിപ്പിച്ചു.';

  @override
  String get errorSyncWrongCode => 'തെറ്റായ ജോടിയാക്കൽ കോഡ്.';

  @override
  String get errorSyncTimedOut => 'ബന്ധത്തിന്റെ സമയപരിധി കഴിഞ്ഞു.';

  @override
  String get errorSyncConnectFailed =>
      'മറ്റേ ഉപകരണവുമായി ബന്ധിപ്പിക്കാൻ കഴിഞ്ഞില്ല. IP വിലാസം, പോർട്ട്, Wi-Fi എന്നിവ പരിശോധിക്കുക.';

  @override
  String get errorSyncConnectionError => 'ബന്ധത്തിൽ പിശക്.';

  @override
  String get errorOpticalInvalidFrame =>
      'ഇത് ഒരു ഒപ്റ്റിക്കൽ സമന്വയ കോഡ് അല്ല.';

  @override
  String get errorOpticalUnsupportedVersion =>
      'ഈ ഒപ്റ്റിക്കൽ കോഡ് മറ്റൊരു ആപ്പ് പതിപ്പിൽ നിന്നുള്ളതാണ്.';

  @override
  String get errorOpticalCorruptedChunk =>
      'ഒരു ഫ്രെയിം കേടായി. ക്യാമറ സ്ഥിരമായി പിടിക്കുക.';

  @override
  String get errorOpticalChecksum =>
      'ഒരു ഫ്രെയിം പരിശോധനയിൽ പരാജയപ്പെട്ടു. ക്യാമറ സ്ഥിരമായി പിടിക്കുക.';

  @override
  String get errorOpticalEmpty => 'അയയ്ക്കാൻ ഒന്നുമില്ല.';

  @override
  String get errorOpticalIncomplete => 'എല്ലാ ഫ്രെയിമുകളും ലഭിച്ചില്ല.';

  @override
  String get errorOpticalIntegrity =>
      'ലഭിച്ച വിവരങ്ങൾ സമഗ്രതാ പരിശോധനയിൽ പരാജയപ്പെട്ടു.';

  @override
  String get errorEnterHostIp => 'ഹോസ്റ്റ് IP വിലാസം നൽകുക';

  @override
  String get errorEnterPort => 'മറ്റേ ഉപകരണത്തിൽ കാണുന്ന പോർട്ട് നൽകുക';

  @override
  String get errorEnterPairingCode => 'ജോടിയാക്കൽ കോഡ് നൽകുക';

  @override
  String get titleSendToDevice => 'ഉപകരണത്തിലേക്ക് അയയ്ക്കൽ';

  @override
  String get descConnectingToHost => 'ഹോസ്റ്റുമായി ബന്ധിപ്പിക്കുന്നു…';

  @override
  String get descReceiving => 'സ്വീകരിക്കുന്നു…';

  @override
  String get descP2pInfo =>
      'Wi-Fi സമന്വയം: രണ്ട് ഉപകരണങ്ങളും ഒരേ Wi-Fi-ലോ ഹോട്ട്സ്പോട്ടിലോ ആയിരിക്കണം. ജോടിയാക്കൽ കോഡ് ഒരിക്കലും നിങ്ങളുടെ ഉപകരണം വിട്ടുപോകില്ല.';

  @override
  String get labelSendOverWifi => 'Wi-Fi വഴി അയയ്ക്കുക';

  @override
  String get descSendOverWifi =>
      'ഹോസ്റ്റ്: പ്രാദേശിക Wi-Fi വഴി അക്കൗണ്ടുകളും ക്രമീകരണങ്ങളും പങ്കിടുക';

  @override
  String get labelReceiveOverWifi => 'Wi-Fi വഴി സ്വീകരിക്കുക';

  @override
  String get descReceiveOverWifi =>
      'ചേരുക: ഹോസ്റ്റ് QR സ്കാൻ ചെയ്യുക അല്ലെങ്കിൽ ഹോസ്റ്റ് IP നൽകുക';

  @override
  String get descOpticalSectionHeader =>
      'ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് സമന്വയം (Wi-Fi ഇല്ല, നെറ്റ്‌വർക്ക് ഇല്ല)';

  @override
  String get labelOpticalSend => 'ഒപ്റ്റിക്കൽ സ്ട്രീം അയയ്ക്കുക';

  @override
  String get descOpticalSend =>
      'അക്കൗണ്ടുകൾ ചലിക്കുന്ന QR സ്ട്രീമായി അയയ്ക്കുക (10–15 FPS)';

  @override
  String get labelOpticalReceive => 'ഒപ്റ്റിക്കൽ സ്ട്രീം സ്കാൻ';

  @override
  String get descOpticalReceive =>
      'ക്യാമറ ഉപയോഗിച്ച് ചലിക്കുന്ന QR സ്ട്രീം പകർത്തുക';

  @override
  String get descScanOtherQrHeader => 'മറ്റേ ഉപകരണത്തിലെ QR സ്കാൻ ചെയ്യുക';

  @override
  String get actionScanQrCode => 'QR സ്കാൻ ചെയ്യുക';

  @override
  String get labelOrEnterManually => 'അല്ലെങ്കിൽ സ്വയം നൽകുക';

  @override
  String get labelHostIp => 'ഹോസ്റ്റ് IP വിലാസം';

  @override
  String get labelPort => 'പോർട്ട്';

  @override
  String get labelPairingCode => 'ജോടിയാക്കൽ കോഡ്';

  @override
  String get actionConnectReceive => 'ബന്ധിപ്പിച്ച് സ്വീകരിക്കുക';

  @override
  String get actionBack => 'പിന്നോട്ട്';

  @override
  String get titleConnected => 'ബന്ധിപ്പിച്ചു';

  @override
  String get descWaitingForSender =>
      'എന്ത് പങ്കിടണമെന്ന് അയയ്ക്കുന്നയാൾ തിരഞ്ഞെടുക്കുന്നതിനായി കാത്തിരിക്കുന്നു…';

  @override
  String get titleSyncComplete => 'സമന്വയം പൂർത്തിയായി';

  @override
  String descSentAccounts(int count) {
    return 'അയച്ച അക്കൗണ്ടുകൾ: $count';
  }

  @override
  String descSentSettings(int count) {
    return 'അയച്ച ക്രമീകരണങ്ങൾ: $count';
  }

  @override
  String descAddedAccounts(int count) {
    return 'ചേർത്ത അക്കൗണ്ടുകൾ: $count';
  }

  @override
  String descAddedAccountsSkipped(int count, int skipped) {
    return 'ചേർത്ത അക്കൗണ്ടുകൾ: $count ($skipped എണ്ണം നേരത്തെ ഉണ്ടായിരുന്നു, നിലനിർത്തി)';
  }

  @override
  String descAppliedSettings(int count) {
    return 'പ്രയോഗിച്ച ക്രമീകരണങ്ങൾ: $count';
  }

  @override
  String get descNothingToSync => 'സമന്വയിപ്പിക്കാൻ ഒന്നുമില്ല.';

  @override
  String get titleSyncFailed => 'സമന്വയം പരാജയപ്പെട്ടു';

  @override
  String get tabServerDetails => 'സെർവർ വിവരങ്ങൾ';

  @override
  String get tabSync => 'സമന്വയം';

  @override
  String get descReceiveHint =>
      'മറ്റേ ഉപകരണത്തിൽ “Wi-Fi വഴി സ്വീകരിക്കുക” → “QR സ്കാൻ ചെയ്യുക” തിരഞ്ഞെടുക്കുക';

  @override
  String get descEnterManuallyHint => 'അല്ലെങ്കിൽ ഇവ സ്വയം നൽകുക';

  @override
  String get labelHostIpShort => 'ഹോസ്റ്റ് IP';

  @override
  String get actionCopyCode => 'കോഡ് പകർത്തുക';

  @override
  String get descPairingCodeCopied =>
      'ജോടിയാക്കൽ കോഡ് പകർത്തി. 60 സെക്കൻഡ് കഴിഞ്ഞ് ഇത് ക്ലിപ്പ്ബോർഡിൽ നിന്ന് മായ്ക്കും.';

  @override
  String get actionStopHosting => 'ഹോസ്റ്റിംഗ് നിർത്തുക';

  @override
  String get descClientConnected =>
      'ഒരു ഉപകരണം ബന്ധിപ്പിച്ചു. എന്ത് പങ്കിടണമെന്ന് തിരഞ്ഞെടുക്കാൻ സമന്വയം ടാബ് തുറക്കുക.';

  @override
  String get descWaitingForClient =>
      'മറ്റേ ഉപകരണം ബന്ധിപ്പിക്കുന്നതിനായി കാത്തിരിക്കുന്നു…';

  @override
  String get descNoClientYet =>
      'ഇതുവരെ ഒരു ഉപകരണവും ബന്ധിപ്പിച്ചിട്ടില്ല. സെർവർ വിവരങ്ങൾ ടാബ് തുറന്ന് മറ്റേ ഉപകരണത്തിൽ QR സ്കാൻ ചെയ്യുകയോ കോഡ് നൽകുകയോ ചെയ്യുക.';

  @override
  String get titleNewClientPhone => 'പുതിയ ഫോൺ';

  @override
  String get descFullSync =>
      'ആദ്യമായി സജ്ജീകരിക്കുന്ന ഫോണിലേക്ക് എല്ലാം — എല്ലാ അക്കൗണ്ടുകളും ആപ്പ് ക്രമീകരണങ്ങളും — അയയ്ക്കുക. ഉപകരണത്തിന് മാത്രമുള്ളവ (ആപ്പ് ലോക്ക്, PIN, ഫോൺ ലോക്ക്, വീണ്ടെടുക്കൽ കീ) അയയ്ക്കില്ല.';

  @override
  String get actionFullSync => 'പൂർണ്ണ സമന്വയം';

  @override
  String get titleSyncToPhone => 'ഒരു ഫോണിലേക്ക്';

  @override
  String get descSelectiveSync =>
      'സ്വന്തം വിവരങ്ങളോടെ ആപ്പ് ഇതിനകം ഉള്ള ഫോണിന്. എന്ത് ചേർക്കണമെന്ന് തിരഞ്ഞെടുക്കുക:';

  @override
  String get labelSyncAccounts => 'അക്കൗണ്ടുകൾ';

  @override
  String get labelSyncSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get descSyncSettings => 'തീം, സ്വയം ലോക്ക്, സമന്വയ സമയപരിധികൾ';

  @override
  String get descNoOverride =>
      'ഇത് മറ്റേ ഉപകരണത്തിൽ ഉള്ള ഒന്നും മാറ്റിയെഴുതില്ല. എന്തെങ്കിലും പൊരുത്തപ്പെട്ടാൽ മറ്റേ ഉപകരണം സ്വന്തം പതിപ്പ് നിലനിർത്തും — അതിലെ വിവരങ്ങൾ നിലനിൽക്കും.';

  @override
  String get actionSync => 'സമന്വയിപ്പിക്കുക';

  @override
  String get descSyncing => 'സമന്വയിപ്പിക്കുന്നു…';

  @override
  String labelDurationSeconds(int seconds) {
    return '~$seconds സെ.';
  }

  @override
  String labelDurationMinutes(int minutes) {
    return '~$minutes മിനി.';
  }

  @override
  String labelDurationMinSec(int minutes, int seconds) {
    return '~$minutes മിനി. $seconds സെ.';
  }

  @override
  String get titleOpticalSend => 'ഒപ്റ്റിക്കൽ സ്ട്രീം';

  @override
  String get titleOpticalScan => 'ഒപ്റ്റിക്കൽ സ്കാൻ';

  @override
  String get descReconstructing => 'അക്കൗണ്ടുകൾ പുനർനിർമ്മിക്കുന്നു…';

  @override
  String get titleLargeVaultWarning => 'വലിയ ഡാറ്റ മുന്നറിയിപ്പ്';

  @override
  String descLargeVault(int chunks, String duration) {
    return 'ഈ കൈമാറ്റത്തിൽ $chunks ഭാഗങ്ങളുണ്ട് (ഏകദേശം $duration). ക്യാമറ QR വഴി ധാരാളം വിവരങ്ങൾ അയയ്ക്കാൻ സമയമെടുക്കും. വേഗത്തിന് Wi-Fi സമന്വയം പരിഗണിക്കുക.';
  }

  @override
  String get descPointReceiver =>
      'സ്വീകരിക്കുന്ന ഉപകരണത്തിന്റെ ക്യാമറ ഈ ചലിക്കുന്ന QR സ്ട്രീമിലേക്ക് തിരിക്കുക. വിവരങ്ങൾ കൈമാറ്റ കോഡ് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്തതാണ്; നെറ്റ്‌വർക്ക് ഉപയോഗിക്കുന്നില്ല.';

  @override
  String get labelStreamHash => 'സ്ട്രീം ഹാഷ്:';

  @override
  String get labelEstDuration => 'ഏകദേശ സമയം:';

  @override
  String get labelFramesRendered => 'കാണിച്ച ഫ്രെയിമുകൾ:';

  @override
  String labelFramesValue(int frame, int total) {
    return '$frame (ഭാഗങ്ങൾ: $total)';
  }

  @override
  String get labelTargetFps => 'ലക്ഷ്യ FPS:';

  @override
  String labelFps(int fps) {
    return '$fps FPS';
  }

  @override
  String labelRemaining(String time) {
    return '$time ബാക്കി';
  }

  @override
  String get descAlignCamera =>
      'ക്യാമറ അയയ്ക്കുന്ന സ്ക്രീനിലേക്ക് നേരെയാക്കുക…';

  @override
  String get descReconstructingStream => 'സ്ട്രീം പുനർനിർമ്മിക്കുന്നു…';

  @override
  String descCaptured(int solved, int total) {
    return 'ലഭിച്ചത്: $solved / $total ഭാഗങ്ങൾ';
  }

  @override
  String labelSession(String hash) {
    return 'സെഷൻ: $hash';
  }

  @override
  String get titleOpticalComplete => 'ഒപ്റ്റിക്കൽ സമന്വയം പൂർത്തി';

  @override
  String get descOpticalComplete =>
      'ഒപ്റ്റിക്കൽ QR സ്ട്രീമിൽ നിന്ന് അക്കൗണ്ടുകൾ പുനർനിർമ്മിച്ചു.';

  @override
  String get titleOpticalFailed => 'ഒപ്റ്റിക്കൽ സമന്വയം പരാജയം';

  @override
  String get titleScanSyncQr => 'സമന്വയ QR സ്കാൻ';

  @override
  String get descScanSenderQr =>
      'അയയ്ക്കുന്ന ഉപകരണത്തിൽ കാണുന്ന QR സ്കാൻ ചെയ്യുക';

  @override
  String get descFeatures01 => 'പ്രധാന 2FA, OTP ഉപകരണങ്ങൾ';

  @override
  String get descFeatures02 =>
      'മാനദണ്ഡങ്ങൾ പാലിക്കുന്ന കോഡ് സൃഷ്ടിയും സ്കാനിംഗും';

  @override
  String get descFeatures03 => 'TOTP സമയാധിഷ്ഠിത കോഡുകൾ';

  @override
  String get descFeatures04 =>
      'RFC 6238 പാലിക്കുന്ന സുരക്ഷിത സമയാധിഷ്ഠിത ഒറ്റത്തവണ പാസ്കോഡുകൾ സൃഷ്ടിക്കുന്നു. 30 അല്ലെങ്കിൽ 60 സെക്കൻഡ് കാലയളവ്, 6 അല്ലെങ്കിൽ 8 അക്കങ്ങൾ, SHA-1, SHA-256, SHA-512 എന്നിവ പിന്തുണയ്ക്കുന്നു.';

  @override
  String get descFeatures05 => 'RFC 6238 മാനദണ്ഡം';

  @override
  String get descFeatures06 => 'SHA-1/256/512';

  @override
  String get descFeatures07 => '30 സെ. അല്ലെങ്കിൽ 60 സെ.';

  @override
  String get descFeatures08 => 'തത്സമയ വലയ ടൈമർ';

  @override
  String get descFeatures09 => 'HOTP കൗണ്ടർ കോഡുകൾ';

  @override
  String get descFeatures10 =>
      'HOTP QR കോഡുകളിൽ നിന്നുള്ള കൗണ്ടർ അധിഷ്ഠിത കോഡുകൾ (RFC 4226). ഓരോ പുതിയ കോഡിനും അടുത്ത കോഡ് ബട്ടൺ അമർത്തുക. കോഡ് കാണിക്കുന്നതിന് മുമ്പ് കൗണ്ടർ സൂക്ഷിക്കും.';

  @override
  String get descFeatures11 => 'QR കോഡ് വഴി ചേർക്കൽ';

  @override
  String get descFeatures12 => 'കൗണ്ടർ സൂക്ഷിക്കും';

  @override
  String get descFeatures13 => 'ഒരു സ്പർശം, ഒരു കോഡ്';

  @override
  String get descFeatures14 => 'വേഗത്തിലുള്ള QR സ്കാനർ';

  @override
  String get descFeatures15 =>
      'സാധാരണ 2FA QR കോഡുകളിലേക്ക് (otpauth://) ക്യാമറ തിരിച്ച് അക്കൗണ്ടുകൾ ചേർക്കുക, അല്ലെങ്കിൽ Google Authenticator എക്സ്പോർട്ട് QR കോഡിൽ നിന്ന് പലതും ഒരുമിച്ച് ഇറക്കുമതി ചെയ്യുക. ഫ്ലാഷ്‌ലൈറ്റും ഉടനടി പരിശോധനയും ഉണ്ട്.';

  @override
  String get descFeatures16 => 'വേഗത്തിലുള്ള കണ്ടെത്തൽ';

  @override
  String get descFeatures17 => 'ഫ്ലാഷ്‌ലൈറ്റ് പിന്തുണ';

  @override
  String get descFeatures18 => 'സുരക്ഷിത പരിശോധന';

  @override
  String get descFeatures19 => 'ബ്രാൻഡ് ഐക്കണുകൾ';

  @override
  String get descFeatures20 =>
      'സാധാരണ സേവനങ്ങൾക്ക് (Apple, AWS, Binance, Discord, GitHub, Google, Microsoft, Nintendo, Proton, Steam) ബ്രാൻഡ് ലോഗോയും മറ്റുള്ളവയ്ക്ക് നിറമുള്ള ആദ്യാക്ഷരങ്ങളും കാണിക്കുന്നു.';

  @override
  String get descFeatures21 => '10 ബ്രാൻഡുകൾ';

  @override
  String get descFeatures22 => 'നിറമുള്ള ആദ്യാക്ഷരങ്ങൾ';

  @override
  String get descFeatures23 => 'സ്വയം പൊരുത്തപ്പെടുത്തൽ';

  @override
  String get descFeatures24 => 'വേഗത്തിലുള്ള പകർപ്പും സമയവും';

  @override
  String get descFeatures25 =>
      'ഏത് കോഡും അമർത്തിയാൽ സ്പർശ പ്രതികരണത്തോടെ ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തും. കോഡ് എത്ര സമയം സാധുവാണെന്ന് വൃത്താകൃതിയിലുള്ള ടൈമർ കാണിക്കുന്നു.';

  @override
  String get descFeatures26 => 'ഒറ്റ സ്പർശത്തിൽ പകർപ്പ്';

  @override
  String get descFeatures27 => 'സ്പർശ പ്രതികരണം';

  @override
  String get descFeatures28 => 'സുഗമ പുരോഗതി വലയം';

  @override
  String get descFeatures29 => 'നിലവറ സുരക്ഷയും സ്വകാര്യതയും';

  @override
  String get descFeatures30 =>
      'ശക്തമായ എൻക്രിപ്ഷൻ, ബയോമെട്രിക്, ഒട്ടും ട്രാക്കിംഗ് ഇല്ല';

  @override
  String get descFeatures31 => 'AES-256-GCM എൻക്രിപ്ഷൻ';

  @override
  String get descFeatures32 =>
      'എല്ലാ അക്കൗണ്ട് രഹസ്യങ്ങളും AES-256-GCM ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത് സൂക്ഷിക്കുന്നു. ഉപകരണ കീ Android Keystore-ൽ സൂക്ഷിക്കുന്നു (പിന്തുണയ്ക്കുന്ന ഫോണുകളിൽ ഹാർഡ്‌വെയർ സംരക്ഷണത്തോടെ).';

  @override
  String get descFeatures33 => 'AES-256-GCM';

  @override
  String get descFeatures34 => 'Android Keystore';

  @override
  String get descFeatures35 => 'സംഭരണത്തിൽ തുറന്ന രഹസ്യമില്ല';

  @override
  String get descFeatures36 => 'ബയോമെട്രിക്, സ്ക്രീൻ ആപ്പ് ലോക്ക്';

  @override
  String get descFeatures37 =>
      'വിരലടയാളം, മുഖം, ഫോൺ സ്ക്രീൻ ലോക്ക്, അല്ലെങ്കിൽ ആപ്പ് PIN ഉപയോഗിച്ച് ആപ്പ് പൂട്ടുക. നിങ്ങളുടെ ഫോൺ എടുക്കുന്നവരിൽ നിന്ന് കോഡുകൾ സുരക്ഷിതമായിരിക്കും.';

  @override
  String get descFeatures38 => 'വിരലടയാളം / മുഖം';

  @override
  String get descFeatures39 => 'ഫോൺ ലോക്ക് പകരം';

  @override
  String get descFeatures40 => 'വേഗത്തിൽ തുറക്കൽ';

  @override
  String get descFeatures41 => 'സ്വയം ലോക്ക്';

  @override
  String get descFeatures42 =>
      'മറ്റ് ആപ്പിലേക്ക് മാറുമ്പോഴോ ആപ്പ് ചെറുതാക്കുമ്പോഴോ ഫോൺ ഉറങ്ങുമ്പോഴോ ആപ്പ് പൂട്ടുകയും തുറന്ന കോഡുകൾ മെമ്മറിയിൽ നിന്ന് നീക്കുകയും ചെയ്യുന്നു.';

  @override
  String get descFeatures43 => 'പശ്ചാത്തല ലോക്ക്';

  @override
  String get descFeatures44 => 'മെമ്മറി വൃത്തിയാക്കൽ';

  @override
  String get descFeatures45 => 'മാറ്റാവുന്ന സമയപരിധി';

  @override
  String get descFeatures46 => 'സ്ക്രീൻഷോട്ട് സംരക്ഷണം (FLAG_SECURE)';

  @override
  String get descFeatures47 =>
      'സ്വതവേ ഓണാണ്. സ്ക്രീൻഷോട്ടുകൾ, സ്ക്രീൻ റെക്കോർഡിംഗ്, സമീപകാല ആപ്പ് ചിത്രങ്ങൾ എന്നിവ തടയുന്നു; അതിനാൽ സ്ക്രീനിൽ നിന്ന് കോഡുകൾ പകർത്താനാവില്ല.';

  @override
  String get descFeatures48 => 'FLAG_SECURE';

  @override
  String get descFeatures49 => 'സമീപകാല കാഴ്ചയില്ല';

  @override
  String get descFeatures50 => 'സ്ക്രീൻ പകർപ്പില്ല';

  @override
  String get descFeatures51 => 'ഓഫ്‌ലൈൻ, ടെലിമെട്രി ഇല്ല';

  @override
  String get descFeatures52 =>
      'പൂർണ്ണമായും ഉപകരണത്തിൽ പ്രവർത്തിക്കുന്നു: ഇന്റർനെറ്റ് സെർവർ, ക്ലൗഡ് ലോഗിൻ, അനലിറ്റിക്സ്, ക്രാഷ് റിപ്പോർട്ട്, ട്രാക്കിംഗ് എന്നിവ ഇല്ല. Wi-Fi സമന്വയം പ്രാദേശിക നെറ്റ്‌വർക്ക് മാത്രം ഉപയോഗിക്കുന്നു.';

  @override
  String get descFeatures53 => 'പൂർണ്ണമായും ഓഫ്‌ലൈൻ';

  @override
  String get descFeatures54 => 'അനലിറ്റിക്സ് ഇല്ല';

  @override
  String get descFeatures55 => 'ക്ലൗഡ് അക്കൗണ്ട് ഇല്ല';

  @override
  String get descFeatures56 => 'രഹസ്യങ്ങൾ എൻക്രിപ്റ്റ് ചെയ്തിരിക്കും';

  @override
  String get descFeatures57 => 'ക്രമീകരണവും ഉൽപ്പാദനക്ഷമതയും';

  @override
  String get descFeatures58 =>
      'അക്കൗണ്ടുകൾ തരംതിരിക്കുക, തിരയുക, നിയന്ത്രിക്കുക';

  @override
  String get descFeatures59 => 'ഒന്നിലധികം അടയാളങ്ങൾ';

  @override
  String get descFeatures60 =>
      'ഏത് അക്കൗണ്ടിനും നിരവധി അടയാളങ്ങൾ നൽകാം (ഉദാ. ജോലി, വ്യക്തിപരം, സാമ്പത്തികം). ഫിൽട്ടർ ബാറിൽ ഒറ്റ സ്പർശത്തിൽ അടയാളം അനുസരിച്ച് അക്കൗണ്ടുകൾ അരിച്ചെടുക്കാം.';

  @override
  String get descFeatures61 => 'ഒരു അക്കൗണ്ടിന് പല അടയാളം';

  @override
  String get descFeatures62 => 'അടയാള ചിപ്പുകൾ';

  @override
  String get descFeatures63 => 'ഒറ്റ സ്പർശ അരിപ്പ്';

  @override
  String get descFeatures64 => 'അടയാള മേഘം';

  @override
  String get descFeatures65 =>
      'എല്ലാ അടയാളങ്ങളും ഓരോന്നിനും എത്ര അക്കൗണ്ടുകൾ ഉണ്ടെന്നും അടയാള മേഘം കാണിക്കുന്നു. ഒരു അടയാളം അമർത്തിയാൽ അതിന്റെ അക്കൗണ്ടുകൾ മാത്രം കാണാം.';

  @override
  String get descFeatures66 => 'ദൃശ്യ അടയാള കാഴ്ച';

  @override
  String get descFeatures67 => 'അക്കൗണ്ട് എണ്ണം';

  @override
  String get descFeatures68 => 'വേഗത്തിലുള്ള നീക്കം';

  @override
  String get descFeatures69 => 'തത്സമയ തിരയൽ';

  @override
  String get descFeatures70 =>
      'പേര്, ഉപയോക്തൃനാമം, സേവനം അല്ലെങ്കിൽ അടയാളം ടൈപ്പ് ചെയ്ത് ഏത് അക്കൗണ്ടും കണ്ടെത്തുക; ടൈപ്പ് ചെയ്യുമ്പോൾ ഫലങ്ങൾ മാറും.';

  @override
  String get descFeatures71 => 'തത്സമയ തിരയൽ';

  @override
  String get descFeatures72 => 'പേരുകളും അടയാളങ്ങളും';

  @override
  String get descFeatures73 => 'ഉടനടി ഫലം';

  @override
  String get descFeatures74 => 'ക്രമപ്പെടുത്തലും തിരുത്തലും';

  @override
  String get descFeatures75 =>
      'അക്കൗണ്ടുകൾ ഇഷ്ടമുള്ള ക്രമത്തിൽ വയ്ക്കുക; ആവശ്യമെങ്കിൽ പേര്, സേവനം, കോഡ് ക്രമീകരണങ്ങൾ എന്നിവ മാറ്റുക.';

  @override
  String get descFeatures76 => 'വലിച്ച് ക്രമം മാറ്റുക';

  @override
  String get descFeatures77 => 'വിവരങ്ങൾ തിരുത്തുക';

  @override
  String get descFeatures78 => 'കൂട്ട പ്രവർത്തനങ്ങൾ';

  @override
  String get descFeatures79 => 'സമന്വയം, എയർ-ഗ്യാപ്പ്, കരുതൽ';

  @override
  String get descFeatures80 =>
      'അക്കൗണ്ടുകൾ സുരക്ഷിതമായി മാറ്റുക, എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ കയറ്റുമതി ചെയ്യുക';

  @override
  String get descFeatures81 => 'Wi-Fi സമന്വയം';

  @override
  String get descFeatures82 =>
      'പ്രാദേശിക Wi-Fi-ലെ രണ്ട് ഉപകരണങ്ങൾക്കിടയിൽ അക്കൗണ്ടുകൾ മാറ്റുക. QR ആയി കാണിക്കുന്ന ജോടിയാക്കൽ കോഡ് കൈമാറ്റം സംരക്ഷിക്കുന്നു; ആ കോഡിൽ നിന്നുള്ള കീ ഉപയോഗിച്ച് വിവരങ്ങൾ എൻക്രിപ്റ്റ് ചെയ്യുന്നു. ഇന്റർനെറ്റ് ഉപയോഗിക്കുന്നില്ല.';

  @override
  String get descFeatures83 => 'പ്രാദേശിക Wi-Fi മാത്രം';

  @override
  String get descFeatures84 => 'എൻക്രിപ്റ്റ് ചെയ്ത കൈമാറ്റം';

  @override
  String get descFeatures85 => 'ക്ലൗഡ് ഇല്ല';

  @override
  String get descFeatures86 => 'ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ്';

  @override
  String get descFeatures87 =>
      'Wi-Fi-ഓ ബ്ലൂടൂത്തോ ഇല്ലാതെ ചലിക്കുന്ന QR കോഡുകൾ വഴി ഓഫ്‌ലൈൻ ഉപകരണത്തിലേക്ക് അക്കൗണ്ടുകൾ മാറ്റുക. നിങ്ങൾ ടൈപ്പ് ചെയ്യുന്ന ഒറ്റത്തവണ കോഡ് ഉപയോഗിച്ച് QR കോഡുകൾ എൻക്രിപ്റ്റ് ചെയ്യുന്നു.';

  @override
  String get descFeatures88 => 'നെറ്റ്‌വർക്ക് ഇല്ല';

  @override
  String get descFeatures89 => 'ചലിക്കുന്ന QR';

  @override
  String get descFeatures90 => 'എൻക്രിപ്റ്റ് ചെയ്ത സ്ട്രീം';

  @override
  String get descFeatures91 => 'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ';

  @override
  String get descFeatures92 =>
      'എല്ലാ അക്കൗണ്ടുകളും നിങ്ങളുടെ രഹസ്യവാക്ക് സംരക്ഷിക്കുന്ന എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഫയലിലേക്ക് കയറ്റുമതി ചെയ്യുക (PBKDF2 കീ ഉള്ള AES-256).';

  @override
  String get descFeatures93 => 'AES-256 എൻക്രിപ്ഷൻ';

  @override
  String get descFeatures94 => 'രഹസ്യവാക്ക് സംരക്ഷണം';

  @override
  String get descFeatures95 => 'കൊണ്ടുപോകാവുന്ന ഫയൽ';

  @override
  String get descFeatures96 => 'സുരക്ഷിത ഇറക്കുമതി';

  @override
  String get descFeatures97 =>
      'കരുതലുകൾ ഇറക്കുമതി ചെയ്യുകയോ സമന്വയ വിവരങ്ങൾ സ്വീകരിക്കുകയോ സുരക്ഷിതമായി ചെയ്യാം. നിലവിലെ അക്കൗണ്ടുകൾ നിലനിർത്തി പുതിയവ ചേർക്കുന്നു; ഒന്നും മാറ്റിയെഴുതില്ല.';

  @override
  String get descFeatures98 => 'ചേർക്കൽ മാത്രം';

  @override
  String get descFeatures99 => 'ഇരട്ടിപ്പ് സംരക്ഷണം';

  @override
  String get descFeatures100 => 'ഇറക്കുമതി സംഗ്രഹം';

  @override
  String get descFeatures101 => 'സവിശേഷതകൾ';

  @override
  String descFeatures102(String appName) {
    return '$appName സവിശേഷതകൾ';
  }

  @override
  String get descFeatures103 =>
      'ആപ്പിലെ എല്ലാ സുരക്ഷാ സംവിധാനങ്ങളും കോഡ് ഉപകരണങ്ങളും പരിചയപ്പെടുക.';

  @override
  String get helpHome01 => 'സഹായ കേന്ദ്രം';

  @override
  String get helpHome02 => 'പ്രാമാണീകരണവും സജ്ജീകരണവും';

  @override
  String get helpHome03 => 'തുടക്കവും അക്കൗണ്ട് ചേർക്കലും';

  @override
  String get helpHome04 =>
      'QR കോഡുകൾ സ്കാൻ ചെയ്യുന്നതും രഹസ്യ കീകൾ സ്വയം ചേർക്കുന്നതും 2FA കോഡുകൾ ഉപയോഗിക്കുന്നതും എങ്ങനെ.';

  @override
  String get helpHome05 => 'സമയ ക്രമീകരണവും കോഡ് വ്യതിയാനവും';

  @override
  String get helpHome06 =>
      'നിരസിക്കപ്പെട്ട കോഡുകൾ, ഫോൺ ഘടികാര വ്യതിയാനം, HOTP കൗണ്ടർ കോഡുകൾ എന്നിവ പരിഹരിക്കൽ.';

  @override
  String get helpHome07 => 'അടയാളങ്ങളും അക്കൗണ്ട് ക്രമീകരണവും';

  @override
  String get helpHome08 =>
      'അടയാളങ്ങൾ ചേർക്കൽ, അക്കൗണ്ടുകൾ അരിച്ചെടുക്കൽ, അടയാള മേഘം, അടയാള നിർവഹണം.';

  @override
  String get helpHome09 => 'സുരക്ഷയും നിലവറ സംരക്ഷണവും';

  @override
  String get helpHome10 => 'ബയോമെട്രിക്, ആപ്പ് ലോക്ക്';

  @override
  String get helpHome11 =>
      'വിരലടയാളം, മുഖം, ഫോൺ സ്ക്രീൻ ലോക്ക്, സ്വയം ലോക്ക് നിയമങ്ങൾ.';

  @override
  String get helpHome12 => 'നിലവറയും സ്ക്രീൻഷോട്ട് സംരക്ഷണവും';

  @override
  String get helpHome13 =>
      'Android Keystore കീ സംഭരണം, FLAG_SECURE സ്ക്രീൻ സംരക്ഷണം, ഓഫ്‌ലൈൻ സ്വകാര്യത.';

  @override
  String get helpHome14 => 'സമന്വയവും കരുതലും';

  @override
  String get helpHome15 => 'Wi-Fi സമന്വയം';

  @override
  String get helpHome16 =>
      'ജോടിയാക്കൽ കോഡിൽ നിന്നുള്ള കീ ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത്, പ്രാദേശിക Wi-Fi വഴി നേരിട്ടുള്ള ഉപകരണ കൈമാറ്റം.';

  @override
  String get helpHome17 => 'ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ് കൈമാറ്റം';

  @override
  String get helpHome18 =>
      'ചലിക്കുന്ന QR കോഡുകൾ വഴി ഓഫ്‌ലൈൻ ഉപകരണത്തിലേക്ക് അക്കൗണ്ടുകൾ മാറ്റുക.';

  @override
  String get helpHome19 => 'എൻക്രിപ്റ്റ് ചെയ്ത കരുതലും പുനഃസ്ഥാപനവും';

  @override
  String get helpHome20 =>
      'രഹസ്യവാക്ക് സംരക്ഷിത കരുതൽ ഫയലുകൾ ഉണ്ടാക്കലും പുതിയ ഫോണിൽ അക്കൗണ്ടുകൾ പുനഃസ്ഥാപിക്കലും.';

  @override
  String get helpHome21 => 'പതിവ് ചോദ്യങ്ങൾ';

  @override
  String get helpHome22 => 'ചോദ്യങ്ങളും പ്രശ്നപരിഹാരവും';

  @override
  String get helpHome23 =>
      'കോഡുകൾ, കരുതൽ, അനുമതികൾ, പുതിയ ഫോണിലേക്ക് മാറൽ എന്നിവയെക്കുറിച്ചുള്ള ലഘു ഉത്തരങ്ങൾ.';

  @override
  String get helpHome24 => 'സഹായ കേന്ദ്രവും മാർഗ്ഗനിർദ്ദേശങ്ങളും';

  @override
  String helpHome25(String appName) {
    return '$appName-ന്റെ എല്ലാ സവിശേഷതകൾക്കുമുള്ള മാർഗ്ഗനിർദ്ദേശങ്ങളും ഉത്തരങ്ങളും.';
  }

  @override
  String get helpStart01 => 'തുടക്കം';

  @override
  String helpStart02(String appName) {
    return 'ഓൺലൈൻ അക്കൗണ്ടുകൾ സംരക്ഷിക്കുന്ന ടു-ഫാക്ടർ (2FA) കോഡുകൾ $appName സൃഷ്ടിക്കുന്നു. എല്ലാ കോഡുകളും ഇന്റർനെറ്റ് ഇല്ലാതെ നിങ്ങളുടെ ഉപകരണത്തിൽ തന്നെ ഉണ്ടാക്കുന്നു.';
  }

  @override
  String get helpStart03 => 'QR കോഡ് വഴി അക്കൗണ്ട് ചേർക്കൽ';

  @override
  String get helpStart04 =>
      'സേവനത്തിൽ (ഉദാ. Google, GitHub, Amazon) സുരക്ഷ അല്ലെങ്കിൽ 2FA ക്രമീകരണങ്ങൾ തുറന്ന് ഓതന്റിക്കേറ്റർ ആപ്പ് സജ്ജമാക്കാൻ തിരഞ്ഞെടുക്കുക.';

  @override
  String helpStart05(String appName, String qrScanner) {
    return '$appName-ൽ ഹോം സ്ക്രീനിലെ “+” ബട്ടൺ അമർത്തി “$qrScanner” തിരഞ്ഞെടുക്കുക.';
  }

  @override
  String get helpStart06 =>
      'കമ്പ്യൂട്ടറിലോ മറ്റ് സ്ക്രീനിലോ ഉള്ള QR കോഡിലേക്ക് ക്യാമറ തിരിക്കുക. അക്കൗണ്ട് ഉടൻ പരിശോധിച്ച് ചേർക്കും.';

  @override
  String get helpStart07 => 'അക്കൗണ്ട് സ്വയം ചേർക്കൽ';

  @override
  String helpStart08(String manualEntry) {
    return 'QR കോഡ് സ്കാൻ ചെയ്യാനാകില്ലെങ്കിൽ, ചേർക്കൽ മെനുവിൽ നിന്ന് “$manualEntry” തിരഞ്ഞെടുക്കുക.';
  }

  @override
  String get helpStart09 =>
      'അക്കൗണ്ട് പേരും (ഉദാ. ഇമെയിൽ അല്ലെങ്കിൽ ഉപയോക്തൃനാമം) നൽകുന്നയാളും (ഉദാ. GitHub, Google) നൽകുക.';

  @override
  String get helpStart10 => 'സേവനം നൽകുന്ന രഹസ്യ കീ (Base32) ഒട്ടിക്കുക.';

  @override
  String get helpStart11 =>
      'വിപുലമായ ക്രമീകരണങ്ങളിൽ അൽഗോരിതം (SHA1, SHA256, SHA512), അക്കങ്ങൾ (6 അല്ലെങ്കിൽ 8), കാലയളവ് (30 അല്ലെങ്കിൽ 60 സെക്കൻഡ്) എന്നിവ ക്രമീകരിക്കാം.';

  @override
  String get helpStart12 => '2FA കോഡുകൾ ഉപയോഗിക്കൽ';

  @override
  String get helpStart13 =>
      'സമയാധിഷ്ഠിത (TOTP) കോഡുകൾ സാധാരണയായി ഓരോ 30 സെക്കൻഡിലും മാറും. കോഡ് എത്ര സമയം സാധുവാണെന്ന് കൗണ്ട്ഡൗൺ വലയം കാണിക്കും.';

  @override
  String get helpStart14 =>
      'ഏത് അക്കൗണ്ടും അമർത്തിയാൽ അതിന്റെ നിലവിലെ കോഡ് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തും.';

  @override
  String get helpStart15 =>
      'വെബ്സൈറ്റിന്റെയോ സേവനത്തിന്റെയോ സൈൻ-ഇൻ സ്ക്രീനിൽ കോഡ് ഒട്ടിക്കുക.';

  @override
  String get helpStart16 =>
      'സൂചന: ഫോൺ നഷ്ടപ്പെട്ടാൽ ഉപകരിക്കാൻ, ഓൺലൈൻ സേവനങ്ങൾ നൽകുന്ന വീണ്ടെടുക്കൽ കോഡുകൾ എപ്പോഴും സുരക്ഷിതമായി സൂക്ഷിക്കുക.';

  @override
  String get helpTime01 => 'സമയ ക്രമീകരണവും വ്യതിയാനവും';

  @override
  String get helpTime02 =>
      'TOTP കോഡുകൾ ഫോണിലെ കൃത്യമായ സമയത്തെ ആശ്രയിക്കുന്നു. ഘടികാരം ഏതാനും സെക്കൻഡ് തെറ്റിയാൽ പോലും വെബ്സൈറ്റുകൾ കോഡ് നിരസിച്ചേക്കാം.';

  @override
  String get helpTime03 => 'TOTP സമയം എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String get helpTime04 =>
      'നിങ്ങളുടെ രഹസ്യ കീയും 30 സെക്കൻഡ് ഘട്ടങ്ങളായി എണ്ണുന്ന നിലവിലെ സമയവും ചേർത്താണ് സമയാധിഷ്ഠിത കോഡ് ഉണ്ടാക്കുന്നത്.';

  @override
  String get helpTime05 =>
      'ഫോണും സെർവറും UTC സമയത്തിൽ ഒത്തുപോകണം. സമയമേഖല മാറ്റുന്നത് UTC-യെ ബാധിക്കില്ല.';

  @override
  String get helpTime06 => 'നിരസിക്കപ്പെട്ട കോഡുകൾ പരിഹരിക്കൽ';

  @override
  String get helpTime07 =>
      'ഫോൺ ക്രമീകരണങ്ങൾ തുറന്ന് System → Date & time എന്നതിലേക്ക് പോകുക.';

  @override
  String get helpTime08 =>
      '“Set time automatically”, “Set time zone automatically” എന്നിവ ഓണാക്കുക.';

  @override
  String get helpTime09 =>
      'അവ നേരത്തെ ഓണാണെങ്കിൽ, ഓഫാക്കി വീണ്ടും ഓണാക്കുക; അപ്പോൾ ഫോൺ നെറ്റ്‌വർക്ക് സമയം ഉടനെ എടുക്കും.';

  @override
  String get helpTime10 => 'HOTP കൗണ്ടർ കോഡുകൾ';

  @override
  String get helpTime11 =>
      'HOTP കോഡുകൾ സമയത്തെയല്ല, ഒരു കൗണ്ടറിനെയാണ് ആശ്രയിക്കുന്നത്; അതിനാൽ ഘടികാരം പ്രശ്നമല്ല. പുതിയ കോഡിനായി അക്കൗണ്ടിലെ അടുത്ത കോഡ് ബട്ടൺ അമർത്തുക.';

  @override
  String get helpTime12 =>
      'ഓരോ സ്പർശവും ഒരു കോഡ് ചെലവാക്കുന്നു. കോഡ് വേണ്ടപ്പോൾ മാത്രം അമർത്തുക: വളരെയധികം ഒഴിവാക്കിയാൽ സേവനം കോഡുകൾ നിരസിച്ചേക്കാം.';

  @override
  String get helpTime13 =>
      'പുനഃസ്ഥാപിച്ച കരുതലിലോ രണ്ടാമത്തെ ഉപകരണത്തിലെ പകർപ്പിലോ പഴയ കൗണ്ടർ ഉണ്ടാകാം. സേവനം കോഡ് നിരസിച്ചാൽ, ഒപ്പമെത്താൻ കുറച്ചുതവണ കൂടി അമർത്തുക.';

  @override
  String get helpTime14 =>
      'സൂചന: നിരസിക്കപ്പെടുന്ന മിക്ക കോഡുകളും ഫോൺ ഘടികാരം തെറ്റുന്നതുകൊണ്ടാണ്. സ്വയമേവയുള്ള നെറ്റ്‌വർക്ക് സമയം ഇത് സ്ഥിരമായി പരിഹരിക്കും.';

  @override
  String get helpTags01 => 'അടയാളങ്ങളും ക്രമീകരണവും';

  @override
  String get helpTags02 =>
      'ജോലി, വ്യക്തിപരം, ബാങ്കിംഗ്, സോഷ്യൽ പോലുള്ള നിങ്ങളുടെ സ്വന്തം ഗ്രൂപ്പുകളിലേക്ക് അടയാളങ്ങൾ 2FA അക്കൗണ്ടുകൾ തരംതിരിക്കുന്നു; അതിനാൽ എളുപ്പത്തിൽ അരിച്ചെടുക്കാം.';

  @override
  String get helpTags03 => 'അക്കൗണ്ടുകൾക്ക് അടയാളം നൽകൽ';

  @override
  String get helpTags04 =>
      'അക്കൗണ്ട് ചേർക്കുമ്പോഴോ തിരുത്തുമ്പോഴോ, കോമ കൊണ്ട് വേർതിരിച്ച് അടയാളങ്ങൾ ടൈപ്പ് ചെയ്യുക (ഉദാ. “ജോലി, ക്ലൗഡ്, ടെക്”).';

  @override
  String get helpTags05 =>
      'ടൈപ്പ് ചെയ്യുമ്പോൾ നിലവിലുള്ള അടയാളങ്ങൾ ആപ്പ് നിർദ്ദേശിക്കും; അതിനാൽ പേരുകൾ ഒരുപോലെ നിലനിൽക്കും.';

  @override
  String helpTags06(String browseTags) {
    return 'ഇതിനകം ഉപയോഗത്തിലുള്ള എല്ലാ അടയാളങ്ങളിൽ നിന്നും തിരഞ്ഞെടുക്കാൻ “$browseTags” അമർത്തുക.';
  }

  @override
  String get helpTags07 => 'അടയാളം അനുസരിച്ച് അരിക്കൽ';

  @override
  String get helpTags08 =>
      'ഹോം സ്ക്രീനിലെ അടയാള ബാർ നിങ്ങളുടെ അടയാളങ്ങൾ അമർത്താവുന്ന ചിപ്പുകളായി കാണിക്കുന്നു.';

  @override
  String helpTags09(String allTags) {
    return 'ഒരു അടയാള ചിപ്പ് അമർത്തിയാൽ അതിന്റെ അക്കൗണ്ടുകൾ മാത്രം കാണാം. അരിപ്പ് നീക്കാൻ “$allTags” അമർത്തുക.';
  }

  @override
  String get helpTags10 =>
      'എല്ലാ അടയാളങ്ങളും ഓരോന്നിനും എത്ര അക്കൗണ്ടുകളുണ്ടെന്നും കാണാൻ അടയാള മേഘത്തിലേക്ക് മാറുക.';

  @override
  String get helpTags11 => 'അടയാള നിർവഹണം';

  @override
  String helpTags12(String settings, String manageTags) {
    return 'എല്ലാ അക്കൗണ്ടുകളിലും ഒരുമിച്ച് അടയാളം പേരുമാറ്റാനോ ഇല്ലാതാക്കാനോ $settings → $manageTags എന്നതിലേക്ക് പോകുക. നിലവിലുള്ള ഒരു പേരിലേക്ക് മാറ്റിയാൽ രണ്ടും ഒന്നാകും.';
  }

  @override
  String get helpTags13 =>
      'ഒരു അടയാളത്തിന്റെ പേര് മാറ്റുമ്പോൾ അത് ഉള്ള എല്ലാ അക്കൗണ്ടുകളും പുതുക്കും.';

  @override
  String get helpTags14 =>
      'ഒരു അടയാളം ഇല്ലാതാക്കിയാൽ അക്കൗണ്ടുകളിൽ നിന്ന് ആ ലേബൽ മാത്രം നീങ്ങും; അക്കൗണ്ടുകൾ നിലനിൽക്കും.';

  @override
  String get helpTags15 =>
      'സൂചന: ചെറിയ അടയാള പേരുകൾ (ഉദാ. “ജോലി”, “സാമ്പത്തികം”) ഫിൽട്ടർ ബാറിൽ നന്നായി കാണും.';

  @override
  String get helpLock01 => 'ബയോമെട്രിക്, ആപ്പ് ലോക്ക്';

  @override
  String helpLock02(String appName) {
    return '$appName-ന് വിരലടയാളം, മുഖം, ഫോൺ സ്ക്രീൻ ലോക്ക്, അല്ലെങ്കിൽ ആപ്പ് PIN ഉപയോഗിച്ച് കോഡുകൾ സംരക്ഷിക്കാനാകും.';
  }

  @override
  String get helpLock03 => 'ആപ്പ് ലോക്ക് എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String helpLock04(String settings, String security) {
    return '$settings → $security എന്നതിൽ ഓണാണെങ്കിൽ, ആപ്പ് തുറക്കുമ്പോഴും തിരികെ വരുമ്പോഴും തുറക്കാൻ ആവശ്യപ്പെടും.';
  }

  @override
  String get helpLock05 =>
      'ആപ്പ് തുറന്നിരിക്കുമ്പോഴും പൂട്ടാത്തപ്പോഴും മാത്രമേ തുറന്ന കോഡുകൾ മെമ്മറിയിലുണ്ടാകൂ.';

  @override
  String get helpLock06 => 'സ്വയം ലോക്ക്';

  @override
  String get helpLock07 =>
      'ആപ്പ് വിടുമ്പോഴോ മറ്റൊരു ആപ്പിലേക്ക് മാറുമ്പോഴോ ഫോൺ സ്ക്രീൻ പൂട്ടുമ്പോഴോ ആപ്പ് ഉടൻ പൂട്ടും. തുറന്നിരിക്കുമ്പോൾ, സ്വയം ലോക്ക് സമയം കഴിഞ്ഞാലും പൂട്ടും.';

  @override
  String get helpLock08 =>
      'തുറന്ന കോഡുകൾ മെമ്മറിയിൽ നിന്ന് നീക്കം ചെയ്യുന്നു; അതിനാൽ ഫോൺ എടുക്കുന്നവർക്ക് അവ വായിക്കാനാവില്ല.';

  @override
  String get helpLock09 => 'പകരം മാർഗ്ഗവും ഫോൺ ലോക്കും';

  @override
  String get helpLock10 =>
      'വിരലടയാളമോ മുഖമോ തിരിച്ചറിയുന്നില്ലെങ്കിൽ (ഉദാ. നനഞ്ഞ വിരലുകൾ, കുറഞ്ഞ വെളിച്ചം), ഫോൺ സ്ക്രീൻ ലോക്കിന്റെ PIN, പാറ്റേൺ, രഹസ്യവാക്ക് എന്നിവ ഉപയോഗിക്കാം.';

  @override
  String helpLock11(String appName) {
    return 'പരിശോധന Android തന്നെയാണ് നടത്തുന്നത്. $appName നിങ്ങളുടെ ബയോമെട്രിക് വിവരങ്ങളോ ഫോൺ പാസ്കോഡോ ഒരിക്കലും കാണുകയോ സൂക്ഷിക്കുകയോ ചെയ്യുന്നില്ല.';
  }

  @override
  String get helpLock12 =>
      'സൂചന: മികച്ച സംരക്ഷണത്തിനായി ഫോൺ ക്രമീകരണങ്ങളിൽ സുരക്ഷിതമായ സ്ക്രീൻ ലോക്ക് സജ്ജമാക്കുക.';

  @override
  String get helpVault01 => 'നിലവറ സുരക്ഷയും സ്വകാര്യതയും';

  @override
  String helpVault02(String appName) {
    return '$appName ഓഫ്‌ലൈനായി പ്രവർത്തിക്കാനും ഒരു സെർവറിനെയും ആശ്രയിക്കാതിരിക്കാനും നിർമ്മിച്ചതാണ്. രഹസ്യ കീകൾ നിങ്ങളുടെ ഉപകരണത്തിൽ എൻക്രിപ്റ്റ് ചെയ്യുന്നു, ഒരു വിദൂര സെർവറിലേക്കും അയയ്ക്കുന്നില്ല.';
  }

  @override
  String get helpVault03 => 'AES-256-GCM എൻക്രിപ്ഷൻ';

  @override
  String get helpVault04 =>
      'എല്ലാ രഹസ്യങ്ങളും കോഡ് ക്രമീകരണങ്ങളും GCM മോഡിലുള്ള AES-256 ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുന്നു; വിവരങ്ങളിലെ ഏത് മാറ്റവും ഇത് കണ്ടെത്തും.';

  @override
  String get helpVault05 =>
      'എൻക്രിപ്ഷൻ കീ നിങ്ങളുടെ ഉപകരണത്തിൽ ഉണ്ടാക്കി Android Keystore-ൽ സൂക്ഷിക്കുന്നു (പിന്തുണയ്ക്കുന്ന ഫോണുകളിൽ ഹാർഡ്‌വെയർ സംരക്ഷണത്തോടെ).';

  @override
  String get helpVault06 =>
      'ഒരു രഹസ്യവും ഒരിക്കലും തുറന്ന രൂപത്തിൽ ഡാറ്റാബേസിൽ എഴുതുന്നില്ല.';

  @override
  String get helpVault07 => 'സ്ക്രീൻഷോട്ട് സംരക്ഷണം (FLAG_SECURE)';

  @override
  String get helpVault08 =>
      'സ്വതവേ ആപ്പ് അതിന്റെ ജാലകത്തിന് Android FLAG_SECURE ഓണാക്കുന്നു. സുരക്ഷാ ക്രമീകരണങ്ങളിൽ ഇത് ഓഫാക്കാം.';

  @override
  String get helpVault09 =>
      'ഇത് സ്ക്രീൻഷോട്ടുകൾ, സ്ക്രീൻ റെക്കോർഡിംഗ്, സ്ക്രീൻ വായിക്കുന്ന ആപ്പുകൾ എന്നിവ നിങ്ങളുടെ കോഡുകൾ പകർത്തുന്നത് തടയുന്നു.';

  @override
  String get helpVault10 =>
      'സമീപകാല ആപ്പുകളുടെ കാഴ്ചയിൽ ആപ്പ് ശൂന്യ സ്ക്രീൻ കാണിക്കുന്നു; അതിനാൽ അടുത്തുള്ളവർക്ക് കോഡുകൾ കാണാനാവില്ല.';

  @override
  String get helpVault11 => 'ക്ലൗഡ് ഇല്ല, ടെലിമെട്രി ഇല്ല';

  @override
  String get helpVault12 =>
      'ആപ്പിന് സെർവറോ ലോഗിനോ പരസ്യമോ അനലിറ്റിക്സ് കോഡോ ഇല്ല.';

  @override
  String get helpVault13 =>
      'നിങ്ങളുടെ രഹസ്യങ്ങളും കോഡുകളും ഒരു സെർവറിലേക്കും അയയ്ക്കുന്നില്ല. ആപ്പ് ലോഗുകളോ ഉപകരണ ഐഡികളോ ഉപയോഗ വിവരങ്ങളോ അയയ്ക്കുന്നില്ല.';

  @override
  String get helpVault14 =>
      'QR സ്കാനിംഗ്, കോഡ് സൃഷ്ടി, കരുതൽ കയറ്റുമതി എന്നിവ ഉൾപ്പെടെ എല്ലാം ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു. Wi-Fi സമന്വയം മാത്രമാണ് പ്രാദേശിക നെറ്റ്‌വർക്ക് ഉപയോഗിക്കുന്നത്.';

  @override
  String get helpVault15 =>
      'സ്വകാര്യതയ്ക്ക് മുൻഗണന: നിങ്ങളുടെ പ്രാമാണീകരണ രഹസ്യങ്ങൾ നിങ്ങളുടേത് മാത്രമാണ്.';

  @override
  String get helpWifi01 => 'Wi-Fi സമന്വയം';

  @override
  String get helpWifi02 =>
      'Wi-Fi സമന്വയം ഒരേ Wi-Fi നെറ്റ്‌വർക്കിലുള്ള രണ്ട് ഫോണുകൾക്കിടയിൽ 2FA അക്കൗണ്ടുകൾ നേരിട്ട് മാറ്റുന്നു. വിവരങ്ങൾ എൻക്രിപ്റ്റ് ചെയ്തതാണ്; ഒരു ക്ലൗഡ് സേവനവും ഉൾപ്പെടുന്നില്ല.';

  @override
  String get helpWifi03 => 'Wi-Fi സമന്വയം എങ്ങനെ';

  @override
  String get helpWifi04 =>
      'ഘട്ടം 1: രണ്ട് ഉപകരണങ്ങളും ഒരേ Wi-Fi നെറ്റ്‌വർക്കിൽ ബന്ധിപ്പിക്കുക.';

  @override
  String helpWifi05(String settings, String syncDevices, String sendOverWifi) {
    return 'ഘട്ടം 2: അയയ്ക്കുന്ന ഉപകരണത്തിൽ $settings → $syncDevices → “$sendOverWifi” തുറക്കുക. അത് ഒരു ജോടിയാക്കൽ QR കോഡും ജോടിയാക്കൽ കോഡും കാണിക്കും.';
  }

  @override
  String helpWifi06(String receiveOverWifi) {
    return 'ഘട്ടം 3: സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ “$receiveOverWifi” അമർത്തി ജോടിയാക്കൽ QR കോഡ് സ്കാൻ ചെയ്യുക (അല്ലെങ്കിൽ വിവരങ്ങൾ ടൈപ്പ് ചെയ്യുക).';
  }

  @override
  String get helpWifi07 =>
      'ഘട്ടം 4: ഉപകരണങ്ങൾ ബന്ധിപ്പിക്കും, അയയ്ക്കുന്നയാൾ എന്ത് പങ്കിടണമെന്ന് തിരഞ്ഞെടുക്കും.';

  @override
  String get helpWifi08 => 'എൻക്രിപ്ഷൻ';

  @override
  String get helpWifi09 =>
      'സ്ക്രീനിൽ കാണിക്കുന്ന ജോടിയാക്കൽ കോഡിൽ നിന്ന് (PBKDF2 വഴി) ഉണ്ടാക്കുന്ന കീ ഉപയോഗിച്ച് AES-256-GCM-ൽ വിവരങ്ങൾ എൻക്രിപ്റ്റ് ചെയ്യുന്നു.';

  @override
  String get helpWifi10 =>
      'ജോടിയാക്കൽ കോഡില്ലാതെ, നിങ്ങളുടെ Wi-Fi ട്രാഫിക് നിരീക്ഷിക്കുന്നവർക്ക് 2FA രഹസ്യങ്ങൾ വായിക്കാനാവില്ല.';

  @override
  String get helpWifi11 =>
      'ജോടിയാക്കൽ കോഡ് ഒരിക്കലും നെറ്റ്‌വർക്ക് വഴി അയയ്ക്കുന്നില്ല; സ്കാൻ ചെയ്തോ ടൈപ്പ് ചെയ്തോ നിങ്ങൾ തന്നെ കൈമാറുന്നു.';

  @override
  String get helpWifi12 => 'സുരക്ഷിത ലയനം';

  @override
  String get helpWifi13 =>
      'സമന്വയം അക്കൗണ്ടുകൾ ചേർക്കുക മാത്രം ചെയ്യുന്നു. സ്വീകരിക്കുന്ന ഉപകരണത്തിലെ ഒന്നും ഇല്ലാതാക്കുകയോ മാറ്റുകയോ ചെയ്യുന്നില്ല.';

  @override
  String get helpWifi14 =>
      'സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ ഇതിനകം ഉള്ള അക്കൗണ്ടുകൾ ഒഴിവാക്കും.';

  @override
  String get helpWifi15 =>
      'സൂചന: കൈമാറ്റം കഴിയുന്നത് വരെ രണ്ട് ഉപകരണങ്ങളും ഉണർന്നും ഒരേ Wi-Fi-ലും വയ്ക്കുക.';

  @override
  String get helpOptical01 => 'ഒപ്റ്റിക്കൽ എയർ-ഗ്യാപ്പ്';

  @override
  String get helpOptical02 =>
      'Wi-Fi, ബ്ലൂടൂത്ത്, കേബിൾ എന്നിവ ഇല്ലാതെ, ചലിക്കുന്ന QR കോഡുകൾ വഴി ഒപ്റ്റിക്കൽ കൈമാറ്റം അക്കൗണ്ടുകൾ ഓഫ്‌ലൈൻ ഉപകരണത്തിലേക്ക് മാറ്റുന്നു.';

  @override
  String get helpOptical03 => 'എയർ-ഗ്യാപ്പ് എന്താണ്?';

  @override
  String get helpOptical04 =>
      'എയർ-ഗ്യാപ്പ് ഉപകരണത്തിന് ഒരു നെറ്റ്‌വർക്ക് ബന്ധവും ഇല്ല (Wi-Fi, ബ്ലൂടൂത്ത്, മൊബൈൽ ഡാറ്റ ഇല്ല; എയർപ്ലെയിൻ മോഡ് ഓൺ).';

  @override
  String get helpOptical05 =>
      'വിവരങ്ങൾ സ്ക്രീനിൽ നിന്ന് ക്യാമറയിലേക്ക് വെളിച്ചമായി മാത്രം സഞ്ചരിക്കുന്നു; അതിനാൽ ചോർത്താൻ നെറ്റ്‌വർക്ക് ഇല്ല. QR കോഡുകൾ എൻക്രിപ്റ്റ് ചെയ്തതാണ്; അതിന്റെ കീ അയയ്ക്കുന്ന സ്ക്രീനിൽ ഒരിക്കലും കാണിക്കാത്ത ഒരു കോഡിൽ നിന്നാണ് വരുന്നത്.';

  @override
  String get helpOptical06 => 'ഒപ്റ്റിക്കൽ കൈമാറ്റം എങ്ങനെ';

  @override
  String helpOptical07(
    String settings,
    String syncDevices,
    String scanOptical,
  ) {
    return 'ഘട്ടം 1: സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ $settings → $syncDevices → “$scanOptical” എന്നതിലേക്ക് പോകുക. അത് ഒരു ഒറ്റത്തവണ കൈമാറ്റ കോഡ് കാണിക്കും.';
  }

  @override
  String helpOptical08(String sendOptical) {
    return 'ഘട്ടം 2: അയയ്ക്കുന്ന ഉപകരണത്തിൽ “$sendOptical” തിരഞ്ഞെടുത്ത് ആ കോഡ് ടൈപ്പ് ചെയ്യുക. അക്കൗണ്ടുകൾ അത് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്ത് ആവർത്തിക്കുന്ന QR കോഡുകളായി കാണിക്കും.';
  }

  @override
  String helpOptical09(String startScanning) {
    return 'ഘട്ടം 3: സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ “$startScanning” അമർത്തി ക്യാമറ അയയ്ക്കുന്ന സ്ക്രീനിലേക്ക് തിരിക്കുക.';
  }

  @override
  String get helpOptical10 =>
      'ഘട്ടം 4: സ്വീകരിക്കുന്ന ഉപകരണം എല്ലാ ഭാഗങ്ങളും ശേഖരിക്കും. എല്ലാ ഭാഗങ്ങളും വായിക്കുകയും കോഡ് ശരിയാവുകയും ചെയ്താൽ അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യും. കോഡ് തെറ്റാണെങ്കിൽ ഒന്നും ഇറക്കുമതി ചെയ്യില്ല.';

  @override
  String get helpOptical11 => 'വേഗത്തിനുള്ള സൂചനകൾ';

  @override
  String get helpOptical12 =>
      'അയയ്ക്കുന്ന ഉപകരണത്തിൽ വേഗം സെക്കൻഡിൽ 10, 12, 15 ഫ്രെയിമുകളായി ക്രമീകരിക്കാം; ക്യാമറ ഫ്രെയിമുകൾ നഷ്ടപ്പെടുത്തുന്നുവെങ്കിൽ കുറഞ്ഞ വേഗം ഉപയോഗിക്കുക.';

  @override
  String get helpOptical13 =>
      'രണ്ട് ഉപകരണങ്ങളും നല്ല വെളിച്ചത്തിൽ സ്ഥിരമായി പിടിക്കുക; സ്ക്രീനിലെ പ്രതിഫലനങ്ങളും തിളക്കവും ഒഴിവാക്കുക.';

  @override
  String get helpOptical14 =>
      'സൂചന: സുരക്ഷിത സ്ഥലത്ത് സൂക്ഷിക്കുന്ന ഓഫ്‌ലൈൻ കരുതൽ ഫോണിന് ഒപ്റ്റിക്കൽ സമന്വയം അനുയോജ്യമാണ്.';

  @override
  String get helpBackup01 => 'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ';

  @override
  String get helpBackup02 =>
      'ഫോൺ കേടാകുമ്പോഴോ നഷ്ടപ്പെടുമ്പോഴോ പുതിയ ഫോണിലേക്ക് മാറുമ്പോഴോ കരുതൽ നിങ്ങളെ സംരക്ഷിക്കുന്നു. ഓരോ കരുതൽ ഫയലും നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന രഹസ്യവാക്ക് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുന്നു.';

  @override
  String get helpBackup03 => 'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ ഉണ്ടാക്കൽ';

  @override
  String helpBackup04(
    String settings,
    String backupRestore,
    String createBackup,
  ) {
    return '$settings → $backupRestore → “$createBackup” അമർത്തുക.';
  }

  @override
  String get helpBackup05 =>
      'ശക്തമായ കരുതൽ രഹസ്യവാക്ക് തിരഞ്ഞെടുക്കുക. ഫയൽ എൻക്രിപ്റ്റ് ചെയ്യാൻ ആപ്പ് അതിൽ നിന്ന് PBKDF2 (300,000 ആവർത്തനങ്ങൾ) ഉപയോഗിച്ച് AES-256 കീ ഉണ്ടാക്കുന്നു.';

  @override
  String get helpBackup06 =>
      'എൻക്രിപ്റ്റ് ചെയ്ത .aes കരുതൽ ഫയൽ ഉപകരണത്തിലോ USB ഡ്രൈവിലോ നിങ്ങളുടെ ഓഫ്‌ലൈൻ ശേഖരത്തിലോ സൂക്ഷിക്കുക.';

  @override
  String get helpBackup07 => 'രഹസ്യവാക്ക് സുരക്ഷയും വീണ്ടെടുക്കലും';

  @override
  String get helpBackup08 =>
      'നിങ്ങളുടെ കരുതൽ രഹസ്യവാക്ക് എവിടെയും സൂക്ഷിക്കുകയോ അയയ്ക്കുകയോ ചെയ്യുന്നില്ല. അത് ഓർമ്മിക്കുകയോ സുരക്ഷിതമായി എഴുതി വയ്ക്കുകയോ ചെയ്യണം.';

  @override
  String helpBackup09(String appName) {
    return '$appName പൂർണ്ണമായും ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നതിനാൽ “രഹസ്യവാക്ക് മറന്നോ” അല്ലെങ്കിൽ സെർവർ പുനഃസജ്ജീകരണം ഇല്ല. നഷ്ടപ്പെട്ട കരുതൽ രഹസ്യവാക്ക് വീണ്ടെടുക്കാനാവില്ല.';
  }

  @override
  String get helpBackup10 => 'കരുതൽ പുനഃസ്ഥാപിക്കൽ';

  @override
  String helpBackup11(
    String settings,
    String backupRestore,
    String restoreBackup,
  ) {
    return '$settings → $backupRestore → “$restoreBackup” അമർത്തുക.';
  }

  @override
  String get helpBackup12 =>
      'കരുതൽ ഫയൽ തിരഞ്ഞെടുത്ത് അത് ഉണ്ടാക്കിയപ്പോൾ ഉപയോഗിച്ച രഹസ്യവാക്ക് നൽകുക.';

  @override
  String get helpBackup13 =>
      'ആപ്പ് ഫയൽ പരിശോധിച്ച് പുതിയ അക്കൗണ്ടുകൾ നിലവിലുള്ളവയോട് ചേർക്കും; നിലവിലുള്ള ഒന്നും ഇല്ലാതാക്കില്ല.';

  @override
  String get helpBackup14 =>
      'സൂചന: പ്രധാനപ്പെട്ട പുതിയ 2FA അക്കൗണ്ടുകൾ ചേർക്കുമ്പോഴെല്ലാം പുതിയ കരുതൽ ഉണ്ടാക്കുക.';

  @override
  String get helpFaq01 => 'ചോദ്യങ്ങളും പരിഹാരവും';

  @override
  String get helpFaq02 =>
      '2FA കോഡുകൾ, വീണ്ടെടുക്കൽ, സുരക്ഷ, സാധാരണ പ്രശ്നങ്ങൾ എന്നിവയെക്കുറിച്ചുള്ള വേഗത്തിലുള്ള ഉത്തരങ്ങൾ.';

  @override
  String get helpFaq03 => '2FA കോഡുകൾ';

  @override
  String get helpFaq04 =>
      'വെബ്സൈറ്റുകൾ എന്റെ കോഡുകൾ നിരസിക്കുന്നത് എന്തുകൊണ്ട്?';

  @override
  String get helpFaq05 =>
      'സാധാരണയായി ഫോൺ ഘടികാരം തെറ്റായിരിക്കും. ഫോൺ ക്രമീകരണങ്ങൾ → Date & time തുറന്ന് “Set time automatically” ഓണാക്കുക; അപ്പോൾ ഘടികാരം UTC-യുമായി ഒത്തുപോകും.';

  @override
  String get helpFaq06 => 'ഒറ്റ സ്പർശത്തിൽ കോഡ് പകർത്താമോ?';

  @override
  String get helpFaq07 =>
      'അതെ. ഹോം സ്ക്രീനിലെ അക്കൗണ്ട് അമർത്തുക; കോഡ് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തുകയും ഒരു ചെറിയ സന്ദേശം അത് ഉറപ്പിക്കുകയും ചെയ്യും.';

  @override
  String get helpFaq08 => 'HOTP കോഡുകൾ TOTP-യിൽ നിന്ന് എങ്ങനെ വ്യത്യസ്തമാണ്?';

  @override
  String get helpFaq09 =>
      'TOTP കോഡുകൾ സമയം അനുസരിച്ച് ഓരോ 30 സെക്കൻഡിലും മാറും. HOTP കോഡുകൾ അടുത്ത കോഡ് ബട്ടൺ അമർത്തുമ്പോൾ മാത്രം മാറും; ഓരോ സ്പർശവും ഒരു കോഡ് ചെലവാക്കുന്നു.';

  @override
  String get helpFaq10 => 'സുരക്ഷയും സ്വകാര്യതയും';

  @override
  String get helpFaq11 => 'ആപ്പ് മാറുമ്പോൾ ഇത് ശൂന്യമാകുന്നത് എന്തുകൊണ്ട്?';

  @override
  String get helpFaq12 =>
      'സ്വതവേ ഓണായ സ്ക്രീൻഷോട്ട് സംരക്ഷണം Android FLAG_SECURE ഓണാക്കുന്നു. സ്ക്രീൻ റെക്കോർഡറുകളും സമീപകാല ആപ്പ് കാഴ്ചയും കോഡുകൾ പകർത്തുന്നത് ഇത് തടയുന്നു.';

  @override
  String helpFaq13(String appName) {
    return '$appName എന്തെങ്കിലും വിവരം ഓൺലൈനായി അയയ്ക്കുന്നുണ്ടോ?';
  }

  @override
  String helpFaq14(String appName) {
    return 'ഇല്ല. $appName ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു. അനലിറ്റിക്സോ ട്രാക്കിംഗോ ക്ലൗഡ് സേവനമോ ഇല്ല. പ്രാദേശിക നെറ്റ്‌വർക്കിൽ Wi-Fi സമന്വയം, ഒപ്റ്റിക്കൽ കൈമാറ്റം, കരുതൽ കയറ്റുമതി എന്നിവ നിങ്ങൾ ആരംഭിക്കുമ്പോൾ മാത്രമേ വിവരങ്ങൾ ഉപകരണം വിടുകയുള്ളൂ.';
  }

  @override
  String get helpFaq15 => 'വിരലടയാളമോ മുഖമോ തിരിച്ചറിയുന്നില്ലെങ്കിൽ?';

  @override
  String get helpFaq16 =>
      'ഫോൺ സ്ക്രീൻ ലോക്കിന്റെ PIN, പാറ്റേൺ, രഹസ്യവാക്ക്, അല്ലെങ്കിൽ ആപ്പ് PIN ഉപയോഗിച്ച് തുറക്കാം.';

  @override
  String get helpFaq17 => 'കരുതലും ഫോൺ മാറ്റവും';

  @override
  String get helpFaq18 => 'അക്കൗണ്ടുകൾ പുതിയ ഫോണിലേക്ക് എങ്ങനെ മാറ്റാം?';

  @override
  String helpFaq19(String syncDevices) {
    return 'പ്രാദേശിക Wi-Fi വഴി “$syncDevices” ഉപയോഗിക്കുക, ഒപ്റ്റിക്കൽ QR സ്ട്രീം സ്കാൻ ചെയ്യുക, അല്ലെങ്കിൽ പഴയ ഫോണിൽ എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽ കയറ്റുമതി ചെയ്ത് പുതിയതിൽ പുനഃസ്ഥാപിക്കുക.';
  }

  @override
  String get helpFaq20 => 'കരുതൽ രഹസ്യവാക്ക് മറന്നാൽ?';

  @override
  String get helpFaq21 =>
      'കരുതലുകൾ AES-256 എൻക്രിപ്ഷൻ ഉപയോഗിക്കുന്നു, സെർവർ ഇല്ല; അതിനാൽ നഷ്ടപ്പെട്ട കരുതൽ രഹസ്യവാക്ക് വീണ്ടെടുക്കാനാവില്ല. അത് സുരക്ഷിതമായി എഴുതി വയ്ക്കുക.';

  @override
  String get helpFaq22 =>
      'കരുതൽ പുനഃസ്ഥാപിക്കുന്നത് എന്റെ അക്കൗണ്ടുകൾ മായ്ക്കുമോ?';

  @override
  String helpFaq23(String appName) {
    return 'ഇല്ല. $appName അക്കൗണ്ടുകൾ ചേർക്കുക മാത്രം ചെയ്യുന്നു. നിലവിലുള്ളവ നിലനിൽക്കും, ഇരട്ടിപ്പുകൾ ഒഴിവാക്കും.';
  }

  @override
  String helpFaq24(String settings, String permissions) {
    return 'കൂടുതൽ സഹായം വേണോ? സഹായത്തിലെ മറ്റ് മാർഗ്ഗനിർദ്ദേശങ്ങൾ വായിക്കുക, അല്ലെങ്കിൽ $settings → $permissions എന്നതിൽ അനുമതികൾ പരിശോധിക്കുക.';
  }

  @override
  String get titleTransferCode => 'കൈമാറ്റ കോഡ്';

  @override
  String get descTransferCodeShow =>
      'ഈ കോഡ് അയയ്ക്കുന്ന ഉപകരണത്തിൽ ടൈപ്പ് ചെയ്യുക, തുടർന്ന് താഴെയുള്ള ബട്ടൺ അമർത്തുക. ഈ കോഡ് മറ്റാരെയും കാണിക്കരുത്.';

  @override
  String get actionStartScanning => 'സ്കാൻ ആരംഭിക്കുക';

  @override
  String get descTransferCodeEnter =>
      'സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ കാണിക്കുന്ന കൈമാറ്റ കോഡ് ടൈപ്പ് ചെയ്യുക. QR സ്ട്രീം അത് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യും.';

  @override
  String get actionStartSending => 'അയയ്ക്കൽ ആരംഭിക്കുക';

  @override
  String errorTransferCodeLength(int count) {
    return 'കോഡിന്റെ എല്ലാ $count അക്ഷരങ്ങളും ടൈപ്പ് ചെയ്യുക.';
  }

  @override
  String get errorOpticalWrongCode =>
      'കോഡ് പൊരുത്തപ്പെട്ടില്ല. അയയ്ക്കുന്ന ഉപകരണത്തിൽ നിർത്തി കോഡ് വീണ്ടും ടൈപ്പ് ചെയ്യുക.';

  @override
  String get errorOpticalCodeInvalid =>
      'കൈമാറ്റ കോഡ് സാധുവല്ല. വീണ്ടും ആരംഭിച്ച് സ്വീകരിക്കുന്ന ഉപകരണത്തിൽ കാണിക്കുന്ന കോഡ് ടൈപ്പ് ചെയ്യുക.';

  @override
  String get tooltipNextCode => 'അടുത്ത കോഡ്';

  @override
  String get descHotpTapForCode => 'ആദ്യം അടുത്ത കോഡ് ബട്ടൺ അമർത്തുക.';

  @override
  String get errorHotpNextFailed => 'അടുത്ത കോഡ് ലഭിച്ചില്ല.';

  @override
  String get tooltipShowPassword => 'രഹസ്യവാക്ക് കാണിക്കുക';

  @override
  String get tooltipHidePassword => 'രഹസ്യവാക്ക് മറയ്ക്കുക';

  @override
  String get tooltipClearSearch => 'തിരയൽ മായ്ക്കുക';

  @override
  String get tooltipShowCode => 'കോഡ് കാണിക്കുക';

  @override
  String get tooltipHideCode => 'കോഡ് മറയ്ക്കുക';

  @override
  String get tooltipAddAccount => 'അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get tooltipAddOptions => 'ചേർക്കാനുള്ള വഴികൾ';

  @override
  String get descCodeHidden => 'കോഡ് മറച്ചിരിക്കുന്നു';

  @override
  String get titleScreenPrivacySection => 'സ്ക്രീൻ സ്വകാര്യത';

  @override
  String get labelBlockScreenshots => 'സ്ക്രീൻഷോട്ട് തടയുക';

  @override
  String get descBlockScreenshots =>
      'സ്ക്രീൻഷോട്ടുകളിലും സ്ക്രീൻ റെക്കോർഡിംഗിലും സമീപകാല ആപ്പ് ചിത്രങ്ങളിലും കോഡുകൾ കാണിക്കുന്നത് തടയുന്നു';

  @override
  String get titleAllowScreenshots => 'സ്ക്രീൻഷോട്ട് അനുവദിക്കണോ?';

  @override
  String get descAllowScreenshotsWarning =>
      'അപ്പോൾ നിങ്ങളുടെ കോഡുകളും രഹസ്യങ്ങളും സ്ക്രീൻഷോട്ടുകളിലും സ്ക്രീൻ റെക്കോർഡിംഗുകളിലും സമീപകാല ആപ്പ് കാഴ്ചയിലും കാണാനാകും. മറ്റ് ആപ്പുകൾക്കും അവ പകർത്താൻ കഴിഞ്ഞേക്കും.';

  @override
  String get errorBlockScreenshotsFailed =>
      'സ്ക്രീൻഷോട്ട് ക്രമീകരണം മാറ്റാനായില്ല';

  @override
  String get titleDataSection => 'വിവരങ്ങൾ';

  @override
  String get labelDeleteAllData => 'എല്ലാ വിവരങ്ങളും ഇല്ലാതാക്കുക';

  @override
  String get descDeleteAllDataEntry =>
      'എല്ലാ അക്കൗണ്ടുകളും ക്രമീകരണങ്ങളും ഈ ഉപകരണത്തിൽനിന്ന് നീക്കുക';

  @override
  String get titleDeleteAllData => 'എല്ലാം ഇല്ലാതാക്കണോ?';

  @override
  String get descDeleteAllDataWarning =>
      'നിങ്ങളുടെ എല്ലാ അക്കൗണ്ടുകളും ആപ്പ് PIN-ഉം വീണ്ടെടുക്കൽ കീയും ക്രമീകരണങ്ങളും ഈ ഉപകരണത്തിൽനിന്ന് നീക്കം ചെയ്യപ്പെടും. ഇത് പഴയപടിയാക്കാനാവില്ല. കരുതൽ പകർപ്പില്ലെങ്കിൽ നിങ്ങളുടെ അക്കൗണ്ടുകളിലേക്കുള്ള പ്രവേശനം നഷ്ടപ്പെട്ടേക്കാം.\n\nമറ്റിടങ്ങളിൽ സൂക്ഷിച്ച കരുതൽ ഫയലുകൾ ഇല്ലാതാകില്ല.';

  @override
  String get descDeleteAllDataUnderstand =>
      'ഇത് പഴയപടിയാക്കാനാവില്ലെന്ന് എനിക്ക് മനസ്സിലായി';

  @override
  String get actionDeleteAll => 'എല്ലാം ഇല്ലാതാക്കുക';

  @override
  String get descAuthReasonDeleteAllData =>
      'എല്ലാ വിവരങ്ങളും ഇല്ലാതാക്കാൻ സ്ഥിരീകരിക്കുക';

  @override
  String get descPinPurposeDeleteAllData => 'എല്ലാ വിവരങ്ങളും ഇല്ലാതാക്കാൻ.';

  @override
  String get descAllDataDeleted => 'എല്ലാ വിവരങ്ങളും ഇല്ലാതാക്കി';

  @override
  String get errorDeleteAllDataFailed =>
      'ചില വിവരങ്ങൾ ഇല്ലാതാക്കാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get titleImportAccounts => 'അക്കൗണ്ട് ഇറക്കുമതി';

  @override
  String get titleQrCodesMissing => 'QR കോഡുകൾ കുറവാണ്';

  @override
  String actionImportCount(int count) {
    return 'ഇറക്കുമതി ($count)';
  }

  @override
  String get labelAlreadyInApp => 'ആപ്പിൽ നിലവിലുണ്ട്';

  @override
  String get labelUnnamedAccount => 'പേരില്ലാത്ത അക്കൗണ്ട്';

  @override
  String descMigrationProgress(int scanned, int total) {
    return '$total QR കോഡുകളിൽ $scanned എണ്ണം സ്കാൻ ചെയ്തു';
  }

  @override
  String descMigrationPartial(int scanned, int total) {
    return '$total QR കോഡുകളിൽ $scanned എണ്ണം മാത്രമേ സ്കാൻ ചെയ്തിട്ടുള്ളൂ. മറ്റ് QR കോഡുകളിലെ അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യില്ല.';
  }

  @override
  String get descImportReviewHint =>
      'ഇറക്കുമതി ചെയ്യേണ്ട Google Authenticator അക്കൗണ്ടുകൾ തിരഞ്ഞെടുക്കുക.';

  @override
  String get descImportHotpReminder =>
      'കൗണ്ടർ അടിസ്ഥാനമാക്കിയ അക്കൗണ്ടുകൾക്ക് പഴയ ആപ്പ് ഇനി ഉപയോഗിക്കരുത്; അല്ലെങ്കിൽ കൗണ്ടറുകൾ പൊരുത്തപ്പെടില്ല.';

  @override
  String get errorMigrationInvalid =>
      'ഈ Google Authenticator QR കോഡ് വായിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get errorMigrationOtherExport =>
      'ഈ QR കോഡ് മറ്റൊരു എക്സ്പോർട്ടിൽ നിന്നുള്ളതാണ്. ഇത് ഉപയോഗിക്കാൻ തിരികെ പോയി വീണ്ടും തുടങ്ങുക.';

  @override
  String get errorImportFailed =>
      'അക്കൗണ്ടുകൾ ഇറക്കുമതി ചെയ്യാൻ കഴിഞ്ഞില്ല. ഒന്നും സംരക്ഷിച്ചിട്ടില്ല.';

  @override
  String get errorEntryDamaged => 'ഈ അക്കൗണ്ടിന്റെ വിവരങ്ങൾ കേടായിരിക്കുന്നു.';

  @override
  String get errorEntryNoSecret => 'ഈ അക്കൗണ്ടിന് രഹസ്യ കീ ഇല്ല.';

  @override
  String get errorEntryShortSecret => 'ഈ അക്കൗണ്ടിന്റെ രഹസ്യ കീ വളരെ ചെറുതാണ്.';

  @override
  String get errorEntryAlgorithm =>
      'ഈ അക്കൗണ്ട് ഉപയോഗിക്കുന്ന അൽഗോരിതം ആപ്പ് പിന്തുണയ്ക്കുന്നില്ല.';

  @override
  String get errorEntryDigits =>
      'ഈ അക്കൗണ്ടിന്റെ കോഡ് നീളം ആപ്പ് പിന്തുണയ്ക്കുന്നില്ല.';

  @override
  String get errorEntryType =>
      'ഈ അക്കൗണ്ടിന്റെ തരം ആപ്പ് പിന്തുണയ്ക്കുന്നില്ല.';
}
