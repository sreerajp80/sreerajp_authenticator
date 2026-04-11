// File Path: sreerajp_authenticator/lib/services/auth_service.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2026 April 05
// Description: Service for handling authentication including app PIN, phone lock, recovery, and lockouts

import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';
import '../utils/constants.dart';

Uint8List _derivePbkdf2Hash(String value, Uint8List salt) {
  final pbkdf2 =
      PBKDF2KeyDerivator(HMac(SHA256Digest(), AppConstants.hmacBlockSize))
        ..init(
          Pbkdf2Parameters(
            salt,
            AppConstants.pbkdf2Iterations,
            AppConstants.pbkdf2HashSize,
          ),
        );
  return pbkdf2.process(Uint8List.fromList(utf8.encode(value)));
}

enum LocalAuthOutcome {
  success,
  failure,
  canceled,
  lockedOut,
  notAvailable,
  error,
}

class LocalAuthResult {
  const LocalAuthResult(this.outcome, {this.code});

  final LocalAuthOutcome outcome;
  final String? code;

  bool get isSuccess => outcome == LocalAuthOutcome.success;
}

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

  static const int maxAttempts = AppConstants.maxPinAttempts;

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
        await _secureStorage.write(
          key: _pinVersionKey,
          value: oldVersion.toString(),
        );
      }

      final oldAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
      if (oldAttempts > 0) {
        await _secureStorage.write(
          key: _failedAttemptsKey,
          value: oldAttempts.toString(),
        );
      }

      final oldLockout = prefs.getInt(_lockoutUntilKey) ?? 0;
      if (oldLockout > 0) {
        await _secureStorage.write(
          key: _lockoutUntilKey,
          value: oldLockout.toString(),
        );
      }

      await prefs.remove(_pinKey);
      await prefs.remove(_pinSaltKey);
      await prefs.remove(_pinVersionKey);
      await prefs.remove(_failedAttemptsKey);
      await prefs.remove(_lockoutUntilKey);
    }

    await _secureStorage.write(key: _migrationDoneKey, value: '1');
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) return false;

      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      AppLogger.error('Failed to check biometric availability', e);
      return false;
    }
  }

  Future<bool> isPhoneLockQuickUnlockAvailable() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      AppLogger.error('Failed to check phone lock availability', e);
      return false;
    }
  }

  Future<LocalAuthResult> authenticateWithBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return const LocalAuthResult(LocalAuthOutcome.notAvailable);
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate with biometrics to access your accounts',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      return LocalAuthResult(
        authenticated ? LocalAuthOutcome.success : LocalAuthOutcome.failure,
      );
    } on PlatformException catch (e) {
      return LocalAuthResult(_mapPlatformException(e), code: e.code);
    }
  }

  Future<LocalAuthResult> authenticateWithPhoneLock() async {
    try {
      final isSupported = await isPhoneLockQuickUnlockAvailable();
      if (!isSupported) {
        return const LocalAuthResult(LocalAuthOutcome.notAvailable);
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock Authenticator with your Phone Screen Lock',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: false,
      );

      return LocalAuthResult(
        authenticated ? LocalAuthOutcome.success : LocalAuthOutcome.failure,
      );
    } on PlatformException catch (e) {
      return LocalAuthResult(_mapPlatformException(e), code: e.code);
    } catch (e) {
      AppLogger.error('Unexpected phone lock authentication failure', e);
      return const LocalAuthResult(LocalAuthOutcome.error);
    }
  }

  LocalAuthOutcome _mapPlatformException(PlatformException exception) {
    final code = exception.code.toLowerCase();

    if (code.contains('lockout') || code.contains('lockedout')) {
      return LocalAuthOutcome.lockedOut;
    }

    if (code.contains('cancel')) {
      return LocalAuthOutcome.canceled;
    }

    if (code.contains('notenrolled') ||
        code.contains('notavailable') ||
        code.contains('passcodenotset') ||
        code.contains('notsupported')) {
      return LocalAuthOutcome.notAvailable;
    }

    return LocalAuthOutcome.error;
  }

  Future<bool> authenticateWithDeviceLock() async {
    return (await authenticateWithPhoneLock()).isSuccess;
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      AppLogger.error('Failed to check local auth device support', e);
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      AppLogger.error('Failed to check biometric capability', e);
      return false;
    }
  }

  Future<bool> authenticate() async {
    return (await authenticateWithPhoneLock()).isSuccess;
  }

  Future<void> setPin(String pin) async {
    final rng = Random.secure();
    final salt = Uint8List.fromList(
      List.generate(AppConstants.saltSize, (_) => rng.nextInt(256)),
    );
    final hash = await _pbkdf2Hash(pin, salt);

    await _secureStorage.write(key: _pinKey, value: base64Encode(hash));
    await _secureStorage.write(key: _pinSaltKey, value: base64Encode(salt));
    await _secureStorage.write(
      key: _pinVersionKey,
      value: AppConstants.currentPinVersion.toString(),
    );
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
        final saltBytes = base64Decode(salt);
        final hash = await _pbkdf2Hash(pin, Uint8List.fromList(saltBytes));
        return base64Encode(hash) == storedHash;
      }

      final bytes = utf8.encode(pin + salt);
      final hash = sha256.convert(bytes);
      final valid = hash.toString() == storedHash;

      if (valid) {
        await setPin(pin);
      }
      return valid;
    } catch (e) {
      AppLogger.error('Failed to validate app PIN', e);
      return false;
    }
  }

  Future<Uint8List> _pbkdf2Hash(String value, Uint8List salt) {
    return Isolate.run(() => _derivePbkdf2Hash(value, salt));
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

  Future<String> generateRecoveryKey() async {
    const chars = AppConstants.recoveryKeyCharset;
    final rng = Random.secure();
    final raw = List.generate(
      AppConstants.recoveryKeyLength,
      (_) => chars[rng.nextInt(chars.length)],
    ).join();
    final formatted =
        '${raw.substring(0, 4)}-${raw.substring(4, 8)}-${raw.substring(8, 12)}-${raw.substring(12, 16)}';

    final salt = Uint8List.fromList(
      List.generate(AppConstants.saltSize, (_) => rng.nextInt(256)),
    );
    final hash = await _pbkdf2Hash(raw, salt);

    await _secureStorage.write(
      key: _recoveryKeyHashKey,
      value: base64Encode(hash),
    );
    await _secureStorage.write(
      key: _recoveryKeySaltKey,
      value: base64Encode(salt),
    );

    return formatted;
  }

  Future<bool> validateRecoveryKey(String enteredKey) async {
    try {
      final storedHash = await _secureStorage.read(key: _recoveryKeyHashKey);
      final storedSalt = await _secureStorage.read(key: _recoveryKeySaltKey);
      if (storedHash == null || storedSalt == null) return false;

      final normalized = enteredKey.replaceAll('-', '').toUpperCase();
      if (normalized.length != AppConstants.recoveryKeyLength) return false;

      final saltBytes = base64Decode(storedSalt);
      final hash = await _pbkdf2Hash(normalized, Uint8List.fromList(saltBytes));
      return base64Encode(hash) == storedHash;
    } catch (e) {
      AppLogger.error('Failed to validate recovery key', e);
      return false;
    }
  }

  Future<bool> hasRecoveryKey() async {
    return await _secureStorage.read(key: _recoveryKeyHashKey) != null;
  }

  Future<void> clearRecoveryKey() async {
    await _secureStorage.delete(key: _recoveryKeyHashKey);
    await _secureStorage.delete(key: _recoveryKeySaltKey);
  }

  Future<int> getFailedAttempts() async {
    final val = await _secureStorage.read(key: _failedAttemptsKey);
    return int.tryParse(val ?? '0') ?? 0;
  }

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

  Future<void> resetFailedPinAttempts() async {
    await _secureStorage.delete(key: _failedAttemptsKey);
    await _secureStorage.delete(key: _lockoutUntilKey);
  }

  int _lockoutDurationSeconds(int attempts) {
    if (attempts <= AppConstants.maxPinAttempts) {
      return AppConstants.lockoutSeconds5Attempts;
    }
    if (attempts == 6) return AppConstants.lockoutSeconds6Attempts;
    if (attempts == 7) return AppConstants.lockoutSeconds7Attempts;
    return AppConstants.lockoutSeconds8PlusAttempts;
  }

  Future<bool> isScreenLockEnabled() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      AppLogger.error('Failed to check screen lock status', e);
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.error('Failed to load available biometrics', e);
      return [];
    }
  }

  String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    }
    if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    }
    if (types.contains(BiometricType.weak)) {
      return 'Biometric (Weak)';
    }
    return 'Biometric';
  }
}
