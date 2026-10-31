import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_sa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
    Locale('sa'),
  ];

  /// Splash screen text shown while the app starts.
  ///
  /// In en, this message translates to:
  /// **'Securing your accounts...'**
  String get descSplashLoading;

  /// Settings screen app-bar title. Keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// Appearance screen title and Settings section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get titleAppearance;

  /// Settings section header for security items. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get titleSecurity;

  /// Settings section header for Features, Help and About. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Explore & support'**
  String get titleExploreSupport;

  /// Language row in Settings and language screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get titleLanguage;

  /// Settings row title that opens the security screen. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Security settings'**
  String get titleSecuritySettings;

  /// Subtitle of the Security settings row.
  ///
  /// In en, this message translates to:
  /// **'Configure app lock and biometric'**
  String get descSecuritySettingsEntry;

  /// Settings row title that opens backup and restore. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get titleBackupRestore;

  /// Subtitle of the Backup & restore row.
  ///
  /// In en, this message translates to:
  /// **'Export or import your accounts'**
  String get descBackupRestoreEntry;

  /// Settings row title that opens tag management. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get titleManageTags;

  /// Subtitle of the Manage tags row.
  ///
  /// In en, this message translates to:
  /// **'Edit, rename, or clean up account tags'**
  String get descManageTagsEntry;

  /// Settings row title that opens device sync (Wi-Fi or optical). Keep short.
  ///
  /// In en, this message translates to:
  /// **'Sync devices'**
  String get titleSyncDevice;

  /// Subtitle of the Sync devices row.
  ///
  /// In en, this message translates to:
  /// **'Transfer accounts via Wi-Fi or Optical Air-Gap'**
  String get descSyncDeviceEntry;

  /// Settings row and dialog title for the Wi-Fi sync host idle timeout. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Sync host timeout'**
  String get titleSyncHostTimeout;

  /// Subtitle of the Sync host timeout row. {seconds} is a number of seconds.
  ///
  /// In en, this message translates to:
  /// **'Stop hosting after {seconds} s if no device connects'**
  String descSyncHostTimeoutEntry(int seconds);

  /// An option in the sync host timeout dialog. {seconds} is 30 or more.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String labelSecondsCount(int seconds);

  /// Settings row title that opens the permissions screen. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get titlePermissions;

  /// Subtitle of the Permissions row.
  ///
  /// In en, this message translates to:
  /// **'View app permissions and status'**
  String get descPermissionsEntry;

  /// Settings row title and About section title for the feature list. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get titleFeatures;

  /// Subtitle of the Features row. {appName} is the app name in the active language.
  ///
  /// In en, this message translates to:
  /// **'Explore all features of {appName}'**
  String descFeaturesEntry(String appName);

  /// Settings row title that opens Help. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get titleHelp;

  /// Subtitle of the Help row.
  ///
  /// In en, this message translates to:
  /// **'Guides, troubleshooting, and sync details'**
  String get descHelpEntry;

  /// About screen title, Settings row title and About section title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get titleAbout;

  /// Subtitle of the About row.
  ///
  /// In en, this message translates to:
  /// **'Version, author, and license details'**
  String get descAboutEntry;

  /// Subtitle of the Appearance row in Settings. {mode} is one of labelThemeSystem, labelThemeLight, labelThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Theme mode: {mode}'**
  String descAppearanceThemeMode(String mode);

  /// Theme mode row and screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get titleThemeMode;

  /// Section header on the Appearance screen. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Theme information'**
  String get titleThemeInformation;

  /// Card title on the Appearance screen. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Visual design system'**
  String get titleVisualDesign;

  /// Card body on the Appearance screen. {appName} is the app name in the active language.
  ///
  /// In en, this message translates to:
  /// **'{appName} uses an offline-first 3D neumorphic theme with vibrant token countdown rings and high-contrast accessibility.'**
  String descVisualDesign(String appName);

  /// Theme mode row subtitle when the theme follows the system.
  ///
  /// In en, this message translates to:
  /// **'System default (follows OS settings)'**
  String get descThemeSummarySystem;

  /// Theme mode row subtitle when the light theme is chosen.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get descThemeSummaryLight;

  /// Theme mode row subtitle when the dark theme is chosen.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get descThemeSummaryDark;

  /// Section header on the Theme mode screen. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Select theme mode'**
  String get titleSelectThemeMode;

  /// Theme option: follow the device theme. Keep short.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get labelThemeSystem;

  /// Subtitle of the System default theme option.
  ///
  /// In en, this message translates to:
  /// **'Automatically follow your device system theme'**
  String get descThemeSystem;

  /// Theme option: light. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get labelThemeLight;

  /// Subtitle of the Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Clean, high-contrast light appearance'**
  String get descThemeLight;

  /// Theme option: dark. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get labelThemeDark;

  /// Subtitle of the Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Comfortable dark appearance for low-light environments'**
  String get descThemeDark;

  /// Section header on the Theme mode screen. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get titleCurrentStatus;

  /// Status line: the dark appearance is in use now. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Active: dark'**
  String get labelActiveDark;

  /// Status line: the light appearance is in use now. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Active: light'**
  String get labelActiveLight;

  /// Status explanation when the theme follows the system.
  ///
  /// In en, this message translates to:
  /// **'Follows your device system-wide dark mode preference.'**
  String get descThemeStatusSystem;

  /// Status explanation when the light theme is chosen.
  ///
  /// In en, this message translates to:
  /// **'Always stays in light appearance mode.'**
  String get descThemeStatusLight;

  /// Status explanation when the dark theme is chosen.
  ///
  /// In en, this message translates to:
  /// **'Always stays in dark appearance mode.'**
  String get descThemeStatusDark;

  /// Section header on the Language screen. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get titleSelectLanguage;

  /// Language option: follow the device language. Keep short.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get labelLanguageSystem;

  /// Subtitle of the System default language option.
  ///
  /// In en, this message translates to:
  /// **'Use the device language when it is English, Malayalam or Sanskrit; otherwise English'**
  String get descLanguageSystem;

  /// The name of the English language, written in the active UI language. Shown under the endonym.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get labelLanguageNameEn;

  /// The name of the Malayalam language, written in the active UI language. Shown under the endonym.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get labelLanguageNameMl;

  /// The name of the Sanskrit language, written in the active UI language. Shown under the endonym.
  ///
  /// In en, this message translates to:
  /// **'Sanskrit'**
  String get labelLanguageNameSa;

  /// Screen-reader label for the Language row in Settings. {value} is the current choice.
  ///
  /// In en, this message translates to:
  /// **'Language: {value}'**
  String descLanguageRowA11y(String value);

  /// Version line under the app name on the About screen. {version} is like 2.9.3.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String labelVersionNumber(String version);

  /// About-screen chip: this is the production build. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get labelEnvProduction;

  /// About-screen chip: this is the development build. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get labelEnvDevelopment;

  /// About-screen feature list item.
  ///
  /// In en, this message translates to:
  /// **'QR code scanning'**
  String get descFeatureQr;

  /// About-screen feature list item.
  ///
  /// In en, this message translates to:
  /// **'Encrypted storage'**
  String get descFeatureEncrypted;

  /// About-screen feature list item.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get descFeatureBackup;

  /// About-screen feature list item.
  ///
  /// In en, this message translates to:
  /// **'Account organization'**
  String get descFeatureOrganize;

  /// About-screen feature list item.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get descFeatureBiometric;

  /// About-screen feature list item.
  ///
  /// In en, this message translates to:
  /// **'Dark mode support'**
  String get descFeatureDarkMode;

  /// About-screen section header above the details rows. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get titleDeveloper;

  /// About-screen section header above the links. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get titleLinks;

  /// About-screen link and dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get titlePrivacyPolicy;

  /// Heading inside the privacy dialog. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Data storage'**
  String get titlePrivacyStorage;

  /// Privacy dialog paragraph about data storage.
  ///
  /// In en, this message translates to:
  /// **'All your account data is stored on your device and encrypted. The app has no server and needs no account.'**
  String get descPrivacyStorage;

  /// Heading inside the privacy dialog. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get titlePrivacyPermissions;

  /// Privacy dialog bullet list of permissions. Keep the bullets and line breaks.
  ///
  /// In en, this message translates to:
  /// **'• Camera: Used for scanning QR codes\n• Local network: Used only for Wi-Fi sync between your own devices\n• Biometric: Optional, for app lock authentication\n\nBackup files are chosen with the system file picker, so no storage permission is needed.'**
  String get descPrivacyPermissions;

  /// Heading inside the privacy dialog. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get titlePrivacySecurity;

  /// Privacy dialog paragraph about security.
  ///
  /// In en, this message translates to:
  /// **'Your secrets are encrypted using AES-256 encryption. They leave your device only when you start a Wi-Fi sync, an optical transfer or a backup export, and they are encrypted each time.'**
  String get descPrivacySecurity;

  /// Dialog button that closes the dialog. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// About-screen link that opens the licence list. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get titleOpenSourceLicenses;

  /// Copyright line at the bottom of the About screen and on the licence page.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Sreeraj P. All rights reserved.'**
  String get descCopyright;

  /// About-screen row label for the author (app_config.json key 'author').
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get aboutDetailAuthor;

  /// About-screen row label for the contact email (key 'email').
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutDetailEmail;

  /// About-screen row label for the website (key 'website').
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutDetailWebsite;

  /// About-screen row label for the privacy policy link (key 'privacyPolicy').
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutDetailPrivacyPolicy;

  /// About-screen row label for the licence (key 'license').
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutDetailLicense;

  /// About-screen row label for the AI tools used to build the app (key 'aiUsed').
  ///
  /// In en, this message translates to:
  /// **'AI used'**
  String get aboutDetailAiUsed;

  /// About-screen row label for the code editors used (key 'ideUsed').
  ///
  /// In en, this message translates to:
  /// **'IDE used'**
  String get aboutDetailIdeUsed;

  /// About-screen signature badge. {heart} is drawn as a red heart icon. Text from docs/PROJECT_PROFILE.md §5.
  ///
  /// In en, this message translates to:
  /// **'Made with {heart} in India'**
  String madeWithLove(String heart);

  /// Screen-reader text for the About badge.
  ///
  /// In en, this message translates to:
  /// **'Made with love in India'**
  String get madeWithLoveA11y;

  /// Dialog button that accepts a message. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Dialog button that cancels. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Button that copies text to the clipboard. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// Lock screen error: the phone screen lock check did not pass.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock failed'**
  String get errorPhoneLockFailed;

  /// Lock screen error: the user closed the phone screen lock prompt.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock was canceled'**
  String get errorPhoneLockCanceled;

  /// Lock screen error: too many failed tries on the phone screen lock.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock is temporarily locked out'**
  String get errorPhoneLockLockedOut;

  /// Lock screen error: the device has no screen lock.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock is not available on this device'**
  String get errorPhoneLockUnavailable;

  /// Lock screen error: an unexpected error during the phone screen lock check.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify phone screen lock'**
  String get errorPhoneLockUnverified;

  /// Lock screen banner: the app PIN is needed because an hour passed.
  ///
  /// In en, this message translates to:
  /// **'App PIN required after 1 hour'**
  String get descPinRequiredIdle;

  /// Lock screen banner: the app PIN is needed because the phone restarted.
  ///
  /// In en, this message translates to:
  /// **'App PIN required after device restart'**
  String get descPinRequiredReboot;

  /// Lock screen banner: the app PIN is needed after 3 failed phone lock tries.
  ///
  /// In en, this message translates to:
  /// **'App PIN required after 3 failed phone lock attempts'**
  String get descPinRequiredFailures;

  /// Lock screen banner: lockdown mode needs the app PIN.
  ///
  /// In en, this message translates to:
  /// **'Lockdown mode is on. Enter your App PIN'**
  String get descPinRequiredLockdown;

  /// Lock screen instruction.
  ///
  /// In en, this message translates to:
  /// **'Use your phone screen lock'**
  String get descUnlockPhoneOnly;

  /// Lock screen instruction.
  ///
  /// In en, this message translates to:
  /// **'Use your phone screen lock or enter your App PIN'**
  String get descUnlockPhoneOrPin;

  /// Lock screen instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your App PIN'**
  String get descUnlockPinOnly;

  /// Lock screen instruction when only the phone lock is offered.
  ///
  /// In en, this message translates to:
  /// **'Use your phone screen lock to unlock'**
  String get descUnlockWithPhone;

  /// PIN field error when the field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your App PIN'**
  String get errorPinEmpty;

  /// PIN field error during a lockout. {seconds} is a number of seconds.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Try again in {seconds} seconds.'**
  String errorPinLockedOut(int seconds);

  /// PIN field error. {count} is the number of tries left (1 or more).
  ///
  /// In en, this message translates to:
  /// **'Incorrect App PIN. Attempts left: {count}'**
  String errorPinIncorrectRemaining(int count);

  /// PIN field error when no tries are left before a lockout.
  ///
  /// In en, this message translates to:
  /// **'Incorrect App PIN'**
  String get errorPinIncorrect;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'No recovery key'**
  String get titleNoRecoveryKey;

  /// Dialog body when the user forgot the PIN and has no recovery key.
  ///
  /// In en, this message translates to:
  /// **'No recovery key was set up for this App PIN. Unfortunately, there is no way to recover access without it.\n\nYou can reinstall the app, but all accounts will be lost.'**
  String get descNoRecoveryKey;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Enter recovery key'**
  String get titleEnterRecoveryKey;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Enter the recovery key you saved when setting up your App PIN.'**
  String get descEnterRecoveryKey;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Recovery key'**
  String get labelRecoveryKey;

  /// Snackbar when the recovery key is wrong.
  ///
  /// In en, this message translates to:
  /// **'Invalid recovery key'**
  String get errorRecoveryKeyInvalid;

  /// Dialog button that checks the recovery key. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get actionRecover;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'New App PIN'**
  String get labelNewPin;

  /// Helper text under the new PIN field.
  ///
  /// In en, this message translates to:
  /// **'4–6 digits'**
  String get descPinDigitsHint;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Confirm App PIN'**
  String get labelConfirmPin;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'App PIN must be at least 4 digits'**
  String get errorPinTooShort;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'App PINs do not match'**
  String get errorPinMismatch;

  /// Dialog button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Save App PIN'**
  String get actionSavePin;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Set new App PIN'**
  String get titleSetNewPin;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your old App PIN has been cleared. Please set a new App PIN.'**
  String get descSetNewPin;

  /// Dialog title that shows a new recovery key. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Recovery key'**
  String get titleRecoveryKey;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Save this recovery key in a safe place. It is the only way to regain access if you forget your App PIN.'**
  String get descRecoveryKeySave;

  /// Snackbar after copying the recovery key.
  ///
  /// In en, this message translates to:
  /// **'Recovery key copied. It is cleared from the clipboard after 60 seconds.'**
  String get descRecoveryKeyCopied;

  /// Warning under a new recovery key.
  ///
  /// In en, this message translates to:
  /// **'This key will NOT be shown again.'**
  String get descRecoveryKeyOnce;

  /// Dialog button: the user saved the recovery key. Keep short.
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved it'**
  String get actionSavedIt;

  /// Lock screen heading. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Enter your App PIN'**
  String get titleEnterYourPin;

  /// Lock screen heading when only the phone lock unlocks the app. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Unlock with phone'**
  String get titleUseDeviceLock;

  /// Lock screen heading. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Unlock the app'**
  String get titleUnlockApp;

  /// PIN field hint during a lockout. {seconds} is a number of seconds.
  ///
  /// In en, this message translates to:
  /// **'Locked for {seconds} s'**
  String labelPinLockedFor(int seconds);

  /// PIN field hint. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Enter App PIN'**
  String get labelEnterPin;

  /// Lockout banner. {seconds} is a number of seconds.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} s'**
  String errorTooManyAttempts(int seconds);

  /// Lock screen button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Unlock with App PIN'**
  String get actionUnlockWithPin;

  /// Lock screen link button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Forgot App PIN?'**
  String get actionForgotPin;

  /// Button text while the phone lock prompt is open. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Checking phone lock…'**
  String get labelCheckingPhoneLock;

  /// Lock screen button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Use phone lock'**
  String get actionUsePhoneLock;

  /// Separator between two unlock options. One word.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get labelOr;

  /// Text shown by the system biometric prompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate with biometrics to access your accounts'**
  String get descAuthReasonBiometric;

  /// Text shown by the system phone screen lock prompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock the authenticator with your phone screen lock'**
  String get descAuthReasonPhoneLock;

  /// Snackbar when app lock is off but a PIN check was asked for.
  ///
  /// In en, this message translates to:
  /// **'App lock is not properly configured. Please re-enable it.'**
  String get errorAppLockMisconfigured;

  /// Snackbar when app lock has neither a PIN nor phone lock.
  ///
  /// In en, this message translates to:
  /// **'App lock has no unlock method. Please re-enable it.'**
  String get errorAppLockNoMethod;

  /// PIN check dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Enter App PIN'**
  String get titleEnterAppPin;

  /// PIN check dialog body.
  ///
  /// In en, this message translates to:
  /// **'App PIN is required for sensitive actions and secret access.'**
  String get descPinRequiredForSensitive;

  /// PIN text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get labelAppPin;

  /// PIN check dialog button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get actionVerify;

  /// PIN check dialog: why the PIN is asked for.
  ///
  /// In en, this message translates to:
  /// **'To view and edit the secret key.'**
  String get descPinPurposeViewSecret;

  /// PIN check dialog: why the PIN is asked for.
  ///
  /// In en, this message translates to:
  /// **'To view and edit the advanced options.'**
  String get descPinPurposeAdvanced;

  /// PIN check dialog: why the PIN is asked for.
  ///
  /// In en, this message translates to:
  /// **'To save changes to the secret key or advanced options.'**
  String get descPinPurposeSaveChanges;

  /// PIN check dialog: why the PIN is asked for.
  ///
  /// In en, this message translates to:
  /// **'To delete the selected accounts.'**
  String get descPinPurposeDeleteSelected;

  /// Tooltip on the close icon in selection mode. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get tooltipCancelSelection;

  /// App-bar title in selection mode. {count} is the number of selected accounts.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String labelSelectedCount(int count);

  /// Home tab. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get tabAccounts;

  /// Home tab. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tabTags;

  /// Tooltip. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get tooltipSelectAll;

  /// Tooltip. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get tooltipDeselectAll;

  /// Tooltip on the sort menu. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get tooltipSort;

  /// Tooltip on the settings icon. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  /// Snackbar after choosing manual sort.
  ///
  /// In en, this message translates to:
  /// **'Long press and drag to reorder accounts'**
  String get descReorderHint;

  /// Sort menu item. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get labelSortManual;

  /// Sort menu item. Keep short.
  ///
  /// In en, this message translates to:
  /// **'By issuer'**
  String get labelSortIssuer;

  /// Sort menu item. Keep short.
  ///
  /// In en, this message translates to:
  /// **'By account name'**
  String get labelSortAccount;

  /// Sort menu item. Keep short.
  ///
  /// In en, this message translates to:
  /// **'By date added'**
  String get labelSortDate;

  /// Home filter bar. {tags} is a comma-separated list of tag names.
  ///
  /// In en, this message translates to:
  /// **'Filtered by: {tags}'**
  String descFilteredBy(String tags);

  /// Button that removes the tag filter. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get actionClearFilter;

  /// Home hint line.
  ///
  /// In en, this message translates to:
  /// **'Long press to enter multi-select • Drag to reorder.'**
  String get descHomeHint;

  /// Bottom bar button in selection mode. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Reassign tags'**
  String get actionReassignTags;

  /// Bottom bar button in selection mode. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Export selected'**
  String get actionExportSelected;

  /// Bottom bar button in selection mode. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get actionDeleteSelected;

  /// Swipe action. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Swipe action and dialog button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get titleDeleteAccount;

  /// Dialog body. {name} is the account name.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String descDeleteAccountConfirm(String name);

  /// Snackbar. {name} is the account name.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String descAccountDeleted(String name);

  /// Dialog title. {count} is the number of selected accounts. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Reassign tags ({count})'**
  String titleReassignTagsCount(int count);

  /// Dialog hint.
  ///
  /// In en, this message translates to:
  /// **'Enter tags separated by commas (e.g. Work, VIP):'**
  String get descReassignTagsHint;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get labelTags;

  /// Example text in the tags field. Two sample tag names.
  ///
  /// In en, this message translates to:
  /// **'Work, Personal'**
  String get labelTagsExample;

  /// Checkbox label in the reassign tags dialog.
  ///
  /// In en, this message translates to:
  /// **'Replace existing tags (instead of appending)'**
  String get descReplaceTags;

  /// Snackbar. {count} is the number of accounts.
  ///
  /// In en, this message translates to:
  /// **'Updated tags for {count} accounts'**
  String descTagsUpdated(int count);

  /// Dialog button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Apply tags'**
  String get actionApplyTags;

  /// Dialog title. {count} is the number of selected accounts. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Export selected ({count})'**
  String titleExportSelectedCount(int count);

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Set a password to encrypt this backup file.'**
  String get descExportPasswordHint;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get labelConfirmPassword;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordTooShort;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMismatch;

  /// Snackbar. {count} is the number of accounts.
  ///
  /// In en, this message translates to:
  /// **'Exported {count} selected accounts'**
  String descExportedSelected(int count);

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Failed to export selected accounts'**
  String get errorExportSelectedFailed;

  /// Dialog button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// Dialog title for deleting several accounts. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete accounts'**
  String get titleDeleteAccounts;

  /// Dialog body. {count} is the number of accounts.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} accounts? This action cannot be undone.'**
  String descDeleteSelectedConfirm(int count);

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Deletion canceled.'**
  String get errorAuthFailedDeleteCanceled;

  /// Snackbar. {count} is the number of accounts.
  ///
  /// In en, this message translates to:
  /// **'{count} accounts deleted'**
  String descAccountsDeleted(int count);

  /// Dialog button. {count} is the number of accounts. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String actionDeleteCount(int count);

  /// Home empty state title when a search has no results.
  ///
  /// In en, this message translates to:
  /// **'No accounts found'**
  String get emptyNoAccountsFound;

  /// Home empty state title when there are no accounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get emptyNoAccountsYet;

  /// Home empty state hint after a search with no results.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get emptyTryDifferentSearch;

  /// Home empty state hint when there are no accounts.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first account'**
  String get emptyAddFirstAccount;

  /// Home empty state tip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Long press + button for more options'**
  String get emptyLongPressTip;

  /// Add-account menu item title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'QR scanner'**
  String get labelQrScanner;

  /// Add-account menu item subtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get descScanQrCode;

  /// Add-account menu item title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get labelManualEntry;

  /// Add-account menu item subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter details manually'**
  String get descEnterDetailsManually;

  /// Home search field hint. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Search accounts…'**
  String get labelSearchAccounts;

  /// Tags tab heading. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Tag cloud'**
  String get titleTagCloud;

  /// Tags tab subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any tag to view matching accounts'**
  String get descTagCloud;

  /// Tooltip of the icon-only button that opens tag management. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get actionManageTags;

  /// Tag search field hint. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Search tags…'**
  String get labelSearchTags;

  /// Tags tab filter line. {tags} is a comma-separated list like #work, #bank.
  ///
  /// In en, this message translates to:
  /// **'Active filter: {tags}'**
  String descActiveFilter(String tags);

  /// Button that clears the tag filter. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Tags tab empty title.
  ///
  /// In en, this message translates to:
  /// **'No tags created yet'**
  String get emptyNoTagsYet;

  /// Tags tab empty title after a search. {query} is the search text.
  ///
  /// In en, this message translates to:
  /// **'No tags matching \"{query}\"'**
  String emptyNoTagsMatching(String query);

  /// Tags tab empty hint.
  ///
  /// In en, this message translates to:
  /// **'Add tags when creating or editing an account'**
  String get emptyAddTagsHint;

  /// Tags tab empty hint after a search.
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different keyword'**
  String get emptyTryDifferentKeyword;

  /// Filter chip that shows all accounts. Keep short.
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get labelAllTags;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'App lock required'**
  String get titleAppLockRequired;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'To edit the secret key, please enable app lock from Security settings first.'**
  String get descAppLockRequiredSecret;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'To edit advanced options, please enable app lock from Security settings first.'**
  String get descAppLockRequiredAdvanced;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'To save changes to sensitive fields (secret key or advanced options), please enable app lock from Security settings first.'**
  String get descAppLockRequiredSave;

  /// Dialog button that opens the security settings. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Open security'**
  String get actionOpenSecurity;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Secret key unlocked'**
  String get descSecretUnlocked;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings unlocked'**
  String get descAdvancedUnlocked;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get descAccountUpdated;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Account added successfully'**
  String get descAccountAdded;

  /// Snackbar error when saving an account fails.
  ///
  /// In en, this message translates to:
  /// **'Could not save the account. Please try again.'**
  String get errorSaveAccountFailed;

  /// Form validation error.
  ///
  /// In en, this message translates to:
  /// **'Secret key is required'**
  String get errorSecretRequired;

  /// Form validation error.
  ///
  /// In en, this message translates to:
  /// **'Invalid secret key. Must be Base32 encoded'**
  String get errorSecretNotBase32;

  /// Form validation error.
  ///
  /// In en, this message translates to:
  /// **'Secret key is too short'**
  String get errorSecretTooShort;

  /// Screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get titleEditAccount;

  /// Screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get titleAddAccount;

  /// Tooltip on the QR icon. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get tooltipScanQr;

  /// Save button when editing. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Update account'**
  String get actionUpdateAccount;

  /// Save button when adding. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get actionAddAccount;

  /// Snackbar when a scanned QR code is not an otpauth code.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a valid authenticator code.'**
  String get errorQrInvalid;

  /// Snackbar when a scanned QR code has no secret.
  ///
  /// In en, this message translates to:
  /// **'The secret key is missing from this QR code.'**
  String get errorQrNoSecret;

  /// Snackbar when adding an account fails for another reason.
  ///
  /// In en, this message translates to:
  /// **'Could not add the account. Please try again.'**
  String get errorAddAccountFailed;

  /// Snackbar. {name} is the issuer and account name.
  ///
  /// In en, this message translates to:
  /// **'Account added: {name}'**
  String descAccountAddedName(String name);

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Add account manually'**
  String get titleAddAccountManually;

  /// Required text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Account name *'**
  String get labelAccountNameRequired;

  /// Text field hint.
  ///
  /// In en, this message translates to:
  /// **'Enter account name'**
  String get descAccountNameHint;

  /// Required text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Secret key *'**
  String get labelSecretKeyRequired;

  /// Text field hint.
  ///
  /// In en, this message translates to:
  /// **'Enter secret key'**
  String get descSecretKeyHint;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Issuer (optional)'**
  String get labelIssuerOptional;

  /// Text field hint with an example service name.
  ///
  /// In en, this message translates to:
  /// **'e.g., Google'**
  String get descIssuerHint;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Account name and secret key are required'**
  String get errorNameAndSecretRequired;

  /// Dialog button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get titleScanQrCode;

  /// Tooltip. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get tooltipToggleFlash;

  /// Tooltip. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get tooltipSwitchCamera;

  /// Instruction over the camera view.
  ///
  /// In en, this message translates to:
  /// **'Position QR code within frame'**
  String get descPositionQr;

  /// Button that opens manual entry. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get actionEnterManually;

  /// Card section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get titleAccountInformation;

  /// Required text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Account name *'**
  String get labelAccountName;

  /// Text field hint with an example user name.
  ///
  /// In en, this message translates to:
  /// **'e.g., john@example.com'**
  String get descAccountNameExample;

  /// Form validation error.
  ///
  /// In en, this message translates to:
  /// **'Account name is required'**
  String get errorAccountNameRequired;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Issuer (optional)'**
  String get labelIssuer;

  /// Text field hint with example service names.
  ///
  /// In en, this message translates to:
  /// **'e.g., Google, GitHub'**
  String get descIssuerExample;

  /// Required field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Secret key *'**
  String get labelSecretKey;

  /// Small label under a lock icon. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Tap to unlock'**
  String get labelTapToUnlock;

  /// Small label under a lock icon. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Enable app lock'**
  String get labelEnableAppLock;

  /// Secret key field hint.
  ///
  /// In en, this message translates to:
  /// **'Base32 encoded secret'**
  String get descSecretKeyBase32;

  /// Card section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get titleAdvancedSettings;

  /// Tooltip on a lock icon.
  ///
  /// In en, this message translates to:
  /// **'Unlock to edit'**
  String get tooltipUnlockToEdit;

  /// Tooltip on a lock icon.
  ///
  /// In en, this message translates to:
  /// **'Turn on app lock'**
  String get tooltipEnableAppLockFirst;

  /// Label for the number of code digits. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get labelDigits;

  /// Label for the code period. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Period (seconds)'**
  String get labelPeriodSeconds;

  /// Label for the hash algorithm. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get labelAlgorithm;

  /// A hidden setting row, e.g. "Digits: ●●". {label} is the setting name, {value} the masked value. Same pattern in every language.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String labelMaskedValue(String label, String value);

  /// A hidden period value. {mask} is a row of dots.
  ///
  /// In en, this message translates to:
  /// **'{mask} seconds'**
  String labelSecondsMasked(String mask);

  /// Hint under hidden advanced settings.
  ///
  /// In en, this message translates to:
  /// **'Tap to unlock and view settings'**
  String get descTapToUnlockSettings;

  /// Hint under hidden advanced settings.
  ///
  /// In en, this message translates to:
  /// **'Enable app lock to edit'**
  String get descEnableAppLockToEdit;

  /// Bottom sheet title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Browse existing tags'**
  String get titleBrowseTags;

  /// Button that clears the selection. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get actionClearAll;

  /// Tooltip on a close icon. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// Search field hint. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Search tags…'**
  String get labelSearchExistingTags;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No existing tags found'**
  String get emptyNoExistingTags;

  /// Empty state hint.
  ///
  /// In en, this message translates to:
  /// **'Type new tags in the text field to assign them to this entry.'**
  String get emptyTypeNewTags;

  /// Empty state title after a search.
  ///
  /// In en, this message translates to:
  /// **'No matching tags'**
  String get emptyNoMatchingTags;

  /// Empty state hint. {query} is the search text.
  ///
  /// In en, this message translates to:
  /// **'No existing tags match \"{query}\".'**
  String emptyNoTagsMatchQuery(String query);

  /// Button that closes the sheet. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Button that applies {count} selected tags. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Apply ({count})'**
  String actionApplySelected(int count);

  /// Tags field hint.
  ///
  /// In en, this message translates to:
  /// **'Comma separated, e.g. Work, Crypto, VIP'**
  String get descTagsFieldHint;

  /// Small hint next to a suggested tag. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get labelTapToAdd;

  /// Tooltip on the browse tags icon. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Browse existing tags'**
  String get tooltipBrowseTags;

  /// Permission name. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get labelPermCamera;

  /// Why the camera permission is needed.
  ///
  /// In en, this message translates to:
  /// **'Used to scan QR codes for adding accounts'**
  String get descPermCamera;

  /// Capability name. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get labelPermBiometric;

  /// Why biometrics are used.
  ///
  /// In en, this message translates to:
  /// **'Used for app lock authentication via fingerprint or device credentials'**
  String get descPermBiometric;

  /// Capability name. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get labelPermVibration;

  /// Why vibration is used.
  ///
  /// In en, this message translates to:
  /// **'Used for haptic feedback during QR code scanning'**
  String get descPermVibration;

  /// Capability name. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Secure storage'**
  String get labelPermSecureStorage;

  /// Why secure storage is used.
  ///
  /// In en, this message translates to:
  /// **'Uses Android Keystore to securely store encryption keys'**
  String get descPermSecureStorage;

  /// Capability name. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Local database'**
  String get labelPermLocalDatabase;

  /// What the local database holds.
  ///
  /// In en, this message translates to:
  /// **'Stores encrypted account data locally on your device'**
  String get descPermLocalDatabase;

  /// Banner at the top of the permissions screen.
  ///
  /// In en, this message translates to:
  /// **'This app only requests permissions when needed and never collects data.'**
  String get descPermissionsIntro;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Runtime permissions'**
  String get titleRuntimePermissions;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Built-in features'**
  String get titleBuiltInCapabilities;

  /// Section header. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get titlePrivacy;

  /// Privacy card title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'No cloud service'**
  String get labelNoCloudService;

  /// Privacy card body.
  ///
  /// In en, this message translates to:
  /// **'The app has no server or cloud account. Wi-Fi sync uses only your local network.'**
  String get descNoCloudService;

  /// Permission status. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get labelStatusGranted;

  /// Permission status. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get labelStatusDenied;

  /// Permission status. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Not granted'**
  String get labelStatusNotGranted;

  /// Permission status. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Not requested'**
  String get labelStatusNotRequested;

  /// Badge on a built-in capability. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get labelBuiltIn;

  /// Snackbar when an OTP cannot be generated. {name} is the account name.
  ///
  /// In en, this message translates to:
  /// **'Code unavailable for {name}'**
  String errorCodeUnavailable(String name);

  /// Snackbar after copying an OTP. {name} is the account name.
  ///
  /// In en, this message translates to:
  /// **'Code copied for {name}'**
  String descCodeCopied(String name);

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'App lock enabled with App PIN'**
  String get descAppLockEnabledPin;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'App lock enabled with phone screen lock'**
  String get descAppLockEnabledPhone;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Disable app lock'**
  String get titleDisableAppLock;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Disabling app lock removes your App PIN, quick unlock preference, and recovery key.'**
  String get descDisableAppLock;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'App lock disabled'**
  String get descAppLockDisabled;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Choose unlock method'**
  String get titleChooseUnlockMethod;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Pick how you want to unlock the app. App PIN is more secure; phone screen lock is more convenient.'**
  String get descChooseUnlockMethod;

  /// Dialog button: choose the phone screen lock. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Phone lock'**
  String get actionPhoneLock;

  /// Dialog button: choose the app PIN. Keep short.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get actionAppPin;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'App PIN enabled'**
  String get descAppPinEnabled;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Enable phone screen lock first, or disable app lock instead.'**
  String get errorEnablePhoneLockFirst;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Remove App PIN'**
  String get titleRemoveAppPin;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your App PIN and recovery key will be deleted. You will unlock the app with phone screen lock only.'**
  String get descRemoveAppPin;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'App PIN removed'**
  String get descAppPinRemoved;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Set an App PIN first, or disable app lock instead.'**
  String get errorSetAppPinFirst;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock quick unlock disabled'**
  String get descQuickUnlockDisabled;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock quick unlock enabled'**
  String get descQuickUnlockEnabled;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock enabled'**
  String get descPhoneLockEnabled;

  /// Row and dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock timeout'**
  String get titleAutoLockTimeout;

  /// Auto-lock option. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get labelLockImmediately;

  /// Auto-lock option, a number of minutes. Keep short.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String labelMinutesCount(int minutes);

  /// Dialog title asking for the current PIN. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Current App PIN'**
  String get titleCurrentPin;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'App PIN changed successfully'**
  String get descAppPinChanged;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Set App PIN'**
  String get titleSetAppPin;

  /// Dialog title and row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Change App PIN'**
  String get titleChangeAppPin;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'App PIN is required for app protection and all secret access.'**
  String get descPinRequiredForProtection;

  /// Dialog button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get titleAppLockSection;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get titleAppPinSection;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock'**
  String get titlePhoneLockSection;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Lockdown'**
  String get titleLockdownSection;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect the app with your App PIN and optional phone screen lock quick unlock'**
  String get descEnableAppLock;

  /// Switch title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Use App PIN'**
  String get labelUseAppPin;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'App PIN is set'**
  String get descAppPinIsSet;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a 4–6 digit PIN for app protection'**
  String get descSetPinHint;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your App PIN'**
  String get descUpdateAppPin;

  /// Row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Reset recovery key'**
  String get labelResetRecoveryKey;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a new recovery key for your App PIN'**
  String get descResetRecoveryKey;

  /// Switch title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Use phone lock'**
  String get labelUsePhoneLock;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional quick unlock for opening the app'**
  String get descPhoneLockOptional;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the app with your phone screen lock'**
  String get descPhoneLockOnly;

  /// Switch title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Lockdown mode'**
  String get labelLockdownMode;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable quick unlock and require your App PIN until you turn this off'**
  String get descLockdownMode;

  /// Info card text.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock is optional quick unlock. App PIN is required for revealing secrets.'**
  String get descInfoPhoneOptional;

  /// Info card text.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock is your only unlock method. Set an App PIN for stronger protection.'**
  String get descInfoPhoneOnly;

  /// Info card text.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock may use fingerprint, face, pattern, PIN, or password depending on your device.'**
  String get descInfoPhoneLockTypes;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Set backup password'**
  String get titleSetBackupPassword;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password to encrypt your backup. You will need this password to restore your accounts.'**
  String get descSetBackupPassword;

  /// Password field helper text.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get descPasswordMin8;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get errorPasswordEmpty;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordTooShort8;

  /// Dialog button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get actionCreateBackup;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'No accounts to back up'**
  String get errorNoAccountsToBackup;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup created successfully'**
  String get descBackupCreated;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Backup canceled or failed'**
  String get errorBackupCanceledOrFailed;

  /// Snackbar error when creating a backup fails.
  ///
  /// In en, this message translates to:
  /// **'Could not create the backup. Please try again.'**
  String get errorBackupFailed;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Restore accounts'**
  String get titleRestoreAccounts;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Import accounts from an encrypted backup file. Existing accounts will not be affected.'**
  String get descRestoreAccounts;

  /// Dialog title asking for the backup password. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get titleEnterBackupPassword;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Enter the password you used when creating this backup:'**
  String get descEnterBackupPassword;

  /// Dialog button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or the backup file is damaged.'**
  String get errorBackupPassword;

  /// Snackbar error: the backup opened but its content failed validation.
  ///
  /// In en, this message translates to:
  /// **'This backup has invalid content, so nothing was restored.'**
  String get errorBackupInvalid;

  /// Shown in the QR scanner when the camera cannot be opened or permission was denied.
  ///
  /// In en, this message translates to:
  /// **'The camera is not available. You can enter the details by hand.'**
  String get errorCameraUnavailable;

  /// Snackbar error: the picked file is above the backup size limit.
  ///
  /// In en, this message translates to:
  /// **'This file is too large to be a backup.'**
  String get errorBackupTooLarge;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'No accounts found in backup. Check your password and try again.'**
  String get errorNoAccountsInBackup;

  /// Snackbar. {count} is the number of accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts restored: {count}'**
  String descAccountsRestored(int count);

  /// Shown on the home screen when the saved accounts could not be read. It must not look like an empty vault.
  ///
  /// In en, this message translates to:
  /// **'Could not load your accounts. Do not delete the app or its data yet. Close the app and open it again.'**
  String get errorAccountsLoadFailed;

  /// Snackbar error when restoring fails.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the backup. Please try again.'**
  String get errorRestoreFailed;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get titleBackupCreated;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your encrypted backup has been saved successfully.'**
  String get descBackupSaved;

  /// Heading in a dialog. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Important:'**
  String get titleImportant;

  /// Bullet list in a dialog. Keep the bullets and line breaks.
  ///
  /// In en, this message translates to:
  /// **'• Store your backup file in a safe location\n• Remember your backup password\n• Without the password, you cannot restore'**
  String get descBackupTips;

  /// Dialog button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get actionGotIt;

  /// Dialog button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Info card text.
  ///
  /// In en, this message translates to:
  /// **'All backups are encrypted with a password for maximum security'**
  String get descBackupsEncrypted;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get titleCreateBackupSection;

  /// Row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Create backup file'**
  String get labelCreateEncryptedBackup;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all accounts with password protection'**
  String get descCreateEncryptedBackup;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get titleRestoreBackupSection;

  /// Row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get labelRestoreFromBackup;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Import accounts from encrypted backup file'**
  String get descRestoreFromBackup;

  /// Card title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Best practices'**
  String get titleBestPractices;

  /// Bullet list. Keep the bullets and line breaks.
  ///
  /// In en, this message translates to:
  /// **'• Create backups regularly\n• Use a strong, unique password\n• Store backups in multiple secure locations\n• Keep your password in a password manager\n• Test your backups by restoring them'**
  String get descBestPractices;

  /// Warning card text.
  ///
  /// In en, this message translates to:
  /// **'Never share your backup files or passwords. Anyone with access to both can generate your authentication codes.'**
  String get descNeverShareBackups;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get titleRenameTag;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get labelTagName;

  /// Text field hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Work, Personal'**
  String get descTagNameExample;

  /// Form validation error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a tag name'**
  String get errorTagNameEmpty;

  /// Form validation error.
  ///
  /// In en, this message translates to:
  /// **'New tag name must be different'**
  String get errorTagNameSame;

  /// Dialog button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// Snackbar. {oldTag} and {newTag} are tag names.
  ///
  /// In en, this message translates to:
  /// **'Renamed #{oldTag} to #{newTag}'**
  String descTagRenamed(String oldTag, String newTag);

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Could not rename the tag. Please try again.'**
  String get errorRenameTagFailed;

  /// Dialog title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get titleDeleteTag;

  /// Dialog body. {tag} is the tag name, {count} the number of accounts.
  ///
  /// In en, this message translates to:
  /// **'Remove tag \"#{tag}\" from {count} accounts?'**
  String descDeleteTagUsed(String tag, int count);

  /// Dialog body. {tag} is the tag name.
  ///
  /// In en, this message translates to:
  /// **'Delete unused tag \"#{tag}\"?'**
  String descDeleteTagUnused(String tag);

  /// Snackbar. {tag} is the tag name.
  ///
  /// In en, this message translates to:
  /// **'Deleted tag #{tag}'**
  String descTagDeleted(String tag);

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the tag. Please try again.'**
  String get errorDeleteTagFailed;

  /// Summary label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Total tags'**
  String get labelTotalTags;

  /// Summary label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Accounts tagged'**
  String get labelAccountsTagged;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No tags found'**
  String get emptyNoTagsFound;

  /// Empty state hint.
  ///
  /// In en, this message translates to:
  /// **'Tags added to accounts will appear here'**
  String get emptyTagsAppearHere;

  /// Empty state hint after a search.
  ///
  /// In en, this message translates to:
  /// **'Try a different search query'**
  String get emptyTryDifferentQuery;

  /// Tag row subtitle. {count} is the number of accounts with this tag.
  ///
  /// In en, this message translates to:
  /// **'Accounts: {count}'**
  String labelAccountCount(int count);

  /// Tooltip. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get tooltipRenameTag;

  /// Tooltip. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get tooltipDeleteTag;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'No device connected in time; hosting stopped.'**
  String get errorSyncHostTimeout;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Could not start hosting. Check that Wi-Fi is on.'**
  String get errorSyncHostStartFailed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'No device is connected to sync with.'**
  String get errorSyncNoDevice;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Select at least one item to sync.'**
  String get errorSyncNothingSelected;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Please try again.'**
  String get errorSyncFailed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Could not start the optical stream.'**
  String get errorOpticalStartFailed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Could not read the optical stream.'**
  String get errorOpticalDecodeFailed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'This is not a sync QR code.'**
  String get errorSyncNotSyncQr;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'This sync QR code is from a different app version.'**
  String get errorSyncUnsupportedVersion;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The sync QR code has no host address.'**
  String get errorSyncMissingHost;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The sync QR code has an invalid port.'**
  String get errorSyncInvalidPort;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The sync QR code has no pairing code.'**
  String get errorSyncMissingCode;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The other device sent data this app cannot read.'**
  String get errorSyncMalformed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The other device sent too many accounts.'**
  String get errorSyncTooManyAccounts;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The other device sent a value that is too large.'**
  String get errorSyncFieldTooLarge;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The other device is no longer connected.'**
  String get errorSyncPeerGone;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Could not send the data.'**
  String get errorSyncSendFailed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'No response from the other device.'**
  String get errorSyncNoResponse;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from the other device.'**
  String get errorSyncInvalidResponse;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The other device closed the connection.'**
  String get errorSyncConnectionClosed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Incorrect pairing code.'**
  String get errorSyncWrongCode;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The connection timed out.'**
  String get errorSyncTimedOut;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the other device. Check the IP address, port and Wi-Fi.'**
  String get errorSyncConnectFailed;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get errorSyncConnectionError;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'This is not an optical sync code.'**
  String get errorOpticalInvalidFrame;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'This optical sync code is from a different app version.'**
  String get errorOpticalUnsupportedVersion;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'A frame was damaged. Keep the camera steady.'**
  String get errorOpticalCorruptedChunk;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'A frame failed its check. Keep the camera steady.'**
  String get errorOpticalChecksum;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to send.'**
  String get errorOpticalEmpty;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'Not all frames were received.'**
  String get errorOpticalIncomplete;

  /// Sync error message.
  ///
  /// In en, this message translates to:
  /// **'The received data failed its integrity check.'**
  String get errorOpticalIntegrity;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Enter the host IP address'**
  String get errorEnterHostIp;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Enter the port shown on the other device'**
  String get errorEnterPort;

  /// Snackbar error.
  ///
  /// In en, this message translates to:
  /// **'Enter the pairing code'**
  String get errorEnterPairingCode;

  /// Screen title while hosting. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Send to device'**
  String get titleSendToDevice;

  /// Progress text.
  ///
  /// In en, this message translates to:
  /// **'Connecting to host…'**
  String get descConnectingToHost;

  /// Progress text.
  ///
  /// In en, this message translates to:
  /// **'Receiving…'**
  String get descReceiving;

  /// Info card text.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi sync: both devices on the same Wi-Fi or hotspot. The pairing code never leaves your device.'**
  String get descP2pInfo;

  /// Row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Send over Wi-Fi'**
  String get labelSendOverWifi;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Host: share your accounts and settings over local Wi-Fi'**
  String get descSendOverWifi;

  /// Row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Receive over Wi-Fi'**
  String get labelReceiveOverWifi;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join: scan the host QR or enter host IP'**
  String get descReceiveOverWifi;

  /// Section header (shown in capitals in English).
  ///
  /// In en, this message translates to:
  /// **'Optical air-gap sync (no Wi-Fi, no network)'**
  String get descOpticalSectionHeader;

  /// Row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Send optical stream'**
  String get labelOpticalSend;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Transmit your accounts as an animated QR stream (12–15 FPS)'**
  String get descOpticalSend;

  /// Row title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Scan optical stream'**
  String get labelOpticalReceive;

  /// Row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture an animated QR stream with the camera'**
  String get descOpticalReceive;

  /// Section header (shown in capitals in English).
  ///
  /// In en, this message translates to:
  /// **'Scan the QR on the other device'**
  String get descScanOtherQrHeader;

  /// Button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get actionScanQrCode;

  /// Divider text. Keep short.
  ///
  /// In en, this message translates to:
  /// **'or enter manually'**
  String get labelOrEnterManually;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Host IP address'**
  String get labelHostIp;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get labelPort;

  /// Text field label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Pairing code'**
  String get labelPairingCode;

  /// Button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Connect & receive'**
  String get actionConnectReceive;

  /// Button that goes back. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// Status title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get titleConnected;

  /// Status text.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the sender to choose what to share…'**
  String get descWaitingForSender;

  /// Status title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get titleSyncComplete;

  /// Summary line.
  ///
  /// In en, this message translates to:
  /// **'Accounts sent: {count}'**
  String descSentAccounts(int count);

  /// Summary line.
  ///
  /// In en, this message translates to:
  /// **'Settings sent: {count}'**
  String descSentSettings(int count);

  /// Summary line.
  ///
  /// In en, this message translates to:
  /// **'Accounts added: {count}'**
  String descAddedAccounts(int count);

  /// Summary line. {skipped} is the number of accounts kept as they were.
  ///
  /// In en, this message translates to:
  /// **'Accounts added: {count} ({skipped} already present, kept)'**
  String descAddedAccountsSkipped(int count, int skipped);

  /// Summary line.
  ///
  /// In en, this message translates to:
  /// **'Settings applied: {count}'**
  String descAppliedSettings(int count);

  /// Summary line.
  ///
  /// In en, this message translates to:
  /// **'Nothing to sync.'**
  String get descNothingToSync;

  /// Status title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get titleSyncFailed;

  /// Tab. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Server details'**
  String get tabServerDetails;

  /// Tab. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get tabSync;

  /// Hint under the host QR.
  ///
  /// In en, this message translates to:
  /// **'On the other device, choose “Receive over Wi-Fi” → “Scan QR code”'**
  String get descReceiveHint;

  /// Heading over the host details.
  ///
  /// In en, this message translates to:
  /// **'Or enter these manually'**
  String get descEnterManuallyHint;

  /// Info row label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Host IP'**
  String get labelHostIpShort;

  /// Button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get actionCopyCode;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Pairing code copied. It is cleared from the clipboard after 60 seconds.'**
  String get descPairingCodeCopied;

  /// Button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Stop hosting'**
  String get actionStopHosting;

  /// Status text.
  ///
  /// In en, this message translates to:
  /// **'A device is connected. Open the Sync tab to choose what to share.'**
  String get descClientConnected;

  /// Status text.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other device to connect…'**
  String get descWaitingForClient;

  /// Hint text.
  ///
  /// In en, this message translates to:
  /// **'No device is connected yet. Open the Server details tab and let the other device scan the QR or enter the code.'**
  String get descNoClientYet;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'New phone'**
  String get titleNewClientPhone;

  /// Section body.
  ///
  /// In en, this message translates to:
  /// **'Send everything — all accounts and app settings — to a phone that is setting up for the first time. Device-specific items (app lock, PIN, phone-lock unlock, recovery key) are not sent.'**
  String get descFullSync;

  /// Button. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Full sync'**
  String get actionFullSync;

  /// Section header. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Sync to a phone'**
  String get titleSyncToPhone;

  /// Section body.
  ///
  /// In en, this message translates to:
  /// **'For a phone that already has the app with its own data. Choose what to add:'**
  String get descSelectiveSync;

  /// Checkbox label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get labelSyncAccounts;

  /// Checkbox label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get labelSyncSettings;

  /// Checkbox subtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, auto-lock, and sync timeouts'**
  String get descSyncSettings;

  /// Info text.
  ///
  /// In en, this message translates to:
  /// **'This will not override anything already on the other device. If something matches, the other device keeps its own version — its data is retained.'**
  String get descNoOverride;

  /// Button. Keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get actionSync;

  /// Progress text.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get descSyncing;

  /// Estimated time in seconds. Keep short.
  ///
  /// In en, this message translates to:
  /// **'~{seconds} s'**
  String labelDurationSeconds(int seconds);

  /// Estimated time in minutes. Keep short.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String labelDurationMinutes(int minutes);

  /// Estimated time. Keep short.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min {seconds} s'**
  String labelDurationMinSec(int minutes, int seconds);

  /// Screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Optical stream'**
  String get titleOpticalSend;

  /// Screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Scan optical stream'**
  String get titleOpticalScan;

  /// Progress text.
  ///
  /// In en, this message translates to:
  /// **'Reconstructing accounts…'**
  String get descReconstructing;

  /// Warning title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Large data warning'**
  String get titleLargeVaultWarning;

  /// Warning body. {chunks} is a number, {duration} an estimated time like ~30 s.
  ///
  /// In en, this message translates to:
  /// **'This transfer has {chunks} chunks ({duration} estimated). Streaming a lot of data over camera QR can be slow. Consider Wi-Fi sync for a faster transfer.'**
  String descLargeVault(int chunks, String duration);

  /// Instruction text.
  ///
  /// In en, this message translates to:
  /// **'Point the receiving device camera at this animated QR stream. The data is encrypted with the transfer code; no network is used.'**
  String get descPointReceiver;

  /// Label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Stream hash:'**
  String get labelStreamHash;

  /// Label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Estimated time:'**
  String get labelEstDuration;

  /// Label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Frames shown:'**
  String get labelFramesRendered;

  /// Frame counter. {frame} and {total} are numbers.
  ///
  /// In en, this message translates to:
  /// **'{frame} (chunks: {total})'**
  String labelFramesValue(int frame, int total);

  /// Label. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Target FPS:'**
  String get labelTargetFps;

  /// Frames per second option. {fps} is a number. Same in every language.
  ///
  /// In en, this message translates to:
  /// **'{fps} FPS'**
  String labelFps(int fps);

  /// Remaining time. {time} is like ~30 s. Keep short.
  ///
  /// In en, this message translates to:
  /// **'{time} remaining'**
  String labelRemaining(String time);

  /// Receiver status text.
  ///
  /// In en, this message translates to:
  /// **'Align the camera with the sending screen…'**
  String get descAlignCamera;

  /// Receiver status text.
  ///
  /// In en, this message translates to:
  /// **'Reconstructing the stream…'**
  String get descReconstructingStream;

  /// Receiver progress. {solved} and {total} are numbers.
  ///
  /// In en, this message translates to:
  /// **'Captured: {solved} / {total} chunks'**
  String descCaptured(int solved, int total);

  /// Receiver session id. {hash} is a short code.
  ///
  /// In en, this message translates to:
  /// **'Session: {hash}'**
  String labelSession(String hash);

  /// Status title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Optical sync done'**
  String get titleOpticalComplete;

  /// Status text.
  ///
  /// In en, this message translates to:
  /// **'The accounts were rebuilt from the optical QR stream.'**
  String get descOpticalComplete;

  /// Status title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Optical sync failed'**
  String get titleOpticalFailed;

  /// Screen title. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Scan sync QR code'**
  String get titleScanSyncQr;

  /// Instruction over the camera view.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR shown on the sending device'**
  String get descScanSenderQr;

  /// Features screen: category heading.
  ///
  /// In en, this message translates to:
  /// **'Core 2FA & OTP tools'**
  String get descFeatures01;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Standards-compliant code generation and scanning'**
  String get descFeatures02;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'TOTP time-based codes'**
  String get descFeatures03;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Generate secure time-based one-time passwords compliant with RFC 6238. Supports 30 or 60 second periods, 6 or 8 digits, and SHA-1, SHA-256 or SHA-512.'**
  String get descFeatures04;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'RFC 6238 standard'**
  String get descFeatures05;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'SHA-1/256/512'**
  String get descFeatures06;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'30 s or 60 s'**
  String get descFeatures07;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Live ring timer'**
  String get descFeatures08;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'HOTP counter codes'**
  String get descFeatures09;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Counter-based codes (RFC 4226) from HOTP QR codes. Tap the next code button for each new code. The counter is saved before the code is shown.'**
  String get descFeatures10;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Add by QR code'**
  String get descFeatures11;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Counter saved'**
  String get descFeatures12;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'One code per tap'**
  String get descFeatures13;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Instant QR code scanner'**
  String get descFeatures14;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Add accounts by pointing your camera at standard 2FA QR codes (otpauth://). Includes a flashlight toggle and instant validation.'**
  String get descFeatures15;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Fast detection'**
  String get descFeatures16;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Flashlight support'**
  String get descFeatures17;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Safe input checks'**
  String get descFeatures18;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Brand icons'**
  String get descFeatures19;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Shows a brand logo for common services (Apple, AWS, Binance, Discord, GitHub, Google, Microsoft, Nintendo, Proton, Steam) and colorful initials for all others.'**
  String get descFeatures20;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'10 built-in brands'**
  String get descFeatures21;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Colorful initials'**
  String get descFeatures22;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Automatic match'**
  String get descFeatures23;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Quick copy & countdown'**
  String get descFeatures24;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Tap any code to copy it to the clipboard with haptic feedback. A circular timer shows how long the code stays valid.'**
  String get descFeatures25;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'One-tap copy'**
  String get descFeatures26;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get descFeatures27;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Smooth progress ring'**
  String get descFeatures28;

  /// Features screen: category heading.
  ///
  /// In en, this message translates to:
  /// **'Vault security & privacy'**
  String get descFeatures29;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Strong encryption, biometrics and zero tracking'**
  String get descFeatures30;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'AES-256-GCM encryption'**
  String get descFeatures31;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'All account secrets are encrypted at rest with AES-256-GCM. The device key is kept in the Android Keystore (hardware-backed on phones that support it).'**
  String get descFeatures32;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'AES-256-GCM'**
  String get descFeatures33;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Android Keystore'**
  String get descFeatures34;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'No plain text at rest'**
  String get descFeatures35;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Biometric & screen app lock'**
  String get descFeatures36;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Lock the app behind your fingerprint, face unlock, your phone screen lock, or an App PIN. Keeps your codes safe from people who pick up your phone.'**
  String get descFeatures37;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint / face'**
  String get descFeatures38;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Phone lock fallback'**
  String get descFeatures39;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Fast unlock'**
  String get descFeatures40;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Automatic lock'**
  String get descFeatures41;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Locks the app and clears decrypted codes from memory when you switch apps, minimize the app, or let the phone sleep.'**
  String get descFeatures42;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Background auto-lock'**
  String get descFeatures43;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Memory cleanup'**
  String get descFeatures44;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Configurable timeout'**
  String get descFeatures45;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Screenshot guard (FLAG_SECURE)'**
  String get descFeatures46;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'On by default. Blocks screenshots, screen recording and recent-apps thumbnails, so your codes cannot be captured from the screen.'**
  String get descFeatures47;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'FLAG_SECURE'**
  String get descFeatures48;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'No recents preview'**
  String get descFeatures49;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'No screen capture'**
  String get descFeatures50;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Offline & zero telemetry'**
  String get descFeatures51;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Works fully on your device: no internet backend, cloud login, analytics, crash reporting or tracking. Wi-Fi sync uses only your local network.'**
  String get descFeatures52;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Fully offline'**
  String get descFeatures53;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'No analytics'**
  String get descFeatures54;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'No cloud accounts'**
  String get descFeatures55;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Secrets stay encrypted'**
  String get descFeatures56;

  /// Features screen: category heading.
  ///
  /// In en, this message translates to:
  /// **'Organization & productivity'**
  String get descFeatures57;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Group, search and manage your accounts'**
  String get descFeatures58;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Multi-tag labels'**
  String get descFeatures59;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Give any account several tags (for example Work, Personal, Finance). Filter the account list by tag with one tap on the filter bar.'**
  String get descFeatures60;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Many tags per account'**
  String get descFeatures61;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Tag chips'**
  String get descFeatures62;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'One-tap filtering'**
  String get descFeatures63;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Tag cloud'**
  String get descFeatures64;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'A tag cloud shows all your tags and how many accounts use each. Tap a tag to show only its accounts.'**
  String get descFeatures65;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Visual tag view'**
  String get descFeatures66;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Account counts'**
  String get descFeatures67;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Fast navigation'**
  String get descFeatures68;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Live search'**
  String get descFeatures69;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Find any account by typing its name, user name, service or tag; results update as you type.'**
  String get descFeatures70;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Real-time search'**
  String get descFeatures71;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Names & tags'**
  String get descFeatures72;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Instant results'**
  String get descFeatures73;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Ordering & editing'**
  String get descFeatures74;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Put your accounts in the order you like, and change account names, services or code settings when needed.'**
  String get descFeatures75;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get descFeatures76;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get descFeatures77;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Batch actions'**
  String get descFeatures78;

  /// Features screen: category heading.
  ///
  /// In en, this message translates to:
  /// **'Sync, air-gap & backups'**
  String get descFeatures79;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Move accounts safely and export encrypted backups'**
  String get descFeatures80;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi sync'**
  String get descFeatures81;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Move accounts between two devices on your local Wi-Fi. A pairing code shown as a QR code protects the transfer; the data is encrypted with a key made from that code. No internet is used.'**
  String get descFeatures82;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Local Wi-Fi only'**
  String get descFeatures83;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Encrypted transfer'**
  String get descFeatures84;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'No cloud'**
  String get descFeatures85;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Optical air-gap sync'**
  String get descFeatures86;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Move accounts to an offline device with an animated series of QR codes, without Wi-Fi or Bluetooth. The QR codes are encrypted with a one-time code that you type.'**
  String get descFeatures87;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'No network'**
  String get descFeatures88;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Animated QR stream'**
  String get descFeatures89;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Encrypted stream'**
  String get descFeatures90;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backups'**
  String get descFeatures91;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Export all your accounts to an encrypted backup file protected by your own password (AES-256 with a PBKDF2 key).'**
  String get descFeatures92;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'AES-256 encrypted'**
  String get descFeatures93;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Password protected'**
  String get descFeatures94;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Portable file'**
  String get descFeatures95;

  /// Features screen: heading.
  ///
  /// In en, this message translates to:
  /// **'Safe import'**
  String get descFeatures96;

  /// Features screen: feature description.
  ///
  /// In en, this message translates to:
  /// **'Import backups or receive sync data safely. Existing accounts are kept and new ones are added; nothing is overwritten.'**
  String get descFeatures97;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Add-only merge'**
  String get descFeatures98;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Duplicate protection'**
  String get descFeatures99;

  /// Features screen: feature highlight chip.
  ///
  /// In en, this message translates to:
  /// **'Import summary'**
  String get descFeatures100;

  /// Features screen: text.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get descFeatures101;

  /// Features screen: text. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'{appName} features'**
  String descFeatures102(String appName);

  /// Features screen: text.
  ///
  /// In en, this message translates to:
  /// **'Explore every security safeguard and code tool built into the app.'**
  String get descFeatures103;

  /// Help center home: text.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpHome01;

  /// Help center home: section heading (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Authentication & setup'**
  String get helpHome02;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Getting started & adding accounts'**
  String get helpHome03;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'How to scan QR codes, add secret keys by hand, and use your 2FA codes.'**
  String get helpHome04;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Time sync & code drift'**
  String get helpHome05;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Fixing rejected codes, phone clock offsets, and HOTP counter codes.'**
  String get helpHome06;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Tags & account organization'**
  String get helpHome07;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Adding tags, filtering accounts, the tag cloud, and managing tags.'**
  String get helpHome08;

  /// Help center home: section heading (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Security & vault protection'**
  String get helpHome09;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Biometric & app lock'**
  String get helpHome10;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint and face unlock, phone screen lock fallback, and auto-lock rules.'**
  String get helpHome11;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Vault & screenshot guard'**
  String get helpHome12;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Android Keystore key storage, FLAG_SECURE screen protection, and offline privacy.'**
  String get helpHome13;

  /// Help center home: section heading (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Sync & backups'**
  String get helpHome14;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi sync'**
  String get helpHome15;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Direct device-to-device transfer over local Wi-Fi, encrypted with a key from the pairing code.'**
  String get helpHome16;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Optical air-gap transfer'**
  String get helpHome17;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Move accounts to an offline device with animated QR codes.'**
  String get helpHome18;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup & restore'**
  String get helpHome19;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Making password-protected backup files and restoring accounts on a new phone.'**
  String get helpHome20;

  /// Help center home: section heading (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpHome21;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'FAQs & troubleshooting'**
  String get helpHome22;

  /// Help center home: heading.
  ///
  /// In en, this message translates to:
  /// **'Short answers about codes, backups, permissions and moving to a new phone.'**
  String get helpHome23;

  /// Help center home: text.
  ///
  /// In en, this message translates to:
  /// **'Help center & guides'**
  String get helpHome24;

  /// Help center home: text. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'Guides and answers for every feature of {appName}.'**
  String helpHome25(String appName);

  /// Help: getting started: text.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get helpStart01;

  /// Help: getting started: intro paragraph. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'{appName} makes two-factor (2FA) codes that protect your online accounts. All codes are made on your device without an internet connection.'**
  String helpStart02(String appName);

  /// Help: getting started: heading.
  ///
  /// In en, this message translates to:
  /// **'Adding an account with a QR code'**
  String get helpStart03;

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'On the service (for example Google, GitHub, Amazon), open its security or 2FA settings and choose to set up an authenticator app.'**
  String get helpStart04;

  /// Help: getting started: bullet point. {appName} = the app name, {qrScanner} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'In {appName}, tap the “+” button on the home screen and choose “{qrScanner}”.'**
  String helpStart05(String appName, String qrScanner);

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code on your computer or other screen. The account is checked and added right away.'**
  String get helpStart06;

  /// Help: getting started: heading.
  ///
  /// In en, this message translates to:
  /// **'Adding an account by hand'**
  String get helpStart07;

  /// Help: getting started: bullet point. {manualEntry} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'If you cannot scan a QR code, choose “{manualEntry}” from the add menu.'**
  String helpStart08(String manualEntry);

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Enter the account name (for example your email or user name) and the issuer (for example GitHub, Google).'**
  String get helpStart09;

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Paste the secret key (Base32) that the service gives you.'**
  String get helpStart10;

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Under advanced settings you can set the algorithm (SHA1, SHA256, SHA512), digits (6 or 8) and period (30 or 60 seconds).'**
  String get helpStart11;

  /// Help: getting started: heading.
  ///
  /// In en, this message translates to:
  /// **'Using your 2FA codes'**
  String get helpStart12;

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Time-based (TOTP) codes change every 30 seconds by default. The countdown ring shows how long the code stays valid.'**
  String get helpStart13;

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Tap any account to copy its current code to the clipboard.'**
  String get helpStart14;

  /// Help: getting started: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Paste the code into the sign-in screen of the website or service.'**
  String get helpStart15;

  /// Help: getting started: tip box.
  ///
  /// In en, this message translates to:
  /// **'Tip: Always keep the backup recovery codes from your online services in a safe place, in case you lose your phone.'**
  String get helpStart16;

  /// Help: time sync: text.
  ///
  /// In en, this message translates to:
  /// **'Time sync & code drift'**
  String get helpTime01;

  /// Help: time sync: intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'TOTP codes depend on the exact time on your phone. If the clock is even a few seconds wrong, websites may reject your codes.'**
  String get helpTime02;

  /// Help: time sync: heading.
  ///
  /// In en, this message translates to:
  /// **'How TOTP time works'**
  String get helpTime03;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'A time-based code is made from your secret key and the current time, counted in 30-second steps.'**
  String get helpTime04;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Your phone and the server must agree on the time in UTC. Changing your time zone does not affect UTC.'**
  String get helpTime05;

  /// Help: time sync: heading.
  ///
  /// In en, this message translates to:
  /// **'Fixing rejected codes'**
  String get helpTime06;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Open your phone settings and go to System → Date & time.'**
  String get helpTime07;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Turn on “Set time automatically” and “Set time zone automatically”.'**
  String get helpTime08;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'If they are already on, turn them off and on again to make the phone fetch the network time now.'**
  String get helpTime09;

  /// Help: time sync: heading.
  ///
  /// In en, this message translates to:
  /// **'HOTP counter codes'**
  String get helpTime10;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'HOTP codes are based on a counter, not on time, so the clock does not matter. Tap the next code button on the account to get a new code.'**
  String get helpTime11;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Each tap uses up one code. Tap only when you need a code: the service may reject codes if you skip too many.'**
  String get helpTime12;

  /// Help: time sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'A restored backup or a copy on a second device can hold an older counter. If the service rejects a code, tap a few more times to catch up.'**
  String get helpTime13;

  /// Help: time sync: tip box.
  ///
  /// In en, this message translates to:
  /// **'Tip: Most rejected codes come from a wrong phone clock. Automatic network time fixes this for good.'**
  String get helpTime14;

  /// Help: tags: text.
  ///
  /// In en, this message translates to:
  /// **'Tags & organization'**
  String get helpTags01;

  /// Help: tags: intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'Tags put your 2FA accounts into your own groups, such as Work, Personal, Banking or Social, so you can filter them easily.'**
  String get helpTags02;

  /// Help: tags: heading.
  ///
  /// In en, this message translates to:
  /// **'Adding tags to accounts'**
  String get helpTags03;

  /// Help: tags: bullet point.
  ///
  /// In en, this message translates to:
  /// **'When adding or editing an account, type tag names separated by commas (for example “Work, Cloud, Tech”).'**
  String get helpTags04;

  /// Help: tags: bullet point.
  ///
  /// In en, this message translates to:
  /// **'While you type, the app suggests tags you already use, so names stay the same.'**
  String get helpTags05;

  /// Help: tags: bullet point. {browseTags} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Tap “{browseTags}” to pick from all tags already in use.'**
  String helpTags06(String browseTags);

  /// Help: tags: heading.
  ///
  /// In en, this message translates to:
  /// **'Filtering by tag'**
  String get helpTags07;

  /// Help: tags: bullet point.
  ///
  /// In en, this message translates to:
  /// **'The tag bar on the home screen shows your tags as chips you can tap.'**
  String get helpTags08;

  /// Help: tags: bullet point. {allTags} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Tap a tag chip to show only its accounts. Tap “{allTags}” to clear the filter.'**
  String helpTags09(String allTags);

  /// Help: tags: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Switch to the tag cloud to see all tags and how many accounts each has.'**
  String get helpTags10;

  /// Help: tags: heading.
  ///
  /// In en, this message translates to:
  /// **'Managing tags'**
  String get helpTags11;

  /// Help: tags: bullet point. {settings} = the current name of that menu item or button, {manageTags} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Go to {settings} → {manageTags} to rename or delete a tag for all accounts at once. Renaming a tag to an existing name merges the two.'**
  String helpTags12(String settings, String manageTags);

  /// Help: tags: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Renaming a tag updates every account that has it.'**
  String get helpTags13;

  /// Help: tags: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Deleting a tag removes the label from accounts; the accounts themselves stay.'**
  String get helpTags14;

  /// Help: tags: tip box.
  ///
  /// In en, this message translates to:
  /// **'Tip: Short tag names (for example “Work”, “Finance”) look best in the filter bar.'**
  String get helpTags15;

  /// Help: biometric and app lock: text.
  ///
  /// In en, this message translates to:
  /// **'Biometric & app lock'**
  String get helpLock01;

  /// Help: biometric and app lock: intro paragraph. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'{appName} can protect your codes with your fingerprint or face, your phone screen lock, or an App PIN.'**
  String helpLock02(String appName);

  /// Help: biometric and app lock: heading.
  ///
  /// In en, this message translates to:
  /// **'How app lock works'**
  String get helpLock03;

  /// Help: biometric and app lock: bullet point. {settings} = the current name of that menu item or button, {security} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'When it is on in {settings} → {security}, the app asks you to unlock whenever you open it or come back to it.'**
  String helpLock04(String settings, String security);

  /// Help: biometric and app lock: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Decrypted codes stay in memory only while the app is open and unlocked.'**
  String get helpLock05;

  /// Help: biometric and app lock: heading.
  ///
  /// In en, this message translates to:
  /// **'Automatic lock'**
  String get helpLock06;

  /// Help: biometric and app lock: bullet point.
  ///
  /// In en, this message translates to:
  /// **'As soon as you leave the app, switch apps, or lock the phone screen, the app locks. While it is open, it also locks after the auto-lock timeout.'**
  String get helpLock07;

  /// Help: biometric and app lock: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Decrypted codes are removed from memory, so someone who picks up the phone cannot read them.'**
  String get helpLock08;

  /// Help: biometric and app lock: heading.
  ///
  /// In en, this message translates to:
  /// **'Fallback & phone lock'**
  String get helpLock09;

  /// Help: biometric and app lock: bullet point.
  ///
  /// In en, this message translates to:
  /// **'If your fingerprint or face is not recognized (for example wet fingers or low light), you can use your phone screen lock PIN, pattern or password.'**
  String get helpLock10;

  /// Help: biometric and app lock: bullet point. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'The check is done by Android itself. {appName} never sees or stores your biometric data or phone passcode.'**
  String helpLock11(String appName);

  /// Help: biometric and app lock: tip box.
  ///
  /// In en, this message translates to:
  /// **'Tip: Set a secure screen lock in your phone settings for the best protection.'**
  String get helpLock12;

  /// Help: vault security: text.
  ///
  /// In en, this message translates to:
  /// **'Vault security & privacy'**
  String get helpVault01;

  /// Help: vault security: intro paragraph. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'{appName} is built to work offline and trust no server. Your secret keys are encrypted on your device and never sent to any remote server.'**
  String helpVault02(String appName);

  /// Help: vault security: heading.
  ///
  /// In en, this message translates to:
  /// **'AES-256-GCM encryption'**
  String get helpVault03;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'All secrets and code settings are encrypted with AES-256 in GCM mode, which also detects any change to the data.'**
  String get helpVault04;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'The encryption key is made on your device and kept in the Android Keystore (hardware-backed on phones that support it).'**
  String get helpVault05;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'No secret is ever written to the database as plain text.'**
  String get helpVault06;

  /// Help: vault security: heading.
  ///
  /// In en, this message translates to:
  /// **'Screenshot guard (FLAG_SECURE)'**
  String get helpVault07;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'By default, the app turns on Android FLAG_SECURE for its window. You can turn it off in Security settings.'**
  String get helpVault08;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'This blocks screenshots, screen recording and screen-reading apps from capturing your codes.'**
  String get helpVault09;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'In the recent-apps view, the app shows a blank screen, so people nearby cannot see your codes.'**
  String get helpVault10;

  /// Help: vault security: heading.
  ///
  /// In en, this message translates to:
  /// **'No cloud, no telemetry'**
  String get helpVault11;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'The app has no server, no login and no advertising or analytics code.'**
  String get helpVault12;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Your secrets and codes are never sent to any server. The app sends no logs, device IDs or usage data.'**
  String get helpVault13;

  /// Help: vault security: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Everything, including QR scanning, code generation and backup export, runs offline. Only Wi-Fi sync uses your local network.'**
  String get helpVault14;

  /// Help: vault security: tip box.
  ///
  /// In en, this message translates to:
  /// **'Privacy first: your authentication secrets belong to you alone.'**
  String get helpVault15;

  /// Help: Wi-Fi sync: text.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi sync'**
  String get helpWifi01;

  /// Help: Wi-Fi sync: intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi sync moves your 2FA accounts directly between two phones on the same Wi-Fi network. The data is encrypted, and no cloud service is involved.'**
  String get helpWifi02;

  /// Help: Wi-Fi sync: heading.
  ///
  /// In en, this message translates to:
  /// **'How Wi-Fi sync works'**
  String get helpWifi03;

  /// Help: Wi-Fi sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Connect both devices to the same Wi-Fi network.'**
  String get helpWifi04;

  /// Help: Wi-Fi sync: bullet point. {settings} = the current name of that menu item or button, {syncDevices} = the current name of that menu item or button, {sendOverWifi} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Step 2: On the sending device, open {settings} → {syncDevices} → “{sendOverWifi}”. It shows a pairing QR code and a pairing code.'**
  String helpWifi05(String settings, String syncDevices, String sendOverWifi);

  /// Help: Wi-Fi sync: bullet point. {receiveOverWifi} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Step 3: On the receiving device, tap “{receiveOverWifi}” and scan the pairing QR code (or type the details).'**
  String helpWifi06(String receiveOverWifi);

  /// Help: Wi-Fi sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Step 4: The devices connect, and the sender chooses what to share.'**
  String get helpWifi07;

  /// Help: Wi-Fi sync: heading.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get helpWifi08;

  /// Help: Wi-Fi sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'The data is encrypted with AES-256-GCM, using a key made (with PBKDF2) from the pairing code shown on the screen.'**
  String get helpWifi09;

  /// Help: Wi-Fi sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Someone watching your Wi-Fi traffic cannot read your 2FA secrets without the pairing code.'**
  String get helpWifi10;

  /// Help: Wi-Fi sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'The pairing code is never sent over the network; you move it yourself, by scanning or typing.'**
  String get helpWifi11;

  /// Help: Wi-Fi sync: heading.
  ///
  /// In en, this message translates to:
  /// **'Safe merging'**
  String get helpWifi12;

  /// Help: Wi-Fi sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Sync only adds accounts. Nothing on the receiving device is deleted or replaced.'**
  String get helpWifi13;

  /// Help: Wi-Fi sync: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Accounts that already exist on the receiving device are skipped.'**
  String get helpWifi14;

  /// Help: Wi-Fi sync: tip box.
  ///
  /// In en, this message translates to:
  /// **'Tip: Keep both devices awake and on the same Wi-Fi until the transfer finishes.'**
  String get helpWifi15;

  /// Help: optical transfer: text.
  ///
  /// In en, this message translates to:
  /// **'Optical air-gap transfer'**
  String get helpOptical01;

  /// Help: optical transfer: intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'Optical transfer moves your accounts to an offline device with an animated series of QR codes, without Wi-Fi, Bluetooth or cables.'**
  String get helpOptical02;

  /// Help: optical transfer: heading.
  ///
  /// In en, this message translates to:
  /// **'What is an air gap?'**
  String get helpOptical03;

  /// Help: optical transfer: bullet point.
  ///
  /// In en, this message translates to:
  /// **'An air-gapped device has no network connection at all (no Wi-Fi, Bluetooth or mobile data; Airplane Mode on).'**
  String get helpOptical04;

  /// Help: optical transfer: bullet point.
  ///
  /// In en, this message translates to:
  /// **'The data travels only as light, from screen to camera, so there is no network to listen to. The QR codes are encrypted, and the key comes from a code that is never shown on the sending screen.'**
  String get helpOptical05;

  /// Help: optical transfer: heading.
  ///
  /// In en, this message translates to:
  /// **'How to do an optical transfer'**
  String get helpOptical06;

  /// Help: optical transfer: bullet point. {settings}, {syncDevices}, {scanOptical} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Step 1: On the receiving device, go to {settings} → {syncDevices} → “{scanOptical}”. It shows a one-time transfer code.'**
  String helpOptical07(String settings, String syncDevices, String scanOptical);

  /// Help: optical transfer: bullet point. {sendOptical} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Step 2: On the sending device, choose “{sendOptical}” and type that code. Your accounts are encrypted with it and shown as a looping series of QR codes.'**
  String helpOptical08(String sendOptical);

  /// Help: optical transfer: bullet point. {startScanning} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Step 3: On the receiving device, tap “{startScanning}” and point the camera at the sending screen.'**
  String helpOptical09(String startScanning);

  /// Help: optical transfer: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Step 4: The receiver collects all parts. When every part is read and the code matches, the accounts are imported. With a wrong code, nothing is imported.'**
  String get helpOptical10;

  /// Help: optical transfer: heading.
  ///
  /// In en, this message translates to:
  /// **'Speed tips'**
  String get helpOptical11;

  /// Help: optical transfer: bullet point.
  ///
  /// In en, this message translates to:
  /// **'You can set the speed on the sender to 10, 12 or 15 frames per second; use a slower speed if the camera misses frames.'**
  String get helpOptical12;

  /// Help: optical transfer: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Hold both devices steady in good light, and avoid reflections or glare on the screen.'**
  String get helpOptical13;

  /// Help: optical transfer: tip box.
  ///
  /// In en, this message translates to:
  /// **'Tip: Optical sync suits a dedicated offline backup phone kept in a safe place.'**
  String get helpOptical14;

  /// Help: backup and restore: text.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup & restore'**
  String get helpBackup01;

  /// Help: backup and restore: intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'Backups protect you if your phone is damaged or lost, or when you move to a new phone. Every backup file is encrypted with a password you choose.'**
  String get helpBackup02;

  /// Help: backup and restore: heading.
  ///
  /// In en, this message translates to:
  /// **'Creating an encrypted backup'**
  String get helpBackup03;

  /// Help: backup and restore: bullet point. {settings} = the current name of that menu item or button, {backupRestore} = the current name of that menu item or button, {createBackup} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Go to {settings} → {backupRestore} → tap “{createBackup}”.'**
  String helpBackup04(
    String settings,
    String backupRestore,
    String createBackup,
  );

  /// Help: backup and restore: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong backup password. The app makes an AES-256 key from it with PBKDF2 (300,000 iterations) to encrypt the file.'**
  String get helpBackup05;

  /// Help: backup and restore: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Save the encrypted .aes backup file on your device, a USB drive, or your own offline archive.'**
  String get helpBackup06;

  /// Help: backup and restore: heading.
  ///
  /// In en, this message translates to:
  /// **'Password safety & recovery'**
  String get helpBackup07;

  /// Help: backup and restore: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Your backup password is never stored or sent anywhere. You must remember it or keep it written down safely.'**
  String get helpBackup08;

  /// Help: backup and restore: bullet point. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'Because {appName} works fully offline, there is no “forgot password” or server reset. A lost backup password cannot be recovered.'**
  String helpBackup09(String appName);

  /// Help: backup and restore: heading.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup'**
  String get helpBackup10;

  /// Help: backup and restore: bullet point. {settings} = the current name of that menu item or button, {backupRestore} = the current name of that menu item or button, {restoreBackup} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Go to {settings} → {backupRestore} → tap “{restoreBackup}”.'**
  String helpBackup11(
    String settings,
    String backupRestore,
    String restoreBackup,
  );

  /// Help: backup and restore: bullet point.
  ///
  /// In en, this message translates to:
  /// **'Pick your backup file and enter the password you used when you made it.'**
  String get helpBackup12;

  /// Help: backup and restore: bullet point.
  ///
  /// In en, this message translates to:
  /// **'The app checks the file and adds new accounts to the ones you have; nothing you have is deleted.'**
  String get helpBackup13;

  /// Help: backup and restore: tip box.
  ///
  /// In en, this message translates to:
  /// **'Tip: Make a fresh backup whenever you add important new 2FA accounts.'**
  String get helpBackup14;

  /// Help: FAQ: text.
  ///
  /// In en, this message translates to:
  /// **'FAQs & troubleshooting'**
  String get helpFaq01;

  /// Help: FAQ: intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'Quick answers about 2FA codes, recovery, security and common problems.'**
  String get helpFaq02;

  /// Help: FAQ: heading.
  ///
  /// In en, this message translates to:
  /// **'2FA codes'**
  String get helpFaq03;

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'Why do websites reject my codes?'**
  String get helpFaq04;

  /// Help: FAQ: answer.
  ///
  /// In en, this message translates to:
  /// **'Usually the phone clock is wrong. Open your phone settings → Date & time and turn on “Set time automatically”, so the clock matches UTC.'**
  String get helpFaq05;

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'Can I copy a code with one tap?'**
  String get helpFaq06;

  /// Help: FAQ: answer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Tap the account on the home screen; its code is copied to the clipboard and a short message confirms it.'**
  String get helpFaq07;

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'How are HOTP codes different from TOTP codes?'**
  String get helpFaq08;

  /// Help: FAQ: answer.
  ///
  /// In en, this message translates to:
  /// **'TOTP codes change every 30 seconds based on time. HOTP codes change only when you tap the next code button, and each tap uses up one code.'**
  String get helpFaq09;

  /// Help: FAQ: heading.
  ///
  /// In en, this message translates to:
  /// **'Security & privacy'**
  String get helpFaq10;

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'Why is the app blank when I switch apps?'**
  String get helpFaq11;

  /// Help: FAQ: answer.
  ///
  /// In en, this message translates to:
  /// **'The screenshot guard, on by default, turns on Android FLAG_SECURE. It stops screen recorders and the recent-apps view from capturing your codes.'**
  String get helpFaq12;

  /// Help: FAQ: question. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'Does {appName} send any data online?'**
  String helpFaq13(String appName);

  /// Help: FAQ: answer. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'No. {appName} works offline. It has no analytics, tracking or cloud service. Your data leaves the device only when you start a Wi-Fi sync on your local network, an optical transfer, or a backup export.'**
  String helpFaq14(String appName);

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'What if my fingerprint or face is not recognized?'**
  String get helpFaq15;

  /// Help: FAQ: answer.
  ///
  /// In en, this message translates to:
  /// **'You can unlock with your phone screen lock PIN, pattern or password, or with your App PIN.'**
  String get helpFaq16;

  /// Help: FAQ: heading.
  ///
  /// In en, this message translates to:
  /// **'Backups & moving phones'**
  String get helpFaq17;

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'How do I move my accounts to a new phone?'**
  String get helpFaq18;

  /// Help: FAQ: answer. {syncDevices} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Use “{syncDevices}” over local Wi-Fi, scan an optical QR stream, or export an encrypted backup on the old phone and restore it on the new one.'**
  String helpFaq19(String syncDevices);

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'What if I forget my backup password?'**
  String get helpFaq20;

  /// Help: FAQ: answer.
  ///
  /// In en, this message translates to:
  /// **'Backups use AES-256 encryption and there is no server, so a lost backup password cannot be recovered. Keep it written down safely.'**
  String get helpFaq21;

  /// Help: FAQ: question.
  ///
  /// In en, this message translates to:
  /// **'Will restoring a backup erase my accounts?'**
  String get helpFaq22;

  /// Help: FAQ: answer. {appName} = the app name.
  ///
  /// In en, this message translates to:
  /// **'No. {appName} only adds accounts. Your existing accounts stay, and duplicates are skipped.'**
  String helpFaq23(String appName);

  /// Help: FAQ: tip box. {settings} = the current name of that menu item or button, {permissions} = the current name of that menu item or button.
  ///
  /// In en, this message translates to:
  /// **'Need more help? Read the other guides in Help, or check your permissions in {settings} → {permissions}.'**
  String helpFaq24(String settings, String permissions);

  /// Optical sync: heading above the one-time transfer code, and the label of the field where it is typed.
  ///
  /// In en, this message translates to:
  /// **'Transfer code'**
  String get titleTransferCode;

  /// Optical sync, receiving device: instruction under the transfer code.
  ///
  /// In en, this message translates to:
  /// **'Type this code on the sending device, then tap the button below. Do not show this code to anyone else.'**
  String get descTransferCodeShow;

  /// Optical sync, receiving device: button that opens the camera after the code was typed on the sender.
  ///
  /// In en, this message translates to:
  /// **'Start scanning'**
  String get actionStartScanning;

  /// Optical sync, sending device: text in the dialog that asks for the transfer code.
  ///
  /// In en, this message translates to:
  /// **'Type the transfer code shown on the receiving device. The QR stream is encrypted with it.'**
  String get descTransferCodeEnter;

  /// Optical sync, sending device: dialog button that starts the encrypted QR stream.
  ///
  /// In en, this message translates to:
  /// **'Start sending'**
  String get actionStartSending;

  /// Optical sync, sending device: field error when the typed code is too short or too long. {count} = number of characters.
  ///
  /// In en, this message translates to:
  /// **'Type all {count} characters of the code.'**
  String errorTransferCodeLength(int count);

  /// Optical sync, receiving device: error when the stream could not be decrypted with this transfer code.
  ///
  /// In en, this message translates to:
  /// **'The code did not match. On the sending device, stop and type the code again.'**
  String get errorOpticalWrongCode;

  /// Optical sync, sending device: error when the typed transfer code is not well formed.
  ///
  /// In en, this message translates to:
  /// **'The transfer code is not valid. Start again and type the code shown on the receiving device.'**
  String get errorOpticalCodeInvalid;

  /// Account tile on the home screen: tooltip of the icon button that makes the next HOTP code.
  ///
  /// In en, this message translates to:
  /// **'Next code'**
  String get tooltipNextCode;

  /// Account tile on the home screen: message when an HOTP code is copied before one was made.
  ///
  /// In en, this message translates to:
  /// **'Tap the next code button first.'**
  String get descHotpTapForCode;

  /// Account tile on the home screen: error when the next HOTP code could not be made or saved.
  ///
  /// In en, this message translates to:
  /// **'Could not get the next code.'**
  String get errorHotpNextFailed;

  /// Tooltip of the eye button in a password field, while the password is hidden.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get tooltipShowPassword;

  /// Tooltip of the eye button in a password field, while the password is shown.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get tooltipHidePassword;

  /// Tooltip of the button that clears a search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get tooltipClearSearch;

  /// Account tile: tooltip of the eye button while the code is hidden.
  ///
  /// In en, this message translates to:
  /// **'Show code'**
  String get tooltipShowCode;

  /// Account tile: tooltip of the eye button while the code is shown.
  ///
  /// In en, this message translates to:
  /// **'Hide code'**
  String get tooltipHideCode;

  /// Home screen: tooltip and screen reader name of the round add button.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get tooltipAddAccount;

  /// Home screen: screen reader hint for a long press on the add button, which opens the options menu.
  ///
  /// In en, this message translates to:
  /// **'More ways to add'**
  String get tooltipAddOptions;

  /// Account tile: what a screen reader says instead of reading out the asterisks of a hidden code.
  ///
  /// In en, this message translates to:
  /// **'Code hidden'**
  String get descCodeHidden;

  /// Security screen: section heading above the screenshot switch.
  ///
  /// In en, this message translates to:
  /// **'Screen privacy'**
  String get titleScreenPrivacySection;

  /// Security screen: switch title. On by default.
  ///
  /// In en, this message translates to:
  /// **'Block screenshots'**
  String get labelBlockScreenshots;

  /// Security screen: switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Stops screenshots, screen recording and recent-apps previews from showing your codes'**
  String get descBlockScreenshots;

  /// Warning dialog title, shown before screenshot blocking is turned off.
  ///
  /// In en, this message translates to:
  /// **'Allow screenshots?'**
  String get titleAllowScreenshots;

  /// Warning dialog body, shown before screenshot blocking is turned off.
  ///
  /// In en, this message translates to:
  /// **'Your codes and secrets can then appear in screenshots, screen recordings and the recent-apps view. Other apps may also be able to capture them.'**
  String get descAllowScreenshotsWarning;

  /// Message shown when the screenshot setting could not be applied.
  ///
  /// In en, this message translates to:
  /// **'Could not change the screenshot setting'**
  String get errorBlockScreenshotsFailed;

  /// Security screen section heading. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get titleDataSection;

  /// Security screen row that starts deleting all app data. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get labelDeleteAllData;

  /// Subtitle of the Delete all data row.
  ///
  /// In en, this message translates to:
  /// **'Remove every account and setting from this device'**
  String get descDeleteAllDataEntry;

  /// Warning dialog title, shown before all app data is deleted. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get titleDeleteAllData;

  /// Warning dialog body, shown before all app data is deleted.
  ///
  /// In en, this message translates to:
  /// **'This removes all your accounts, your App PIN, your recovery key and your settings from this device. It cannot be undone. Without a backup, you may lose access to your accounts.\n\nBackup files you saved elsewhere are not deleted.'**
  String get descDeleteAllDataWarning;

  /// Checkbox in the warning, shown only when the phone has no lock and no App PIN is set.
  ///
  /// In en, this message translates to:
  /// **'I understand this cannot be undone'**
  String get descDeleteAllDataUnderstand;

  /// Button that confirms deleting all app data. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get actionDeleteAll;

  /// Reason shown in the system phone-lock prompt before all app data is deleted.
  ///
  /// In en, this message translates to:
  /// **'Confirm to delete all data'**
  String get descAuthReasonDeleteAllData;

  /// Why the App PIN is asked for, shown in the PIN dialog.
  ///
  /// In en, this message translates to:
  /// **'To delete all data.'**
  String get descPinPurposeDeleteAllData;

  /// Message shown after all app data was deleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get descAllDataDeleted;

  /// Message shown when part of the delete failed.
  ///
  /// In en, this message translates to:
  /// **'Some data could not be deleted. Please try again.'**
  String get errorDeleteAllDataFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml', 'sa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
    case 'sa':
      return AppLocalizationsSa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
