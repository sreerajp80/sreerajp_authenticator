// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sanskrit (`sa`).
class AppLocalizationsSa extends AppLocalizations {
  AppLocalizationsSa([String locale = 'sa']) : super(locale);

  @override
  String get descSplashLoading => 'भवतः उपयोक्तृविवरणानि सुरक्ष्यन्ते...';

  @override
  String get titleSettings => 'विन्यासः';

  @override
  String get titleAppearance => 'दृश्यरूपम्';

  @override
  String get titleSecurity => 'सुरक्षा';

  @override
  String get titleExploreSupport => 'अन्वेषणं साहाय्यं च';

  @override
  String get titleLanguage => 'भाषा';

  @override
  String get titleSecuritySettings => 'सुरक्षाविन्यासः';

  @override
  String get descSecuritySettingsEntry =>
      'अनुप्रयोगतालकं जैवमितिं च विन्यस्यताम्';

  @override
  String get titleBackupRestore => 'प्रतिलिपिः पुनःस्थापनं च';

  @override
  String get descBackupRestoreEntry =>
      'उपयोक्तृविवरणानि निर्याप्यन्ताम् आनीयन्तां वा';

  @override
  String get titleManageTags => 'चिह्नप्रबन्धनम्';

  @override
  String get descManageTagsEntry =>
      'उपयोक्तृविवरणचिह्नानां संपादनं, नामपरिवर्तनं, शोधनं च';

  @override
  String get titleSyncDevice => 'उपकरणसमन्वयः';

  @override
  String get descSyncDeviceEntry =>
      'Wi-Fi-माध्यमेन प्रकाशीयवायुविच्छेदमाध्यमेन वा उपयोक्तृविवरणानि प्रेष्यन्ताम्';

  @override
  String get titleSyncHostTimeout => 'आतिथेयकालसीमा';

  @override
  String descSyncHostTimeoutEntry(int seconds) {
    return 'यदि $seconds क्षणेषु किमपि उपकरणं न संयुज्यते तर्हि आतिथ्यं स्थगयिष्यते';
  }

  @override
  String labelSecondsCount(int seconds) {
    return '$seconds क्षणाः';
  }

  @override
  String get titlePermissions => 'अनुमतयः';

  @override
  String get descPermissionsEntry =>
      'अनुप्रयोगस्य अनुमतयः तासां स्थितिः च दृश्यताम्';

  @override
  String get titleFeatures => 'विशेषताः';

  @override
  String descFeaturesEntry(String appName) {
    return '$appName इत्यस्य सर्वाः विशेषताः अन्विष्यन्ताम्';
  }

  @override
  String get titleHelp => 'साहाय्यम्';

  @override
  String get descHelpEntry => 'मार्गदर्शिकाः, समस्यापरिहारः, समन्वयविवरणं च';

  @override
  String get titleAbout => 'विषयपरिचयः';

  @override
  String get descAboutEntry => 'संस्करणं, लेखकः, अनुज्ञापत्रविवरणं च';

  @override
  String descAppearanceThemeMode(String mode) {
    return 'रूपविन्यासप्रकारः: $mode';
  }

  @override
  String get titleThemeMode => 'रूपविन्यासप्रकारः';

  @override
  String get titleThemeInformation => 'रूपविन्याससूचना';

  @override
  String get titleVisualDesign => 'दृश्यरचनापद्धतिः';

  @override
  String descVisualDesign(String appName) {
    return '$appName अन्तर्जालं विना कार्यक्षमं त्रिविमीयं मृदुरूपविन्यासं प्रयुङ्क्ते, यस्मिन् दीप्तानि गणनावलयानि उच्चवर्णभेदयुक्ता सुगमता च सन्ति।';
  }

  @override
  String get descThemeSummarySystem => 'तन्त्रसिद्धम् (उपकरणविन्यासम् अनुसरति)';

  @override
  String get descThemeSummaryLight => 'दीप्तरूपम्';

  @override
  String get descThemeSummaryDark => 'श्यामरूपम्';

  @override
  String get titleSelectThemeMode => 'रूपविन्यासचयनम्';

  @override
  String get labelThemeSystem => 'तन्त्रसिद्धम्';

  @override
  String get descThemeSystem =>
      'उपकरणस्य तन्त्ररूपविन्यासः स्वयम् अनुस्रियताम्';

  @override
  String get labelThemeLight => 'दीप्तरूपम्';

  @override
  String get descThemeLight => 'स्वच्छम् उच्चवर्णभेदयुक्तं दीप्तरूपम्';

  @override
  String get labelThemeDark => 'श्यामरूपम्';

  @override
  String get descThemeDark => 'अल्पप्रकाशे नेत्रसुखदं श्यामरूपम्';

  @override
  String get titleCurrentStatus => 'वर्तमानस्थितिः';

  @override
  String get labelActiveDark => 'सक्रियम्: श्यामरूपम्';

  @override
  String get labelActiveLight => 'सक्रियम्: दीप्तरूपम्';

  @override
  String get descThemeStatusSystem => 'उपकरणस्य श्यामरूपविन्यासम् अनुसरति।';

  @override
  String get descThemeStatusLight => 'सदा दीप्तरूपे एव तिष्ठति।';

  @override
  String get descThemeStatusDark => 'सदा श्यामरूपे एव तिष्ठति।';

  @override
  String get titleSelectLanguage => 'भाषाचयनम्';

  @override
  String get labelLanguageSystem => 'तन्त्रसिद्धम्';

  @override
  String get descLanguageSystem =>
      'उपकरणभाषा आङ्ग्लभाषा मलयाळभाषा संस्कृतं वा चेत् सा एव प्रयुज्यते; अन्यथा आङ्ग्लभाषा';

  @override
  String get labelLanguageNameEn => 'आङ्ग्लभाषा';

  @override
  String get labelLanguageNameMl => 'मलयाळभाषा';

  @override
  String get labelLanguageNameSa => 'संस्कृतम्';

  @override
  String descLanguageRowA11y(String value) {
    return 'भाषा: $value';
  }

  @override
  String labelVersionNumber(String version) {
    return 'संस्करणम् $version';
  }

  @override
  String get labelEnvProduction => 'प्रकाशितसंस्करणम्';

  @override
  String get labelEnvDevelopment => 'विकाससंस्करणम्';

  @override
  String get descFeatureQr => 'QR-सङ्केतावलोकनम्';

  @override
  String get descFeatureEncrypted => 'गूढलेखितसङ्ग्रहः';

  @override
  String get descFeatureBackup => 'प्रतिलिपिः पुनःस्थापनं च';

  @override
  String get descFeatureOrganize => 'उपयोक्तृविवरणव्यवस्था';

  @override
  String get descFeatureBiometric => 'जैवमितिप्रमाणीकरणम्';

  @override
  String get descFeatureDarkMode => 'श्यामरूपसमर्थनम्';

  @override
  String get titleDeveloper => 'विकासकः';

  @override
  String get titleLinks => 'अनुबन्धाः';

  @override
  String get titlePrivacyPolicy => 'गोपनीयतानीतिः';

  @override
  String get titlePrivacyStorage => 'दत्तांशसङ्ग्रहः';

  @override
  String get descPrivacyStorage =>
      'भवतः सर्वः उपयोक्तृविवरणदत्तांशः भवतः उपकरणे गूढलिखितः सङ्गृह्यते। अनुप्रयोगस्य सेवकः नास्ति, उपयोक्तृविवरणम् अपि न आवश्यकम्।';

  @override
  String get titlePrivacyPermissions => 'अनुमतयः';

  @override
  String get descPrivacyPermissions =>
      '• छायाग्राहकम्: QR-सङ्केतावलोकनाय\n• स्थानीयजालम्: भवतः उपकरणानां मध्ये Wi-Fi-समन्वयाय एव\n• जैवमितिः: ऐच्छिकम्, अनुप्रयोगतालकोद्घाटनाय\n\nप्रतिलिपिसञ्चिकाः प्रणाल्याः सञ्चिकाचयनेन चीयन्ते, अतः सञ्चयानुमतिः न आवश्यकी।';

  @override
  String get titlePrivacySecurity => 'सुरक्षा';

  @override
  String get descPrivacySecurity =>
      'भवतः रहस्यानि AES-256 गूढलेखनेन सुरक्ष्यन्ते। Wi-Fi-समन्वयं, प्रकाशीयप्रेषणं, प्रतिलिपिनिर्यापणं वा भवान् आरभते तदा एव तानि उपकरणात् बहिः गच्छन्ति, प्रतिवारं गूढलिखितानि च भवन्ति।';

  @override
  String get actionClose => 'पिधीयताम्';

  @override
  String get titleOpenSourceLicenses => 'मुक्तस्रोतानुज्ञापत्राणि';

  @override
  String get descCopyright => '© 2026 श्रीराज पी। सर्वे अधिकाराः सुरक्षिताः।';

  @override
  String get aboutDetailAuthor => 'लेखकः';

  @override
  String get aboutDetailEmail => 'विद्युत्पत्रम्';

  @override
  String get aboutDetailWebsite => 'जालस्थानम्';

  @override
  String get aboutDetailPrivacyPolicy => 'गोपनीयतानीतिः';

  @override
  String get aboutDetailLicense => 'अनुज्ञापत्रम्';

  @override
  String get aboutDetailAiUsed => 'प्रयुक्ता कृत्रिमबुद्धिः';

  @override
  String get aboutDetailIdeUsed => 'प्रयुक्तं विकाससाधनम्';

  @override
  String madeWithLove(String heart) {
    return 'सस्नेहं निर्मितम् $heart भारते';
  }

  @override
  String get madeWithLoveA11y => 'सस्नेहं निर्मितम् भारते';

  @override
  String get actionOk => 'अस्तु';

  @override
  String get actionCancel => 'निरस्यताम्';

  @override
  String get actionCopy => 'प्रतिलिख्यताम्';

  @override
  String get errorPhoneLockFailed => 'दूरभाषपटलतालकम् असफलम्';

  @override
  String get errorPhoneLockCanceled => 'दूरभाषपटलतालकं निरस्तम्';

  @override
  String get errorPhoneLockLockedOut =>
      'दूरभाषपटलतालकं तात्कालिकरूपेण अवरुद्धम्';

  @override
  String get errorPhoneLockUnavailable =>
      'अस्मिन् उपकरणे दूरभाषपटलतालकं न उपलभ्यते';

  @override
  String get errorPhoneLockUnverified => 'दूरभाषपटलतालकं परीक्षितुं न शक्तम्';

  @override
  String get descPinRequiredIdle => 'एकहोरानन्तरम् अनुप्रयोग-PIN आवश्यकम्';

  @override
  String get descPinRequiredReboot =>
      'उपकरणस्य पुनरारम्भात् अनुप्रयोग-PIN आवश्यकम्';

  @override
  String get descPinRequiredFailures =>
      'दूरभाषतालकस्य त्रिवारम् असाफल्यात् अनुप्रयोग-PIN आवश्यकम्';

  @override
  String get descPinRequiredLockdown =>
      'पूर्णावरोधः सक्रियः। अनुप्रयोग-PIN दीयताम्';

  @override
  String get descUnlockPhoneOnly => 'दूरभाषपटलतालकं प्रयुज्यताम्';

  @override
  String get descUnlockPhoneOrPin =>
      'दूरभाषपटलतालकं प्रयुज्यताम्, अथवा अनुप्रयोग-PIN दीयताम्';

  @override
  String get descUnlockPinOnly => 'अनुप्रयोग-PIN दीयताम्';

  @override
  String get descUnlockWithPhone => 'उद्घाटनाय दूरभाषपटलतालकं प्रयुज्यताम्';

  @override
  String get errorPinEmpty => 'प्रथमम् अनुप्रयोग-PIN दीयताम्';

  @override
  String errorPinLockedOut(int seconds) {
    return 'बहवः विफलप्रयत्नाः। $seconds क्षणानन्तरं पुनः प्रयत्यताम्।';
  }

  @override
  String errorPinIncorrectRemaining(int count) {
    return 'अशुद्धम् अनुप्रयोग-PIN। अवशिष्टाः प्रयत्नाः: $count';
  }

  @override
  String get errorPinIncorrect => 'अशुद्धम् अनुप्रयोग-PIN';

  @override
  String get titleNoRecoveryKey => 'पुनःप्राप्तिकुञ्चिका नास्ति';

  @override
  String get descNoRecoveryKey =>
      'अस्य अनुप्रयोग-PIN इत्यस्य कृते पुनःप्राप्तिकुञ्चिका न सज्जीकृता। तया विना प्रवेशं पुनः प्राप्तुम् उपायः नास्ति।\n\nअनुप्रयोगं पुनः स्थापयितुं शक्यते, किन्तु सर्वाणि उपयोक्तृविवरणानि नश्यन्ति।';

  @override
  String get titleEnterRecoveryKey => 'कुञ्चिकाप्रवेशः';

  @override
  String get descEnterRecoveryKey =>
      'अनुप्रयोग-PIN सज्जीकरणकाले रक्षिता पुनःप्राप्तिकुञ्चिका दीयताम्।';

  @override
  String get labelRecoveryKey => 'पुनःप्राप्तिकुञ्चिका';

  @override
  String get errorRecoveryKeyInvalid => 'अमान्या पुनःप्राप्तिकुञ्चिका';

  @override
  String get actionRecover => 'पुनः प्राप्यताम्';

  @override
  String get labelNewPin => 'नूतनम् अनुप्रयोग-PIN';

  @override
  String get descPinDigitsHint => '4–6 अङ्काः';

  @override
  String get labelConfirmPin => 'अनुप्रयोग-PIN स्थिरीकरणम्';

  @override
  String get errorPinTooShort =>
      'अनुप्रयोग-PIN न्यूनातिन्यूनं चतुरङ्कात्मकं भवेत्';

  @override
  String get errorPinMismatch => 'अनुप्रयोग-PIN-द्वयं न सङ्गच्छते';

  @override
  String get actionSavePin => 'PIN रक्ष्यताम्';

  @override
  String get titleSetNewPin => 'नूतनPIN-सज्जीकरणम्';

  @override
  String get descSetNewPin =>
      'भवतः पुरातनम् अनुप्रयोग-PIN अपनीतम्। नूतनम् अनुप्रयोग-PIN सज्जीक्रियताम्।';

  @override
  String get titleRecoveryKey => 'पुनःप्राप्तिकुञ्चिका';

  @override
  String get descRecoveryKeySave =>
      'इयं पुनःप्राप्तिकुञ्चिका सुरक्षिते स्थाने रक्ष्यताम्। अनुप्रयोग-PIN विस्मृते सति प्रवेशं पुनः प्राप्तुम् अयम् एव एकः उपायः।';

  @override
  String get descRecoveryKeyCopied =>
      'पुनःप्राप्तिकुञ्चिका प्रतिलिखिता। 60 क्षणानन्तरं सा अपनेष्यते।';

  @override
  String get descRecoveryKeyOnce => 'इयं कुञ्चिका पुनः न दर्शयिष्यते।';

  @override
  String get actionSavedIt => 'मया रक्षिता';

  @override
  String get titleEnterYourPin => 'PIN-प्रवेशः';

  @override
  String get titleUseDeviceLock => 'दूरभाषतालकम्';

  @override
  String get titleUnlockApp => 'तालकोद्घाटनम्';

  @override
  String labelPinLockedFor(int seconds) {
    return '$seconds क्षणान् अवरुद्धम्';
  }

  @override
  String get labelEnterPin => 'PIN दीयताम्';

  @override
  String errorTooManyAttempts(int seconds) {
    return 'अतिप्रयत्नाः। $seconds क्षणानन्तरं पुनः प्रयत्यताम्';
  }

  @override
  String get actionUnlockWithPin => 'PIN-द्वारेण उद्घाट्यताम्';

  @override
  String get actionForgotPin => 'PIN विस्मृतम्?';

  @override
  String get labelCheckingPhoneLock => 'परीक्ष्यते…';

  @override
  String get actionUsePhoneLock => 'दूरभाषतालकं प्रयुज्यताम्';

  @override
  String get labelOr => 'अथवा';

  @override
  String get descAuthReasonBiometric =>
      'उपयोक्तृविवरणानि द्रष्टुं जैवमित्या प्रमाणीक्रियताम्';

  @override
  String get descAuthReasonPhoneLock =>
      'दूरभाषपटलतालकेन प्रमाणीकारकम् उद्घाट्यताम्';

  @override
  String get errorAppLockMisconfigured =>
      'अनुप्रयोगतालकं सम्यक् न विन्यस्तम्। पुनः सक्रियीक्रियताम्।';

  @override
  String get errorAppLockNoMethod =>
      'अनुप्रयोगतालकस्य उद्घाटनोपायः नास्ति। पुनः सक्रियीक्रियताम्।';

  @override
  String get titleEnterAppPin => 'PIN-प्रवेशः';

  @override
  String get descPinRequiredForSensitive =>
      'संवेदनशीलकार्याणां रहस्यप्रवेशस्य च कृते अनुप्रयोग-PIN आवश्यकम्।';

  @override
  String get labelAppPin => 'अनुप्रयोग-PIN';

  @override
  String get actionVerify => 'परीक्ष्यताम्';

  @override
  String get descPinPurposeViewSecret =>
      'गुप्तकुञ्चिकां द्रष्टुं सम्पादयितुं च।';

  @override
  String get descPinPurposeAdvanced => 'उन्नतविकल्पान् द्रष्टुं सम्पादयितुं च।';

  @override
  String get descPinPurposeSaveChanges =>
      'गुप्तकुञ्चिकायाम् उन्नतविकल्पेषु वा कृतानि परिवर्तनानि रक्षितुम्।';

  @override
  String get descPinPurposeDeleteSelected =>
      'चितानि उपयोक्तृविवरणानि लोप्तुम्।';

  @override
  String get tooltipCancelSelection => 'चयनं निरस्यताम्';

  @override
  String labelSelectedCount(int count) {
    return '$count चितानि';
  }

  @override
  String get tabAccounts => 'उपयोक्तृविवरणानि';

  @override
  String get tabTags => 'चिह्नानि';

  @override
  String get tooltipSelectAll => 'सर्वं चीयताम्';

  @override
  String get tooltipDeselectAll => 'सर्वं विमुच्यताम्';

  @override
  String get tooltipSort => 'क्रमीकरणम्';

  @override
  String get tooltipSettings => 'विन्यासः';

  @override
  String get descReorderHint =>
      'उपयोक्तृविवरणानां क्रमपरिवर्तनाय दीर्घं स्पृश्य कृष्यताम्';

  @override
  String get labelSortManual => 'स्वहस्तेन';

  @override
  String get labelSortIssuer => 'प्रदातृक्रमेण';

  @override
  String get labelSortAccount => 'नामक्रमेण';

  @override
  String get labelSortDate => 'योजनदिनक्रमेण';

  @override
  String descFilteredBy(String tags) {
    return 'चिह्नैः परिशोधितम्: $tags';
  }

  @override
  String get actionClearFilter => 'परिशोधनं निरस्यताम्';

  @override
  String get descHomeHint =>
      'बहुचयनाय दीर्घं स्पृश्यताम् • क्रमपरिवर्तनाय कृष्यताम्।';

  @override
  String get actionReassignTags => 'चिह्नानि परिवर्त्यन्ताम्';

  @override
  String get actionExportSelected => 'निर्याप्यताम्';

  @override
  String get actionDeleteSelected => 'लुप्यताम्';

  @override
  String get actionEdit => 'सम्पाद्यताम्';

  @override
  String get actionDelete => 'लुप्यताम्';

  @override
  String get titleDeleteAccount => 'विवरणलोपः';

  @override
  String descDeleteAccountConfirm(String name) {
    return '$name इति लोप्तव्यम् इति निश्चयः वा?';
  }

  @override
  String descAccountDeleted(String name) {
    return '$name लुप्तम्';
  }

  @override
  String titleReassignTagsCount(int count) {
    return 'चिह्नपरिवर्तनम् ($count)';
  }

  @override
  String get descReassignTagsHint =>
      'अल्पविरामैः पृथक्कृतानि चिह्नानि दीयन्ताम् (यथा कार्यम्, VIP):';

  @override
  String get labelTags => 'चिह्नानि';

  @override
  String get labelTagsExample => 'कार्यम्, व्यक्तिगतम्';

  @override
  String get descReplaceTags =>
      'विद्यमानचिह्नानां स्थाने स्थाप्यन्ताम् (न तु योज्यन्ताम्)';

  @override
  String descTagsUpdated(int count) {
    return '$count विवरणानां चिह्नानि नवीकृतानि';
  }

  @override
  String get actionApplyTags => 'प्रयुज्यताम्';

  @override
  String titleExportSelectedCount(int count) {
    return 'निर्यापणम् ($count)';
  }

  @override
  String get descExportPasswordHint =>
      'अस्य प्रतिलिपिसञ्चिकायाः गूढलेखनाय गुप्तशब्दः सज्जीक्रियताम्।';

  @override
  String get labelPassword => 'गुप्तशब्दः';

  @override
  String get labelConfirmPassword => 'गुप्तशब्दस्थिरीकरणम्';

  @override
  String get errorPasswordTooShort =>
      'गुप्तशब्दे न्यूनातिन्यूनं षड् अक्षराणि भवेयुः';

  @override
  String get errorPasswordMismatch => 'गुप्तशब्दौ न सङ्गच्छेते';

  @override
  String descExportedSelected(int count) {
    return 'चितानि $count विवरणानि निर्यापितानि';
  }

  @override
  String get errorExportSelectedFailed =>
      'चितानि विवरणानि निर्यापयितुं न शक्तम्';

  @override
  String get actionExport => 'निर्याप्यताम्';

  @override
  String get titleDeleteAccounts => 'विवरणलोपः';

  @override
  String descDeleteSelectedConfirm(int count) {
    return '$count विवरणानि लोप्तव्यानि इति निश्चयः वा? इदं कार्यं प्रतिवर्तयितुं न शक्यते।';
  }

  @override
  String get errorAuthFailedDeleteCanceled =>
      'प्रमाणीकरणम् असफलम्। लोपः निरस्तः।';

  @override
  String descAccountsDeleted(int count) {
    return '$count विवरणानि लुप्तानि';
  }

  @override
  String actionDeleteCount(int count) {
    return 'लुप्यताम् ($count)';
  }

  @override
  String get emptyNoAccountsFound => 'न किमपि विवरणं प्राप्तम्';

  @override
  String get emptyNoAccountsYet => 'अद्यापि विवरणानि न सन्ति';

  @override
  String get emptyTryDifferentSearch => 'अन्येन पदेन अन्विष्यताम्';

  @override
  String get emptyAddFirstAccount => 'प्रथमविवरणं योजयितुं + गण्डः स्पृश्यताम्';

  @override
  String get emptyLongPressTip =>
      'सूचना: अधिकविकल्पेभ्यः + गण्डः दीर्घं स्पृश्यताम्';

  @override
  String get labelQrScanner => 'QR-अवलोकनम्';

  @override
  String get descScanQrCode => 'QR-सङ्केतः अवलोक्यताम्';

  @override
  String get labelManualEntry => 'स्वहस्तप्रवेशः';

  @override
  String get descEnterDetailsManually => 'विवरणानि स्वयं दीयन्ताम्';

  @override
  String get labelSearchAccounts => 'विवरणान्वेषणम्…';

  @override
  String get titleTagCloud => 'चिह्नमेघः';

  @override
  String get descTagCloud =>
      'सम्बद्धविवरणानि द्रष्टुं किमपि चिह्नं स्पृश्यताम्';

  @override
  String get actionManageTags => 'चिह्नानि व्यवस्थाप्यन्ताम्';

  @override
  String get labelSearchTags => 'चिह्नान्वेषणम्…';

  @override
  String descActiveFilter(String tags) {
    return 'सक्रियपरिशोधनम्: $tags';
  }

  @override
  String get actionClear => 'अपनीयताम्';

  @override
  String get emptyNoTagsYet => 'अद्यापि चिह्नानि न सन्ति';

  @override
  String emptyNoTagsMatching(String query) {
    return '\"$query\" इत्यनेन न किमपि चिह्नं मिलितम्';
  }

  @override
  String get emptyAddTagsHint =>
      'विवरणस्य रचनाकाले सम्पादनकाले वा चिह्नानि योज्यन्ताम्';

  @override
  String get emptyTryDifferentKeyword => 'अन्येन शब्देन अन्विष्यताम्';

  @override
  String get labelAllTags => 'सर्वचिह्नानि';

  @override
  String get titleAppLockRequired => 'अनुप्रयोगतालकम् आवश्यकम्';

  @override
  String get descAppLockRequiredSecret =>
      'गुप्तकुञ्चिकायाः सम्पादनाय प्रथमं सुरक्षाविन्यासे अनुप्रयोगतालकं सक्रियीक्रियताम्।';

  @override
  String get descAppLockRequiredAdvanced =>
      'उन्नतविकल्पानां सम्पादनाय प्रथमं सुरक्षाविन्यासे अनुप्रयोगतालकं सक्रियीक्रियताम्।';

  @override
  String get descAppLockRequiredSave =>
      'संवेदनशीलक्षेत्रेषु (गुप्तकुञ्चिकायाम् उन्नतविकल्पेषु वा) परिवर्तनानि रक्षितुं प्रथमं सुरक्षाविन्यासे अनुप्रयोगतालकं सक्रियीक्रियताम्।';

  @override
  String get actionOpenSecurity => 'सुरक्षा उद्घाट्यताम्';

  @override
  String get descSecretUnlocked => 'गुप्तकुञ्चिका उद्घाटिता';

  @override
  String get descAdvancedUnlocked => 'उन्नतविन्यासः उद्घाटितः';

  @override
  String get descAccountUpdated => 'विवरणं सफलतया नवीकृतम्';

  @override
  String get descAccountAdded => 'विवरणं सफलतया योजितम्';

  @override
  String get errorSaveAccountFailed =>
      'विवरणं रक्षितुं न शक्तम्। पुनः प्रयत्यताम्।';

  @override
  String get errorSecretRequired => 'गुप्तकुञ्चिका आवश्यकी';

  @override
  String get errorSecretNotBase32 =>
      'अमान्या गुप्तकुञ्चिका। Base32-रूपेण भवेत्';

  @override
  String get errorSecretTooShort => 'गुप्तकुञ्चिका अतिह्रस्वा';

  @override
  String get titleEditAccount => 'विवरणसम्पादनम्';

  @override
  String get titleAddAccount => 'विवरणयोजनम्';

  @override
  String get tooltipScanQr => 'QR-अवलोकनम्';

  @override
  String get actionUpdateAccount => 'विवरणं नवीक्रियताम्';

  @override
  String get actionAddAccount => 'विवरणं योज्यताम्';

  @override
  String get errorQrInvalid => 'अयं QR-सङ्केतः मान्यः प्रमाणीकरणसङ्केतः न।';

  @override
  String get errorQrNoSecret => 'अस्मिन् QR-सङ्केते गुप्तकुञ्चिका नास्ति।';

  @override
  String get errorAddAccountFailed =>
      'विवरणं योजयितुं न शक्तम्। पुनः प्रयत्यताम्।';

  @override
  String descAccountAddedName(String name) {
    return 'विवरणं योजितम्: $name';
  }

  @override
  String get titleAddAccountManually => 'स्वहस्तयोजनम्';

  @override
  String get labelAccountNameRequired => 'विवरणनाम *';

  @override
  String get descAccountNameHint => 'विवरणनाम दीयताम्';

  @override
  String get labelSecretKeyRequired => 'गुप्तकुञ्चिका *';

  @override
  String get descSecretKeyHint => 'गुप्तकुञ्चिका दीयताम्';

  @override
  String get labelIssuerOptional => 'प्रदाता (ऐच्छिकम्)';

  @override
  String get descIssuerHint => 'यथा Google';

  @override
  String get errorNameAndSecretRequired => 'विवरणनाम गुप्तकुञ्चिका च आवश्यके';

  @override
  String get actionAdd => 'योज्यताम्';

  @override
  String get titleScanQrCode => 'QR-अवलोकनम्';

  @override
  String get tooltipToggleFlash => 'दीपः परिवर्त्यताम्';

  @override
  String get tooltipSwitchCamera => 'छायाग्राहकं परिवर्त्यताम्';

  @override
  String get descPositionQr => 'QR-सङ्केतः चतुरस्रान्तः स्थाप्यताम्';

  @override
  String get actionEnterManually => 'स्वहस्तेन दीयताम्';

  @override
  String get titleAccountInformation => 'विवरणसूचना';

  @override
  String get labelAccountName => 'विवरणनाम *';

  @override
  String get descAccountNameExample => 'यथा john@example.com';

  @override
  String get errorAccountNameRequired => 'विवरणनाम आवश्यकम्';

  @override
  String get labelIssuer => 'प्रदाता (ऐच्छिकम्)';

  @override
  String get descIssuerExample => 'यथा Google, GitHub';

  @override
  String get labelSecretKey => 'गुप्तकुञ्चिका *';

  @override
  String get labelTapToUnlock => 'उद्घाटनाय स्पृश्यताम्';

  @override
  String get labelEnableAppLock => 'तालकं सक्रियीक्रियताम्';

  @override
  String get descSecretKeyBase32 => 'Base32-रूपं रहस्यम्';

  @override
  String get titleAdvancedSettings => 'उन्नतविन्यासः';

  @override
  String get tooltipUnlockToEdit => 'सम्पादनाय उद्घाट्यताम्';

  @override
  String get tooltipEnableAppLockFirst => 'तालकं सक्रियीक्रियताम्';

  @override
  String get labelDigits => 'अङ्काः';

  @override
  String get labelPeriodSeconds => 'कालावधिः (क्षणाः)';

  @override
  String get labelAlgorithm => 'गणनविधिः';

  @override
  String labelMaskedValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String labelSecondsMasked(String mask) {
    return '$mask क्षणाः';
  }

  @override
  String get descTapToUnlockSettings => 'विन्यासं द्रष्टुम् उद्घाट्यताम्';

  @override
  String get descEnableAppLockToEdit => 'सम्पादनाय तालकं सक्रियीक्रियताम्';

  @override
  String get titleBrowseTags => 'विद्यमानचिह्नानि';

  @override
  String get actionClearAll => 'सर्वम् अपनीयताम्';

  @override
  String get tooltipClose => 'पिधीयताम्';

  @override
  String get labelSearchExistingTags => 'चिह्नान्वेषणम्…';

  @override
  String get emptyNoExistingTags => 'न किमपि चिह्नं प्राप्तम्';

  @override
  String get emptyTypeNewTags =>
      'अस्मै विवरणाय नूतनानि चिह्नानि लेखक्षेत्रे लिख्यन्ताम्।';

  @override
  String get emptyNoMatchingTags => 'अनुरूपचिह्नानि न सन्ति';

  @override
  String emptyNoTagsMatchQuery(String query) {
    return '\"$query\" इत्यनेन अनुरूपं चिह्नं नास्ति।';
  }

  @override
  String get actionDone => 'समाप्तम्';

  @override
  String actionApplySelected(int count) {
    return 'प्रयुज्यताम् ($count)';
  }

  @override
  String get descTagsFieldHint => 'अल्पविरामैः पृथक्, यथा कार्यम्, VIP';

  @override
  String get labelTapToAdd => 'योजनाय स्पृश्यताम्';

  @override
  String get tooltipBrowseTags => 'विद्यमानचिह्नानि';

  @override
  String get labelPermCamera => 'छायाग्राहकम्';

  @override
  String get descPermCamera => 'विवरणयोजनाय QR-सङ्केतावलोकनार्थम्';

  @override
  String get labelPermBiometric => 'जैवमितिकोद्घाटनम्';

  @override
  String get descPermBiometric =>
      'अङ्गुलिमुद्रया उपकरणतालकेन वा अनुप्रयोगतालकोद्घाटनाय';

  @override
  String get labelPermVibration => 'कम्पनम्';

  @override
  String get descPermVibration => 'QR-सङ्केतावलोकनकाले स्पर्शप्रतिक्रियार्थम्';

  @override
  String get labelPermSecureStorage => 'सुरक्षितसङ्ग्रहः';

  @override
  String get descPermSecureStorage =>
      'गूढलेखनकुञ्चिकाः सुरक्षितं रक्षितुम् Android Keystore प्रयुज्यते';

  @override
  String get labelPermLocalDatabase => 'स्थानीयदत्तांशकोशः';

  @override
  String get descPermLocalDatabase =>
      'गूढलेखितविवरणदत्तांशः भवतः उपकरणे एव सङ्गृह्यते';

  @override
  String get descPermissionsIntro =>
      'अयम् अनुप्रयोगः आवश्यकतायाम् एव अनुमतीः याचते, न कदापि दत्तांशं सञ्चिनोति।';

  @override
  String get titleRuntimePermissions => 'कार्यकालानुमतयः';

  @override
  String get titleBuiltInCapabilities => 'अन्तर्निहितविशेषताः';

  @override
  String get titlePrivacy => 'गोपनीयता';

  @override
  String get labelNoCloudService => 'मेघसेवा नास्ति';

  @override
  String get descNoCloudService =>
      'अनुप्रयोगस्य सेवकः मेघविवरणं वा नास्ति। Wi-Fi-समन्वयः केवलं स्थानीयजालं प्रयुङ्क्ते।';

  @override
  String get labelStatusGranted => 'अनुमतम्';

  @override
  String get labelStatusDenied => 'निषिद्धम्';

  @override
  String get labelStatusNotGranted => 'न अनुमतम्';

  @override
  String get labelStatusNotRequested => 'न याचितम्';

  @override
  String get labelBuiltIn => 'अन्तर्निहितम्';

  @override
  String errorCodeUnavailable(String name) {
    return '$name इत्यस्य सङ्केतः न उपलभ्यते';
  }

  @override
  String descCodeCopied(String name) {
    return '$name इत्यस्य सङ्केतः प्रतिलिखितः';
  }

  @override
  String get descAppLockEnabledPin =>
      'अनुप्रयोग-PIN सहितम् अनुप्रयोगतालकं सक्रियम्';

  @override
  String get descAppLockEnabledPhone =>
      'दूरभाषपटलतालकेन अनुप्रयोगतालकं सक्रियम्';

  @override
  String get titleDisableAppLock => 'तालकनिष्क्रियीकरणम्';

  @override
  String get descDisableAppLock =>
      'अनुप्रयोगतालकस्य निष्क्रियीकरणेन भवतः अनुप्रयोग-PIN, शीघ्रोद्घाटनरुचिः, पुनःप्राप्तिकुञ्चिका च अपनीयन्ते।';

  @override
  String get descAppLockDisabled => 'अनुप्रयोगतालकं निष्क्रियम्';

  @override
  String get titleChooseUnlockMethod => 'उद्घाटनविधिचयनम्';

  @override
  String get descChooseUnlockMethod =>
      'अनुप्रयोगः कथम् उद्घाटनीयः इति चीयताम्। अनुप्रयोग-PIN अधिकसुरक्षितम्; दूरभाषपटलतालकम् अधिकसुकरम्।';

  @override
  String get actionPhoneLock => 'दूरभाषतालकम्';

  @override
  String get actionAppPin => 'अनुप्रयोग-PIN';

  @override
  String get descAppPinEnabled => 'अनुप्रयोग-PIN सक्रियम्';

  @override
  String get errorEnablePhoneLockFirst =>
      'प्रथमं दूरभाषपटलतालकं सक्रियीक्रियताम्, अथवा अनुप्रयोगतालकं निष्क्रियीक्रियताम्।';

  @override
  String get titleRemoveAppPin => 'PIN-अपनयनम्';

  @override
  String get descRemoveAppPin =>
      'भवतः अनुप्रयोग-PIN पुनःप्राप्तिकुञ्चिका च लुप्येते। अनुप्रयोगः केवलं दूरभाषपटलतालकेन उद्घाटयिष्यते।';

  @override
  String get descAppPinRemoved => 'अनुप्रयोग-PIN अपनीतम्';

  @override
  String get errorSetAppPinFirst =>
      'प्रथमम् अनुप्रयोग-PIN सज्जीक्रियताम्, अथवा अनुप्रयोगतालकं निष्क्रियीक्रियताम्।';

  @override
  String get descQuickUnlockDisabled =>
      'दूरभाषपटलतालकेन शीघ्रोद्घाटनं निष्क्रियम्';

  @override
  String get descQuickUnlockEnabled => 'दूरभाषपटलतालकेन शीघ्रोद्घाटनं सक्रियम्';

  @override
  String get descPhoneLockEnabled => 'दूरभाषपटलतालकं सक्रियम्';

  @override
  String get titleAutoLockTimeout => 'स्वतालनकालः';

  @override
  String get labelLockImmediately => 'तत्क्षणम्';

  @override
  String labelMinutesCount(int minutes) {
    return '$minutes निमेषाः';
  }

  @override
  String get titleCurrentPin => 'वर्तमानम् अनुप्रयोग-PIN';

  @override
  String get descAppPinChanged => 'अनुप्रयोग-PIN सफलतया परिवर्तितम्';

  @override
  String get titleSetAppPin => 'PIN-सज्जीकरणम्';

  @override
  String get titleChangeAppPin => 'PIN-परिवर्तनम्';

  @override
  String get descPinRequiredForProtection =>
      'अनुप्रयोगरक्षणाय सर्वरहस्यप्रवेशाय च अनुप्रयोग-PIN आवश्यकम्।';

  @override
  String get actionConfirm => 'स्थिरीक्रियताम्';

  @override
  String get titleAppLockSection => 'अनुप्रयोगतालकम्';

  @override
  String get titleAppPinSection => 'अनुप्रयोग-PIN';

  @override
  String get titlePhoneLockSection => 'दूरभाषपटलतालकम्';

  @override
  String get titleLockdownSection => 'पूर्णावरोधः';

  @override
  String get descEnableAppLock =>
      'अनुप्रयोग-PIN ऐच्छिकेन दूरभाषपटलतालकशीघ्रोद्घाटनेन च अनुप्रयोगः रक्ष्यताम्';

  @override
  String get labelUseAppPin => 'PIN-प्रयोगः';

  @override
  String get descAppPinIsSet => 'अनुप्रयोग-PIN सज्जम्';

  @override
  String get descSetPinHint =>
      'अनुप्रयोगरक्षणाय 4–6 अङ्कात्मकं PIN सज्जीक्रियताम्';

  @override
  String get descUpdateAppPin => 'अनुप्रयोग-PIN नवीक्रियताम्';

  @override
  String get labelResetRecoveryKey => 'कुञ्चिकानवीकरणम्';

  @override
  String get descResetRecoveryKey =>
      'अनुप्रयोग-PIN कृते नूतना पुनःप्राप्तिकुञ्चिका रच्यताम्';

  @override
  String get labelUsePhoneLock => 'दूरभाषतालकप्रयोगः';

  @override
  String get descPhoneLockOptional =>
      'अनुप्रयोगोद्घाटनाय ऐच्छिकं शीघ्रोद्घाटनम्';

  @override
  String get descPhoneLockOnly => 'दूरभाषपटलतालकेन अनुप्रयोगः उद्घाट्यताम्';

  @override
  String get labelLockdownMode => 'पूर्णावरोधविधिः';

  @override
  String get descLockdownMode =>
      'एतत् यावत् न निष्क्रियीक्रियते तावत् शीघ्रोद्घाटनं निरुध्य अनुप्रयोग-PIN याच्यताम्';

  @override
  String get descInfoPhoneOptional =>
      'दूरभाषपटलतालकम् ऐच्छिकं शीघ्रोद्घाटनम्। रहस्यप्रकाशनाय अनुप्रयोग-PIN आवश्यकम्।';

  @override
  String get descInfoPhoneOnly =>
      'दूरभाषपटलतालकम् एव भवतः एकमात्रः उद्घाटनोपायः। दृढतररक्षणाय अनुप्रयोग-PIN सज्जीक्रियताम्।';

  @override
  String get descInfoPhoneLockTypes =>
      'उपकरणानुसारं दूरभाषपटलतालकम् अङ्गुलिमुद्रां, मुखं, रेखाचित्रं, PIN, गुप्तशब्दं वा प्रयुङ्क्ते।';

  @override
  String get titleSetBackupPassword => 'प्रतिलिपिगुप्तशब्दः';

  @override
  String get descSetBackupPassword =>
      'प्रतिलिपेः गूढलेखनाय दृढः गुप्तशब्दः रच्यताम्। विवरणानां पुनःस्थापनाय अयं गुप्तशब्दः आवश्यकः।';

  @override
  String get descPasswordMin8 => 'न्यूनातिन्यूनम् अष्ट अक्षराणि';

  @override
  String get errorPasswordEmpty => 'गुप्तशब्दः रिक्तः न भवेत्';

  @override
  String get errorPasswordTooShort8 =>
      'गुप्तशब्दे न्यूनातिन्यूनम् अष्ट अक्षराणि भवेयुः';

  @override
  String get actionCreateBackup => 'प्रतिलिपिः रच्यताम्';

  @override
  String get errorNoAccountsToBackup => 'प्रतिलिपये विवरणानि न सन्ति';

  @override
  String get descBackupCreated => 'गूढलेखिता प्रतिलिपिः सफलतया रचिता';

  @override
  String get errorBackupCanceledOrFailed => 'प्रतिलिपिः निरस्ता असफला वा';

  @override
  String get errorBackupFailed =>
      'प्रतिलिपिं रचयितुं न शक्तम्। पुनः प्रयत्यताम्।';

  @override
  String get titleRestoreAccounts => 'विवरणपुनःस्थापनम्';

  @override
  String get descRestoreAccounts =>
      'गूढलेखितप्रतिलिपिसञ्चिकातः विवरणानि आनीयन्ताम्। विद्यमानविवरणेषु प्रभावः न भविष्यति।';

  @override
  String get titleEnterBackupPassword => 'प्रतिलिपिगुप्तशब्दः';

  @override
  String get descEnterBackupPassword =>
      'अस्याः प्रतिलिपेः रचनाकाले प्रयुक्तः गुप्तशब्दः दीयताम्:';

  @override
  String get actionRestore => 'पुनःस्थाप्यताम्';

  @override
  String get errorBackupPassword =>
      'गुप्तशब्दः अशुद्धः, अथवा प्रतिलिपिसञ्चिका दूषिता।';

  @override
  String get errorBackupInvalid =>
      'अस्याः प्रतिलिपेः विषयः अमान्यः, अतः किमपि न पुनःस्थापितम्।';

  @override
  String get errorCameraUnavailable =>
      'छायाग्राहकं न उपलभ्यते। विवरणं स्वयं लिखितुं शक्यते।';

  @override
  String get errorBackupTooLarge =>
      'इयं सञ्चिका प्रतिलिपिरूपेण अतिबृहती अस्ति।';

  @override
  String get errorNoAccountsInBackup =>
      'प्रतिलिपौ न किमपि विवरणं प्राप्तम्। गुप्तशब्दं परीक्ष्य पुनः प्रयत्यताम्।';

  @override
  String descAccountsRestored(int count) {
    return 'पुनःस्थापितानि विवरणानि: $count';
  }

  @override
  String get errorAccountsLoadFailed =>
      'भवतः विवरणानि उद्घाटयितुं न शक्तानि। अनुप्रयोगः तस्य दत्तांशः वा इदानीं न अपाक्रियताम्। अनुप्रयोगं पिधाय पुनः उद्घाट्यताम्।';

  @override
  String get errorRestoreFailed =>
      'प्रतिलिपिं पुनःस्थापयितुं न शक्तम्। पुनः प्रयत्यताम्।';

  @override
  String get titleBackupCreated => 'प्रतिलिपिः रचिता';

  @override
  String get descBackupSaved => 'भवतः गूढलेखिता प्रतिलिपिः सफलतया रक्षिता।';

  @override
  String get titleImportant => 'मुख्यम्:';

  @override
  String get descBackupTips =>
      '• प्रतिलिपिसञ्चिका सुरक्षिते स्थाने रक्ष्यताम्\n• प्रतिलिपिगुप्तशब्दः स्मर्यताम्\n• गुप्तशब्दं विना पुनःस्थापनं न शक्यम्';

  @override
  String get actionGotIt => 'अवगतम्';

  @override
  String get actionContinue => 'अनुवर्त्यताम्';

  @override
  String get descBackupsEncrypted =>
      'परमसुरक्षायै सर्वाः प्रतिलिपयः गुप्तशब्देन गूढलेखिताः';

  @override
  String get titleCreateBackupSection => 'प्रतिलिपिरचना';

  @override
  String get labelCreateEncryptedBackup => 'गूढलेखिता प्रतिलिपिः';

  @override
  String get descCreateEncryptedBackup =>
      'गुप्तशब्दरक्षया सर्वाणि विवरणानि निर्याप्यन्ताम्';

  @override
  String get titleRestoreBackupSection => 'प्रतिलिपिपुनःस्थापनम्';

  @override
  String get labelRestoreFromBackup => 'प्रतिलिपेः पुनःस्थापनम्';

  @override
  String get descRestoreFromBackup =>
      'गूढलेखितप्रतिलिपिसञ्चिकातः विवरणानि आनीयन्ताम्';

  @override
  String get titleBestPractices => 'उत्तमाचाराः';

  @override
  String get descBestPractices =>
      '• नियमितं प्रतिलिपयः रच्यन्ताम्\n• दृढः अनन्यः गुप्तशब्दः प्रयुज्यताम्\n• प्रतिलिपयः बहुषु सुरक्षितस्थानेषु रक्ष्यन्ताम्\n• गुप्तशब्दः गुप्तशब्दप्रबन्धके रक्ष्यताम्\n• पुनःस्थापनेन प्रतिलिपयः परीक्ष्यन्ताम्';

  @override
  String get descNeverShareBackups =>
      'प्रतिलिपिसञ्चिकाः गुप्तशब्दान् वा कदापि मा वितरतु। उभयं प्राप्तवान् कोऽपि भवतः प्रमाणीकरणसङ्केतान् रचयितुं शक्नोति।';

  @override
  String get titleRenameTag => 'चिह्ननामपरिवर्तनम्';

  @override
  String get labelTagName => 'चिह्ननाम';

  @override
  String get descTagNameExample => 'यथा कार्यम्, व्यक्तिगतम्';

  @override
  String get errorTagNameEmpty => 'चिह्ननाम दीयताम्';

  @override
  String get errorTagNameSame => 'नूतनं नाम भिन्नं भवेत्';

  @override
  String get actionRename => 'नाम परिवर्त्यताम्';

  @override
  String descTagRenamed(String oldTag, String newTag) {
    return '#$oldTag इति #$newTag इति परिवर्तितम्';
  }

  @override
  String get errorRenameTagFailed =>
      'चिह्ननाम परिवर्तयितुं न शक्तम्। पुनः प्रयत्यताम्।';

  @override
  String get titleDeleteTag => 'चिह्नलोपः';

  @override
  String descDeleteTagUsed(String tag, int count) {
    return '$count विवरणेभ्यः \"#$tag\" अपनेतव्यं वा?';
  }

  @override
  String descDeleteTagUnused(String tag) {
    return 'अप्रयुक्तं \"#$tag\" लोप्तव्यं वा?';
  }

  @override
  String descTagDeleted(String tag) {
    return '#$tag लुप्तम्';
  }

  @override
  String get errorDeleteTagFailed =>
      'चिह्नं लोप्तुं न शक्तम्। पुनः प्रयत्यताम्।';

  @override
  String get labelTotalTags => 'सर्वचिह्नसङ्ख्या';

  @override
  String get labelAccountsTagged => 'चिह्नितविवरणानि';

  @override
  String get emptyNoTagsFound => 'न किमपि चिह्नं प्राप्तम्';

  @override
  String get emptyTagsAppearHere => 'विवरणेषु योजितानि चिह्नानि अत्र दृश्यन्ते';

  @override
  String get emptyTryDifferentQuery => 'अन्यत् अन्वेषणं प्रयत्यताम्';

  @override
  String labelAccountCount(int count) {
    return 'विवरणानि: $count';
  }

  @override
  String get tooltipRenameTag => 'नाम परिवर्त्यताम्';

  @override
  String get tooltipDeleteTag => 'लुप्यताम्';

  @override
  String get errorSyncHostTimeout =>
      'काले किमपि उपकरणं न संयुक्तम्; आतिथ्यं स्थगितम्।';

  @override
  String get errorSyncHostStartFailed =>
      'आतिथ्यम् आरब्धुं न शक्तम्। Wi-Fi सक्रियम् इति परीक्ष्यताम्।';

  @override
  String get errorSyncNoDevice => 'समन्वयाय किमपि उपकरणं न संयुक्तम्।';

  @override
  String get errorSyncNothingSelected =>
      'समन्वयाय न्यूनातिन्यूनम् एकं चीयताम्।';

  @override
  String get errorSyncFailed => 'समन्वयः असफलः। पुनः प्रयत्यताम्।';

  @override
  String get errorOpticalStartFailed => 'प्रकाशीयप्रवाहम् आरब्धुं न शक्तम्।';

  @override
  String get errorOpticalDecodeFailed => 'प्रकाशीयप्रवाहं पठितुं न शक्तम्।';

  @override
  String get errorSyncNotSyncQr => 'अयं समन्वय-QR-सङ्केतः न।';

  @override
  String get errorSyncUnsupportedVersion =>
      'अयं समन्वय-QR-सङ्केतः भिन्नसंस्करणात् आगतः।';

  @override
  String get errorSyncMissingHost => 'समन्वय-QR-सङ्केते आतिथेयसङ्केतः नास्ति।';

  @override
  String get errorSyncInvalidPort => 'समन्वय-QR-सङ्केते द्वारसङ्ख्या अमान्या।';

  @override
  String get errorSyncMissingCode => 'समन्वय-QR-सङ्केते युग्मनसङ्केतः नास्ति।';

  @override
  String get errorSyncMalformed =>
      'अपरेण उपकरणेन प्रेषितः दत्तांशः अनेन अनुप्रयोगेण पठितुं न शक्यः।';

  @override
  String get errorSyncTooManyAccounts =>
      'अपरेण उपकरणेन अत्यधिकानि विवरणानि प्रेषितानि।';

  @override
  String get errorSyncFieldTooLarge =>
      'अपरेण उपकरणेन अतिबृहत् मूल्यं प्रेषितम्।';

  @override
  String get errorSyncPeerGone => 'अपरम् उपकरणम् इदानीं न संयुक्तम्।';

  @override
  String get errorSyncSendFailed => 'दत्तांशं प्रेषयितुं न शक्तम्।';

  @override
  String get errorSyncNoResponse => 'अपरस्मात् उपकरणात् प्रत्युत्तरं नास्ति।';

  @override
  String get errorSyncInvalidResponse =>
      'अपरस्मात् उपकरणात् अप्रत्याशितं प्रत्युत्तरम्।';

  @override
  String get errorSyncConnectionClosed => 'अपरेण उपकरणेन सम्बन्धः समापितः।';

  @override
  String get errorSyncWrongCode => 'अशुद्धः युग्मनसङ्केतः।';

  @override
  String get errorSyncTimedOut => 'सम्बन्धस्य कालसीमा अतीता।';

  @override
  String get errorSyncConnectFailed =>
      'अपरेण उपकरणेन सह संयोक्तुं न शक्तम्। IP-सङ्केतः, द्वारसङ्ख्या, Wi-Fi च परीक्ष्यन्ताम्।';

  @override
  String get errorSyncConnectionError => 'सम्बन्धदोषः।';

  @override
  String get errorOpticalInvalidFrame => 'अयं प्रकाशीयसमन्वयसङ्केतः न।';

  @override
  String get errorOpticalUnsupportedVersion =>
      'अयं प्रकाशीयसङ्केतः भिन्नसंस्करणात् आगतः।';

  @override
  String get errorOpticalCorruptedChunk =>
      'एकं चित्रखण्डं दूषितम्। छायाग्राहकं स्थिरं ध्रियताम्।';

  @override
  String get errorOpticalChecksum =>
      'एकं चित्रखण्डं परीक्षायाम् असफलम्। छायाग्राहकं स्थिरं ध्रियताम्।';

  @override
  String get errorOpticalEmpty => 'प्रेषणाय किमपि नास्ति।';

  @override
  String get errorOpticalIncomplete => 'सर्वाणि चित्रखण्डानि न प्राप्तानि।';

  @override
  String get errorOpticalIntegrity =>
      'प्राप्तः दत्तांशः अखण्डतापरीक्षायाम् असफलः।';

  @override
  String get errorEnterHostIp => 'आतिथेय-IP-सङ्केतः दीयताम्';

  @override
  String get errorEnterPort =>
      'अपरस्मिन् उपकरणे दृश्यमाना द्वारसङ्ख्या दीयताम्';

  @override
  String get errorEnterPairingCode => 'युग्मनसङ्केतः दीयताम्';

  @override
  String get titleSendToDevice => 'उपकरणं प्रति प्रेषणम्';

  @override
  String get descConnectingToHost => 'आतिथेयेन सह संयुज्यते…';

  @override
  String get descReceiving => 'स्वीक्रियते…';

  @override
  String get descP2pInfo =>
      'Wi-Fi-समन्वयः: उभे उपकरणे एकस्मिन् एव Wi-Fi-जाले भवेताम्। युग्मनसङ्केतः कदापि भवतः उपकरणात् बहिः न गच्छति।';

  @override
  String get labelSendOverWifi => 'Wi-Fi-द्वारेण प्रेषणम्';

  @override
  String get descSendOverWifi =>
      'आतिथेयः: स्थानीय-Wi-Fi-द्वारेण विवरणानि विन्यासं च वितीर्यताम्';

  @override
  String get labelReceiveOverWifi => 'Wi-Fi-द्वारेण स्वीकारः';

  @override
  String get descReceiveOverWifi =>
      'संयोगः: आतिथेय-QR अवलोक्यताम् अथवा आतिथेय-IP दीयताम्';

  @override
  String get descOpticalSectionHeader =>
      'प्रकाशीयवायुविच्छेदसमन्वयः (Wi-Fi न, जालं न)';

  @override
  String get labelOpticalSend => 'प्रकाशीयप्रवाहप्रेषणम्';

  @override
  String get descOpticalSend =>
      'विवरणानि चलत्-QR-प्रवाहरूपेण प्रेष्यन्ताम् (12–15 FPS)';

  @override
  String get labelOpticalReceive => 'प्रकाशीयप्रवाहावलोकनम्';

  @override
  String get descOpticalReceive => 'छायाग्राहकेण चलत्-QR-प्रवाहः गृह्यताम्';

  @override
  String get descScanOtherQrHeader => 'अपरस्मिन् उपकरणे स्थितम् QR अवलोक्यताम्';

  @override
  String get actionScanQrCode => 'QR अवलोक्यताम्';

  @override
  String get labelOrEnterManually => 'अथवा स्वयं दीयताम्';

  @override
  String get labelHostIp => 'आतिथेय-IP-सङ्केतः';

  @override
  String get labelPort => 'द्वारसङ्ख्या';

  @override
  String get labelPairingCode => 'युग्मनसङ्केतः';

  @override
  String get actionConnectReceive => 'संयुज्य स्वीक्रियताम्';

  @override
  String get actionBack => 'प्रत्यागमनम्';

  @override
  String get titleConnected => 'संयुक्तम्';

  @override
  String get descWaitingForSender =>
      'किं वितरणीयम् इति प्रेषकस्य चयनं प्रतीक्ष्यते…';

  @override
  String get titleSyncComplete => 'समन्वयः समाप्तः';

  @override
  String descSentAccounts(int count) {
    return 'प्रेषितानि विवरणानि: $count';
  }

  @override
  String descSentSettings(int count) {
    return 'प्रेषिताः विन्यासाः: $count';
  }

  @override
  String descAddedAccounts(int count) {
    return 'योजितानि विवरणानि: $count';
  }

  @override
  String descAddedAccountsSkipped(int count, int skipped) {
    return 'योजितानि विवरणानि: $count ($skipped पूर्वमेव विद्यमानानि, रक्षितानि)';
  }

  @override
  String descAppliedSettings(int count) {
    return 'प्रयुक्ताः विन्यासाः: $count';
  }

  @override
  String get descNothingToSync => 'समन्वयाय किमपि नास्ति।';

  @override
  String get titleSyncFailed => 'समन्वयः असफलः';

  @override
  String get tabServerDetails => 'सेवकविवरणम्';

  @override
  String get tabSync => 'समन्वयः';

  @override
  String get descReceiveHint =>
      'अपरस्मिन् उपकरणे “Wi-Fi-द्वारेण स्वीकारः” → “QR अवलोक्यताम्” चीयताम्';

  @override
  String get descEnterManuallyHint => 'अथवा एतानि स्वयं दीयन्ताम्';

  @override
  String get labelHostIpShort => 'आतिथेय-IP';

  @override
  String get actionCopyCode => 'सङ्केतः प्रतिलिख्यताम्';

  @override
  String get descPairingCodeCopied =>
      'युग्मनसङ्केतः प्रतिलिखितः। 60 क्षणानन्तरं सः अपनेष्यते।';

  @override
  String get actionStopHosting => 'आतिथ्यं स्थग्यताम्';

  @override
  String get descClientConnected =>
      'एकम् उपकरणं संयुक्तम्। किं वितरणीयम् इति चेतुं समन्वयपृष्ठम् उद्घाट्यताम्।';

  @override
  String get descWaitingForClient => 'अपरस्य उपकरणस्य संयोगः प्रतीक्ष्यते…';

  @override
  String get descNoClientYet =>
      'अद्यापि किमपि उपकरणं न संयुक्तम्। सेवकविवरणपृष्ठम् उद्घाट्य अपरेण उपकरणेन QR अवलोक्यताम् सङ्केतः वा दीयताम्।';

  @override
  String get titleNewClientPhone => 'नूतनदूरभाषः';

  @override
  String get descFullSync =>
      'प्रथमवारं सज्जीक्रियमाणं दूरभाषं प्रति सर्वं — सर्वाणि विवरणानि अनुप्रयोगविन्यासाः च — प्रेष्यताम्। उपकरणविशिष्टानि (अनुप्रयोगतालकं, PIN, दूरभाषतालकं, पुनःप्राप्तिकुञ्चिका) न प्रेष्यन्ते।';

  @override
  String get actionFullSync => 'पूर्णसमन्वयः';

  @override
  String get titleSyncToPhone => 'दूरभाषं प्रति';

  @override
  String get descSelectiveSync =>
      'स्वदत्तांशसहितम् अनुप्रयोगं पूर्वमेव धारयतः दूरभाषस्य कृते। किं योजनीयम् इति चीयताम्:';

  @override
  String get labelSyncAccounts => 'विवरणानि';

  @override
  String get labelSyncSettings => 'विन्यासाः';

  @override
  String get descSyncSettings => 'रूपविन्यासः, स्वतालनं, समन्वयकालसीमाः';

  @override
  String get descNoOverride =>
      'अपरस्मिन् उपकरणे विद्यमानं किमपि न परिवर्त्यते। किमपि साम्ये सति अपरम् उपकरणं स्वसंस्करणं रक्षति — तस्य दत्तांशः तिष्ठति।';

  @override
  String get actionSync => 'समन्वीयताम्';

  @override
  String get descSyncing => 'समन्वीयते…';

  @override
  String labelDurationSeconds(int seconds) {
    return '~$seconds क्षणाः';
  }

  @override
  String labelDurationMinutes(int minutes) {
    return '~$minutes निमेषाः';
  }

  @override
  String labelDurationMinSec(int minutes, int seconds) {
    return '~$minutes निमेषाः $seconds क्षणाः';
  }

  @override
  String get titleOpticalSend => 'प्रकाशीयप्रवाहः';

  @override
  String get titleOpticalScan => 'प्रकाशीयावलोकनम्';

  @override
  String get descReconstructing => 'विवरणानि पुनर्निर्मीयन्ते…';

  @override
  String get titleLargeVaultWarning => 'बृहद्दत्तांशपूर्वसूचना';

  @override
  String descLargeVault(int chunks, String duration) {
    return 'अस्मिन् प्रेषणे $chunks खण्डाः सन्ति (प्रायः $duration)। छायाग्राहक-QR-द्वारेण बहुदत्तांशप्रेषणं मन्दं भवति। शीघ्रप्रेषणाय Wi-Fi-समन्वयः विचार्यताम्।';
  }

  @override
  String get descPointReceiver =>
      'स्वीकर्तृ-उपकरणस्य छायाग्राहकम् अस्मिन् चलत्-QR-प्रवाहे स्थाप्यताम्। दत्तांशः प्रेषणसङ्केतेन गूढलेखितः; जालं न प्रयुज्यते।';

  @override
  String get labelStreamHash => 'प्रवाहचिह्नम्:';

  @override
  String get labelEstDuration => 'अनुमितकालः:';

  @override
  String get labelFramesRendered => 'दर्शितखण्डाः:';

  @override
  String labelFramesValue(int frame, int total) {
    return '$frame (खण्डाः: $total)';
  }

  @override
  String get labelTargetFps => 'लक्ष्य-FPS:';

  @override
  String labelFps(int fps) {
    return '$fps FPS';
  }

  @override
  String labelRemaining(String time) {
    return '$time अवशिष्टम्';
  }

  @override
  String get descAlignCamera => 'छायाग्राहकं प्रेषकपटलेन सह संरेख्यताम्…';

  @override
  String get descReconstructingStream => 'प्रवाहः पुनर्निर्मीयते…';

  @override
  String descCaptured(int solved, int total) {
    return 'गृहीताः: $solved / $total खण्डाः';
  }

  @override
  String labelSession(String hash) {
    return 'सत्रम्: $hash';
  }

  @override
  String get titleOpticalComplete => 'प्रकाशीयसमन्वयः समाप्तः';

  @override
  String get descOpticalComplete =>
      'प्रकाशीय-QR-प्रवाहात् विवरणानि पुनर्निर्मितानि।';

  @override
  String get titleOpticalFailed => 'प्रकाशीयसमन्वयः असफलः';

  @override
  String get titleScanSyncQr => 'समन्वय-QR-अवलोकनम्';

  @override
  String get descScanSenderQr => 'प्रेषक-उपकरणे दृश्यमानम् QR अवलोक्यताम्';

  @override
  String get descFeatures01 => 'मुख्यानि 2FA-OTP-साधनानि';

  @override
  String get descFeatures02 => 'मानकानुसारिणी सङ्केतरचना अवलोकनं च';

  @override
  String get descFeatures03 => 'TOTP कालाधारितसङ्केताः';

  @override
  String get descFeatures04 =>
      'RFC 6238 अनुसारं सुरक्षिताः कालाधारिताः एकवारिकसङ्केताः रच्यन्ते। 30 अथवा 60 क्षणानां कालावधिः, 6 अथवा 8 अङ्काः, SHA-1, SHA-256, SHA-512 च समर्थिताः।';

  @override
  String get descFeatures05 => 'RFC 6238 मानकम्';

  @override
  String get descFeatures06 => 'SHA-1/256/512';

  @override
  String get descFeatures07 => '30 अथवा 60 क्षणाः';

  @override
  String get descFeatures08 => 'सजीवं वलयकालमापकम्';

  @override
  String get descFeatures09 => 'HOTP गणकसङ्केताः';

  @override
  String get descFeatures10 =>
      'HOTP-QR-सङ्केतेभ्यः गणकाधारिताः सङ्केताः (RFC 4226)। प्रत्येकं नूतनसङ्केताय अग्रिमसङ्केतगण्डं स्पृश्यताम्। सङ्केतदर्शनात् पूर्वं गणकः रक्ष्यते।';

  @override
  String get descFeatures11 => 'QR-सङ्केतेन योजनम्';

  @override
  String get descFeatures12 => 'गणकः रक्षितः';

  @override
  String get descFeatures13 => 'एकस्पर्शे एकः सङ्केतः';

  @override
  String get descFeatures14 => 'शीघ्रं QR-अवलोकनम्';

  @override
  String get descFeatures15 =>
      'मानक-2FA-QR-सङ्केतेषु (otpauth://) छायाग्राहकं स्थापयित्वा विवरणानि योज्यन्ताम्। दीपः तत्क्षणपरीक्षणं च अन्तर्भवतः।';

  @override
  String get descFeatures16 => 'शीघ्रं ज्ञानम्';

  @override
  String get descFeatures17 => 'दीपसमर्थनम्';

  @override
  String get descFeatures18 => 'सुरक्षितपरीक्षणम्';

  @override
  String get descFeatures19 => 'चिह्नचित्राणि';

  @override
  String get descFeatures20 =>
      'प्रसिद्धसेवानां (Apple, AWS, Binance, Discord, GitHub, Google, Microsoft, Nintendo, Proton, Steam) चिह्नचित्रम्, अन्यासां वर्णमय-आद्याक्षराणि च दर्श्यन्ते।';

  @override
  String get descFeatures21 => '10 अन्तर्निहितचिह्नानि';

  @override
  String get descFeatures22 => 'वर्णमय-आद्याक्षराणि';

  @override
  String get descFeatures23 => 'स्वयं मेलनम्';

  @override
  String get descFeatures24 => 'शीघ्रप्रतिलेखनं कालगणना च';

  @override
  String get descFeatures25 =>
      'कमपि सङ्केतं स्पृष्ट्वा स्पर्शप्रतिक्रियया सह प्रतिलिपिफलके प्रतिलिख्यते। सङ्केतः कियत्कालं मान्यः इति वृत्ताकारः कालमापकः दर्शयति।';

  @override
  String get descFeatures26 => 'एकस्पर्शप्रतिलेखनम्';

  @override
  String get descFeatures27 => 'स्पर्शप्रतिक्रिया';

  @override
  String get descFeatures28 => 'सुगमं प्रगतिवलयम्';

  @override
  String get descFeatures29 => 'कोशसुरक्षा गोपनीयता च';

  @override
  String get descFeatures30 => 'दृढं गूढलेखनं, जैवमितिः, अनुसरणं सर्वथा नास्ति';

  @override
  String get descFeatures31 => 'AES-256-GCM गूढलेखनम्';

  @override
  String get descFeatures32 =>
      'सर्वाणि विवरणरहस्यानि AES-256-GCM-द्वारा गूढलेखितानि रक्ष्यन्ते। उपकरणकुञ्चिका Android Keystore-मध्ये रक्ष्यते (समर्थेषु दूरभाषेषु यन्त्रांशरक्षया)।';

  @override
  String get descFeatures33 => 'AES-256-GCM';

  @override
  String get descFeatures34 => 'Android Keystore';

  @override
  String get descFeatures35 => 'कोशे अनावृतं रहस्यं नास्ति';

  @override
  String get descFeatures36 => 'जैवमितिः पटलतालकं च';

  @override
  String get descFeatures37 =>
      'अङ्गुलिमुद्रया, मुखेन, दूरभाषपटलतालकेन, अनुप्रयोग-PIN-द्वारा वा अनुप्रयोगः ताल्यताम्। भवतः दूरभाषं गृह्णद्भ्यः सङ्केताः सुरक्षिताः तिष्ठन्ति।';

  @override
  String get descFeatures38 => 'अङ्गुलिमुद्रा / मुखम्';

  @override
  String get descFeatures39 => 'दूरभाषतालकविकल्पः';

  @override
  String get descFeatures40 => 'शीघ्रोद्घाटनम्';

  @override
  String get descFeatures41 => 'स्वतालनम्';

  @override
  String get descFeatures42 =>
      'अन्यानुप्रयोगं प्रति गमने, लघूकरणे, दूरभाषस्य निद्रायां वा अनुप्रयोगः ताल्यते, विगूढसङ्केताः स्मृतेः अपनीयन्ते च।';

  @override
  String get descFeatures43 => 'पृष्ठभूमितालनम्';

  @override
  String get descFeatures44 => 'स्मृतिशोधनम्';

  @override
  String get descFeatures45 => 'परिवर्तनीया कालसीमा';

  @override
  String get descFeatures46 => 'पटलचित्ररक्षा (FLAG_SECURE)';

  @override
  String get descFeatures47 =>
      'मूलतः सक्रियम्। पटलचित्राणि, पटलध्वन्यालेखनं, सद्यःप्रयुक्तानुप्रयोगचित्राणि च निरुध्यन्ते; अतः पटलात् सङ्केताः प्राप्तुं न शक्यन्ते।';

  @override
  String get descFeatures48 => 'FLAG_SECURE';

  @override
  String get descFeatures49 => 'सद्यःदृश्यं नास्ति';

  @override
  String get descFeatures50 => 'पटलग्रहणं नास्ति';

  @override
  String get descFeatures51 => 'अन्तर्जालरहितम्, दूरमापनं नास्ति';

  @override
  String get descFeatures52 =>
      'पूर्णतया उपकरणे एव कार्यं करोति: अन्तर्जालसेवकः, मेघप्रवेशः, विश्लेषणं, दोषप्रतिवेदनम्, अनुसरणं च न सन्ति। Wi-Fi-समन्वयः केवलं स्थानीयजालं प्रयुङ्क्ते।';

  @override
  String get descFeatures53 => 'पूर्णतया अन्तर्जालरहितम्';

  @override
  String get descFeatures54 => 'विश्लेषणं नास्ति';

  @override
  String get descFeatures55 => 'मेघविवरणं नास्ति';

  @override
  String get descFeatures56 => 'रहस्यानि गूढलिखितानि';

  @override
  String get descFeatures57 => 'व्यवस्था कार्यक्षमता च';

  @override
  String get descFeatures58 =>
      'विवरणानि वर्गीक्रियन्ताम्, अन्विष्यन्ताम्, व्यवस्थाप्यन्ताम्';

  @override
  String get descFeatures59 => 'बहुचिह्नव्यवस्था';

  @override
  String get descFeatures60 =>
      'कस्मैचित् अपि विवरणाय बहूनि चिह्नानि दीयन्ताम् (यथा कार्यम्, व्यक्तिगतम्, वित्तम्)। परिशोधनपट्टिकायाम् एकस्पर्शेन चिह्नानुसारं विवरणसूची परिशोध्यताम्।';

  @override
  String get descFeatures61 => 'विवरणे बहूनि चिह्नानि';

  @override
  String get descFeatures62 => 'चिह्नपट्टिकाः';

  @override
  String get descFeatures63 => 'एकस्पर्शपरिशोधनम्';

  @override
  String get descFeatures64 => 'चिह्नमेघः';

  @override
  String get descFeatures65 =>
      'चिह्नमेघः सर्वाणि चिह्नानि, प्रत्येकेन कति विवरणानि सम्बद्धानि इति च दर्शयति। चिह्नं स्पृष्ट्वा तस्य विवरणानि एव दृश्यन्ते।';

  @override
  String get descFeatures66 => 'दृश्यचिह्नदर्शनम्';

  @override
  String get descFeatures67 => 'विवरणसङ्ख्या';

  @override
  String get descFeatures68 => 'शीघ्रसञ्चारः';

  @override
  String get descFeatures69 => 'सजीवान्वेषणम्';

  @override
  String get descFeatures70 =>
      'नाम, उपयोक्तृनाम, सेवा, चिह्नं वा लिखित्वा कमपि विवरणं प्राप्यताम्; लेखनसमये फलानि परिवर्तन्ते।';

  @override
  String get descFeatures71 => 'तत्कालान्वेषणम्';

  @override
  String get descFeatures72 => 'नामानि चिह्नानि च';

  @override
  String get descFeatures73 => 'तत्क्षणफलम्';

  @override
  String get descFeatures74 => 'क्रमीकरणं सम्पादनं च';

  @override
  String get descFeatures75 =>
      'विवरणानि इष्टक्रमेण स्थाप्यन्ताम्; आवश्यकतायां नाम, सेवा, सङ्केतविन्यासः च परिवर्त्यन्ताम्।';

  @override
  String get descFeatures76 => 'कर्षणेन क्रमपरिवर्तनम्';

  @override
  String get descFeatures77 => 'विवरणसम्पादनम्';

  @override
  String get descFeatures78 => 'समूहकार्याणि';

  @override
  String get descFeatures79 => 'समन्वयः, वायुविच्छेदः, प्रतिलिपयः च';

  @override
  String get descFeatures80 =>
      'विवरणानि सुरक्षितं स्थानान्तर्यन्ताम्, गूढलेखिताः प्रतिलिपयः निर्याप्यन्ताम्';

  @override
  String get descFeatures81 => 'Wi-Fi-समन्वयः';

  @override
  String get descFeatures82 =>
      'स्थानीय-Wi-Fi-जाले द्वयोः उपकरणयोः मध्ये विवरणानि स्थानान्तर्यन्ताम्। QR-रूपेण दर्शितः युग्मनसङ्केतः प्रेषणं रक्षति; तस्मात् सङ्केतात् निर्मितया कुञ्चिकया दत्तांशः गूढलेखितः भवति। अन्तर्जालं न प्रयुज्यते।';

  @override
  String get descFeatures83 => 'केवलं स्थानीय-Wi-Fi';

  @override
  String get descFeatures84 => 'गूढलेखितं प्रेषणम्';

  @override
  String get descFeatures85 => 'मेघः नास्ति';

  @override
  String get descFeatures86 => 'प्रकाशीयवायुविच्छेदः';

  @override
  String get descFeatures87 =>
      'Wi-Fi, नीलदन्तं (Bluetooth) वा विना चलत्-QR-सङ्केतश्रेण्या अन्तर्जालरहितम् उपकरणं प्रति विवरणानि स्थानान्तर्यन्ताम्। QR-सङ्केताः भवता लिखितेन एकवारिकसङ्केतेन गूढलेख्यन्ते।';

  @override
  String get descFeatures88 => 'जालं नास्ति';

  @override
  String get descFeatures89 => 'चलत्-QR-प्रवाहः';

  @override
  String get descFeatures90 => 'गूढलेखितप्रवाहः';

  @override
  String get descFeatures91 => 'गूढलेखिताः प्रतिलिपयः';

  @override
  String get descFeatures92 =>
      'सर्वाणि विवरणानि भवतः गुप्तशब्देन रक्षितायां गूढलेखितप्रतिलिपिसञ्चिकायां निर्याप्यन्ताम् (PBKDF2-कुञ्चिकया AES-256)।';

  @override
  String get descFeatures93 => 'AES-256 गूढलेखितम्';

  @override
  String get descFeatures94 => 'गुप्तशब्दरक्षितम्';

  @override
  String get descFeatures95 => 'वहनीया सञ्चिका';

  @override
  String get descFeatures96 => 'सुरक्षितम् आनयनम्';

  @override
  String get descFeatures97 =>
      'प्रतिलिपीनाम् आनयनं समन्वयदत्तांशस्वीकारः च सुरक्षितौ। विद्यमानविवरणानि रक्ष्यन्ते, नूतनानि योज्यन्ते; किमपि न परिवर्त्यते।';

  @override
  String get descFeatures98 => 'केवलं योजनम्';

  @override
  String get descFeatures99 => 'द्विरुक्तिरक्षा';

  @override
  String get descFeatures100 => 'आनयनसारः';

  @override
  String get descFeatures101 => 'विशेषताः';

  @override
  String descFeatures102(String appName) {
    return '$appName विशेषताः';
  }

  @override
  String get descFeatures103 =>
      'अनुप्रयोगे अन्तर्निहिताः सर्वाः सुरक्षाव्यवस्थाः सङ्केतसाधनानि च परिचीयन्ताम्।';

  @override
  String get helpHome01 => 'साहाय्यकेन्द्रम्';

  @override
  String get helpHome02 => 'प्रमाणीकरणं सज्जीकरणं च';

  @override
  String get helpHome03 => 'आरम्भः विवरणयोजनं च';

  @override
  String get helpHome04 =>
      'QR-सङ्केतावलोकनं, गुप्तकुञ्चिकानां स्वहस्तयोजनं, 2FA-सङ्केतप्रयोगः च कथम्।';

  @override
  String get helpHome05 => 'कालसमन्वयः सङ्केतविचलनं च';

  @override
  String get helpHome06 =>
      'निराकृतसङ्केताः, दूरभाषघटिकाविचलनं, HOTP-गणकसङ्केताः च।';

  @override
  String get helpHome07 => 'चिह्नानि विवरणव्यवस्था च';

  @override
  String get helpHome08 =>
      'चिह्नयोजनं, विवरणपरिशोधनं, चिह्नमेघः, चिह्नप्रबन्धनं च।';

  @override
  String get helpHome09 => 'सुरक्षा कोशरक्षा च';

  @override
  String get helpHome10 => 'जैवमितिः अनुप्रयोगतालकं च';

  @override
  String get helpHome11 =>
      'अङ्गुलिमुद्रा, मुखोद्घाटनं, दूरभाषपटलतालकविकल्पः, स्वतालननियमाः च।';

  @override
  String get helpHome12 => 'कोशः पटलचित्ररक्षा च';

  @override
  String get helpHome13 =>
      'Android Keystore कुञ्चिकासङ्ग्रहः, FLAG_SECURE पटलरक्षा, अन्तर्जालरहिता गोपनीयता च।';

  @override
  String get helpHome14 => 'समन्वयः प्रतिलिपयः च';

  @override
  String get helpHome15 => 'Wi-Fi-समन्वयः';

  @override
  String get helpHome16 =>
      'युग्मनसङ्केतात् निर्मितया कुञ्चिकया गूढलेखितं, स्थानीय-Wi-Fi-द्वारेण साक्षात् उपकरणप्रेषणम्।';

  @override
  String get helpHome17 => 'प्रकाशीयवायुविच्छेदप्रेषणम्';

  @override
  String get helpHome18 =>
      'चलत्-QR-सङ्केतैः अन्तर्जालरहितम् उपकरणं प्रति विवरणानि स्थानान्तर्यन्ताम्।';

  @override
  String get helpHome19 => 'गूढलेखितप्रतिलिपिः पुनःस्थापनं च';

  @override
  String get helpHome20 =>
      'गुप्तशब्दरक्षितप्रतिलिपिसञ्चिकारचना, नूतने दूरभाषे विवरणपुनःस्थापनं च।';

  @override
  String get helpHome21 => 'प्रायः पृष्टाः प्रश्नाः';

  @override
  String get helpHome22 => 'प्रश्नाः समस्यापरिहारः च';

  @override
  String get helpHome23 =>
      'सङ्केताः, प्रतिलिपयः, अनुमतयः, नूतनदूरभाषं प्रति स्थानान्तरणं च इति विषये लघूत्तराणि।';

  @override
  String get helpHome24 => 'साहाय्यकेन्द्रं मार्गदर्शिकाः च';

  @override
  String helpHome25(String appName) {
    return '$appName इत्यस्य सर्वविशेषताणां कृते मार्गदर्शिकाः उत्तराणि च।';
  }

  @override
  String get helpStart01 => 'आरम्भः';

  @override
  String helpStart02(String appName) {
    return '$appName भवतः अन्तर्जालविवरणानि रक्षन्तः द्विस्तरीयाः (2FA) सङ्केताः रचयति। सर्वे सङ्केताः अन्तर्जालं विना भवतः उपकरणे एव रच्यन्ते।';
  }

  @override
  String get helpStart03 => 'QR-सङ्केतेन विवरणयोजनम्';

  @override
  String get helpStart04 =>
      'सेवायां (यथा Google, GitHub, Amazon) सुरक्षा-2FA-विन्यासम् उद्घाट्य प्रमाणीकरणानुप्रयोगस्य सज्जीकरणं चीयताम्।';

  @override
  String helpStart05(String appName, String qrScanner) {
    return '$appName इत्यस्मिन् मुख्यपटले “+” गण्डं स्पृष्ट्वा “$qrScanner” चीयताम्।';
  }

  @override
  String get helpStart06 =>
      'सङ्गणके अन्यपटले वा स्थिते QR-सङ्केते छायाग्राहकं स्थाप्यताम्। विवरणं तत्क्षणं परीक्ष्य योज्यते।';

  @override
  String get helpStart07 => 'स्वहस्तेन विवरणयोजनम्';

  @override
  String helpStart08(String manualEntry) {
    return 'QR-सङ्केतः अवलोकयितुं न शक्यते चेत्, योजनसूच्याः “$manualEntry” चीयताम्।';
  }

  @override
  String get helpStart09 =>
      'विवरणनाम (यथा विद्युत्पत्रम् उपयोक्तृनाम वा) प्रदाता (यथा GitHub, Google) च दीयताम्।';

  @override
  String get helpStart10 => 'सेवया दत्ता गुप्तकुञ्चिका (Base32) संयोज्यताम्।';

  @override
  String get helpStart11 =>
      'उन्नतविन्यासे गणनविधिः (SHA1, SHA256, SHA512), अङ्काः (6 अथवा 8), कालावधिः (30 अथवा 60 क्षणाः) च निश्चेतुं शक्यन्ते।';

  @override
  String get helpStart12 => '2FA-सङ्केतप्रयोगः';

  @override
  String get helpStart13 =>
      'कालाधारिताः (TOTP) सङ्केताः सामान्यतः प्रतिक्षणत्रिंशत् परिवर्तन्ते। सङ्केतः कियत्कालं मान्यः इति गणनावलयं दर्शयति।';

  @override
  String get helpStart14 =>
      'कमपि विवरणं स्पृष्ट्वा तस्य वर्तमानसङ्केतः प्रतिलिपिफलके प्रतिलिख्यते।';

  @override
  String get helpStart15 =>
      'जालस्थानस्य सेवायाः वा प्रवेशपटले सङ्केतः संयोज्यताम्।';

  @override
  String get helpStart16 =>
      'सूचना: दूरभाषनाशे उपयोगाय अन्तर्जालसेवाभिः दत्ताः पुनःप्राप्तिसङ्केताः सदा सुरक्षिते स्थाने रक्ष्यन्ताम्।';

  @override
  String get helpTime01 => 'कालसमन्वयः विचलनं च';

  @override
  String get helpTime02 =>
      'TOTP-सङ्केताः दूरभाषस्य यथार्थकालम् आश्रयन्ते। घटिका कतिपयक्षणान् अपि विचलति चेत् जालस्थानानि सङ्केतान् निराकुर्युः।';

  @override
  String get helpTime03 => 'TOTP-कालः कथं कार्यं करोति';

  @override
  String get helpTime04 =>
      'कालाधारितः सङ्केतः भवतः गुप्तकुञ्चिकया त्रिंशत्क्षणात्मकैः पदैः गणितेन वर्तमानकालेन च रच्यते।';

  @override
  String get helpTime05 =>
      'दूरभाषेण सेवकेन च UTC-काले ऐकमत्यं भवेत्। कालक्षेत्रपरिवर्तनं UTC न प्रभावयति।';

  @override
  String get helpTime06 => 'निराकृतसङ्केतसमाधानम्';

  @override
  String get helpTime07 =>
      'दूरभाषविन्यासम् उद्घाट्य System → Date & time प्रति गम्यताम्।';

  @override
  String get helpTime08 =>
      '“Set time automatically” “Set time zone automatically” च सक्रियीक्रियेताम्।';

  @override
  String get helpTime09 =>
      'तानि पूर्वमेव सक्रियाणि चेत्, निष्क्रियीकृत्य पुनः सक्रियीक्रियन्ताम्; तदा दूरभाषः जालकालं तत्क्षणं गृह्णाति।';

  @override
  String get helpTime10 => 'HOTP-गणकसङ्केताः';

  @override
  String get helpTime11 =>
      'HOTP-सङ्केताः कालं न, गणकम् आश्रयन्ते, अतः घटिकायाः प्रभावः नास्ति। नूतनसङ्केताय विवरणे अग्रिमसङ्केतगण्डं स्पृश्यताम्।';

  @override
  String get helpTime12 =>
      'प्रत्येकं स्पर्शः एकं सङ्केतं व्ययति। आवश्यके एव स्पृश्यताम्: बहुषु त्यक्तेषु सेवा सङ्केतान् निराकुर्यात्।';

  @override
  String get helpTime13 =>
      'पुनःस्थापितायां प्रतिलिप्यां द्वितीयोपकरणस्थे प्रतिरूपे वा पुरातनः गणकः स्यात्। सेवा सङ्केतं निराकरोति चेत्, समीकरणाय कतिचित् वारान् पुनः स्पृश्यताम्।';

  @override
  String get helpTime14 =>
      'सूचना: अधिकांशाः निराकृतसङ्केताः दूरभाषघटिकायाः दोषात् भवन्ति। स्वचालितः जालकालः एतत् स्थिरतया समादधाति।';

  @override
  String get helpTags01 => 'चिह्नानि व्यवस्था च';

  @override
  String get helpTags02 =>
      'चिह्नानि भवतः 2FA-विवरणानि स्वकीयवर्गेषु (यथा कार्यम्, व्यक्तिगतम्, वित्तकोशः, समाजः) स्थापयन्ति, येन सुखेन परिशोधनं भवति।';

  @override
  String get helpTags03 => 'विवरणेभ्यः चिह्नदानम्';

  @override
  String get helpTags04 =>
      'विवरणयोजने सम्पादने वा अल्पविरामैः पृथक्कृतानि चिह्ननामानि लिख्यन्ताम् (यथा “कार्यम्, मेघः, तन्त्रम्”)।';

  @override
  String get helpTags05 =>
      'लेखनसमये अनुप्रयोगः विद्यमानचिह्नानि सूचयति, येन नामानि समानानि तिष्ठन्ति।';

  @override
  String helpTags06(String browseTags) {
    return 'प्रयुक्तेभ्यः सर्वचिह्नेभ्यः चेतुं “$browseTags” स्पृश्यताम्।';
  }

  @override
  String get helpTags07 => 'चिह्नानुसारं परिशोधनम्';

  @override
  String get helpTags08 =>
      'मुख्यपटलस्य चिह्नपट्टिका भवतः चिह्नानि स्पर्शनीयपट्टिकारूपेण दर्शयति।';

  @override
  String helpTags09(String allTags) {
    return 'चिह्नपट्टिकां स्पृष्ट्वा तस्य विवरणानि एव दृश्यन्ते। परिशोधनम् अपनेतुं “$allTags” स्पृश्यताम्।';
  }

  @override
  String get helpTags10 =>
      'सर्वचिह्नानि प्रत्येकस्य विवरणसङ्ख्या च द्रष्टुं चिह्नमेघं प्रति गम्यताम्।';

  @override
  String get helpTags11 => 'चिह्नप्रबन्धनम्';

  @override
  String helpTags12(String settings, String manageTags) {
    return 'सर्वविवरणेषु एकदा चिह्ननामपरिवर्तनाय लोपाय वा $settings → $manageTags प्रति गम्यताम्। विद्यमानं नाम दत्तं चेत् उभे एकीभवतः।';
  }

  @override
  String get helpTags13 =>
      'चिह्ननामपरिवर्तनेन तद्युक्तानि सर्वविवरणानि नवीक्रियन्ते।';

  @override
  String get helpTags14 =>
      'चिह्नलोपेन विवरणेभ्यः केवलं चिह्नम् अपनीयते; विवरणानि तिष्ठन्ति।';

  @override
  String get helpTags15 =>
      'सूचना: लघूनि चिह्ननामानि (यथा “कार्यम्”, “वित्तम्”) परिशोधनपट्टिकायां सुन्दराणि दृश्यन्ते।';

  @override
  String get helpLock01 => 'जैवमितिः अनुप्रयोगतालकं च';

  @override
  String helpLock02(String appName) {
    return '$appName अङ्गुलिमुद्रया, मुखेन, दूरभाषपटलतालकेन, अनुप्रयोग-PIN-द्वारा वा भवतः सङ्केतान् रक्षितुं शक्नोति।';
  }

  @override
  String get helpLock03 => 'अनुप्रयोगतालकं कथं कार्यं करोति';

  @override
  String helpLock04(String settings, String security) {
    return '$settings → $security इत्यत्र सक्रियं चेत्, अनुप्रयोगस्य उद्घाटने पुनरागमने च उद्घाटनं याच्यते।';
  }

  @override
  String get helpLock05 =>
      'अनुप्रयोगः उद्घाटितः अतालितः च यावत् तावत् एव विगूढसङ्केताः स्मृतौ तिष्ठन्ति।';

  @override
  String get helpLock06 => 'स्वतालनम्';

  @override
  String get helpLock07 =>
      'अनुप्रयोगत्यागे, अन्यानुप्रयोगगमने, दूरभाषपटलतालने वा अनुप्रयोगः तत्क्षणं ताल्यते। उद्घाटितावस्थायां स्वतालनकालानन्तरम् अपि ताल्यते।';

  @override
  String get helpLock08 =>
      'विगूढसङ्केताः स्मृतेः अपनीयन्ते, अतः दूरभाषं गृह्णन् तान् पठितुं न शक्नोति।';

  @override
  String get helpLock09 => 'विकल्पः दूरभाषतालकं च';

  @override
  String get helpLock10 =>
      'अङ्गुलिमुद्रा मुखं वा न अभिज्ञायते चेत् (यथा आर्द्राङ्गुलयः, अल्पप्रकाशः), दूरभाषपटलतालकस्य PIN, रेखाचित्रं, गुप्तशब्दः वा प्रयोक्तुं शक्यते।';

  @override
  String helpLock11(String appName) {
    return 'परीक्षणम् Android स्वयं करोति। $appName भवतः जैवमितिदत्तांशं दूरभाषगुप्तसङ्केतं वा कदापि न पश्यति न रक्षति च।';
  }

  @override
  String get helpLock12 =>
      'सूचना: उत्तमरक्षणाय दूरभाषविन्यासे सुरक्षितं पटलतालकं सज्जीक्रियताम्।';

  @override
  String get helpVault01 => 'कोशसुरक्षा गोपनीयता च';

  @override
  String helpVault02(String appName) {
    return '$appName अन्तर्जालं विना कार्याय कस्मिन्नपि सेवके अविश्वासाय च निर्मितम्। भवतः गुप्तकुञ्चिकाः उपकरणे एव गूढलेख्यन्ते, कस्मैचित् अपि दूरसेवकाय न प्रेष्यन्ते।';
  }

  @override
  String get helpVault03 => 'AES-256-GCM गूढलेखनम्';

  @override
  String get helpVault04 =>
      'सर्वाणि रहस्यानि सङ्केतविन्यासाः च GCM-विधौ AES-256-द्वारा गूढलेख्यन्ते, यत् दत्तांशस्य कमपि परिवर्तनं ज्ञापयति।';

  @override
  String get helpVault05 =>
      'गूढलेखनकुञ्चिका भवतः उपकरणे रच्यते, Android Keystore-मध्ये रक्ष्यते च (समर्थेषु दूरभाषेषु यन्त्रांशरक्षया)।';

  @override
  String get helpVault06 =>
      'किमपि रहस्यम् अनावृतरूपेण दत्तांशकोशे कदापि न लिख्यते।';

  @override
  String get helpVault07 => 'पटलचित्ररक्षा (FLAG_SECURE)';

  @override
  String get helpVault08 =>
      'मूलतः अनुप्रयोगः स्वगवाक्षाय Android FLAG_SECURE सक्रियीकरोति। सुरक्षाविन्यासे एतत् निष्क्रियीकर्तुं शक्यते।';

  @override
  String get helpVault09 =>
      'एतत् पटलचित्राणि, पटलालेखनं, पटलपाठकानुप्रयोगान् च भवतः सङ्केतग्रहणात् निरुणद्धि।';

  @override
  String get helpVault10 =>
      'सद्यःप्रयुक्तानुप्रयोगदर्शने अनुप्रयोगः रिक्तपटलं दर्शयति, अतः समीपस्थाः सङ्केतान् द्रष्टुं न शक्नुवन्ति।';

  @override
  String get helpVault11 => 'मेघः न, दूरमापनं न';

  @override
  String get helpVault12 =>
      'अनुप्रयोगे सेवकः, प्रवेशः, विज्ञापनं, विश्लेषणसङ्केतः वा नास्ति।';

  @override
  String get helpVault13 =>
      'भवतः रहस्यानि सङ्केताः च कस्मैचित् अपि सेवकाय न प्रेष्यन्ते। अनुप्रयोगः लेखान्, उपकरणपरिचयान्, उपयोगविवरणं वा न प्रेषयति।';

  @override
  String get helpVault14 =>
      'QR-अवलोकनं, सङ्केतरचना, प्रतिलिपिनिर्यापणं च सर्वम् अन्तर्जालं विना चलति। केवलं Wi-Fi-समन्वयः स्थानीयजालं प्रयुङ्क्ते।';

  @override
  String get helpVault15 => 'गोपनीयता प्रथमा: भवतः प्रमाणीकरणरहस्यानि भवतः एव।';

  @override
  String get helpWifi01 => 'Wi-Fi-समन्वयः';

  @override
  String get helpWifi02 =>
      'Wi-Fi-समन्वयः एकस्मिन् Wi-Fi-जाले स्थितयोः द्वयोः दूरभाषयोः मध्ये 2FA-विवरणानि साक्षात् स्थानान्तरयति। दत्तांशः गूढलेखितः, कापि मेघसेवा न प्रयुज्यते।';

  @override
  String get helpWifi03 => 'Wi-Fi-समन्वयः कथम्';

  @override
  String get helpWifi04 =>
      'पदम् 1: उभे उपकरणे एकस्मिन् Wi-Fi-जाले संयुज्येताम्।';

  @override
  String helpWifi05(String settings, String syncDevices, String sendOverWifi) {
    return 'पदम् 2: प्रेषक-उपकरणे $settings → $syncDevices → “$sendOverWifi” उद्घाट्यताम्। तत् युग्मन-QR-सङ्केतं युग्मनसङ्केतं च दर्शयति।';
  }

  @override
  String helpWifi06(String receiveOverWifi) {
    return 'पदम् 3: स्वीकर्तृ-उपकरणे “$receiveOverWifi” स्पृष्ट्वा युग्मन-QR-सङ्केतः अवलोक्यताम् (अथवा विवरणानि लिख्यन्ताम्)।';
  }

  @override
  String get helpWifi07 =>
      'पदम् 4: उपकरणे संयुज्येते, प्रेषकः किं वितरणीयम् इति चिनोति।';

  @override
  String get helpWifi08 => 'गूढलेखनम्';

  @override
  String get helpWifi09 =>
      'पटले दर्शितात् युग्मनसङ्केतात् (PBKDF2-द्वारा) निर्मितया कुञ्चिकया AES-256-GCM-मध्ये दत्तांशः गूढलेख्यते।';

  @override
  String get helpWifi10 =>
      'युग्मनसङ्केतं विना भवतः Wi-Fi-प्रवाहं निरीक्षमाणः 2FA-रहस्यानि पठितुं न शक्नोति।';

  @override
  String get helpWifi11 =>
      'युग्मनसङ्केतः जालेन कदापि न प्रेष्यते; अवलोकनेन लेखनेन वा भवान् एव तं स्थानान्तरयति।';

  @override
  String get helpWifi12 => 'सुरक्षितं संयोजनम्';

  @override
  String get helpWifi13 =>
      'समन्वयः केवलं विवरणानि योजयति। स्वीकर्तृ-उपकरणे किमपि न लुप्यते न परिवर्त्यते च।';

  @override
  String get helpWifi14 =>
      'स्वीकर्तृ-उपकरणे पूर्वमेव विद्यमानानि विवरणानि त्यज्यन्ते।';

  @override
  String get helpWifi15 =>
      'सूचना: प्रेषणसमाप्तिपर्यन्तम् उभे उपकरणे जागृते एकस्मिन् Wi-Fi-जाले च स्थाप्येताम्।';

  @override
  String get helpOptical01 => 'प्रकाशीयवायुविच्छेदः';

  @override
  String get helpOptical02 =>
      'प्रकाशीयप्रेषणं Wi-Fi, नीलदन्तं, तन्तून् वा विना चलत्-QR-सङ्केतश्रेण्या अन्तर्जालरहितम् उपकरणं प्रति विवरणानि स्थानान्तरयति।';

  @override
  String get helpOptical03 => 'वायुविच्छेदः कः?';

  @override
  String get helpOptical04 =>
      'वायुविच्छिन्नस्य उपकरणस्य कोऽपि जालसम्बन्धः नास्ति (Wi-Fi, नीलदन्तः, चलदूरभाषदत्तांशः न; विमानविधिः सक्रियः)।';

  @override
  String get helpOptical05 =>
      'दत्तांशः पटलात् छायाग्राहकं प्रति केवलं प्रकाशरूपेण गच्छति, अतः श्रवणाय जालं नास्ति। QR-सङ्केताः गूढलेखिताः, तेषां कुञ्चिका च प्रेषकपटले कदापि अदर्शितात् सङ्केतात् निर्मीयते।';

  @override
  String get helpOptical06 => 'प्रकाशीयप्रेषणं कथम्';

  @override
  String helpOptical07(
    String settings,
    String syncDevices,
    String scanOptical,
  ) {
    return 'पदम् 1: स्वीकर्तृ-उपकरणे $settings → $syncDevices → “$scanOptical” प्रति गम्यताम्। तत् एकवारिकं प्रेषणसङ्केतं दर्शयति।';
  }

  @override
  String helpOptical08(String sendOptical) {
    return 'पदम् 2: प्रेषक-उपकरणे “$sendOptical” चित्वा सः सङ्केतः लिख्यताम्। विवरणानि तेन गूढलेखितानि आवर्तमानया QR-सङ्केतश्रेण्या दर्श्यन्ते।';
  }

  @override
  String helpOptical09(String startScanning) {
    return 'पदम् 3: स्वीकर्तृ-उपकरणे “$startScanning” स्पृष्ट्वा छायाग्राहकं प्रेषकपटले स्थाप्यताम्।';
  }

  @override
  String get helpOptical10 =>
      'पदम् 4: स्वीकर्ता सर्वान् खण्डान् सङ्गृह्णाति। सर्वेषु खण्डेषु पठितेषु सङ्केते च शुद्धे विवरणानि आनीयन्ते। सङ्केते अशुद्धे किमपि न आनीयते।';

  @override
  String get helpOptical11 => 'वेगसूचनाः';

  @override
  String get helpOptical12 =>
      'प्रेषके वेगः प्रतिक्षणं 10, 12, 15 वा चित्रखण्डाः इति निश्चेतुं शक्यते; छायाग्राहकः खण्डान् त्यजति चेत् मन्दवेगः प्रयुज्यताम्।';

  @override
  String get helpOptical13 =>
      'उभे उपकरणे सुप्रकाशे स्थिरं ध्रियेताम्; पटले प्रतिबिम्बं दीप्तिं च परिहरतु।';

  @override
  String get helpOptical14 =>
      'सूचना: सुरक्षिते स्थाने रक्षिताय अन्तर्जालरहिताय प्रतिलिपिदूरभाषाय प्रकाशीयसमन्वयः उचितः।';

  @override
  String get helpBackup01 => 'गूढलेखितप्रतिलिपिः';

  @override
  String get helpBackup02 =>
      'दूरभाषस्य क्षतौ नाशे वा नूतनदूरभाषं प्रति गमने वा प्रतिलिपयः भवन्तं रक्षन्ति। प्रत्येका प्रतिलिपिसञ्चिका भवता चितेन गुप्तशब्देन गूढलेख्यते।';

  @override
  String get helpBackup03 => 'गूढलेखितप्रतिलिपिरचना';

  @override
  String helpBackup04(
    String settings,
    String backupRestore,
    String createBackup,
  ) {
    return '$settings → $backupRestore → “$createBackup” स्पृश्यताम्।';
  }

  @override
  String get helpBackup05 =>
      'दृढः प्रतिलिपिगुप्तशब्दः चीयताम्। सञ्चिकायाः गूढलेखनाय अनुप्रयोगः तस्मात् PBKDF2 (300,000 आवृत्तयः) इत्यनेन AES-256-कुञ्चिकां रचयति।';

  @override
  String get helpBackup06 =>
      'गूढलेखिता .aes प्रतिलिपिसञ्चिका उपकरणे, USB-धारके, स्वकीये अन्तर्जालरहिते सञ्चये वा रक्ष्यताम्।';

  @override
  String get helpBackup07 => 'गुप्तशब्दसुरक्षा पुनःप्राप्तिः च';

  @override
  String get helpBackup08 =>
      'भवतः प्रतिलिपिगुप्तशब्दः कुत्रापि न रक्ष्यते न प्रेष्यते च। सः स्मर्तव्यः सुरक्षितं लिखित्वा रक्षणीयः वा।';

  @override
  String helpBackup09(String appName) {
    return '$appName पूर्णतया अन्तर्जालं विना चलति, अतः “गुप्तशब्दविस्मरणम्” सेवकपुनःसज्जीकरणं वा नास्ति। नष्टः प्रतिलिपिगुप्तशब्दः पुनः प्राप्तुं न शक्यते।';
  }

  @override
  String get helpBackup10 => 'प्रतिलिपिपुनःस्थापनम्';

  @override
  String helpBackup11(
    String settings,
    String backupRestore,
    String restoreBackup,
  ) {
    return '$settings → $backupRestore → “$restoreBackup” स्पृश्यताम्।';
  }

  @override
  String get helpBackup12 =>
      'प्रतिलिपिसञ्चिकां चित्वा तस्याः रचनाकाले प्रयुक्तः गुप्तशब्दः दीयताम्।';

  @override
  String get helpBackup13 =>
      'अनुप्रयोगः सञ्चिकां परीक्ष्य नूतनविवरणानि विद्यमानेषु योजयति; विद्यमानं किमपि न लुप्यते।';

  @override
  String get helpBackup14 =>
      'सूचना: महत्त्वपूर्णानि नूतनानि 2FA-विवरणानि योज्यन्ते यदा यदा तदा तदा नूतना प्रतिलिपिः रच्यताम्।';

  @override
  String get helpFaq01 => 'प्रश्नाः समाधानं च';

  @override
  String get helpFaq02 =>
      '2FA-सङ्केताः, पुनःप्राप्तिः, सुरक्षा, सामान्यसमस्याः च इति विषये शीघ्रोत्तराणि।';

  @override
  String get helpFaq03 => '2FA-सङ्केताः';

  @override
  String get helpFaq04 => 'जालस्थानानि मम सङ्केतान् किमर्थं निराकुर्वन्ति?';

  @override
  String get helpFaq05 =>
      'प्रायः दूरभाषघटिका अशुद्धा भवति। दूरभाषविन्यासः → Date & time उद्घाट्य “Set time automatically” सक्रियीक्रियताम्, येन घटिका UTC-अनुसारिणी भवति।';

  @override
  String get helpFaq06 => 'एकस्पर्शेन सङ्केतः प्रतिलेखितुं शक्यते वा?';

  @override
  String get helpFaq07 =>
      'आम्। मुख्यपटले विवरणं स्पृश्यताम्; तस्य सङ्केतः प्रतिलिपिफलके प्रतिलिख्यते, लघुसन्देशः तत् दृढीकरोति च।';

  @override
  String get helpFaq08 => 'HOTP-सङ्केताः TOTP-सङ्केतेभ्यः कथं भिन्नाः?';

  @override
  String get helpFaq09 =>
      'TOTP-सङ्केताः कालानुसारं प्रतिक्षणत्रिंशत् परिवर्तन्ते। HOTP-सङ्केताः अग्रिमसङ्केतगण्डस्पर्शे एव परिवर्तन्ते, प्रत्येकं स्पर्शः एकं सङ्केतं व्ययति च।';

  @override
  String get helpFaq10 => 'सुरक्षा गोपनीयता च';

  @override
  String get helpFaq11 => 'अनुप्रयोगपरिवर्तने अयं रिक्तः किमर्थम्?';

  @override
  String get helpFaq12 =>
      'मूलतः सक्रिया पटलचित्ररक्षा Android FLAG_SECURE सक्रियीकरोति। एतत् पटलालेखकान् सद्यःप्रयुक्तानुप्रयोगदर्शनं च सङ्केतग्रहणात् निरुणद्धि।';

  @override
  String helpFaq13(String appName) {
    return '$appName किमपि दत्तांशम् अन्तर्जाले प्रेषयति वा?';
  }

  @override
  String helpFaq14(String appName) {
    return 'न। $appName अन्तर्जालं विना चलति। विश्लेषणम्, अनुसरणं, मेघसेवा वा नास्ति। स्थानीयजाले Wi-Fi-समन्वयं, प्रकाशीयप्रेषणं, प्रतिलिपिनिर्यापणं वा भवान् आरभते तदा एव दत्तांशः उपकरणात् बहिः गच्छति।';
  }

  @override
  String get helpFaq15 => 'अङ्गुलिमुद्रा मुखं वा न अभिज्ञायते चेत् किम्?';

  @override
  String get helpFaq16 =>
      'दूरभाषपटलतालकस्य PIN, रेखाचित्रेण, गुप्तशब्देन, अनुप्रयोग-PIN-द्वारा वा उद्घाटयितुं शक्यते।';

  @override
  String get helpFaq17 => 'प्रतिलिपयः दूरभाषपरिवर्तनं च';

  @override
  String get helpFaq18 => 'विवरणानि नूतनदूरभाषं प्रति कथं स्थानान्तर्यन्ते?';

  @override
  String helpFaq19(String syncDevices) {
    return 'स्थानीय-Wi-Fi-द्वारेण “$syncDevices” प्रयुज्यताम्, प्रकाशीय-QR-प्रवाहः अवलोक्यताम्, अथवा पुरातने दूरभाषे गूढलेखितप्रतिलिपिं निर्याप्य नूतने पुनःस्थाप्यताम्।';
  }

  @override
  String get helpFaq20 => 'प्रतिलिपिगुप्तशब्दः विस्मृतः चेत् किम्?';

  @override
  String get helpFaq21 =>
      'प्रतिलिपयः AES-256-गूढलेखनं प्रयुञ्जते, सेवकः च नास्ति, अतः नष्टः प्रतिलिपिगुप्तशब्दः पुनः प्राप्तुं न शक्यते। सः सुरक्षितं लिखित्वा रक्ष्यताम्।';

  @override
  String get helpFaq22 => 'प्रतिलिपिपुनःस्थापनं मम विवरणानि मार्क्ष्यति वा?';

  @override
  String helpFaq23(String appName) {
    return 'न। $appName केवलं विवरणानि योजयति। विद्यमानानि तिष्ठन्ति, द्विरुक्तानि त्यज्यन्ते।';
  }

  @override
  String helpFaq24(String settings, String permissions) {
    return 'अधिकसाहाय्यम् अपेक्षितं वा? साहाय्ये अन्याः मार्गदर्शिकाः पठ्यन्ताम्, अथवा $settings → $permissions इत्यत्र अनुमतयः परीक्ष्यन्ताम्।';
  }

  @override
  String get titleTransferCode => 'प्रेषणसङ्केतः';

  @override
  String get descTransferCodeShow =>
      'अयं सङ्केतः प्रेषक-उपकरणे लिख्यताम्, ततः अधःस्थं गण्डं स्पृश्यताम्। अयं सङ्केतः अन्यस्मै न दर्शनीयः।';

  @override
  String get actionStartScanning => 'अवलोकनम् आरभ्यताम्';

  @override
  String get descTransferCodeEnter =>
      'स्वीकर्तृ-उपकरणे दर्शितः प्रेषणसङ्केतः लिख्यताम्। QR-प्रवाहः तेन गूढलेख्यते।';

  @override
  String get actionStartSending => 'प्रेषणम् आरभ्यताम्';

  @override
  String errorTransferCodeLength(int count) {
    return 'सङ्केतस्य सर्वाणि $count अक्षराणि लिख्यन्ताम्।';
  }

  @override
  String get errorOpticalWrongCode =>
      'सङ्केतः न समानः। प्रेषक-उपकरणे स्थगयित्वा सङ्केतः पुनः लिख्यताम्।';

  @override
  String get errorOpticalCodeInvalid =>
      'प्रेषणसङ्केतः अमान्यः। पुनः आरभ्य स्वीकर्तृ-उपकरणे दर्शितः सङ्केतः लिख्यताम्।';

  @override
  String get tooltipNextCode => 'अग्रिमसङ्केतः';

  @override
  String get descHotpTapForCode => 'प्रथमम् अग्रिमसङ्केतगण्डं स्पृश्यताम्।';

  @override
  String get errorHotpNextFailed => 'अग्रिमसङ्केतः न प्राप्तः।';

  @override
  String get tooltipShowPassword => 'गुप्तशब्दः दर्श्यताम्';

  @override
  String get tooltipHidePassword => 'गुप्तशब्दः गोप्यताम्';

  @override
  String get tooltipClearSearch => 'अन्वेषणं मार्ज्यताम्';

  @override
  String get tooltipShowCode => 'सङ्केतः दर्श्यताम्';

  @override
  String get tooltipHideCode => 'सङ्केतः गोप्यताम्';

  @override
  String get tooltipAddAccount => 'विवरणं योज्यताम्';

  @override
  String get tooltipAddOptions => 'योजनविकल्पाः';

  @override
  String get descCodeHidden => 'सङ्केतः गुप्तः';

  @override
  String get titleScreenPrivacySection => 'पटलगोपनीयता';

  @override
  String get labelBlockScreenshots => 'पटलचित्रनिरोधः';

  @override
  String get descBlockScreenshots =>
      'पटलचित्रेषु पटलालेखने सद्यःप्रयुक्तानुप्रयोगचित्रेषु च सङ्केतानां प्रदर्शनं निरुणद्धि';

  @override
  String get titleAllowScreenshots => 'पटलचित्राणि अनुमन्यन्ताम्?';

  @override
  String get descAllowScreenshotsWarning =>
      'ततः भवतः सङ्केताः रहस्यानि च पटलचित्रेषु पटलालेखनेषु सद्यःप्रयुक्तानुप्रयोगदर्शने च दृश्येरन्। अन्ये अनुप्रयोगाः अपि तानि गृह्णीयुः।';

  @override
  String get errorBlockScreenshotsFailed =>
      'पटलचित्रविन्यासः परिवर्तयितुं न शक्तः';

  @override
  String get titleDataSection => 'दत्तांशः';

  @override
  String get labelDeleteAllData => 'सर्वः दत्तांशः लुप्यताम्';

  @override
  String get descDeleteAllDataEntry =>
      'सर्वाणि उपयोक्तृविवरणानि सर्वः विन्यासः च अस्मात् उपकरणात् लुप्यन्ताम्';

  @override
  String get titleDeleteAllData => 'सर्वं लुप्यताम्?';

  @override
  String get descDeleteAllDataWarning =>
      'भवतः सर्वाणि उपयोक्तृविवरणानि, अनुप्रयोग-PIN, पुनःप्राप्तिकुञ्चिका, विन्यासः च अस्मात् उपकरणात् लुप्यन्ते। एतत् प्रत्यावर्तयितुं न शक्यते। प्रतिलिपिं विना उपयोक्तृविवरणेषु प्रवेशः नश्येत्।\n\nअन्यत्र रक्षिताः प्रतिलिपिसञ्चिकाः न लुप्यन्ते।';

  @override
  String get descDeleteAllDataUnderstand =>
      'एतत् प्रत्यावर्तयितुं न शक्यते इति जानामि';

  @override
  String get actionDeleteAll => 'सर्वं लुप्यताम्';

  @override
  String get descAuthReasonDeleteAllData =>
      'सर्वस्य दत्तांशस्य लोपः स्थिरीक्रियताम्';

  @override
  String get descPinPurposeDeleteAllData => 'सर्वं दत्तांशं लोप्तुम्।';

  @override
  String get descAllDataDeleted => 'सर्वः दत्तांशः लुप्तः';

  @override
  String get errorDeleteAllDataFailed =>
      'कश्चित् दत्तांशः लोप्तुं न शक्तः। पुनः प्रयत्यताम्।';
}
