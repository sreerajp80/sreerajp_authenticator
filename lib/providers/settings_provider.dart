// File Path: sreerajp_authenticator/lib/providers/settings_provider.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2026 May 27
// Description: Provider for app settings, app lock state, and adaptive authentication policy

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/data_wipe_service.dart';
import '../services/device_state_service.dart';
import '../services/otp_service.dart';
import '../utils/app_logger.dart';
import '../utils/constants.dart';
import '../utils/screen_protection.dart';

/// Which unlock instruction the lock screen shows. The screen turns it into
/// localized text (providers hold no UI text).
enum UnlockInstruction { phoneLockOnly, phoneLockOrPin, pinOnly }

enum PinRequiredReason {
  none,
  idleTimeout,
  reboot,
  quickUnlockFailures,
  lockdown,
}

class SettingsProvider extends ChangeNotifier {
  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyPhoneLockQuickUnlockEnabled =
      'phone_lock_quick_unlock_enabled';
  static const String _keyAutoLockTimeout = 'auto_lock_timeout';
  static const String _keySortBy = 'sort_by';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLastActiveTime = 'last_active_time';
  static const String _keyLastStrongAuthAtMs = 'last_strong_auth_at_ms';
  static const String _keyQuickUnlockFailureCount =
      'quick_unlock_failure_count';
  static const String _keyLockdownEnabled = 'lockdown_enabled';
  static const String _keyLastKnownBootCount = 'last_known_boot_count';
  static const String _keyPinRequiredReason = 'pin_required_reason';
  static const String _keySyncHostIdleTimeout = 'sync_host_idle_timeout';
  static const String _legacyKeyAppLockPin = 'app_lock_pin';
  static const String _keyBlockScreenshots = 'block_screenshots';

  /// The saved screenshot choice. A missing value means blocked. Stays on this
  /// device: it is not part of sync or backup settings.
  static bool readBlockScreenshots(SharedPreferences prefs) =>
      prefs.getBool(_keyBlockScreenshots) ?? true;

  final AuthService _authService = AuthService();
  final DeviceStateService _deviceStateService = DeviceStateService();

  bool _isAppLockEnabled = false;
  bool _isPhoneLockQuickUnlockEnabled = false;
  int _autoLockTimeout = 60;
  int _syncHostIdleTimeout = AppConstants.syncHostIdleTimeoutDefault;
  String _sortBy = AppConstants.defaultSortBy;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  bool _isLocked = false;
  bool _hasPinSet = false;
  int _lastActiveTime = 0;
  int _lastStrongAuthAtMs = 0;
  int _quickUnlockFailureCount = 0;
  bool _lockdownEnabled = false;
  bool _blockScreenshots = true;
  int? _lastKnownBootCount;
  int? _currentBootCount;
  PinRequiredReason _pinRequiredReason = PinRequiredReason.none;
  Timer? _autoLockTimer;
  bool _isBackupInProgress = false;
  bool _isSyncInProgress = false;

  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get phoneLockQuickUnlockEnabled => _isPhoneLockQuickUnlockEnabled;
  int get autoLockTimeout => _autoLockTimeout;
  int get syncHostIdleTimeout => _syncHostIdleTimeout;
  String get sortBy => _sortBy;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isLocked => _isLocked;
  bool get hasPinSet => _hasPinSet;
  bool get lockdownEnabled => _lockdownEnabled;
  bool get blockScreenshots => _blockScreenshots;
  PinRequiredReason get pinRequiredReason => _pinRequiredReason;
  bool get hasAnyUnlockMethod => _hasPinSet || _isPhoneLockQuickUnlockEnabled;
  bool get requiresAppPinForUnlock => _hasPinSet && !canUsePhoneLockQuickUnlock;
  bool get canUsePhoneLockQuickUnlock =>
      _isAppLockEnabled &&
      _isPhoneLockQuickUnlockEnabled &&
      _pinRequiredReason == PinRequiredReason.none;

  UnlockInstruction get unlockInstruction {
    if (canUsePhoneLockQuickUnlock) {
      if (!_hasPinSet) {
        return UnlockInstruction.phoneLockOnly;
      }
      return UnlockInstruction.phoneLockOrPin;
    }
    return UnlockInstruction.pinOnly;
  }

  void setBackupInProgress(bool value) {
    _isBackupInProgress = value;
    if (!value && _isAppLockEnabled && !_isLocked) {
      _updateLastActiveTime();
      _startAutoLockTimer();
    }
  }

  /// Suppress idle/background auto-lock while a P2P sync session is active, so a
  /// host waiting for a peer is not locked out mid-transfer. Mirrors
  /// [setBackupInProgress]; the sync screen sets this on entry and clears it on
  /// exit. Clearing it while unlocked refreshes activity and restarts the timer.
  void setSyncInProgress(bool value) {
    _isSyncInProgress = value;
    if (!value && _isAppLockEnabled && !_isLocked) {
      _updateLastActiveTime();
      _startAutoLockTimer();
    }
  }

  late final Future<void> initialized;

  SettingsProvider() {
    initialized = _loadSettings();
  }

  @override
  void dispose() {
    _autoLockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isAppLockEnabled = prefs.getBool(_keyAppLockEnabled) ?? false;
    _autoLockTimeout = prefs.getInt(_keyAutoLockTimeout) ?? 60;
    _syncHostIdleTimeout = _clampSyncHostIdleTimeout(
      prefs.getInt(_keySyncHostIdleTimeout) ??
          AppConstants.syncHostIdleTimeoutDefault,
    );
    _sortBy = _normalizeSortBy(prefs.getString(_keySortBy));
    _lastActiveTime = prefs.getInt(_keyLastActiveTime) ?? 0;
    _lastStrongAuthAtMs = prefs.getInt(_keyLastStrongAuthAtMs) ?? 0;
    _quickUnlockFailureCount = prefs.getInt(_keyQuickUnlockFailureCount) ?? 0;
    _lockdownEnabled = prefs.getBool(_keyLockdownEnabled) ?? false;
    _blockScreenshots = readBlockScreenshots(prefs);
    _lastKnownBootCount = prefs.getInt(_keyLastKnownBootCount);
    _pinRequiredReason = _reasonFromString(
      prefs.getString(_keyPinRequiredReason),
    );

    if (prefs.containsKey(_legacyKeyAppLockPin)) {
      await prefs.remove(_legacyKeyAppLockPin);
    }

    _hasPinSet = await _authService.hasPin();

    _isPhoneLockQuickUnlockEnabled =
        prefs.getBool(_keyPhoneLockQuickUnlockEnabled) ?? false;

    if (_isAppLockEnabled && !hasAnyUnlockMethod) {
      _isAppLockEnabled = false;
      await prefs.setBool(_keyAppLockEnabled, false);
    }

    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    _updateDarkMode();

    _currentBootCount = await _deviceStateService.getBootCount();

    if (_isAppLockEnabled && hasAnyUnlockMethod) {
      _isLocked = true;
    } else {
      _isLocked = false;
    }

    await reevaluateUnlockPolicy(notify: false);
    notifyListeners();
  }

  PinRequiredReason _reasonFromString(String? value) {
    switch (value) {
      case 'idleTimeout':
        return PinRequiredReason.idleTimeout;
      case 'reboot':
        return PinRequiredReason.reboot;
      case 'quickUnlockFailures':
        return PinRequiredReason.quickUnlockFailures;
      case 'lockdown':
        return PinRequiredReason.lockdown;
      default:
        return PinRequiredReason.none;
    }
  }

  String _reasonToString(PinRequiredReason reason) {
    switch (reason) {
      case PinRequiredReason.idleTimeout:
        return 'idleTimeout';
      case PinRequiredReason.reboot:
        return 'reboot';
      case PinRequiredReason.quickUnlockFailures:
        return 'quickUnlockFailures';
      case PinRequiredReason.lockdown:
        return 'lockdown';
      case PinRequiredReason.none:
        return 'none';
    }
  }

  Future<void> _persistAdaptiveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastStrongAuthAtMs, _lastStrongAuthAtMs);
    await prefs.setInt(_keyQuickUnlockFailureCount, _quickUnlockFailureCount);
    await prefs.setBool(_keyLockdownEnabled, _lockdownEnabled);
    await prefs.setString(
      _keyPinRequiredReason,
      _reasonToString(_pinRequiredReason),
    );

    if (_lastKnownBootCount == null) {
      await prefs.remove(_keyLastKnownBootCount);
    } else {
      await prefs.setInt(_keyLastKnownBootCount, _lastKnownBootCount!);
    }
  }

  void _updateDarkMode() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && brightness == Brightness.dark);
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    if (enabled && !_hasPinSet && !_isPhoneLockQuickUnlockEnabled) {
      return;
    }

    _isAppLockEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);

    if (!enabled) {
      _isPhoneLockQuickUnlockEnabled = false;
      _lockdownEnabled = false;
      _lastStrongAuthAtMs = 0;
      _quickUnlockFailureCount = 0;
      _lastKnownBootCount = null;
      _pinRequiredReason = PinRequiredReason.none;
      await prefs.setBool(_keyPhoneLockQuickUnlockEnabled, false);
      await setAppLockPin(null);
      await setLocked(false);
      _stopAutoLockTimer();
    } else {
      await handleSuccessfulAppPinUnlock(notify: false);
      await setLocked(false);
      _startAutoLockTimer();
    }

    await _persistAdaptiveState();
    notifyListeners();
  }

  Future<void> setPhoneLockQuickUnlockEnabled(bool enabled) async {
    _isPhoneLockQuickUnlockEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPhoneLockQuickUnlockEnabled, enabled);

    await reevaluateUnlockPolicy(notify: false);
    notifyListeners();
  }

  Future<void> setLockdownEnabled(bool enabled) async {
    _lockdownEnabled = enabled;
    await reevaluateUnlockPolicy(notify: false);
    notifyListeners();
  }

  /// Applies the change to the window first, and saves it only if that worked.
  Future<void> setBlockScreenshots(bool enabled) async {
    if (enabled) {
      await enableScreenProtection();
    } else {
      await disableScreenProtection();
    }
    _blockScreenshots = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBlockScreenshots, enabled);

    notifyListeners();
  }

  /// Deletes all app data, then reads the settings back from the now empty
  /// stores, so memory matches what is really left. Screenshot blocking returns
  /// to on. Returns false if something could not be deleted or protection could
  /// not be turned back on; the user can try again.
  Future<bool> deleteAllData({DataWipeService? wipeService}) async {
    _stopAutoLockTimer();
    var success = await (wipeService ?? DataWipeService()).wipeAll();
    OTPService.clearCache();

    await _loadSettings();
    if (_blockScreenshots) {
      try {
        await enableScreenProtection();
      } catch (e) {
        AppLogger.error('Could not turn screen protection back on', e);
        success = false;
      }
    }
    return success;
  }

  Future<void> setAutoLockTimeout(int seconds) async {
    _autoLockTimeout = seconds;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoLockTimeout, seconds);

    if (_isAppLockEnabled) {
      _startAutoLockTimer();
    }

    notifyListeners();
  }

  int _clampSyncHostIdleTimeout(int seconds) => seconds.clamp(
    AppConstants.syncHostIdleTimeoutMin,
    AppConstants.syncHostIdleTimeoutMax,
  );

  Future<void> setSyncHostIdleTimeout(int seconds) async {
    _syncHostIdleTimeout = _clampSyncHostIdleTimeout(seconds);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySyncHostIdleTimeout, _syncHostIdleTimeout);

    notifyListeners();
  }

  /// Validate a stored/incoming sort value, falling back to the default when it
  /// is null or not a recognized option.
  String _normalizeSortBy(String? value) {
    if (value != null && AppConstants.sortByOptions.contains(value)) {
      return value;
    }
    return AppConstants.defaultSortBy;
  }

  Future<void> setSortBy(String value) async {
    // Ignore unrecognized values so a bad input never changes the current sort.
    if (!AppConstants.sortByOptions.contains(value)) return;
    if (value == _sortBy) return;
    _sortBy = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySortBy, value);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateDarkMode();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);

    notifyListeners();
  }

  /// The only settings that ever cross devices during a P2P sync. Everything
  /// else on this provider (app lock, App PIN, phone-lock/biometric unlock,
  /// recovery key, lockdown, boot/adaptive-auth state) is device-specific and is
  /// deliberately excluded. See docs/security.md.
  Map<String, dynamic> syncableSettingsSnapshot() => {
    AppConstants.syncSettingThemeMode: _themeMode.index,
    AppConstants.syncSettingAutoLockTimeout: _autoLockTimeout,
    AppConstants.syncSettingSyncHostIdleTimeout: _syncHostIdleTimeout,
  };

  /// Apply settings received from a peer. When [overwrite] is false (incremental
  /// sync) a value is applied only if this device has not already set that key,
  /// so the receiver's own choices always win — nothing is overridden. When
  /// [overwrite] is true (full sync to a fresh device) values are applied
  /// outright. Unknown keys and malformed values are ignored. Returns the number
  /// of settings actually applied.
  Future<int> applySyncedSettings(
    Map<String, dynamic> settings, {
    required bool overwrite,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var applied = 0;

    Future<bool> shouldApply(String prefKey) async =>
        overwrite || !prefs.containsKey(prefKey);

    final themeValue = settings[AppConstants.syncSettingThemeMode];
    if (themeValue is int &&
        themeValue >= 0 &&
        themeValue < ThemeMode.values.length &&
        await shouldApply(_keyThemeMode)) {
      await setThemeMode(ThemeMode.values[themeValue]);
      applied++;
    }

    final autoLockValue = settings[AppConstants.syncSettingAutoLockTimeout];
    if (autoLockValue is int &&
        autoLockValue >= 0 &&
        await shouldApply(_keyAutoLockTimeout)) {
      await setAutoLockTimeout(autoLockValue);
      applied++;
    }

    final idleValue = settings[AppConstants.syncSettingSyncHostIdleTimeout];
    if (idleValue is int && await shouldApply(_keySyncHostIdleTimeout)) {
      // setSyncHostIdleTimeout clamps to the allowed range.
      await setSyncHostIdleTimeout(idleValue);
      applied++;
    }

    return applied;
  }

  Future<void> setLocked(bool locked) async {
    _isLocked = locked;

    if (!locked) {
      await _updateLastActiveTime();
      _startAutoLockTimer();
    } else {
      _stopAutoLockTimer();
    }

    notifyListeners();
  }

  Future<void> setAppLockPin(String? pin) async {
    if (pin != null) {
      await _authService.setPin(pin);
      _hasPinSet = true;
      await handleSuccessfulAppPinUnlock(notify: false);
    } else {
      await _authService.clearPin();
      _hasPinSet = false;
      _lastStrongAuthAtMs = 0;
      _quickUnlockFailureCount = 0;
      _lastKnownBootCount = null;
      _pinRequiredReason = PinRequiredReason.none;
    }

    await _persistAdaptiveState();
    notifyListeners();
  }

  Future<bool> verifyPin(String enteredPin) async {
    final lockout = await _authService.getLockoutRemainingSeconds();
    if (lockout > 0) return false;

    final valid = await _authService.validatePin(enteredPin);
    if (valid) {
      await _authService.resetFailedPinAttempts();
    } else {
      await _authService.recordFailedPinAttempt();
    }
    return valid;
  }

  Future<int> getLockoutRemainingSeconds() =>
      _authService.getLockoutRemainingSeconds();

  Future<int> getFailedAttempts() => _authService.getFailedAttempts();

  Future<String> generateRecoveryKey() => _authService.generateRecoveryKey();

  Future<bool> validateAndResetWithRecoveryKey(String recoveryKey) async {
    final valid = await _authService.validateRecoveryKey(recoveryKey);
    if (valid) {
      await _authService.clearPin();
      await _authService.resetFailedPinAttempts();
      _hasPinSet = false;
      _lastStrongAuthAtMs = 0;
      _quickUnlockFailureCount = 0;
      _pinRequiredReason = PinRequiredReason.none;
      await _persistAdaptiveState();
      notifyListeners();
    }
    return valid;
  }

  Future<bool> hasRecoveryKey() => _authService.hasRecoveryKey();

  Future<void> handleQuickUnlockResult(LocalAuthResult result) async {
    if (result.outcome == LocalAuthOutcome.success) {
      _quickUnlockFailureCount = 0;
    } else if (result.outcome == LocalAuthOutcome.failure) {
      _quickUnlockFailureCount += 1;
    }

    await reevaluateUnlockPolicy(notify: false);
    notifyListeners();
  }

  Future<void> handleSuccessfulAppPinUnlock({bool notify = true}) async {
    _lastStrongAuthAtMs = DateTime.now().millisecondsSinceEpoch;
    _quickUnlockFailureCount = 0;
    _currentBootCount ??= await _deviceStateService.getBootCount();
    _lastKnownBootCount = _currentBootCount;
    if (!_lockdownEnabled) {
      _pinRequiredReason = PinRequiredReason.none;
    }

    await _persistAdaptiveState();
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> reevaluateUnlockPolicy({bool notify = true}) async {
    if (!_isAppLockEnabled) {
      _pinRequiredReason = PinRequiredReason.none;
      await _persistAdaptiveState();
      if (notify) notifyListeners();
      return;
    }

    _currentBootCount ??= await _deviceStateService.getBootCount();

    if (!_hasPinSet) {
      _pinRequiredReason = PinRequiredReason.none;
    } else if (_lockdownEnabled) {
      _pinRequiredReason = PinRequiredReason.lockdown;
    } else if (_currentBootCount != null &&
        _lastKnownBootCount != null &&
        _currentBootCount != _lastKnownBootCount) {
      _pinRequiredReason = PinRequiredReason.reboot;
    } else if (_lastStrongAuthAtMs == 0 ||
        DateTime.now().millisecondsSinceEpoch - _lastStrongAuthAtMs >=
            AppConstants.strongAuthTimeout.inMilliseconds) {
      _pinRequiredReason = PinRequiredReason.idleTimeout;
    } else if (_quickUnlockFailureCount >=
        AppConstants.maxQuickUnlockAttempts) {
      _pinRequiredReason = PinRequiredReason.quickUnlockFailures;
    } else {
      _pinRequiredReason = PinRequiredReason.none;
    }

    await _persistAdaptiveState();
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _updateLastActiveTime() async {
    _lastActiveTime = DateTime.now().millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastActiveTime, _lastActiveTime);
  }

  Future<void> onAppResumed() async {
    await reevaluateUnlockPolicy(notify: false);

    if (!_isLocked) {
      await _updateLastActiveTime();
      _startAutoLockTimer();
    }

    notifyListeners();
  }

  Future<void> onAppPaused() async {
    if (_isBackupInProgress) return;
    if (_isSyncInProgress) return;

    if (_isAppLockEnabled && hasAnyUnlockMethod) {
      await _updateLastActiveTime();
      _stopAutoLockTimer();

      _isLocked = true;
      OTPService.clearCache();
      notifyListeners();
    }
  }

  Future<void> _checkAutoLock() async {
    if (_isBackupInProgress) return;
    if (_isSyncInProgress) return;
    if (!_isAppLockEnabled) return;
    if (!hasAnyUnlockMethod) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDiff = (currentTime - _lastActiveTime) ~/ 1000;

    if (_autoLockTimeout == 0 || timeDiff >= _autoLockTimeout) {
      _isLocked = true;
      OTPService.clearCache();
      notifyListeners();
    }
  }

  void _startAutoLockTimer() {
    _stopAutoLockTimer();

    if (!_isAppLockEnabled) {
      return;
    }

    if (!hasAnyUnlockMethod) {
      return;
    }

    if (_autoLockTimeout == 0) {
      return;
    }

    final elapsed =
        (DateTime.now().millisecondsSinceEpoch - _lastActiveTime) ~/ 1000;
    final remaining = _autoLockTimeout - elapsed;

    if (remaining <= 0) {
      _isLocked = true;
      OTPService.clearCache();
      notifyListeners();
      return;
    }

    _autoLockTimer = Timer(Duration(seconds: remaining), () {
      if (_isBackupInProgress) return;
      if (_isSyncInProgress) return;
      _isLocked = true;
      OTPService.clearCache();
      _autoLockTimer = null;
      notifyListeners();
    });
  }

  void _stopAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;
  }

  Future<void> resetActivityTimer() async {
    if (_isAppLockEnabled && !_isLocked) {
      await _updateLastActiveTime();
    }
  }

  void checkAndLockApp() {
    if (_isAppLockEnabled && hasAnyUnlockMethod) {
      _checkAutoLock();
    }
  }
}
