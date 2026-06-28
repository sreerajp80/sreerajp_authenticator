// File Path: sreerajp_authenticator/lib/utils/constants.dart
// Description: Centralized constants extracted from across the codebase

class AppConstants {
  AppConstants._();

  // ─── Cryptography ──────────────────────────────────────────────────────────

  static const int aesKeySize = 32;
  static const int gcmNonceSize = 12;
  static const int gcmNonceBase64Length = 16;
  static const int cbcIvBase64Length = 24;
  static const int saltSize = 16;
  static const int pbkdf2Iterations = 300000;
  static const int pbkdf2IterationsPin = 100000;
  static const int pbkdf2HashSize = 32;
  static const int hmacBlockSize = 64;

  // ─── Secure Storage Keys ───────────────────────────────────────────────────

  static const String encryptionKeyAlias = 'authenticator_key';

  static const String pinHashKey = 'app_pin_hash';
  static const String pinSaltKey = 'app_pin_salt';
  static const String pinVersionKey = 'app_pin_version';
  static const String failedAttemptsKey = 'pin_failed_attempts';
  static const String lockoutUntilKey = 'pin_lockout_until';
  static const String pinMigrationDoneKey = 'pin_migrated_to_keystore';
  static const String recoveryKeyHashKey = 'recovery_key_hash';
  static const String recoveryKeySaltKey = 'recovery_key_salt';

  // ─── Migration Flags (SharedPreferences) ───────────────────────────────────

  static const String aesMigrationKey = 'aes_migration_v1_complete';
  static const String gcmMigrationKey = 'gcm_migration_v2_complete';

  // ─── Database ──────────────────────────────────────────────────────────────

  static const String databaseName = 'authenticator.db';
  static const int databaseVersion = 2;
  static const String accountsTable = 'accounts';
  static const String groupsTable = 'groups';

  // ─── OTP ───────────────────────────────────────────────────────────────────

  static const Duration cacheTtl = Duration(minutes: 5);
  static const String otpUnavailablePlaceholder = '------';
  static const int minSecretLength = 16;

  // ─── Account / OTP Defaults ────────────────────────────────────────────────

  static const int defaultDigits = 6;
  static const int defaultPeriod = 30;
  static const String defaultAlgorithm = 'SHA1';
  static const int defaultSortOrder = 0;

  // ─── Group Defaults ────────────────────────────────────────────────────────

  static const String defaultGroupColor = 'blue';

  // ─── PIN / Auth ────────────────────────────────────────────────────────────

  static const int maxPinAttempts = 5;
  static const int maxQuickUnlockAttempts = 3;
  static const int currentPinVersion = 3;
  static const int recoveryKeyLength = 16;
  static const String recoveryKeyCharset = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const Duration strongAuthTimeout = Duration(hours: 1);

  static const String deviceStateChannel =
      'sreerajp_authenticator/device_state';
  static const String getBootCountMethod = 'getBootCount';

  static const int lockoutSeconds5Attempts = 30;
  static const int lockoutSeconds6Attempts = 60;
  static const int lockoutSeconds7Attempts = 300;
  static const int lockoutSeconds8PlusAttempts = 1800;

  // ─── Backup / Export ───────────────────────────────────────────────────────

  static const String backupVersion = '2.0';
  static const String encryptedBackupExtension = 'aes';
  static const String jsonBackupExtension = 'json';

  // ─── P2P LAN Sync ──────────────────────────────────────────────────────────

  // Hostile-peer hardening (see docs/security.md). Authenticator payloads are
  // tiny; the payload cap is intentionally generous, not expected to be hit.
  static const int syncMaxHandshakeLine = 4096; // bytes per handshake line
  static const int syncMaxPayloadLine = 16 * 1024 * 1024; // 16 MB payload cap
  static const Duration syncSocketTimeout = Duration(seconds: 30);
  static const Duration syncConnectTimeout = Duration(seconds: 6);

  // Payload validation caps applied before ingestion.
  static const int syncMaxAccounts = 5000;
  static const int syncMaxGroups = 1000;
  static const int syncMaxFieldLength = 4096;

  // Pairing code: 64 chars from a 31-symbol alphabet (no 0/O/1/I/L) ≈ 320 bits.
  static const int syncPairingCodeLength = 64;
  static const int syncPairingCodeGroup = 8; // display grouping
  static const String syncPairingAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  // Handshake messages (transmitted encrypted, never in clear).
  static const String syncHelloMessage = 'HELLO_SYNC';
  static const String syncAcceptMessage = 'ACCEPT_SYNC';
  static const String syncDeniedMessage = 'DENIED';

  // Host auto-stop on idle: configurable window (seconds) after which a host
  // with no successful handshake tears down its listener.
  static const int syncHostIdleTimeoutDefault = 120;
  static const int syncHostIdleTimeoutMin = 30;
  static const int syncHostIdleTimeoutMax = 600;

  // ─── App / Branding (flavor-dependent) ─────────────────────────────────────

  static const String appNameProd = 'Sreeraj P Authenticator';
  static const String appNameDev = 'Sreeraj P Authenticator Dev';
  static const String environmentNameProd = 'Production';
  static const String environmentNameDev = 'Development';
  static const String bannerLabelProd = 'PROD';
  static const String bannerLabelDev = 'DEV';

  // ─── About Screen ──────────────────────────────────────────────────────────

  static const String licensesLegalese =
      '© 2026 Sreeraj P. All rights reserved.';
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
  static const String aiUsedValue = 'Claude 4.5, 4.6 & 4.8 and ChatGPT';
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

class AboutInfoEntry {
  final String label;
  final String value;

  const AboutInfoEntry(this.label, this.value);
}
