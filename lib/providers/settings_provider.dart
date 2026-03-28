// File Path: sreerajp_authenticator/lib/providers/settings_provider.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2025 October 14
// Description: Provider for managing app settings including security, theme, and export preferences with auto-lock functionality

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/otp_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyAutoLockTimeout = 'auto_lock_timeout';
  static const String _keyExportFormat = 'export_format';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyRequireAuth = 'require_authentication';
  static const String _keyLastActiveTime = 'last_active_time';
  static const String _keyLockType = 'lock_type'; // 'app_pin' or 'device_lock'
  // Legacy key — only used during migration cleanup on first load
  static const String _legacyKeyAppLockPin = 'app_lock_pin';

  final AuthService _authService = AuthService();

  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  int _autoLockTimeout = 60; // seconds
  String _exportFormat = 'json'; // json, csv, encrypted
  ThemeMode _themeMode = ThemeMode.system;
  bool _requireAuthentication = false;
  bool _isDarkMode = false;
  bool _isLocked = false;
  bool _hasPinSet = false;
  int _lastActiveTime = 0;
  Timer? _autoLockTimer;
  String _lockType = 'app_pin'; // or 'device_lock'
  bool _isBackupInProgress = false;

  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  int get autoLockTimeout => _autoLockTimeout;
  String get exportFormat => _exportFormat;
  ThemeMode get themeMode => _themeMode;
  bool get requireAuthentication => _requireAuthentication;
  bool get isDarkMode => _isDarkMode;
  bool get isLocked => _isLocked;
  bool get hasPinSet => _hasPinSet;
  String get lockType => _lockType;
  bool get isBackupInProgress => _isBackupInProgress;

  void setBackupInProgress(bool value) {
    _isBackupInProgress = value;
    if (!value && _isAppLockEnabled && !_isLocked) {
      _updateLastActiveTime();
      _startAutoLockTimer();
    }
  }

  /// Completes once [_loadSettings] has finished so callers can await
  /// the provider being fully ready before making lock-state decisions.
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
    _isBiometricEnabled = prefs.getBool(_keyBiometricEnabled) ?? false;
    _autoLockTimeout = prefs.getInt(_keyAutoLockTimeout) ?? 60;
    _exportFormat = prefs.getString(_keyExportFormat) ?? 'json';
    _requireAuthentication = prefs.getBool(_keyRequireAuth) ?? false;
    _lastActiveTime = prefs.getInt(_keyLastActiveTime) ?? 0;
    _lockType = prefs.getString(_keyLockType) ?? 'app_pin';

    // Migrate: erase any legacy plaintext PIN that may exist from older versions
    if (prefs.containsKey(_legacyKeyAppLockPin)) {
      await prefs.remove(_legacyKeyAppLockPin);
    }

    // Check whether a hashed PIN is stored via AuthService
    _hasPinSet = await _authService.hasPin();

    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    // Determine dark mode based on theme mode
    _updateDarkMode();

    // On cold start, if app lock is enabled, ALWAYS lock the app
    if (_isAppLockEnabled &&
        (_hasPinSet || _lockType == 'device_lock')) {
      _isLocked = true; // Always lock on app startup
    } else {
      _isLocked = false;
    }

    notifyListeners();
  }

  void _updateDarkMode() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && brightness == Brightness.dark);
  }

  Future<void> setLockType(String type) async {
    _lockType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLockType, type);

    // Clear app PIN if switching to device lock
    if (type == 'device_lock') {
      await setAppLockPin(null);
    }

    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    _isAppLockEnabled = enabled;
    _requireAuthentication = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);
    await prefs.setBool(_keyRequireAuth, enabled);

    // If disabling app lock, also disable biometric and clear PIN
    if (!enabled) {
      await setBiometricEnabled(false);
      await setAppLockPin(null);
      await setLocked(false);
      _stopAutoLockTimer();
    } else {
      await setLocked(true);
      // If enabling, start auto-lock monitoring
      _startAutoLockTimer();
    }

    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);

    notifyListeners();
  }

  Future<void> setAutoLockTimeout(int seconds) async {
    _autoLockTimeout = seconds;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoLockTimeout, seconds);

    // Restart timer with new timeout
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
      // App unlocked, update last active time and start timer
      await _updateLastActiveTime();
      _startAutoLockTimer();
    } else {
      // App locked, stop timer
      _stopAutoLockTimer();
    }

    notifyListeners();
  }

  Future<void> setAppLockPin(String? pin) async {
    if (pin != null) {
      await _authService.setPin(pin);
      _hasPinSet = true;
    } else {
      await _authService.clearPin();
      _hasPinSet = false;
    }

    notifyListeners();
  }

  // Method to verify PIN — checks lockout, delegates hash comparison to AuthService,
  // and records success/failure for brute-force tracking.
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

  /// Remaining lockout seconds (0 = not locked out).
  Future<int> getLockoutRemainingSeconds() =>
      _authService.getLockoutRemainingSeconds();

  /// Consecutive failed PIN attempts so far.
  Future<int> getFailedAttempts() => _authService.getFailedAttempts();

  // ─── Recovery key ──────────────────────────────────────────────────────────

  /// Generates a new recovery key and returns the plaintext for the user to save.
  Future<String> generateRecoveryKey() => _authService.generateRecoveryKey();

  /// Validates the user-entered recovery key and, if valid, resets the PIN
  /// and lockout state so the user can set a new PIN.
  Future<bool> validateAndResetWithRecoveryKey(String recoveryKey) async {
    final valid = await _authService.validateRecoveryKey(recoveryKey);
    if (valid) {
      await _authService.clearPin();
      await _authService.resetFailedPinAttempts();
      _hasPinSet = false;
      notifyListeners();
    }
    return valid;
  }

  /// Whether a recovery key has been set up.
  Future<bool> hasRecoveryKey() => _authService.hasRecoveryKey();

  // Update last active time
  Future<void> _updateLastActiveTime() async {
    _lastActiveTime = DateTime.now().millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastActiveTime, _lastActiveTime);
  }

  // Called when app comes to foreground
  Future<void> onAppResumed() async {
    // When app resumes from background, it should already be locked (from onAppPaused)
    // Don't force lock here - that would immediately re-lock after internal unlock!
    // Just handle timer management for unlocked state

    if (!_isLocked) {
      // App is currently unlocked, reset activity timer
      await _updateLastActiveTime();
      _startAutoLockTimer();
    }
    // If app is locked, do nothing - user must authenticate via LockScreen
  }

  // Called when app goes to background
  Future<void> onAppPaused() async {
    if (_isBackupInProgress) return;

    if (_isAppLockEnabled &&
        (_hasPinSet || _lockType == 'device_lock')) {
      await _updateLastActiveTime();
      _stopAutoLockTimer();

      _isLocked = true;
      OTPService.clearCache();
      notifyListeners();
    }
  }

  // Check if app should be locked based on timeout
  Future<void> _checkAutoLock() async {
    if (_isBackupInProgress) return;
    if (!_isAppLockEnabled) return;
    if (_lockType == 'app_pin' && !_hasPinSet) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDiff = (currentTime - _lastActiveTime) ~/ 1000; // in seconds

    // If timeout is 0 (immediately) or time difference exceeds timeout, lock the app
    if (_autoLockTimeout == 0 || timeDiff >= _autoLockTimeout) {
      _isLocked = true;
      OTPService.clearCache();
      notifyListeners();
    }
  }

  // Start auto-lock timer
  void _startAutoLockTimer() {
    _stopAutoLockTimer();

    if (!_isAppLockEnabled) {
      return;
    }

    if (_lockType == 'app_pin' && !_hasPinSet) {
      return;
    }

    // For immediate timeout, don't start a timer
    if (_autoLockTimeout == 0) {
      // With 0 timeout, app should lock immediately when going to background
      // No timer needed, just ensure onAppPaused locks the app
      return;
    }

    // Calculate remaining time until lock, accounting for time already elapsed
    final elapsed = (DateTime.now().millisecondsSinceEpoch - _lastActiveTime) ~/ 1000;
    final remaining = _autoLockTimeout - elapsed;

    if (remaining <= 0) {
      // Already past timeout
      _isLocked = true;
      OTPService.clearCache();
      notifyListeners();
      return;
    }

    // Fire once at the exact timeout moment
    _autoLockTimer = Timer(Duration(seconds: remaining), () {
      if (_isBackupInProgress) return;
      _isLocked = true;
      OTPService.clearCache();
      _autoLockTimer = null;
      notifyListeners();
    });
  }

  // Stop auto-lock timer
  void _stopAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;
  }

  // Method to reset activity timer (call this on user interactions)
  Future<void> resetActivityTimer() async {
    if (_isAppLockEnabled && !_isLocked) {
      await _updateLastActiveTime();
    }
  }

  // Legacy method for backward compatibility
  void checkAndLockApp() {
    if (_isAppLockEnabled &&
        (_hasPinSet || _lockType == 'device_lock')) {
      _checkAutoLock();
    }
  }
}
