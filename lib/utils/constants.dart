// File Path: sreerajp_authenticator/lib/utils/constants.dart
// Description: Centralized constants extracted from across the codebase

class AppConstants {
  AppConstants._();

  // ─── Cryptography ──────────────────────────────────────────────────────────

  static const int aesKeySize = 32;
  static const int gcmNonceSize = 12;
  static const int gcmNonceBase64Length = 16;
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

  // ─── Database ──────────────────────────────────────────────────────────────

  static const String databaseName = 'authenticator.db';
  static const int databaseVersion = 4;

  // ─── OTP ───────────────────────────────────────────────────────────────────

  static const Duration cacheTtl = Duration(minutes: 5);
  static const String otpUnavailablePlaceholder = '------';
  static const int minSecretLength = 16;

  // ─── Account / OTP Defaults ────────────────────────────────────────────────

  /// Default account sort on the home screen: alphabetical by issuer.
  /// Allowed values: 'manual', 'issuer', 'account', 'date'.
  static const String defaultSortBy = 'issuer';
  static const List<String> sortByOptions = <String>[
    'manual',
    'issuer',
    'account',
    'date',
  ];

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

  // ─── P2P LAN Sync ──────────────────────────────────────────────────────────

  // Hostile-peer hardening (see docs/security.md). Authenticator payloads are
  // tiny; the payload cap is intentionally generous, not expected to be hit.
  static const int syncMaxHandshakeLine = 4096; // bytes per handshake line
  static const int syncMaxPayloadLine = 16 * 1024 * 1024; // 16 MB payload cap
  static const Duration syncSocketTimeout = Duration(seconds: 30);
  static const Duration syncConnectTimeout = Duration(seconds: 6);

  // Payload validation caps applied before ingestion.
  static const int syncMaxAccounts = 5000;
  static const int syncMaxFieldLength = 4096;

  // Largest backup file accepted before it is read (same as the sync payload cap).
  static const int backupMaxFileBytes = syncMaxPayloadLine;

  // How long copied secrets stay on the clipboard.
  static const Duration clipboardClearDefault = Duration(seconds: 30);
  static const Duration clipboardClearLong = Duration(seconds: 60);

  // Pairing code: 64 chars from a 31-symbol alphabet (no 0/O/1/I/L) ≈ 320 bits.
  static const int syncPairingCodeLength = 64;
  static const int syncPairingCodeGroup = 8; // display grouping
  static const String syncPairingAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  // Optical sync: one-time transfer code (12 chars ~ 59 bits), shown on the
  // receiver and typed on the sender, so a recording of the stream alone
  // cannot be decrypted.
  static const int opticalTransferCodeLength = 12;
  static const int opticalTransferCodeGroup = 4;
  static const int opticalFrameVersion = 2;

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

  // Sync payload shape. In addition to 'accounts', the payload may
  // carry a small 'settings' object and a 'syncMode' marker so the receiver can
  // apply settings with the right semantics (overwrite for a full sync to a new
  // client; fill-only / never-override for an incremental sync).
  static const String syncPayloadKeySettings = 'settings';
  static const String syncPayloadKeySyncMode = 'syncMode';
  static const String syncModeFull = 'full';
  static const String syncModeIncremental = 'incremental';

  // ─── Optical Air-Gap Sync ──────────────────────────────────────────────────

  /// Threshold (chunk count) above which a payload is considered large for camera QR streaming.
  /// 60 chunks at 12 FPS is ~5 seconds of streaming.
  static const int opticalLargeVaultChunkThreshold = 60;

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
}
