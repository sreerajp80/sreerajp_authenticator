// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get descSplashLoading => 'Securing your accounts...';

  @override
  String get titleSettings => 'Settings';

  @override
  String get titleAppearance => 'Appearance';

  @override
  String get titleSecurity => 'Security';

  @override
  String get titleExploreSupport => 'Explore & support';

  @override
  String get titleLanguage => 'Language';

  @override
  String get titleSecuritySettings => 'Security settings';

  @override
  String get descSecuritySettingsEntry => 'Configure app lock and biometric';

  @override
  String get titleBackupRestore => 'Backup & restore';

  @override
  String get descBackupRestoreEntry => 'Export or import your accounts';

  @override
  String get titleManageTags => 'Manage tags';

  @override
  String get descManageTagsEntry => 'Edit, rename, or clean up account tags';

  @override
  String get titleSyncDevice => 'Sync devices';

  @override
  String get descSyncDeviceEntry =>
      'Transfer accounts via Wi-Fi or Optical Air-Gap';

  @override
  String get titleSyncHostTimeout => 'Sync host timeout';

  @override
  String descSyncHostTimeoutEntry(int seconds) {
    return 'Stop hosting after $seconds s if no device connects';
  }

  @override
  String labelSecondsCount(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get titlePermissions => 'Permissions';

  @override
  String get descPermissionsEntry => 'View app permissions and status';

  @override
  String get titleFeatures => 'Features';

  @override
  String descFeaturesEntry(String appName) {
    return 'Explore all features of $appName';
  }

  @override
  String get titleHelp => 'Help';

  @override
  String get descHelpEntry => 'Guides, troubleshooting, and sync details';

  @override
  String get titleAbout => 'About';

  @override
  String get descAboutEntry => 'Version, author, and license details';

  @override
  String descAppearanceThemeMode(String mode) {
    return 'Theme mode: $mode';
  }

  @override
  String get titleThemeMode => 'Theme mode';

  @override
  String get titleThemeInformation => 'Theme information';

  @override
  String get titleVisualDesign => 'Visual design system';

  @override
  String descVisualDesign(String appName) {
    return '$appName uses an offline-first 3D neumorphic theme with vibrant token countdown rings and high-contrast accessibility.';
  }

  @override
  String get descThemeSummarySystem => 'System default (follows OS settings)';

  @override
  String get descThemeSummaryLight => 'Light theme';

  @override
  String get descThemeSummaryDark => 'Dark theme';

  @override
  String get titleSelectThemeMode => 'Select theme mode';

  @override
  String get labelThemeSystem => 'System default';

  @override
  String get descThemeSystem => 'Automatically follow your device system theme';

  @override
  String get labelThemeLight => 'Light theme';

  @override
  String get descThemeLight => 'Clean, high-contrast light appearance';

  @override
  String get labelThemeDark => 'Dark theme';

  @override
  String get descThemeDark =>
      'Comfortable dark appearance for low-light environments';

  @override
  String get titleCurrentStatus => 'Current status';

  @override
  String get labelActiveDark => 'Active: dark';

  @override
  String get labelActiveLight => 'Active: light';

  @override
  String get descThemeStatusSystem =>
      'Follows your device system-wide dark mode preference.';

  @override
  String get descThemeStatusLight => 'Always stays in light appearance mode.';

  @override
  String get descThemeStatusDark => 'Always stays in dark appearance mode.';

  @override
  String get titleSelectLanguage => 'Select language';

  @override
  String get labelLanguageSystem => 'System default';

  @override
  String get descLanguageSystem =>
      'Use the device language when it is English, Malayalam or Sanskrit; otherwise English';

  @override
  String get labelLanguageNameEn => 'English';

  @override
  String get labelLanguageNameMl => 'Malayalam';

  @override
  String get labelLanguageNameSa => 'Sanskrit';

  @override
  String descLanguageRowA11y(String value) {
    return 'Language: $value';
  }

  @override
  String labelVersionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get labelEnvProduction => 'Production';

  @override
  String get labelEnvDevelopment => 'Development';

  @override
  String get descFeatureQr => 'QR code scanning';

  @override
  String get descFeatureEncrypted => 'Encrypted storage';

  @override
  String get descFeatureBackup => 'Backup & restore';

  @override
  String get descFeatureOrganize => 'Account organization';

  @override
  String get descFeatureBiometric => 'Biometric authentication';

  @override
  String get descFeatureDarkMode => 'Dark mode support';

  @override
  String get titleDeveloper => 'Developer';

  @override
  String get titleLinks => 'Links';

  @override
  String get titlePrivacyPolicy => 'Privacy policy';

  @override
  String get titlePrivacyStorage => 'Data storage';

  @override
  String get descPrivacyStorage =>
      'All your account data is stored on your device and encrypted. The app has no server and needs no account.';

  @override
  String get titlePrivacyPermissions => 'Permissions';

  @override
  String get descPrivacyPermissions =>
      '• Camera: Used for scanning QR codes\n• Local network: Used only for Wi-Fi sync between your own devices\n• Biometric: Optional, for app lock authentication\n\nBackup files are chosen with the system file picker, so no storage permission is needed.';

  @override
  String get titlePrivacySecurity => 'Security';

  @override
  String get descPrivacySecurity =>
      'Your secrets are encrypted using AES-256 encryption. They leave your device only when you start a Wi-Fi sync, an optical transfer or a backup export, and they are encrypted each time.';

  @override
  String get actionClose => 'Close';

  @override
  String get titleOpenSourceLicenses => 'Open source licenses';

  @override
  String get descCopyright => '© 2026 Sreeraj P. All rights reserved.';

  @override
  String get aboutDetailAuthor => 'Author';

  @override
  String get aboutDetailEmail => 'Email';

  @override
  String get aboutDetailWebsite => 'Website';

  @override
  String get aboutDetailPrivacyPolicy => 'Privacy policy';

  @override
  String get aboutDetailLicense => 'License';

  @override
  String get aboutDetailAiUsed => 'AI used';

  @override
  String get aboutDetailIdeUsed => 'IDE used';

  @override
  String madeWithLove(String heart) {
    return 'Made with $heart in India';
  }

  @override
  String get madeWithLoveA11y => 'Made with love in India';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionCopy => 'Copy';

  @override
  String get errorPhoneLockFailed => 'Phone screen lock failed';

  @override
  String get errorPhoneLockCanceled => 'Phone screen lock was canceled';

  @override
  String get errorPhoneLockLockedOut =>
      'Phone screen lock is temporarily locked out';

  @override
  String get errorPhoneLockUnavailable =>
      'Phone screen lock is not available on this device';

  @override
  String get errorPhoneLockUnverified => 'Unable to verify phone screen lock';

  @override
  String get descPinRequiredIdle => 'App PIN required after 1 hour';

  @override
  String get descPinRequiredReboot => 'App PIN required after device restart';

  @override
  String get descPinRequiredFailures =>
      'App PIN required after 3 failed phone lock attempts';

  @override
  String get descPinRequiredLockdown =>
      'Lockdown mode is on. Enter your App PIN';

  @override
  String get descUnlockPhoneOnly => 'Use your phone screen lock';

  @override
  String get descUnlockPhoneOrPin =>
      'Use your phone screen lock or enter your App PIN';

  @override
  String get descUnlockPinOnly => 'Enter your App PIN';

  @override
  String get descUnlockWithPhone => 'Use your phone screen lock to unlock';

  @override
  String get errorPinEmpty => 'Please enter your App PIN';

  @override
  String errorPinLockedOut(int seconds) {
    return 'Too many failed attempts. Try again in $seconds seconds.';
  }

  @override
  String errorPinIncorrectRemaining(int count) {
    return 'Incorrect App PIN. Attempts left: $count';
  }

  @override
  String get errorPinIncorrect => 'Incorrect App PIN';

  @override
  String get titleNoRecoveryKey => 'No recovery key';

  @override
  String get descNoRecoveryKey =>
      'No recovery key was set up for this App PIN. Unfortunately, there is no way to recover access without it.\n\nYou can reinstall the app, but all accounts will be lost.';

  @override
  String get titleEnterRecoveryKey => 'Enter recovery key';

  @override
  String get descEnterRecoveryKey =>
      'Enter the recovery key you saved when setting up your App PIN.';

  @override
  String get labelRecoveryKey => 'Recovery key';

  @override
  String get errorRecoveryKeyInvalid => 'Invalid recovery key';

  @override
  String get actionRecover => 'Recover';

  @override
  String get labelNewPin => 'New App PIN';

  @override
  String get descPinDigitsHint => '4–6 digits';

  @override
  String get labelConfirmPin => 'Confirm App PIN';

  @override
  String get errorPinTooShort => 'App PIN must be at least 4 digits';

  @override
  String get errorPinMismatch => 'App PINs do not match';

  @override
  String get actionSavePin => 'Save App PIN';

  @override
  String get titleSetNewPin => 'Set new App PIN';

  @override
  String get descSetNewPin =>
      'Your old App PIN has been cleared. Please set a new App PIN.';

  @override
  String get titleRecoveryKey => 'Recovery key';

  @override
  String get descRecoveryKeySave =>
      'Save this recovery key in a safe place. It is the only way to regain access if you forget your App PIN.';

  @override
  String get descRecoveryKeyCopied =>
      'Recovery key copied. It is cleared from the clipboard after 60 seconds.';

  @override
  String get descRecoveryKeyOnce => 'This key will NOT be shown again.';

  @override
  String get actionSavedIt => 'I\'ve saved it';

  @override
  String get titleEnterYourPin => 'Enter your App PIN';

  @override
  String get titleUseDeviceLock => 'Unlock with phone';

  @override
  String get titleUnlockApp => 'Unlock the app';

  @override
  String labelPinLockedFor(int seconds) {
    return 'Locked for $seconds s';
  }

  @override
  String get labelEnterPin => 'Enter App PIN';

  @override
  String errorTooManyAttempts(int seconds) {
    return 'Too many attempts. Try again in $seconds s';
  }

  @override
  String get actionUnlockWithPin => 'Unlock with App PIN';

  @override
  String get actionForgotPin => 'Forgot App PIN?';

  @override
  String get labelCheckingPhoneLock => 'Checking phone lock…';

  @override
  String get actionUsePhoneLock => 'Use phone lock';

  @override
  String get labelOr => 'or';

  @override
  String get descAuthReasonBiometric =>
      'Authenticate with biometrics to access your accounts';

  @override
  String get descAuthReasonPhoneLock =>
      'Unlock the authenticator with your phone screen lock';

  @override
  String get errorAppLockMisconfigured =>
      'App lock is not properly configured. Please re-enable it.';

  @override
  String get errorAppLockNoMethod =>
      'App lock has no unlock method. Please re-enable it.';

  @override
  String get titleEnterAppPin => 'Enter App PIN';

  @override
  String get descPinRequiredForSensitive =>
      'App PIN is required for sensitive actions and secret access.';

  @override
  String get labelAppPin => 'App PIN';

  @override
  String get actionVerify => 'Verify';

  @override
  String get descPinPurposeViewSecret => 'To view and edit the secret key.';

  @override
  String get descPinPurposeAdvanced => 'To view and edit the advanced options.';

  @override
  String get descPinPurposeSaveChanges =>
      'To save changes to the secret key or advanced options.';

  @override
  String get descPinPurposeDeleteSelected => 'To delete the selected accounts.';

  @override
  String get tooltipCancelSelection => 'Cancel selection';

  @override
  String labelSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get tabAccounts => 'Accounts';

  @override
  String get tabTags => 'Tags';

  @override
  String get tooltipSelectAll => 'Select all';

  @override
  String get tooltipDeselectAll => 'Deselect all';

  @override
  String get tooltipSort => 'Sort';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get descReorderHint => 'Long press and drag to reorder accounts';

  @override
  String get labelSortManual => 'Manual';

  @override
  String get labelSortIssuer => 'By issuer';

  @override
  String get labelSortAccount => 'By account name';

  @override
  String get labelSortDate => 'By date added';

  @override
  String descFilteredBy(String tags) {
    return 'Filtered by: $tags';
  }

  @override
  String get actionClearFilter => 'Clear filter';

  @override
  String get descHomeHint =>
      'Long press to enter multi-select • Drag to reorder.';

  @override
  String get actionReassignTags => 'Reassign tags';

  @override
  String get actionExportSelected => 'Export selected';

  @override
  String get actionDeleteSelected => 'Delete selected';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get titleDeleteAccount => 'Delete account';

  @override
  String descDeleteAccountConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String descAccountDeleted(String name) {
    return '$name deleted';
  }

  @override
  String titleReassignTagsCount(int count) {
    return 'Reassign tags ($count)';
  }

  @override
  String get descReassignTagsHint =>
      'Enter tags separated by commas (e.g. Work, VIP):';

  @override
  String get labelTags => 'Tags';

  @override
  String get labelTagsExample => 'Work, Personal';

  @override
  String get descReplaceTags => 'Replace existing tags (instead of appending)';

  @override
  String descTagsUpdated(int count) {
    return 'Updated tags for $count accounts';
  }

  @override
  String get actionApplyTags => 'Apply tags';

  @override
  String titleExportSelectedCount(int count) {
    return 'Export selected ($count)';
  }

  @override
  String get descExportPasswordHint =>
      'Set a password to encrypt this backup file.';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelConfirmPassword => 'Confirm password';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String descExportedSelected(int count) {
    return 'Exported $count selected accounts';
  }

  @override
  String get errorExportSelectedFailed => 'Failed to export selected accounts';

  @override
  String get actionExport => 'Export';

  @override
  String get titleDeleteAccounts => 'Delete accounts';

  @override
  String descDeleteSelectedConfirm(int count) {
    return 'Are you sure you want to delete $count accounts? This action cannot be undone.';
  }

  @override
  String get errorAuthFailedDeleteCanceled =>
      'Authentication failed. Deletion canceled.';

  @override
  String descAccountsDeleted(int count) {
    return '$count accounts deleted';
  }

  @override
  String actionDeleteCount(int count) {
    return 'Delete ($count)';
  }

  @override
  String get emptyNoAccountsFound => 'No accounts found';

  @override
  String get emptyNoAccountsYet => 'No accounts yet';

  @override
  String get emptyTryDifferentSearch => 'Try a different search term';

  @override
  String get emptyAddFirstAccount =>
      'Tap the + button to add your first account';

  @override
  String get emptyLongPressTip => 'Tip: Long press + button for more options';

  @override
  String get labelQrScanner => 'QR scanner';

  @override
  String get descScanQrCode => 'Scan QR code';

  @override
  String get labelManualEntry => 'Manual entry';

  @override
  String get descEnterDetailsManually => 'Enter details manually';

  @override
  String get labelSearchAccounts => 'Search accounts…';

  @override
  String get titleTagCloud => 'Tag cloud';

  @override
  String get descTagCloud => 'Tap any tag to view matching accounts';

  @override
  String get actionManageTags => 'Manage tags';

  @override
  String get labelSearchTags => 'Search tags…';

  @override
  String descActiveFilter(String tags) {
    return 'Active filter: $tags';
  }

  @override
  String get actionClear => 'Clear';

  @override
  String get emptyNoTagsYet => 'No tags created yet';

  @override
  String emptyNoTagsMatching(String query) {
    return 'No tags matching \"$query\"';
  }

  @override
  String get emptyAddTagsHint => 'Add tags when creating or editing an account';

  @override
  String get emptyTryDifferentKeyword =>
      'Try searching for a different keyword';

  @override
  String get labelAllTags => 'All tags';

  @override
  String get titleAppLockRequired => 'App lock required';

  @override
  String get descAppLockRequiredSecret =>
      'To edit the secret key, please enable app lock from Security settings first.';

  @override
  String get descAppLockRequiredAdvanced =>
      'To edit advanced options, please enable app lock from Security settings first.';

  @override
  String get descAppLockRequiredSave =>
      'To save changes to sensitive fields (secret key or advanced options), please enable app lock from Security settings first.';

  @override
  String get actionOpenSecurity => 'Open security';

  @override
  String get descSecretUnlocked => 'Secret key unlocked';

  @override
  String get descAdvancedUnlocked => 'Advanced settings unlocked';

  @override
  String get descAccountUpdated => 'Account updated successfully';

  @override
  String get descAccountAdded => 'Account added successfully';

  @override
  String get errorSaveAccountFailed =>
      'Could not save the account. Please try again.';

  @override
  String get errorSecretRequired => 'Secret key is required';

  @override
  String get errorSecretNotBase32 =>
      'Invalid secret key. Must be Base32 encoded';

  @override
  String get errorSecretTooShort => 'Secret key is too short';

  @override
  String get titleEditAccount => 'Edit account';

  @override
  String get titleAddAccount => 'Add account';

  @override
  String get tooltipScanQr => 'Scan QR code';

  @override
  String get actionUpdateAccount => 'Update account';

  @override
  String get actionAddAccount => 'Add account';

  @override
  String get errorQrInvalid =>
      'This QR code is not a valid authenticator code.';

  @override
  String get errorQrNoSecret => 'The secret key is missing from this QR code.';

  @override
  String get errorAddAccountFailed =>
      'Could not add the account. Please try again.';

  @override
  String descAccountAddedName(String name) {
    return 'Account added: $name';
  }

  @override
  String get titleAddAccountManually => 'Add account manually';

  @override
  String get labelAccountNameRequired => 'Account name *';

  @override
  String get descAccountNameHint => 'Enter account name';

  @override
  String get labelSecretKeyRequired => 'Secret key *';

  @override
  String get descSecretKeyHint => 'Enter secret key';

  @override
  String get labelIssuerOptional => 'Issuer (optional)';

  @override
  String get descIssuerHint => 'e.g., Google';

  @override
  String get errorNameAndSecretRequired =>
      'Account name and secret key are required';

  @override
  String get actionAdd => 'Add';

  @override
  String get titleScanQrCode => 'Scan QR code';

  @override
  String get tooltipToggleFlash => 'Toggle flash';

  @override
  String get tooltipSwitchCamera => 'Switch camera';

  @override
  String get descPositionQr => 'Position QR code within frame';

  @override
  String get actionEnterManually => 'Enter manually';

  @override
  String get titleAccountInformation => 'Account information';

  @override
  String get labelAccountName => 'Account name *';

  @override
  String get descAccountNameExample => 'e.g., john@example.com';

  @override
  String get errorAccountNameRequired => 'Account name is required';

  @override
  String get labelIssuer => 'Issuer (optional)';

  @override
  String get descIssuerExample => 'e.g., Google, GitHub';

  @override
  String get labelSecretKey => 'Secret key *';

  @override
  String get labelTapToUnlock => 'Tap to unlock';

  @override
  String get labelEnableAppLock => 'Enable app lock';

  @override
  String get descSecretKeyBase32 => 'Base32 encoded secret';

  @override
  String get titleAdvancedSettings => 'Advanced settings';

  @override
  String get tooltipUnlockToEdit => 'Unlock to edit';

  @override
  String get tooltipEnableAppLockFirst => 'Turn on app lock';

  @override
  String get labelDigits => 'Digits';

  @override
  String get labelPeriodSeconds => 'Period (seconds)';

  @override
  String get labelAlgorithm => 'Algorithm';

  @override
  String labelMaskedValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String labelSecondsMasked(String mask) {
    return '$mask seconds';
  }

  @override
  String get descTapToUnlockSettings => 'Tap to unlock and view settings';

  @override
  String get descEnableAppLockToEdit => 'Enable app lock to edit';

  @override
  String get titleBrowseTags => 'Browse existing tags';

  @override
  String get actionClearAll => 'Clear all';

  @override
  String get tooltipClose => 'Close';

  @override
  String get labelSearchExistingTags => 'Search tags…';

  @override
  String get emptyNoExistingTags => 'No existing tags found';

  @override
  String get emptyTypeNewTags =>
      'Type new tags in the text field to assign them to this entry.';

  @override
  String get emptyNoMatchingTags => 'No matching tags';

  @override
  String emptyNoTagsMatchQuery(String query) {
    return 'No existing tags match \"$query\".';
  }

  @override
  String get actionDone => 'Done';

  @override
  String actionApplySelected(int count) {
    return 'Apply ($count)';
  }

  @override
  String get descTagsFieldHint => 'Comma separated, e.g. Work, Crypto, VIP';

  @override
  String get labelTapToAdd => 'Tap to add';

  @override
  String get tooltipBrowseTags => 'Browse existing tags';

  @override
  String get labelPermCamera => 'Camera';

  @override
  String get descPermCamera => 'Used to scan QR codes for adding accounts';

  @override
  String get labelPermBiometric => 'Biometric unlock';

  @override
  String get descPermBiometric =>
      'Used for app lock authentication via fingerprint or device credentials';

  @override
  String get labelPermVibration => 'Vibration';

  @override
  String get descPermVibration =>
      'Used for haptic feedback during QR code scanning';

  @override
  String get labelPermSecureStorage => 'Secure storage';

  @override
  String get descPermSecureStorage =>
      'Uses Android Keystore to securely store encryption keys';

  @override
  String get labelPermLocalDatabase => 'Local database';

  @override
  String get descPermLocalDatabase =>
      'Stores encrypted account data locally on your device';

  @override
  String get descPermissionsIntro =>
      'This app only requests permissions when needed and never collects data.';

  @override
  String get titleRuntimePermissions => 'Runtime permissions';

  @override
  String get titleBuiltInCapabilities => 'Built-in features';

  @override
  String get titlePrivacy => 'Privacy';

  @override
  String get labelNoCloudService => 'No cloud service';

  @override
  String get descNoCloudService =>
      'The app has no server or cloud account. Wi-Fi sync uses only your local network.';

  @override
  String get labelStatusGranted => 'Granted';

  @override
  String get labelStatusDenied => 'Denied';

  @override
  String get labelStatusNotGranted => 'Not granted';

  @override
  String get labelStatusNotRequested => 'Not requested';

  @override
  String get labelBuiltIn => 'Built-in';

  @override
  String errorCodeUnavailable(String name) {
    return 'Code unavailable for $name';
  }

  @override
  String descCodeCopied(String name) {
    return 'Code copied for $name';
  }

  @override
  String get descAppLockEnabledPin => 'App lock enabled with App PIN';

  @override
  String get descAppLockEnabledPhone =>
      'App lock enabled with phone screen lock';

  @override
  String get titleDisableAppLock => 'Disable app lock';

  @override
  String get descDisableAppLock =>
      'Disabling app lock removes your App PIN, quick unlock preference, and recovery key.';

  @override
  String get descAppLockDisabled => 'App lock disabled';

  @override
  String get titleChooseUnlockMethod => 'Choose unlock method';

  @override
  String get descChooseUnlockMethod =>
      'Pick how you want to unlock the app. App PIN is more secure; phone screen lock is more convenient.';

  @override
  String get actionPhoneLock => 'Phone lock';

  @override
  String get actionAppPin => 'App PIN';

  @override
  String get descAppPinEnabled => 'App PIN enabled';

  @override
  String get errorEnablePhoneLockFirst =>
      'Enable phone screen lock first, or disable app lock instead.';

  @override
  String get titleRemoveAppPin => 'Remove App PIN';

  @override
  String get descRemoveAppPin =>
      'Your App PIN and recovery key will be deleted. You will unlock the app with phone screen lock only.';

  @override
  String get descAppPinRemoved => 'App PIN removed';

  @override
  String get errorSetAppPinFirst =>
      'Set an App PIN first, or disable app lock instead.';

  @override
  String get descQuickUnlockDisabled =>
      'Phone screen lock quick unlock disabled';

  @override
  String get descQuickUnlockEnabled => 'Phone screen lock quick unlock enabled';

  @override
  String get descPhoneLockEnabled => 'Phone screen lock enabled';

  @override
  String get titleAutoLockTimeout => 'Auto-lock timeout';

  @override
  String get labelLockImmediately => 'Immediately';

  @override
  String labelMinutesCount(int minutes) {
    return '$minutes min';
  }

  @override
  String get titleCurrentPin => 'Current App PIN';

  @override
  String get descAppPinChanged => 'App PIN changed successfully';

  @override
  String get titleSetAppPin => 'Set App PIN';

  @override
  String get titleChangeAppPin => 'Change App PIN';

  @override
  String get descPinRequiredForProtection =>
      'App PIN is required for app protection and all secret access.';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get titleAppLockSection => 'App lock';

  @override
  String get titleAppPinSection => 'App PIN';

  @override
  String get titlePhoneLockSection => 'Phone screen lock';

  @override
  String get titleLockdownSection => 'Lockdown';

  @override
  String get descEnableAppLock =>
      'Protect the app with your App PIN and optional phone screen lock quick unlock';

  @override
  String get labelUseAppPin => 'Use App PIN';

  @override
  String get descAppPinIsSet => 'App PIN is set';

  @override
  String get descSetPinHint => 'Set a 4–6 digit PIN for app protection';

  @override
  String get descUpdateAppPin => 'Update your App PIN';

  @override
  String get labelResetRecoveryKey => 'Reset recovery key';

  @override
  String get descResetRecoveryKey =>
      'Generate a new recovery key for your App PIN';

  @override
  String get labelUsePhoneLock => 'Use phone lock';

  @override
  String get descPhoneLockOptional =>
      'Optional quick unlock for opening the app';

  @override
  String get descPhoneLockOnly => 'Unlock the app with your phone screen lock';

  @override
  String get labelLockdownMode => 'Lockdown mode';

  @override
  String get descLockdownMode =>
      'Disable quick unlock and require your App PIN until you turn this off';

  @override
  String get descInfoPhoneOptional =>
      'Phone screen lock is optional quick unlock. App PIN is required for revealing secrets.';

  @override
  String get descInfoPhoneOnly =>
      'Phone screen lock is your only unlock method. Set an App PIN for stronger protection.';

  @override
  String get descInfoPhoneLockTypes =>
      'Phone screen lock may use fingerprint, face, pattern, PIN, or password depending on your device.';

  @override
  String get titleSetBackupPassword => 'Set backup password';

  @override
  String get descSetBackupPassword =>
      'Create a strong password to encrypt your backup. You will need this password to restore your accounts.';

  @override
  String get descPasswordMin8 => 'Minimum 8 characters';

  @override
  String get errorPasswordEmpty => 'Password cannot be empty';

  @override
  String get errorPasswordTooShort8 => 'Password must be at least 8 characters';

  @override
  String get actionCreateBackup => 'Create backup';

  @override
  String get errorNoAccountsToBackup => 'No accounts to back up';

  @override
  String get descBackupCreated => 'Encrypted backup created successfully';

  @override
  String get errorBackupCanceledOrFailed => 'Backup canceled or failed';

  @override
  String get errorBackupFailed =>
      'Could not create the backup. Please try again.';

  @override
  String get titleRestoreAccounts => 'Restore accounts';

  @override
  String get descRestoreAccounts =>
      'Import accounts from an encrypted backup file. Existing accounts will not be affected.';

  @override
  String get titleEnterBackupPassword => 'Backup password';

  @override
  String get descEnterBackupPassword =>
      'Enter the password you used when creating this backup:';

  @override
  String get actionRestore => 'Restore';

  @override
  String get errorBackupPassword =>
      'Wrong password, or the backup file is damaged.';

  @override
  String get errorBackupInvalid =>
      'This backup has invalid content, so nothing was restored.';

  @override
  String get errorCameraUnavailable =>
      'The camera is not available. You can enter the details by hand.';

  @override
  String get errorBackupTooLarge => 'This file is too large to be a backup.';

  @override
  String get errorNoAccountsInBackup =>
      'No accounts found in backup. Check your password and try again.';

  @override
  String descAccountsRestored(int count) {
    return 'Accounts restored: $count';
  }

  @override
  String get errorAccountsLoadFailed =>
      'Could not load your accounts. Do not delete the app or its data yet. Close the app and open it again.';

  @override
  String get errorRestoreFailed =>
      'Could not restore the backup. Please try again.';

  @override
  String get titleBackupCreated => 'Backup created';

  @override
  String get descBackupSaved =>
      'Your encrypted backup has been saved successfully.';

  @override
  String get titleImportant => 'Important:';

  @override
  String get descBackupTips =>
      '• Store your backup file in a safe location\n• Remember your backup password\n• Without the password, you cannot restore';

  @override
  String get actionGotIt => 'Got it';

  @override
  String get actionContinue => 'Continue';

  @override
  String get descBackupsEncrypted =>
      'All backups are encrypted with a password for maximum security';

  @override
  String get titleCreateBackupSection => 'Create backup';

  @override
  String get labelCreateEncryptedBackup => 'Create backup file';

  @override
  String get descCreateEncryptedBackup =>
      'Export all accounts with password protection';

  @override
  String get titleRestoreBackupSection => 'Restore backup';

  @override
  String get labelRestoreFromBackup => 'Restore from backup';

  @override
  String get descRestoreFromBackup =>
      'Import accounts from encrypted backup file';

  @override
  String get titleBestPractices => 'Best practices';

  @override
  String get descBestPractices =>
      '• Create backups regularly\n• Use a strong, unique password\n• Store backups in multiple secure locations\n• Keep your password in a password manager\n• Test your backups by restoring them';

  @override
  String get descNeverShareBackups =>
      'Never share your backup files or passwords. Anyone with access to both can generate your authentication codes.';

  @override
  String get titleRenameTag => 'Rename tag';

  @override
  String get labelTagName => 'Tag name';

  @override
  String get descTagNameExample => 'e.g. Work, Personal';

  @override
  String get errorTagNameEmpty => 'Please enter a tag name';

  @override
  String get errorTagNameSame => 'New tag name must be different';

  @override
  String get actionRename => 'Rename';

  @override
  String descTagRenamed(String oldTag, String newTag) {
    return 'Renamed #$oldTag to #$newTag';
  }

  @override
  String get errorRenameTagFailed =>
      'Could not rename the tag. Please try again.';

  @override
  String get titleDeleteTag => 'Delete tag';

  @override
  String descDeleteTagUsed(String tag, int count) {
    return 'Remove tag \"#$tag\" from $count accounts?';
  }

  @override
  String descDeleteTagUnused(String tag) {
    return 'Delete unused tag \"#$tag\"?';
  }

  @override
  String descTagDeleted(String tag) {
    return 'Deleted tag #$tag';
  }

  @override
  String get errorDeleteTagFailed =>
      'Could not delete the tag. Please try again.';

  @override
  String get labelTotalTags => 'Total tags';

  @override
  String get labelAccountsTagged => 'Accounts tagged';

  @override
  String get emptyNoTagsFound => 'No tags found';

  @override
  String get emptyTagsAppearHere => 'Tags added to accounts will appear here';

  @override
  String get emptyTryDifferentQuery => 'Try a different search query';

  @override
  String labelAccountCount(int count) {
    return 'Accounts: $count';
  }

  @override
  String get tooltipRenameTag => 'Rename tag';

  @override
  String get tooltipDeleteTag => 'Delete tag';

  @override
  String get errorSyncHostTimeout =>
      'No device connected in time; hosting stopped.';

  @override
  String get errorSyncHostStartFailed =>
      'Could not start hosting. Check that Wi-Fi is on.';

  @override
  String get errorSyncNoDevice => 'No device is connected to sync with.';

  @override
  String get errorSyncNothingSelected => 'Select at least one item to sync.';

  @override
  String get errorSyncFailed => 'Sync failed. Please try again.';

  @override
  String get errorOpticalStartFailed => 'Could not start the optical stream.';

  @override
  String get errorOpticalDecodeFailed => 'Could not read the optical stream.';

  @override
  String get errorSyncNotSyncQr => 'This is not a sync QR code.';

  @override
  String get errorSyncUnsupportedVersion =>
      'This sync QR code is from a different app version.';

  @override
  String get errorSyncMissingHost => 'The sync QR code has no host address.';

  @override
  String get errorSyncInvalidPort => 'The sync QR code has an invalid port.';

  @override
  String get errorSyncMissingCode => 'The sync QR code has no pairing code.';

  @override
  String get errorSyncMalformed =>
      'The other device sent data this app cannot read.';

  @override
  String get errorSyncTooManyAccounts =>
      'The other device sent too many accounts.';

  @override
  String get errorSyncFieldTooLarge =>
      'The other device sent a value that is too large.';

  @override
  String get errorSyncPeerGone => 'The other device is no longer connected.';

  @override
  String get errorSyncSendFailed => 'Could not send the data.';

  @override
  String get errorSyncNoResponse => 'No response from the other device.';

  @override
  String get errorSyncInvalidResponse =>
      'Unexpected response from the other device.';

  @override
  String get errorSyncConnectionClosed =>
      'The other device closed the connection.';

  @override
  String get errorSyncWrongCode => 'Incorrect pairing code.';

  @override
  String get errorSyncTimedOut => 'The connection timed out.';

  @override
  String get errorSyncConnectFailed =>
      'Could not connect to the other device. Check the IP address, port and Wi-Fi.';

  @override
  String get errorSyncConnectionError => 'Connection error.';

  @override
  String get errorOpticalInvalidFrame => 'This is not an optical sync code.';

  @override
  String get errorOpticalUnsupportedVersion =>
      'This optical sync code is from a different app version.';

  @override
  String get errorOpticalCorruptedChunk =>
      'A frame was damaged. Keep the camera steady.';

  @override
  String get errorOpticalChecksum =>
      'A frame failed its check. Keep the camera steady.';

  @override
  String get errorOpticalEmpty => 'There is nothing to send.';

  @override
  String get errorOpticalIncomplete => 'Not all frames were received.';

  @override
  String get errorOpticalIntegrity =>
      'The received data failed its integrity check.';

  @override
  String get errorEnterHostIp => 'Enter the host IP address';

  @override
  String get errorEnterPort => 'Enter the port shown on the other device';

  @override
  String get errorEnterPairingCode => 'Enter the pairing code';

  @override
  String get titleSendToDevice => 'Send to device';

  @override
  String get descConnectingToHost => 'Connecting to host…';

  @override
  String get descReceiving => 'Receiving…';

  @override
  String get descP2pInfo =>
      'Wi-Fi sync: both devices on the same Wi-Fi or hotspot. The pairing code never leaves your device.';

  @override
  String get labelSendOverWifi => 'Send over Wi-Fi';

  @override
  String get descSendOverWifi =>
      'Host: share your accounts and settings over local Wi-Fi';

  @override
  String get labelReceiveOverWifi => 'Receive over Wi-Fi';

  @override
  String get descReceiveOverWifi => 'Join: scan the host QR or enter host IP';

  @override
  String get descOpticalSectionHeader =>
      'Optical air-gap sync (no Wi-Fi, no network)';

  @override
  String get labelOpticalSend => 'Send optical stream';

  @override
  String get descOpticalSend =>
      'Transmit your accounts as an animated QR stream (12–15 FPS)';

  @override
  String get labelOpticalReceive => 'Scan optical stream';

  @override
  String get descOpticalReceive =>
      'Capture an animated QR stream with the camera';

  @override
  String get descScanOtherQrHeader => 'Scan the QR on the other device';

  @override
  String get actionScanQrCode => 'Scan QR code';

  @override
  String get labelOrEnterManually => 'or enter manually';

  @override
  String get labelHostIp => 'Host IP address';

  @override
  String get labelPort => 'Port';

  @override
  String get labelPairingCode => 'Pairing code';

  @override
  String get actionConnectReceive => 'Connect & receive';

  @override
  String get actionBack => 'Back';

  @override
  String get titleConnected => 'Connected';

  @override
  String get descWaitingForSender =>
      'Waiting for the sender to choose what to share…';

  @override
  String get titleSyncComplete => 'Sync complete';

  @override
  String descSentAccounts(int count) {
    return 'Accounts sent: $count';
  }

  @override
  String descSentSettings(int count) {
    return 'Settings sent: $count';
  }

  @override
  String descAddedAccounts(int count) {
    return 'Accounts added: $count';
  }

  @override
  String descAddedAccountsSkipped(int count, int skipped) {
    return 'Accounts added: $count ($skipped already present, kept)';
  }

  @override
  String descAppliedSettings(int count) {
    return 'Settings applied: $count';
  }

  @override
  String get descNothingToSync => 'Nothing to sync.';

  @override
  String get titleSyncFailed => 'Sync failed';

  @override
  String get tabServerDetails => 'Server details';

  @override
  String get tabSync => 'Sync';

  @override
  String get descReceiveHint =>
      'On the other device, choose “Receive over Wi-Fi” → “Scan QR code”';

  @override
  String get descEnterManuallyHint => 'Or enter these manually';

  @override
  String get labelHostIpShort => 'Host IP';

  @override
  String get actionCopyCode => 'Copy code';

  @override
  String get descPairingCodeCopied =>
      'Pairing code copied. It is cleared from the clipboard after 60 seconds.';

  @override
  String get actionStopHosting => 'Stop hosting';

  @override
  String get descClientConnected =>
      'A device is connected. Open the Sync tab to choose what to share.';

  @override
  String get descWaitingForClient => 'Waiting for the other device to connect…';

  @override
  String get descNoClientYet =>
      'No device is connected yet. Open the Server details tab and let the other device scan the QR or enter the code.';

  @override
  String get titleNewClientPhone => 'New phone';

  @override
  String get descFullSync =>
      'Send everything — all accounts and app settings — to a phone that is setting up for the first time. Device-specific items (app lock, PIN, phone-lock unlock, recovery key) are not sent.';

  @override
  String get actionFullSync => 'Full sync';

  @override
  String get titleSyncToPhone => 'Sync to a phone';

  @override
  String get descSelectiveSync =>
      'For a phone that already has the app with its own data. Choose what to add:';

  @override
  String get labelSyncAccounts => 'Accounts';

  @override
  String get labelSyncSettings => 'Settings';

  @override
  String get descSyncSettings => 'Theme, auto-lock, and sync timeouts';

  @override
  String get descNoOverride =>
      'This will not override anything already on the other device. If something matches, the other device keeps its own version — its data is retained.';

  @override
  String get actionSync => 'Sync';

  @override
  String get descSyncing => 'Syncing…';

  @override
  String labelDurationSeconds(int seconds) {
    return '~$seconds s';
  }

  @override
  String labelDurationMinutes(int minutes) {
    return '~$minutes min';
  }

  @override
  String labelDurationMinSec(int minutes, int seconds) {
    return '~$minutes min $seconds s';
  }

  @override
  String get titleOpticalSend => 'Optical stream';

  @override
  String get titleOpticalScan => 'Scan optical stream';

  @override
  String get descReconstructing => 'Reconstructing accounts…';

  @override
  String get titleLargeVaultWarning => 'Large data warning';

  @override
  String descLargeVault(int chunks, String duration) {
    return 'This transfer has $chunks chunks ($duration estimated). Streaming a lot of data over camera QR can be slow. Consider Wi-Fi sync for a faster transfer.';
  }

  @override
  String get descPointReceiver =>
      'Point the receiving device camera at this animated QR stream. The data is encrypted with the transfer code; no network is used.';

  @override
  String get labelStreamHash => 'Stream hash:';

  @override
  String get labelEstDuration => 'Estimated time:';

  @override
  String get labelFramesRendered => 'Frames shown:';

  @override
  String labelFramesValue(int frame, int total) {
    return '$frame (chunks: $total)';
  }

  @override
  String get labelTargetFps => 'Target FPS:';

  @override
  String labelFps(int fps) {
    return '$fps FPS';
  }

  @override
  String labelRemaining(String time) {
    return '$time remaining';
  }

  @override
  String get descAlignCamera => 'Align the camera with the sending screen…';

  @override
  String get descReconstructingStream => 'Reconstructing the stream…';

  @override
  String descCaptured(int solved, int total) {
    return 'Captured: $solved / $total chunks';
  }

  @override
  String labelSession(String hash) {
    return 'Session: $hash';
  }

  @override
  String get titleOpticalComplete => 'Optical sync done';

  @override
  String get descOpticalComplete =>
      'The accounts were rebuilt from the optical QR stream.';

  @override
  String get titleOpticalFailed => 'Optical sync failed';

  @override
  String get titleScanSyncQr => 'Scan sync QR code';

  @override
  String get descScanSenderQr => 'Scan the QR shown on the sending device';

  @override
  String get descFeatures01 => 'Core 2FA & OTP tools';

  @override
  String get descFeatures02 =>
      'Standards-compliant code generation and scanning';

  @override
  String get descFeatures03 => 'TOTP time-based codes';

  @override
  String get descFeatures04 =>
      'Generate secure time-based one-time passwords compliant with RFC 6238. Supports 30 or 60 second periods, 6 or 8 digits, and SHA-1, SHA-256 or SHA-512.';

  @override
  String get descFeatures05 => 'RFC 6238 standard';

  @override
  String get descFeatures06 => 'SHA-1/256/512';

  @override
  String get descFeatures07 => '30 s or 60 s';

  @override
  String get descFeatures08 => 'Live ring timer';

  @override
  String get descFeatures09 => 'HOTP counter codes';

  @override
  String get descFeatures10 =>
      'Counter-based codes (RFC 4226) from HOTP QR codes. Tap the next code button for each new code. The counter is saved before the code is shown.';

  @override
  String get descFeatures11 => 'Add by QR code';

  @override
  String get descFeatures12 => 'Counter saved';

  @override
  String get descFeatures13 => 'One code per tap';

  @override
  String get descFeatures14 => 'Instant QR code scanner';

  @override
  String get descFeatures15 =>
      'Add accounts by pointing your camera at standard 2FA QR codes (otpauth://). Includes a flashlight toggle and instant validation.';

  @override
  String get descFeatures16 => 'Fast detection';

  @override
  String get descFeatures17 => 'Flashlight support';

  @override
  String get descFeatures18 => 'Safe input checks';

  @override
  String get descFeatures19 => 'Brand icons';

  @override
  String get descFeatures20 =>
      'Shows a brand logo for common services (Apple, AWS, Binance, Discord, GitHub, Google, Microsoft, Nintendo, Proton, Steam) and colorful initials for all others.';

  @override
  String get descFeatures21 => '10 built-in brands';

  @override
  String get descFeatures22 => 'Colorful initials';

  @override
  String get descFeatures23 => 'Automatic match';

  @override
  String get descFeatures24 => 'Quick copy & countdown';

  @override
  String get descFeatures25 =>
      'Tap any code to copy it to the clipboard with haptic feedback. A circular timer shows how long the code stays valid.';

  @override
  String get descFeatures26 => 'One-tap copy';

  @override
  String get descFeatures27 => 'Haptic feedback';

  @override
  String get descFeatures28 => 'Smooth progress ring';

  @override
  String get descFeatures29 => 'Vault security & privacy';

  @override
  String get descFeatures30 =>
      'Strong encryption, biometrics and zero tracking';

  @override
  String get descFeatures31 => 'AES-256-GCM encryption';

  @override
  String get descFeatures32 =>
      'All account secrets are encrypted at rest with AES-256-GCM. The device key is kept in the Android Keystore (hardware-backed on phones that support it).';

  @override
  String get descFeatures33 => 'AES-256-GCM';

  @override
  String get descFeatures34 => 'Android Keystore';

  @override
  String get descFeatures35 => 'No plain text at rest';

  @override
  String get descFeatures36 => 'Biometric & screen app lock';

  @override
  String get descFeatures37 =>
      'Lock the app behind your fingerprint, face unlock, your phone screen lock, or an App PIN. Keeps your codes safe from people who pick up your phone.';

  @override
  String get descFeatures38 => 'Fingerprint / face';

  @override
  String get descFeatures39 => 'Phone lock fallback';

  @override
  String get descFeatures40 => 'Fast unlock';

  @override
  String get descFeatures41 => 'Automatic lock';

  @override
  String get descFeatures42 =>
      'Locks the app and clears decrypted codes from memory when you switch apps, minimize the app, or let the phone sleep.';

  @override
  String get descFeatures43 => 'Background auto-lock';

  @override
  String get descFeatures44 => 'Memory cleanup';

  @override
  String get descFeatures45 => 'Configurable timeout';

  @override
  String get descFeatures46 => 'Screenshot guard (FLAG_SECURE)';

  @override
  String get descFeatures47 =>
      'On by default. Blocks screenshots, screen recording and recent-apps thumbnails, so your codes cannot be captured from the screen.';

  @override
  String get descFeatures48 => 'FLAG_SECURE';

  @override
  String get descFeatures49 => 'No recents preview';

  @override
  String get descFeatures50 => 'No screen capture';

  @override
  String get descFeatures51 => 'Offline & zero telemetry';

  @override
  String get descFeatures52 =>
      'Works fully on your device: no internet backend, cloud login, analytics, crash reporting or tracking. Wi-Fi sync uses only your local network.';

  @override
  String get descFeatures53 => 'Fully offline';

  @override
  String get descFeatures54 => 'No analytics';

  @override
  String get descFeatures55 => 'No cloud accounts';

  @override
  String get descFeatures56 => 'Secrets stay encrypted';

  @override
  String get descFeatures57 => 'Organization & productivity';

  @override
  String get descFeatures58 => 'Group, search and manage your accounts';

  @override
  String get descFeatures59 => 'Multi-tag labels';

  @override
  String get descFeatures60 =>
      'Give any account several tags (for example Work, Personal, Finance). Filter the account list by tag with one tap on the filter bar.';

  @override
  String get descFeatures61 => 'Many tags per account';

  @override
  String get descFeatures62 => 'Tag chips';

  @override
  String get descFeatures63 => 'One-tap filtering';

  @override
  String get descFeatures64 => 'Tag cloud';

  @override
  String get descFeatures65 =>
      'A tag cloud shows all your tags and how many accounts use each. Tap a tag to show only its accounts.';

  @override
  String get descFeatures66 => 'Visual tag view';

  @override
  String get descFeatures67 => 'Account counts';

  @override
  String get descFeatures68 => 'Fast navigation';

  @override
  String get descFeatures69 => 'Live search';

  @override
  String get descFeatures70 =>
      'Find any account by typing its name, user name, service or tag; results update as you type.';

  @override
  String get descFeatures71 => 'Real-time search';

  @override
  String get descFeatures72 => 'Names & tags';

  @override
  String get descFeatures73 => 'Instant results';

  @override
  String get descFeatures74 => 'Ordering & editing';

  @override
  String get descFeatures75 =>
      'Put your accounts in the order you like, and change account names, services or code settings when needed.';

  @override
  String get descFeatures76 => 'Drag to reorder';

  @override
  String get descFeatures77 => 'Edit details';

  @override
  String get descFeatures78 => 'Batch actions';

  @override
  String get descFeatures79 => 'Sync, air-gap & backups';

  @override
  String get descFeatures80 =>
      'Move accounts safely and export encrypted backups';

  @override
  String get descFeatures81 => 'Wi-Fi sync';

  @override
  String get descFeatures82 =>
      'Move accounts between two devices on your local Wi-Fi. A pairing code shown as a QR code protects the transfer; the data is encrypted with a key made from that code. No internet is used.';

  @override
  String get descFeatures83 => 'Local Wi-Fi only';

  @override
  String get descFeatures84 => 'Encrypted transfer';

  @override
  String get descFeatures85 => 'No cloud';

  @override
  String get descFeatures86 => 'Optical air-gap sync';

  @override
  String get descFeatures87 =>
      'Move accounts to an offline device with an animated series of QR codes, without Wi-Fi or Bluetooth. The QR codes are encrypted with a one-time code that you type.';

  @override
  String get descFeatures88 => 'No network';

  @override
  String get descFeatures89 => 'Animated QR stream';

  @override
  String get descFeatures90 => 'Encrypted stream';

  @override
  String get descFeatures91 => 'Encrypted backups';

  @override
  String get descFeatures92 =>
      'Export all your accounts to an encrypted backup file protected by your own password (AES-256 with a PBKDF2 key).';

  @override
  String get descFeatures93 => 'AES-256 encrypted';

  @override
  String get descFeatures94 => 'Password protected';

  @override
  String get descFeatures95 => 'Portable file';

  @override
  String get descFeatures96 => 'Safe import';

  @override
  String get descFeatures97 =>
      'Import backups or receive sync data safely. Existing accounts are kept and new ones are added; nothing is overwritten.';

  @override
  String get descFeatures98 => 'Add-only merge';

  @override
  String get descFeatures99 => 'Duplicate protection';

  @override
  String get descFeatures100 => 'Import summary';

  @override
  String get descFeatures101 => 'Features';

  @override
  String descFeatures102(String appName) {
    return '$appName features';
  }

  @override
  String get descFeatures103 =>
      'Explore every security safeguard and code tool built into the app.';

  @override
  String get helpHome01 => 'Help center';

  @override
  String get helpHome02 => 'Authentication & setup';

  @override
  String get helpHome03 => 'Getting started & adding accounts';

  @override
  String get helpHome04 =>
      'How to scan QR codes, add secret keys by hand, and use your 2FA codes.';

  @override
  String get helpHome05 => 'Time sync & code drift';

  @override
  String get helpHome06 =>
      'Fixing rejected codes, phone clock offsets, and HOTP counter codes.';

  @override
  String get helpHome07 => 'Tags & account organization';

  @override
  String get helpHome08 =>
      'Adding tags, filtering accounts, the tag cloud, and managing tags.';

  @override
  String get helpHome09 => 'Security & vault protection';

  @override
  String get helpHome10 => 'Biometric & app lock';

  @override
  String get helpHome11 =>
      'Fingerprint and face unlock, phone screen lock fallback, and auto-lock rules.';

  @override
  String get helpHome12 => 'Vault & screenshot guard';

  @override
  String get helpHome13 =>
      'Android Keystore key storage, FLAG_SECURE screen protection, and offline privacy.';

  @override
  String get helpHome14 => 'Sync & backups';

  @override
  String get helpHome15 => 'Wi-Fi sync';

  @override
  String get helpHome16 =>
      'Direct device-to-device transfer over local Wi-Fi, encrypted with a key from the pairing code.';

  @override
  String get helpHome17 => 'Optical air-gap transfer';

  @override
  String get helpHome18 =>
      'Move accounts to an offline device with animated QR codes.';

  @override
  String get helpHome19 => 'Encrypted backup & restore';

  @override
  String get helpHome20 =>
      'Making password-protected backup files and restoring accounts on a new phone.';

  @override
  String get helpHome21 => 'Frequently asked questions';

  @override
  String get helpHome22 => 'FAQs & troubleshooting';

  @override
  String get helpHome23 =>
      'Short answers about codes, backups, permissions and moving to a new phone.';

  @override
  String get helpHome24 => 'Help center & guides';

  @override
  String helpHome25(String appName) {
    return 'Guides and answers for every feature of $appName.';
  }

  @override
  String get helpStart01 => 'Getting started';

  @override
  String helpStart02(String appName) {
    return '$appName makes two-factor (2FA) codes that protect your online accounts. All codes are made on your device without an internet connection.';
  }

  @override
  String get helpStart03 => 'Adding an account with a QR code';

  @override
  String get helpStart04 =>
      'On the service (for example Google, GitHub, Amazon), open its security or 2FA settings and choose to set up an authenticator app.';

  @override
  String helpStart05(String appName, String qrScanner) {
    return 'In $appName, tap the “+” button on the home screen and choose “$qrScanner”.';
  }

  @override
  String get helpStart06 =>
      'Point the camera at the QR code on your computer or other screen. The account is checked and added right away.';

  @override
  String get helpStart07 => 'Adding an account by hand';

  @override
  String helpStart08(String manualEntry) {
    return 'If you cannot scan a QR code, choose “$manualEntry” from the add menu.';
  }

  @override
  String get helpStart09 =>
      'Enter the account name (for example your email or user name) and the issuer (for example GitHub, Google).';

  @override
  String get helpStart10 =>
      'Paste the secret key (Base32) that the service gives you.';

  @override
  String get helpStart11 =>
      'Under advanced settings you can set the algorithm (SHA1, SHA256, SHA512), digits (6 or 8) and period (30 or 60 seconds).';

  @override
  String get helpStart12 => 'Using your 2FA codes';

  @override
  String get helpStart13 =>
      'Time-based (TOTP) codes change every 30 seconds by default. The countdown ring shows how long the code stays valid.';

  @override
  String get helpStart14 =>
      'Tap any account to copy its current code to the clipboard.';

  @override
  String get helpStart15 =>
      'Paste the code into the sign-in screen of the website or service.';

  @override
  String get helpStart16 =>
      'Tip: Always keep the backup recovery codes from your online services in a safe place, in case you lose your phone.';

  @override
  String get helpTime01 => 'Time sync & code drift';

  @override
  String get helpTime02 =>
      'TOTP codes depend on the exact time on your phone. If the clock is even a few seconds wrong, websites may reject your codes.';

  @override
  String get helpTime03 => 'How TOTP time works';

  @override
  String get helpTime04 =>
      'A time-based code is made from your secret key and the current time, counted in 30-second steps.';

  @override
  String get helpTime05 =>
      'Your phone and the server must agree on the time in UTC. Changing your time zone does not affect UTC.';

  @override
  String get helpTime06 => 'Fixing rejected codes';

  @override
  String get helpTime07 =>
      'Open your phone settings and go to System → Date & time.';

  @override
  String get helpTime08 =>
      'Turn on “Set time automatically” and “Set time zone automatically”.';

  @override
  String get helpTime09 =>
      'If they are already on, turn them off and on again to make the phone fetch the network time now.';

  @override
  String get helpTime10 => 'HOTP counter codes';

  @override
  String get helpTime11 =>
      'HOTP codes are based on a counter, not on time, so the clock does not matter. Tap the next code button on the account to get a new code.';

  @override
  String get helpTime12 =>
      'Each tap uses up one code. Tap only when you need a code: the service may reject codes if you skip too many.';

  @override
  String get helpTime13 =>
      'A restored backup or a copy on a second device can hold an older counter. If the service rejects a code, tap a few more times to catch up.';

  @override
  String get helpTime14 =>
      'Tip: Most rejected codes come from a wrong phone clock. Automatic network time fixes this for good.';

  @override
  String get helpTags01 => 'Tags & organization';

  @override
  String get helpTags02 =>
      'Tags put your 2FA accounts into your own groups, such as Work, Personal, Banking or Social, so you can filter them easily.';

  @override
  String get helpTags03 => 'Adding tags to accounts';

  @override
  String get helpTags04 =>
      'When adding or editing an account, type tag names separated by commas (for example “Work, Cloud, Tech”).';

  @override
  String get helpTags05 =>
      'While you type, the app suggests tags you already use, so names stay the same.';

  @override
  String helpTags06(String browseTags) {
    return 'Tap “$browseTags” to pick from all tags already in use.';
  }

  @override
  String get helpTags07 => 'Filtering by tag';

  @override
  String get helpTags08 =>
      'The tag bar on the home screen shows your tags as chips you can tap.';

  @override
  String helpTags09(String allTags) {
    return 'Tap a tag chip to show only its accounts. Tap “$allTags” to clear the filter.';
  }

  @override
  String get helpTags10 =>
      'Switch to the tag cloud to see all tags and how many accounts each has.';

  @override
  String get helpTags11 => 'Managing tags';

  @override
  String helpTags12(String settings, String manageTags) {
    return 'Go to $settings → $manageTags to rename or delete a tag for all accounts at once. Renaming a tag to an existing name merges the two.';
  }

  @override
  String get helpTags13 => 'Renaming a tag updates every account that has it.';

  @override
  String get helpTags14 =>
      'Deleting a tag removes the label from accounts; the accounts themselves stay.';

  @override
  String get helpTags15 =>
      'Tip: Short tag names (for example “Work”, “Finance”) look best in the filter bar.';

  @override
  String get helpLock01 => 'Biometric & app lock';

  @override
  String helpLock02(String appName) {
    return '$appName can protect your codes with your fingerprint or face, your phone screen lock, or an App PIN.';
  }

  @override
  String get helpLock03 => 'How app lock works';

  @override
  String helpLock04(String settings, String security) {
    return 'When it is on in $settings → $security, the app asks you to unlock whenever you open it or come back to it.';
  }

  @override
  String get helpLock05 =>
      'Decrypted codes stay in memory only while the app is open and unlocked.';

  @override
  String get helpLock06 => 'Automatic lock';

  @override
  String get helpLock07 =>
      'As soon as you leave the app, switch apps, or lock the phone screen, the app locks. While it is open, it also locks after the auto-lock timeout.';

  @override
  String get helpLock08 =>
      'Decrypted codes are removed from memory, so someone who picks up the phone cannot read them.';

  @override
  String get helpLock09 => 'Fallback & phone lock';

  @override
  String get helpLock10 =>
      'If your fingerprint or face is not recognized (for example wet fingers or low light), you can use your phone screen lock PIN, pattern or password.';

  @override
  String helpLock11(String appName) {
    return 'The check is done by Android itself. $appName never sees or stores your biometric data or phone passcode.';
  }

  @override
  String get helpLock12 =>
      'Tip: Set a secure screen lock in your phone settings for the best protection.';

  @override
  String get helpVault01 => 'Vault security & privacy';

  @override
  String helpVault02(String appName) {
    return '$appName is built to work offline and trust no server. Your secret keys are encrypted on your device and never sent to any remote server.';
  }

  @override
  String get helpVault03 => 'AES-256-GCM encryption';

  @override
  String get helpVault04 =>
      'All secrets and code settings are encrypted with AES-256 in GCM mode, which also detects any change to the data.';

  @override
  String get helpVault05 =>
      'The encryption key is made on your device and kept in the Android Keystore (hardware-backed on phones that support it).';

  @override
  String get helpVault06 =>
      'No secret is ever written to the database as plain text.';

  @override
  String get helpVault07 => 'Screenshot guard (FLAG_SECURE)';

  @override
  String get helpVault08 =>
      'By default, the app turns on Android FLAG_SECURE for its window. You can turn it off in Security settings.';

  @override
  String get helpVault09 =>
      'This blocks screenshots, screen recording and screen-reading apps from capturing your codes.';

  @override
  String get helpVault10 =>
      'In the recent-apps view, the app shows a blank screen, so people nearby cannot see your codes.';

  @override
  String get helpVault11 => 'No cloud, no telemetry';

  @override
  String get helpVault12 =>
      'The app has no server, no login and no advertising or analytics code.';

  @override
  String get helpVault13 =>
      'Your secrets and codes are never sent to any server. The app sends no logs, device IDs or usage data.';

  @override
  String get helpVault14 =>
      'Everything, including QR scanning, code generation and backup export, runs offline. Only Wi-Fi sync uses your local network.';

  @override
  String get helpVault15 =>
      'Privacy first: your authentication secrets belong to you alone.';

  @override
  String get helpWifi01 => 'Wi-Fi sync';

  @override
  String get helpWifi02 =>
      'Wi-Fi sync moves your 2FA accounts directly between two phones on the same Wi-Fi network. The data is encrypted, and no cloud service is involved.';

  @override
  String get helpWifi03 => 'How Wi-Fi sync works';

  @override
  String get helpWifi04 =>
      'Step 1: Connect both devices to the same Wi-Fi network.';

  @override
  String helpWifi05(String settings, String syncDevices, String sendOverWifi) {
    return 'Step 2: On the sending device, open $settings → $syncDevices → “$sendOverWifi”. It shows a pairing QR code and a pairing code.';
  }

  @override
  String helpWifi06(String receiveOverWifi) {
    return 'Step 3: On the receiving device, tap “$receiveOverWifi” and scan the pairing QR code (or type the details).';
  }

  @override
  String get helpWifi07 =>
      'Step 4: The devices connect, and the sender chooses what to share.';

  @override
  String get helpWifi08 => 'Encryption';

  @override
  String get helpWifi09 =>
      'The data is encrypted with AES-256-GCM, using a key made (with PBKDF2) from the pairing code shown on the screen.';

  @override
  String get helpWifi10 =>
      'Someone watching your Wi-Fi traffic cannot read your 2FA secrets without the pairing code.';

  @override
  String get helpWifi11 =>
      'The pairing code is never sent over the network; you move it yourself, by scanning or typing.';

  @override
  String get helpWifi12 => 'Safe merging';

  @override
  String get helpWifi13 =>
      'Sync only adds accounts. Nothing on the receiving device is deleted or replaced.';

  @override
  String get helpWifi14 =>
      'Accounts that already exist on the receiving device are skipped.';

  @override
  String get helpWifi15 =>
      'Tip: Keep both devices awake and on the same Wi-Fi until the transfer finishes.';

  @override
  String get helpOptical01 => 'Optical air-gap transfer';

  @override
  String get helpOptical02 =>
      'Optical transfer moves your accounts to an offline device with an animated series of QR codes, without Wi-Fi, Bluetooth or cables.';

  @override
  String get helpOptical03 => 'What is an air gap?';

  @override
  String get helpOptical04 =>
      'An air-gapped device has no network connection at all (no Wi-Fi, Bluetooth or mobile data; Airplane Mode on).';

  @override
  String get helpOptical05 =>
      'The data travels only as light, from screen to camera, so there is no network to listen to. The QR codes are encrypted, and the key comes from a code that is never shown on the sending screen.';

  @override
  String get helpOptical06 => 'How to do an optical transfer';

  @override
  String helpOptical07(
    String settings,
    String syncDevices,
    String scanOptical,
  ) {
    return 'Step 1: On the receiving device, go to $settings → $syncDevices → “$scanOptical”. It shows a one-time transfer code.';
  }

  @override
  String helpOptical08(String sendOptical) {
    return 'Step 2: On the sending device, choose “$sendOptical” and type that code. Your accounts are encrypted with it and shown as a looping series of QR codes.';
  }

  @override
  String helpOptical09(String startScanning) {
    return 'Step 3: On the receiving device, tap “$startScanning” and point the camera at the sending screen.';
  }

  @override
  String get helpOptical10 =>
      'Step 4: The receiver collects all parts. When every part is read and the code matches, the accounts are imported. With a wrong code, nothing is imported.';

  @override
  String get helpOptical11 => 'Speed tips';

  @override
  String get helpOptical12 =>
      'You can set the speed on the sender to 10, 12 or 15 frames per second; use a slower speed if the camera misses frames.';

  @override
  String get helpOptical13 =>
      'Hold both devices steady in good light, and avoid reflections or glare on the screen.';

  @override
  String get helpOptical14 =>
      'Tip: Optical sync suits a dedicated offline backup phone kept in a safe place.';

  @override
  String get helpBackup01 => 'Encrypted backup & restore';

  @override
  String get helpBackup02 =>
      'Backups protect you if your phone is damaged or lost, or when you move to a new phone. Every backup file is encrypted with a password you choose.';

  @override
  String get helpBackup03 => 'Creating an encrypted backup';

  @override
  String helpBackup04(
    String settings,
    String backupRestore,
    String createBackup,
  ) {
    return 'Go to $settings → $backupRestore → tap “$createBackup”.';
  }

  @override
  String get helpBackup05 =>
      'Choose a strong backup password. The app makes an AES-256 key from it with PBKDF2 (300,000 iterations) to encrypt the file.';

  @override
  String get helpBackup06 =>
      'Save the encrypted .aes backup file on your device, a USB drive, or your own offline archive.';

  @override
  String get helpBackup07 => 'Password safety & recovery';

  @override
  String get helpBackup08 =>
      'Your backup password is never stored or sent anywhere. You must remember it or keep it written down safely.';

  @override
  String helpBackup09(String appName) {
    return 'Because $appName works fully offline, there is no “forgot password” or server reset. A lost backup password cannot be recovered.';
  }

  @override
  String get helpBackup10 => 'Restoring a backup';

  @override
  String helpBackup11(
    String settings,
    String backupRestore,
    String restoreBackup,
  ) {
    return 'Go to $settings → $backupRestore → tap “$restoreBackup”.';
  }

  @override
  String get helpBackup12 =>
      'Pick your backup file and enter the password you used when you made it.';

  @override
  String get helpBackup13 =>
      'The app checks the file and adds new accounts to the ones you have; nothing you have is deleted.';

  @override
  String get helpBackup14 =>
      'Tip: Make a fresh backup whenever you add important new 2FA accounts.';

  @override
  String get helpFaq01 => 'FAQs & troubleshooting';

  @override
  String get helpFaq02 =>
      'Quick answers about 2FA codes, recovery, security and common problems.';

  @override
  String get helpFaq03 => '2FA codes';

  @override
  String get helpFaq04 => 'Why do websites reject my codes?';

  @override
  String get helpFaq05 =>
      'Usually the phone clock is wrong. Open your phone settings → Date & time and turn on “Set time automatically”, so the clock matches UTC.';

  @override
  String get helpFaq06 => 'Can I copy a code with one tap?';

  @override
  String get helpFaq07 =>
      'Yes. Tap the account on the home screen; its code is copied to the clipboard and a short message confirms it.';

  @override
  String get helpFaq08 => 'How are HOTP codes different from TOTP codes?';

  @override
  String get helpFaq09 =>
      'TOTP codes change every 30 seconds based on time. HOTP codes change only when you tap the next code button, and each tap uses up one code.';

  @override
  String get helpFaq10 => 'Security & privacy';

  @override
  String get helpFaq11 => 'Why is the app blank when I switch apps?';

  @override
  String get helpFaq12 =>
      'The screenshot guard, on by default, turns on Android FLAG_SECURE. It stops screen recorders and the recent-apps view from capturing your codes.';

  @override
  String helpFaq13(String appName) {
    return 'Does $appName send any data online?';
  }

  @override
  String helpFaq14(String appName) {
    return 'No. $appName works offline. It has no analytics, tracking or cloud service. Your data leaves the device only when you start a Wi-Fi sync on your local network, an optical transfer, or a backup export.';
  }

  @override
  String get helpFaq15 => 'What if my fingerprint or face is not recognized?';

  @override
  String get helpFaq16 =>
      'You can unlock with your phone screen lock PIN, pattern or password, or with your App PIN.';

  @override
  String get helpFaq17 => 'Backups & moving phones';

  @override
  String get helpFaq18 => 'How do I move my accounts to a new phone?';

  @override
  String helpFaq19(String syncDevices) {
    return 'Use “$syncDevices” over local Wi-Fi, scan an optical QR stream, or export an encrypted backup on the old phone and restore it on the new one.';
  }

  @override
  String get helpFaq20 => 'What if I forget my backup password?';

  @override
  String get helpFaq21 =>
      'Backups use AES-256 encryption and there is no server, so a lost backup password cannot be recovered. Keep it written down safely.';

  @override
  String get helpFaq22 => 'Will restoring a backup erase my accounts?';

  @override
  String helpFaq23(String appName) {
    return 'No. $appName only adds accounts. Your existing accounts stay, and duplicates are skipped.';
  }

  @override
  String helpFaq24(String settings, String permissions) {
    return 'Need more help? Read the other guides in Help, or check your permissions in $settings → $permissions.';
  }

  @override
  String get titleTransferCode => 'Transfer code';

  @override
  String get descTransferCodeShow =>
      'Type this code on the sending device, then tap the button below. Do not show this code to anyone else.';

  @override
  String get actionStartScanning => 'Start scanning';

  @override
  String get descTransferCodeEnter =>
      'Type the transfer code shown on the receiving device. The QR stream is encrypted with it.';

  @override
  String get actionStartSending => 'Start sending';

  @override
  String errorTransferCodeLength(int count) {
    return 'Type all $count characters of the code.';
  }

  @override
  String get errorOpticalWrongCode =>
      'The code did not match. On the sending device, stop and type the code again.';

  @override
  String get errorOpticalCodeInvalid =>
      'The transfer code is not valid. Start again and type the code shown on the receiving device.';

  @override
  String get tooltipNextCode => 'Next code';

  @override
  String get descHotpTapForCode => 'Tap the next code button first.';

  @override
  String get errorHotpNextFailed => 'Could not get the next code.';

  @override
  String get tooltipShowPassword => 'Show password';

  @override
  String get tooltipHidePassword => 'Hide password';

  @override
  String get tooltipClearSearch => 'Clear search';

  @override
  String get tooltipShowCode => 'Show code';

  @override
  String get tooltipHideCode => 'Hide code';

  @override
  String get tooltipAddAccount => 'Add account';

  @override
  String get tooltipAddOptions => 'More ways to add';

  @override
  String get descCodeHidden => 'Code hidden';

  @override
  String get titleScreenPrivacySection => 'Screen privacy';

  @override
  String get labelBlockScreenshots => 'Block screenshots';

  @override
  String get descBlockScreenshots =>
      'Stops screenshots, screen recording and recent-apps previews from showing your codes';

  @override
  String get titleAllowScreenshots => 'Allow screenshots?';

  @override
  String get descAllowScreenshotsWarning =>
      'Your codes and secrets can then appear in screenshots, screen recordings and the recent-apps view. Other apps may also be able to capture them.';

  @override
  String get errorBlockScreenshotsFailed =>
      'Could not change the screenshot setting';

  @override
  String get titleDataSection => 'Data';

  @override
  String get labelDeleteAllData => 'Delete all data';

  @override
  String get descDeleteAllDataEntry =>
      'Remove every account and setting from this device';

  @override
  String get titleDeleteAllData => 'Delete all data?';

  @override
  String get descDeleteAllDataWarning =>
      'This removes all your accounts, your App PIN, your recovery key and your settings from this device. It cannot be undone. Without a backup, you may lose access to your accounts.\n\nBackup files you saved elsewhere are not deleted.';

  @override
  String get descDeleteAllDataUnderstand =>
      'I understand this cannot be undone';

  @override
  String get actionDeleteAll => 'Delete all';

  @override
  String get descAuthReasonDeleteAllData => 'Confirm to delete all data';

  @override
  String get descPinPurposeDeleteAllData => 'To delete all data.';

  @override
  String get descAllDataDeleted => 'All data deleted';

  @override
  String get errorDeleteAllDataFailed =>
      'Some data could not be deleted. Please try again.';
}
