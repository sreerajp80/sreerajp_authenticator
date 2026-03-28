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
  static const int currentPinVersion = 2;
  static const int recoveryKeyLength = 16;
  static const String recoveryKeyCharset = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static const int lockoutSeconds5Attempts = 30;
  static const int lockoutSeconds6Attempts = 60;
  static const int lockoutSeconds7Attempts = 300;
  static const int lockoutSeconds8PlusAttempts = 1800;

  // ─── Backup / Export ───────────────────────────────────────────────────────

  static const String backupVersion = '2.0';
  static const String encryptedBackupExtension = 'aes';
  static const String jsonBackupExtension = 'json';
}
