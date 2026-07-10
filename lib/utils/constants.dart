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

  /// Default account sort on the home screen: alphabetical by issuer.
  /// Allowed values: 'manual', 'issuer', 'account', 'date'.
  static const String defaultSortBy = 'issuer';
  static const List<String> sortByOptions = <String>[
    'manual',
    'issuer',
    'account',
    'date',
  ];

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

  // Sync QR: a versioned, offline-only URI encoding the host IP, port, and
  // pairing code so the receiving device can scan instead of typing. The QR is
  // shown only on the host screen and read by the peer's camera — it is an
  // out-of-band channel and is never sent over the network (see docs/security.md
  // §5.1). Shape: spauth://sync?v=1&ip=<ip>&port=<port>&code=<code>.
  static const String syncQrScheme = 'spauth';
  static const String syncQrHost = 'sync';
  static const String syncQrVersion = '1';
  static const String syncQrKeyVersion = 'v';
  static const String syncQrKeyIp = 'ip';
  static const String syncQrKeyPort = 'port';
  static const String syncQrKeyCode = 'code';

  // Handshake messages (transmitted encrypted, never in clear).
  static const String syncHelloMessage = 'HELLO_SYNC';
  static const String syncAcceptMessage = 'ACCEPT_SYNC';
  static const String syncDeniedMessage = 'DENIED';

  // Host auto-stop on idle: configurable window (seconds) after which a host
  // with no successful handshake tears down its listener.
  static const int syncHostIdleTimeoutDefault = 120;
  static const int syncHostIdleTimeoutMin = 30;
  static const int syncHostIdleTimeoutMax = 600;

  // Once a client has authenticated the host holds the connection open and waits
  // for the sender to choose what to share (Full Sync / selective Sync). This is
  // how long the client waits for that payload before giving up.
  static const Duration syncPayloadWaitTimeout = Duration(minutes: 10);

  // Sync payload shape. In addition to 'accounts' and 'groups', the payload may
  // carry a small 'settings' object and a 'syncMode' marker so the receiver can
  // apply settings with the right semantics (overwrite for a full sync to a new
  // client; fill-only / never-override for an incremental sync).
  static const String syncPayloadKeySettings = 'settings';
  static const String syncPayloadKeySyncMode = 'syncMode';
  static const String syncModeFull = 'full';
  static const String syncModeIncremental = 'incremental';

  // Category identifiers used by the selective (incremental) sync UI and payload.
  static const String syncCategoryAccounts = 'accounts';
  static const String syncCategoryGroups = 'groups';
  static const String syncCategorySettings = 'settings';

  // Keys used inside the synced 'settings' object. These name the only settings
  // that ever cross devices; every other SettingsProvider value (app lock, App
  // PIN, phone-lock/biometric unlock, recovery key, lockdown, boot/adaptive-auth
  // state) is device-specific and never transmitted. See docs/security.md.
  static const String syncSettingThemeMode = 'theme_mode';
  static const String syncSettingAutoLockTimeout = 'auto_lock_timeout';
  static const String syncSettingSyncHostIdleTimeout = 'sync_host_idle_timeout';

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
