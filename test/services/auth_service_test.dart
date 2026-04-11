import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  final Map<String, String> fakeSecureStorage = {};
  late bool deviceSupported;
  late List<String> availableBiometrics;
  Object? authenticateResponse;

  setUp(() {
    fakeSecureStorage.clear();
    authService = AuthService();
    deviceSupported = true;
    availableBiometrics = <String>['fingerprint'];
    authenticateResponse = true;

    const secureChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'read':
              final key = methodCall.arguments['key'] as String;
              return fakeSecureStorage[key];
            case 'write':
              final key = methodCall.arguments['key'] as String;
              final value = methodCall.arguments['value'] as String;
              fakeSecureStorage[key] = value;
              return null;
            case 'delete':
              final key = methodCall.arguments['key'] as String;
              fakeSecureStorage.remove(key);
              return null;
            case 'deleteAll':
              fakeSecureStorage.clear();
              return null;
            default:
              return null;
          }
        });

    SharedPreferences.setMockInitialValues({});

    const localAuthChannel = MethodChannel('plugins.flutter.io/local_auth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localAuthChannel, (
          MethodCall methodCall,
        ) async {
          switch (methodCall.method) {
            case 'isDeviceSupported':
              return deviceSupported;
            case 'deviceSupportsBiometrics':
              return availableBiometrics.isNotEmpty;
            case 'getAvailableBiometrics':
              return availableBiometrics;
            case 'authenticate':
              if (authenticateResponse is PlatformException) {
                throw authenticateResponse! as PlatformException;
              }
              return authenticateResponse;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/local_auth'),
          null,
        );
  });

  group('phone lock auth', () {
    test('authenticateWithPhoneLock returns success', () async {
      final result = await authService.authenticateWithPhoneLock();
      expect(result.outcome, LocalAuthOutcome.success);
    });

    test(
      'authenticateWithPhoneLock returns failure when authenticate is false',
      () async {
        authenticateResponse = false;

        final result = await authService.authenticateWithPhoneLock();
        expect(result.outcome, LocalAuthOutcome.failure);
      },
    );

    test(
      'authenticateWithPhoneLock returns notAvailable when device unsupported',
      () async {
        deviceSupported = false;

        final result = await authService.authenticateWithPhoneLock();
        expect(result.outcome, LocalAuthOutcome.notAvailable);
      },
    );

    test('authenticateWithPhoneLock maps cancel errors', () async {
      authenticateResponse = PlatformException(code: 'UserCanceled');

      final result = await authService.authenticateWithPhoneLock();
      expect(result.outcome, LocalAuthOutcome.canceled);
    });

    test('authenticateWithPhoneLock maps lockout errors', () async {
      authenticateResponse = PlatformException(code: 'LockedOut');

      final result = await authService.authenticateWithPhoneLock();
      expect(result.outcome, LocalAuthOutcome.lockedOut);
    });
  });

  group('PIN management', () {
    test('hasPin returns false when no PIN is set', () async {
      expect(await authService.hasPin(), isFalse);
    });

    test('setPin stores hash and salt in secure storage', () async {
      await authService.setPin('1234');

      expect(fakeSecureStorage.containsKey('app_pin_hash'), isTrue);
      expect(fakeSecureStorage.containsKey('app_pin_salt'), isTrue);
      expect(fakeSecureStorage['app_pin_version'], '2');
    });

    test('validatePin returns true for correct PIN', () async {
      await authService.setPin('1234');
      expect(await authService.validatePin('1234'), isTrue);
    });

    test('validatePin returns false for wrong PIN', () async {
      await authService.setPin('1234');
      expect(await authService.validatePin('5678'), isFalse);
    });

    test('clearPin removes pin state and recovery data', () async {
      await authService.setPin('1234');
      await authService.generateRecoveryKey();
      await authService.recordFailedPinAttempt();

      await authService.clearPin();

      expect(fakeSecureStorage.containsKey('app_pin_hash'), isFalse);
      expect(fakeSecureStorage.containsKey('recovery_key_hash'), isFalse);
      expect(fakeSecureStorage.containsKey('pin_failed_attempts'), isFalse);
    });

    test('setPin and generateRecoveryKey keep both verifiers valid', () async {
      await authService.setPin('1234');
      final recoveryKey = await authService.generateRecoveryKey();

      expect(await authService.validatePin('1234'), isTrue);
      expect(await authService.validateRecoveryKey(recoveryKey), isTrue);
    });
  });

  group('legacy PIN migration', () {
    test('validates legacy SHA-256 PIN and auto-migrates to PBKDF2', () async {
      const pin = '9999';
      const legacySalt = '1609459200000';
      final legacyHash = sha256
          .convert(utf8.encode(pin + legacySalt))
          .toString();

      fakeSecureStorage['app_pin_hash'] = legacyHash;
      fakeSecureStorage['app_pin_salt'] = legacySalt;
      fakeSecureStorage['app_pin_version'] = '1';
      fakeSecureStorage['pin_migrated_to_keystore'] = '1';

      expect(await authService.validatePin(pin), isTrue);
      expect(fakeSecureStorage['app_pin_version'], '2');
      expect(await authService.validatePin(pin), isTrue);
    });

    test('migrates PIN from SharedPreferences to secure storage', () async {
      const pin = '5555';
      const legacySalt = '1609459200000';
      final legacyHash = sha256
          .convert(utf8.encode(pin + legacySalt))
          .toString();

      SharedPreferences.setMockInitialValues({
        'app_pin_hash': legacyHash,
        'app_pin_salt': legacySalt,
        'app_pin_version': 1,
        'pin_failed_attempts': 2,
      });

      final hasPin = await authService.hasPin();
      expect(hasPin, isTrue);
      expect(fakeSecureStorage['app_pin_hash'], legacyHash);
      expect(fakeSecureStorage['pin_failed_attempts'], '2');
    });
  });

  group('recovery key', () {
    test('generateRecoveryKey returns XXXX-XXXX-XXXX-XXXX format', () async {
      final key = await authService.generateRecoveryKey();
      expect(
        key,
        matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$')),
      );
    });

    test('validateRecoveryKey succeeds with correct key', () async {
      final key = await authService.generateRecoveryKey();
      expect(await authService.validateRecoveryKey(key), isTrue);
    });

    test('clearRecoveryKey removes stored hash and salt', () async {
      await authService.generateRecoveryKey();
      await authService.clearRecoveryKey();
      expect(await authService.hasRecoveryKey(), isFalse);
    });
  });

  group('brute-force protection', () {
    test('recordFailedPinAttempt increments counter', () async {
      await authService.recordFailedPinAttempt();
      expect(await authService.getFailedAttempts(), 1);
    });

    test('lockout is applied at 5 failed attempts', () async {
      for (var i = 0; i < 5; i++) {
        await authService.recordFailedPinAttempt();
      }
      final remaining = await authService.getLockoutRemainingSeconds();
      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(30));
    });

    test('resetFailedPinAttempts clears counter and lockout', () async {
      for (var i = 0; i < 5; i++) {
        await authService.recordFailedPinAttempt();
      }
      await authService.resetFailedPinAttempts();

      expect(await authService.getFailedAttempts(), 0);
      expect(await authService.getLockoutRemainingSeconds(), 0);
    });
  });

  group('getBiometricTypeString', () {
    test('returns Face ID for face biometric', () {
      expect(
        authService.getBiometricTypeString([BiometricType.face]),
        'Face ID',
      );
    });

    test('returns Fingerprint for fingerprint biometric', () {
      expect(
        authService.getBiometricTypeString([BiometricType.fingerprint]),
        'Fingerprint',
      );
    });
  });

  test('maxAttempts is 5', () {
    expect(AuthService.maxAttempts, 5);
  });
}
