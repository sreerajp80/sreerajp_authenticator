import '../config/app_flavor_config.dart';

class AboutInfoEntry {
  final String label;
  final String value;

  const AboutInfoEntry(this.label, this.value);
}

class AboutScreenContent {
  AboutScreenContent._();

  static String get appName => AppFlavorConfig.instance.appName;
  static String get environmentName => AppFlavorConfig.instance.environmentName;
  static const String licensesLegalese =
      '© 2025 Sreeraj P. All rights reserved.';
  static const String aboutSectionTitle = 'About';
  static const String aboutDescription =
      'A secure and reliable two-factor authentication app that helps protect your online accounts. Generate time-based one-time passwords (TOTP) and counter-based passwords (HOTP) with support for multiple algorithms.';
  static const String featuresSectionTitle = 'Features';
  static const String qrScanningFeature = 'QR code scanning';
  static const String encryptedStorageFeature = 'Encrypted storage';
  static const String backupRestoreFeature = 'Backup & restore';
  static const String accountOrganizationFeature = 'Account organization';
  static const String biometricAuthFeature = 'Biometric authentication';
  static const String darkModeFeature = 'Dark mode support';
  static const String linksSectionTitle = 'LINKS';
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String privacyPolicyStorageTitle = 'Data Storage';
  static const String privacyPolicyStorageDescription =
      'All your account data is stored locally on your device and is encrypted using industry-standard encryption algorithms. We do not collect, transmit, or store any of your data on external servers.';
  static const String privacyPolicyPermissionsTitle = 'Permissions';
  static const String privacyPolicyPermissionsDescription =
      '• Camera: Used for scanning QR codes\n'
      '• Storage: Used for backup and restore functionality\n'
      '• Biometric: Optional, for app lock authentication';
  static const String privacyPolicySecurityTitle = 'Security';
  static const String privacyPolicySecurityDescription =
      'Your secrets are encrypted using AES-256 encryption. The app does not require internet access and works completely offline, ensuring your authentication codes never leave your device.';
  static const String closeButtonText = 'Close';
  static const String openSourceLicensesTitle = 'Open Source Licenses';
  static const String developerSectionTitle = 'DEVELOPER';
  static const String designConceptLabel = 'Design & Concept';
  static const String aiUsedLabel = 'AI Used';
  static const String developerEmailLabel = 'Developer Email';
  static const String developerName = 'Sreeraj P';
  static const String developerEmail = 'sreerajp@zohomail.in';
  static const String aiUsedValue = 'Claude 4.5 & 4.6 and ChatGPT';
  static const List<AboutInfoEntry> developerInfo = <AboutInfoEntry>[
    AboutInfoEntry(designConceptLabel, developerName),
    AboutInfoEntry(aiUsedLabel, aiUsedValue),
    AboutInfoEntry(developerEmailLabel, developerEmail),
  ];
  static const String copyrightText = '© 2026 Sreeraj P. All rights reserved.';
  static const String footerText = 'Made with ❤️ in India';

  static String get developerInitials {
    final parts = developerName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);

    return parts.map((part) => part[0]).join().toUpperCase();
  }
}
