// File Path: sreerajp_authenticator/lib/services/auth_service.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2025 October 12
// Description: Service for handling authentication including biometric, PIN, and device lock

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // kept for one-time migration only
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

import '../utils/constants.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const _secureStorage = FlutterSecureStorage();

  static const String _pinKey = AppConstants.pinHashKey;
  static const String _pinSaltKey = AppConstants.pinSaltKey;
  static const String _pinVersionKey = AppConstants.pinVersionKey;
  static const String _failedAttemptsKey = AppConstants.failedAttemptsKey;
  static const String _lockoutUntilKey = AppConstants.lockoutUntilKey;
  static const String _migrationDoneKey = AppConstants.pinMigrationDoneKey;
  static const String _recoveryKeyHashKey = AppConstants.recoveryKeyHashKey;
  static const String _recoveryKeySaltKey = AppConstants.recoveryKeySaltKey;

  static const int _pbkdf2Iterations = AppConstants.pbkdf2Iterations;

  /// Maximum consecutive wrong PIN attempts before a lockout is imposed.
  static const int maxAttempts = AppConstants.maxPinAttempts;

  // ─── One-time migration: SharedPreferences → FlutterSecureStorage ──────────
  // Runs transparently on first call to hasPin() / validatePin().
  // Preserves any existing PIN hash so users are not logged out on upgrade.

  Future<void> _migrateLegacyPinIfNeeded() async {
    final already = await _secureStorage.read(key: _migrationDoneKey);
    if (already != null) return;

    final prefs = await SharedPreferences.getInstance();
    final oldHash = prefs.getString(_pinKey);
    if (oldHash != null) {
      await _secureStorage.write(key: _pinKey, value: oldHash);

      final oldSalt = prefs.getString(_pinSaltKey);
      if (oldSalt != null) {
        await _secureStorage.write(key: _pinSaltKey, value: oldSalt);
      }

      final oldVersion = prefs.getInt(_pinVersionKey);
      if (oldVersion != null) {
        await _secureStorage.write(key: _pinVersionKey, value: oldVersion.toString());
      }

      final oldAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
      if (oldAttempts > 0) {
        await _secureStorage.write(key: _failedAttemptsKey, value: oldAttempts.toString());
      }

      final oldLockout = prefs.getInt(_lockoutUntilKey) ?? 0;
      if (oldLockout > 0) {
        await _secureStorage.write(key: _lockoutUntilKey, value: oldLockout.toString());
      }

      // Erase sensitive data from SharedPreferences.
      await prefs.remove(_pinKey);
      await prefs.remove(_pinSaltKey);
      await prefs.remove(_pinVersionKey);
      await prefs.remove(_failedAttemptsKey);
      await prefs.remove(_lockoutUntilKey);
    }

    // Mark migration done (stored in secure storage itself).
    await _secureStorage.write(key: _migrationDoneKey, value: '1');
  }

  // ─── Biometric / device-lock authentication ─────────────────────────────────

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) return false;

      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your accounts',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  Future<bool> authenticateWithDeviceLock() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        debugPrint('Device lock not supported on this device');
        return false;
      }

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        debugPrint(
          'No device authentication available. Please set up a screen lock.',
        );
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock Authenticator with your device credentials',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: false,
      );

      return authenticated;
    } on PlatformException catch (e) {
      debugPrint(
        'Error during device lock authentication: ${e.code} - ${e.message}',
      );

      if (e.code == 'NotAvailable') {
        debugPrint(
          'Device lock not available. Please set up screen lock in device settings.',
        );
      } else if (e.code == 'NotEnrolled') {
        debugPrint('No authentication method enrolled.');
      } else if (e.code == 'LockedOut') {
        debugPrint('Too many failed attempts. Try again later.');
      }

      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final biometricAvailable = await isBiometricAvailable();
      if (biometricAvailable) {
        return await authenticateWithBiometric();
      }
      return false;
    } catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    }
  }

  // ─── PIN management ──────────────────────────────────────────────────────────

  Future<void> setPin(String pin) async {
    final rng = Random.secure();
    final salt = Uint8List.fromList(
      List.generate(AppConstants.saltSize, (_) => rng.nextInt(256)),
    );
    final hash = _pbkdf2Hash(pin, salt);

    await _secureStorage.write(key: _pinKey, value: base64Encode(hash));
    await _secureStorage.write(key: _pinSaltKey, value: base64Encode(salt));
    await _secureStorage.write(key: _pinVersionKey, value: AppConstants.currentPinVersion.toString());
  }

  Future<bool> validatePin(String pin) async {
    try {
      await _migrateLegacyPinIfNeeded();

      final storedHash = await _secureStorage.read(key: _pinKey);
      final salt = await _secureStorage.read(key: _pinSaltKey);

      if (storedHash == null || salt == null) return false;

      final versionStr = await _secureStorage.read(key: _pinVersionKey);
      final version = int.tryParse(versionStr ?? '1') ?? 1;

      if (version >= 2) {
        // Current PBKDF2 format
        final saltBytes = base64Decode(salt);
        final hash = _pbkdf2Hash(pin, Uint8List.fromList(saltBytes));
        return base64Encode(hash) == storedHash;
      } else {
        // Legacy: single SHA-256 with timestamp salt
        final bytes = utf8.encode(pin + salt);
        final hash = sha256.convert(bytes);
        final valid = hash.toString() == storedHash;

        // Migrate to PBKDF2 on successful validation
        if (valid) await setPin(pin);
        return valid;
      }
    } catch (e) {
      debugPrint('Error validating PIN: $e');
      return false;
    }
  }

  Uint8List _pbkdf2Hash(String pin, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), AppConstants.hmacBlockSize))
      ..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, AppConstants.pbkdf2HashSize));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(pin)));
  }

  Future<bool> hasPin() async {
    await _migrateLegacyPinIfNeeded();
    return await _secureStorage.read(key: _pinKey) != null;
  }

  Future<void> clearPin() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _pinVersionKey);
    await clearRecoveryKey();
    await resetFailedPinAttempts();
  }

  // ─── Recovery key management ────────────────────────────────────────────────

  /// Generates a recovery key, stores its PBKDF2 hash, and returns the
  /// plaintext key (formatted as XXXX-XXXX-XXXX-XXXX) for the user to save.
  /// This is the ONLY time the plaintext is available.
  Future<String> generateRecoveryKey() async {
    const chars = AppConstants.recoveryKeyCharset;
    final rng = Random.secure();
    final raw = List.generate(AppConstants.recoveryKeyLength, (_) => chars[rng.nextInt(chars.length)]).join();
    final formatted = '${raw.substring(0, 4)}-${raw.substring(4, 8)}-${raw.substring(8, 12)}-${raw.substring(12, 16)}';

    final salt = Uint8List.fromList(List.generate(AppConstants.saltSize, (_) => rng.nextInt(256)));
    final hash = _pbkdf2Hash(raw, salt);

    await _secureStorage.write(key: _recoveryKeyHashKey, value: base64Encode(hash));
    await _secureStorage.write(key: _recoveryKeySaltKey, value: base64Encode(salt));

    return formatted;
  }

  /// Validates a recovery key entered by the user.
  Future<bool> validateRecoveryKey(String enteredKey) async {
    try {
      final storedHash = await _secureStorage.read(key: _recoveryKeyHashKey);
      final storedSalt = await _secureStorage.read(key: _recoveryKeySaltKey);
      if (storedHash == null || storedSalt == null) return false;

      // Strip dashes and uppercase
      final normalized = enteredKey.replaceAll('-', '').toUpperCase();
      if (normalized.length != AppConstants.recoveryKeyLength) return false;

      final saltBytes = base64Decode(storedSalt);
      final hash = _pbkdf2Hash(normalized, Uint8List.fromList(saltBytes));
      return base64Encode(hash) == storedHash;
    } catch (e) {
      debugPrint('Error validating recovery key: $e');
      return false;
    }
  }

  /// Whether a recovery key has been set up.
  Future<bool> hasRecoveryKey() async {
    return await _secureStorage.read(key: _recoveryKeyHashKey) != null;
  }

  /// Removes the stored recovery key hash.
  Future<void> clearRecoveryKey() async {
    await _secureStorage.delete(key: _recoveryKeyHashKey);
    await _secureStorage.delete(key: _recoveryKeySaltKey);
  }

  // ─── Brute-force protection ───────────────────────────────────────────────

  /// Returns the number of consecutive failed PIN attempts.
  Future<int> getFailedAttempts() async {
    final val = await _secureStorage.read(key: _failedAttemptsKey);
    return int.tryParse(val ?? '0') ?? 0;
  }

  /// Returns seconds remaining in the current lockout, or 0 if not locked out.
  Future<int> getLockoutRemainingSeconds() async {
    final val = await _secureStorage.read(key: _lockoutUntilKey);
    final lockoutUntil = int.tryParse(val ?? '0') ?? 0;
    if (lockoutUntil == 0) return 0;
    final remainingMs = lockoutUntil - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) {
      await _secureStorage.delete(key: _lockoutUntilKey);
      return 0;
    }
    return (remainingMs / 1000).ceil();
  }

  /// Records a failed PIN attempt and applies a lockout if the threshold is reached.
  Future<void> recordFailedPinAttempt() async {
    final attempts = (await getFailedAttempts()) + 1;
    await _secureStorage.write(
      key: _failedAttemptsKey,
      value: attempts.toString(),
    );

    if (attempts >= maxAttempts) {
      final lockoutSeconds = _lockoutDurationSeconds(attempts);
      final lockoutUntil =
          DateTime.now().millisecondsSinceEpoch + lockoutSeconds * 1000;
      await _secureStorage.write(
        key: _lockoutUntilKey,
        value: lockoutUntil.toString(),
      );
    }
  }

  /// Clears the failed attempt counter and any active lockout (call on success).
  Future<void> resetFailedPinAttempts() async {
    await _secureStorage.delete(key: _failedAttemptsKey);
    await _secureStorage.delete(key: _lockoutUntilKey);
  }

  /// Lockout duration in seconds, escalating with each attempt beyond the threshold.
  int _lockoutDurationSeconds(int attempts) {
    if (attempts <= AppConstants.maxPinAttempts) return AppConstants.lockoutSeconds5Attempts;
    if (attempts == 6) return AppConstants.lockoutSeconds6Attempts;
    if (attempts == 7) return AppConstants.lockoutSeconds7Attempts;
    return AppConstants.lockoutSeconds8PlusAttempts;
  }

  Future<bool> isScreenLockEnabled() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking screen lock: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric (Weak)';
    }
    return 'Biometric';
  }
}
