// File Path: sreerajp_authenticator/lib/providers/settings_provider.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2026 April 05
// Description: Provider for app settings, app lock state, and adaptive authentication policy

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/device_state_service.dart';
import '../services/otp_service.dart';
import '../utils/constants.dart';

enum PinRequiredReason {
  none,
  idleTimeout,
  reboot,
  quickUnlockFailures,
  lockdown,
}

class SettingsProvider extends ChangeNotifier {
  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPhoneLockQuickUnlockEnabled =
      'phone_lock_quick_unlock_enabled';
  static const String _keyAutoLockTimeout = 'auto_lock_timeout';
  static const String _keyExportFormat = 'export_format';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyRequireAuth = 'require_authentication';
  static const String _keyLastActiveTime = 'last_active_time';
  static const String _keyLegacyLockType = 'lock_type';
  static const String _keyLastStrongAuthAtMs = 'last_strong_auth_at_ms';
  static const String _keyQuickUnlockFailureCount =
      'quick_unlock_failure_count';
  static const String _keyLockdownEnabled = 'lockdown_enabled';
  static const String _keyLastKnownBootCount = 'last_known_boot_count';
  static const String _keyPinRequiredReason = 'pin_required_reason';
  static const String _legacyKeyAppLockPin = 'app_lock_pin';

  final AuthService _authService = AuthService();
  final DeviceStateService _deviceStateService = DeviceStateService();

  bool _isAppLockEnabled = false;
  bool _isPhoneLockQuickUnlockEnabled = false;
  int _autoLockTimeout = 60;
  String _exportFormat = 'json';
  ThemeMode _themeMode = ThemeMode.system;
  bool _requireAuthentication = false;
  bool _isDarkMode = false;
  bool _isLocked = false;
  bool _hasPinSet = false;
  bool _needsMandatoryPinMigration = false;
  int _lastActiveTime = 0;
  int _lastStrongAuthAtMs = 0;
  int _quickUnlockFailureCount = 0;
  bool _lockdownEnabled = false;
  int? _lastKnownBootCount;
  int? _currentBootCount;
  PinRequiredReason _pinRequiredReason = PinRequiredReason.none;
  Timer? _autoLockTimer;
  bool _isBackupInProgress = false;

  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get phoneLockQuickUnlockEnabled => _isPhoneLockQuickUnlockEnabled;
  bool get isBiometricEnabled => _isPhoneLockQuickUnlockEnabled;
  int get autoLockTimeout => _autoLockTimeout;
  String get exportFormat => _exportFormat;
  ThemeMode get themeMode => _themeMode;
  bool get requireAuthentication => _requireAuthentication;
  bool get isDarkMode => _isDarkMode;
  bool get isLocked => _isLocked;
  bool get hasPinSet => _hasPinSet;
  String get lockType =>
      _isPhoneLockQuickUnlockEnabled ? 'device_lock' : 'app_pin';
  bool get isBackupInProgress => _isBackupInProgress;
  bool get lockdownEnabled => _lockdownEnabled;
  PinRequiredReason get pinRequiredReason => _pinRequiredReason;
  bool get adaptiveAuthAvailable => _isAppLockEnabled && _hasPinSet;
  bool get hasQuickUnlockAvailable => _isPhoneLockQuickUnlockEnabled;
  bool get needsMandatoryPinMigrationSync => _needsMandatoryPinMigration;
  bool get requiresAppPinForUnlock => !canUsePhoneLockQuickUnlock;
  bool get canUsePhoneLockQuickUnlock =>
      _isAppLockEnabled &&
      _hasPinSet &&
      !_needsMandatoryPinMigration &&
      _isPhoneLockQuickUnlockEnabled &&
      _pinRequiredReason == PinRequiredReason.none;

  String get unlockInstructionText {
    if (_needsMandatoryPinMigration) {
      return 'Use your Phone Screen Lock to set up your App PIN';
    }
    if (canUsePhoneLockQuickUnlock) {
      return 'Use your Phone Screen Lock or enter your App PIN';
    }
    return 'Enter your App PIN';
  }

  String get pinRequiredMessage {
    switch (_pinRequiredReason) {
      case PinRequiredReason.idleTimeout:
        return 'App PIN required after 1 hour';
      case PinRequiredReason.reboot:
        return 'App PIN required after device restart';
      case PinRequiredReason.quickUnlockFailures:
        return 'App PIN required after 3 failed phone lock attempts';
      case PinRequiredReason.lockdown:
        return 'Lockdown mode is on. Enter your App PIN';
      case PinRequiredReason.none:
        return '';
    }
  }

  void setBackupInProgress(bool value) {
    _isBackupInProgress = value;
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
    _exportFormat = prefs.getString(_keyExportFormat) ?? 'json';
    _requireAuthentication = prefs.getBool(_keyRequireAuth) ?? false;
    _lastActiveTime = prefs.getInt(_keyLastActiveTime) ?? 0;
    _lastStrongAuthAtMs = prefs.getInt(_keyLastStrongAuthAtMs) ?? 0;
    _quickUnlockFailureCount =
        prefs.getInt(_keyQuickUnlockFailureCount) ?? 0;
    _lockdownEnabled = prefs.getBool(_keyLockdownEnabled) ?? false;
    _lastKnownBootCount = prefs.getInt(_keyLastKnownBootCount);
    _pinRequiredReason = _reasonFromString(
      prefs.getString(_keyPinRequiredReason),
    );

    if (prefs.containsKey(_legacyKeyAppLockPin)) {
      await prefs.remove(_legacyKeyAppLockPin);
    }

    _hasPinSet = await _authService.hasPin();

    final hasQuickUnlockPref = prefs.containsKey(
      _keyPhoneLockQuickUnlockEnabled,
    );
    final legacyBiometricEnabled = prefs.getBool(_keyBiometricEnabled) ?? false;
    final legacyLockType = prefs.getString(_keyLegacyLockType);

    if (hasQuickUnlockPref) {
      _isPhoneLockQuickUnlockEnabled =
          prefs.getBool(_keyPhoneLockQuickUnlockEnabled) ?? false;
    } else {
      _isPhoneLockQuickUnlockEnabled =
          legacyLockType == 'device_lock' || legacyBiometricEnabled;
      await prefs.setBool(
        _keyPhoneLockQuickUnlockEnabled,
        _isPhoneLockQuickUnlockEnabled,
      );
    }

    _needsMandatoryPinMigration =
        _isAppLockEnabled && !_hasPinSet && legacyLockType == 'device_lock';
    if (!_hasPinSet && !_needsMandatoryPinMigration) {
      _isPhoneLockQuickUnlockEnabled = false;
    }

    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    _updateDarkMode();

    _currentBootCount = await _deviceStateService.getBootCount();

    if (_isAppLockEnabled && (_hasPinSet || _needsMandatoryPinMigration)) {
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

  Future<void> setLockType(String type) async {
    await setPhoneLockQuickUnlockEnabled(type == 'device_lock');
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    if (enabled && !_hasPinSet) {
      return;
    }

    _isAppLockEnabled = enabled;
    _requireAuthentication = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);
    await prefs.setBool(_keyRequireAuth, enabled);

    if (!enabled) {
      _isPhoneLockQuickUnlockEnabled = false;
      _lockdownEnabled = false;
      _lastStrongAuthAtMs = 0;
      _quickUnlockFailureCount = 0;
      _lastKnownBootCount = null;
      _pinRequiredReason = PinRequiredReason.none;
      _needsMandatoryPinMigration = false;
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
    await prefs.setBool(_keyBiometricEnabled, enabled);

    await reevaluateUnlockPolicy(notify: false);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await setPhoneLockQuickUnlockEnabled(enabled);
  }

  Future<void> setLockdownEnabled(bool enabled) async {
    _lockdownEnabled = enabled;
    await reevaluateUnlockPolicy(notify: false);
    notifyListeners();
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

  Future<void> setExportFormat(String format) async {
    _exportFormat = format;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExportFormat, format);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateDarkMode();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);

    notifyListeners();
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
      _needsMandatoryPinMigration = false;
      await handleSuccessfulAppPinUnlock(notify: false);
    } else {
      await _authService.clearPin();
      _hasPinSet = false;
      _needsMandatoryPinMigration = false;
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

  Future<bool> needsMandatoryPinMigration() async => _needsMandatoryPinMigration;

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

    if (_needsMandatoryPinMigration || !_hasPinSet) {
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

    if (_isAppLockEnabled && (_hasPinSet || _needsMandatoryPinMigration)) {
      await _updateLastActiveTime();
      _stopAutoLockTimer();

      _isLocked = true;
      OTPService.clearCache();
      notifyListeners();
    }
  }

  Future<void> _checkAutoLock() async {
    if (_isBackupInProgress) return;
    if (!_isAppLockEnabled) return;
    if (!_hasPinSet && !_needsMandatoryPinMigration) return;

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

    if (!_hasPinSet && !_needsMandatoryPinMigration) {
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
    if (_isAppLockEnabled && (_hasPinSet || _needsMandatoryPinMigration)) {
      _checkAutoLock();
    }
  }
}
