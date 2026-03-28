import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  final Map<String, String> fakeSecureStorage = {};

  setUp(() {
    fakeSecureStorage.clear();
    authService = AuthService();

    // Mock FlutterSecureStorage
    const secureChannel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
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

    // Mock SharedPreferences with empty initial values (for migration tests)
    SharedPreferences.setMockInitialValues({});

    // Mock local_auth method channel
    const localAuthChannel =
        MethodChannel('plugins.flutter.io/local_auth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localAuthChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isDeviceSupported':
          return true;
        case 'getAvailableBiometrics':
          return <String>['fingerprint'];
        case 'authenticate':
          return true;
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

  // ─── PIN management ─────────────────────────────────────────────────────────

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

    test('hasPin returns true after setting a PIN', () async {
      await authService.setPin('1234');
      expect(await authService.hasPin(), isTrue);
    });

    test('validatePin returns true for correct PIN', () async {
      await authService.setPin('1234');
      expect(await authService.validatePin('1234'), isTrue);
    });

    test('validatePin returns false for wrong PIN', () async {
      await authService.setPin('1234');
      expect(await authService.validatePin('5678'), isFalse);
    });

    test('validatePin returns false when no PIN is stored', () async {
      expect(await authService.validatePin('1234'), isFalse);
    });

    test('PIN hash is PBKDF2 (version 2), not plaintext', () async {
      await authService.setPin('1234');
      final storedHash = fakeSecureStorage['app_pin_hash']!;
      // Hash is base64 of 32-byte PBKDF2 output
      final hashBytes = base64Decode(storedHash);
      expect(hashBytes.length, 32);
      // Hash should not be the PIN itself
      expect(storedHash, isNot(equals('1234')));
    });

    test('salt is 16 bytes', () async {
      await authService.setPin('1234');
      final salt = fakeSecureStorage['app_pin_salt']!;
      final saltBytes = base64Decode(salt);
      expect(saltBytes.length, 16);
    });

    test('same PIN produces different hashes (random salt)', () async {
      await authService.setPin('1234');
      final hash1 = fakeSecureStorage['app_pin_hash'];
      final salt1 = fakeSecureStorage['app_pin_salt'];

      await authService.setPin('1234');
      final hash2 = fakeSecureStorage['app_pin_hash'];
      final salt2 = fakeSecureStorage['app_pin_salt'];

      // Different salts → different hashes
      expect(salt1, isNot(equals(salt2)));
      expect(hash1, isNot(equals(hash2)));
    });

    test('clearPin removes hash, salt, version, recovery key, and resets attempts', () async {
      await authService.setPin('1234');
      await authService.generateRecoveryKey();
      await authService.recordFailedPinAttempt();

      await authService.clearPin();

      expect(fakeSecureStorage.containsKey('app_pin_hash'), isFalse);
      expect(fakeSecureStorage.containsKey('app_pin_salt'), isFalse);
      expect(fakeSecureStorage.containsKey('app_pin_version'), isFalse);
      expect(fakeSecureStorage.containsKey('recovery_key_hash'), isFalse);
      expect(fakeSecureStorage.containsKey('recovery_key_salt'), isFalse);
      expect(fakeSecureStorage.containsKey('pin_failed_attempts'), isFalse);
      expect(fakeSecureStorage.containsKey('pin_lockout_until'), isFalse);
    });
  });

  // ─── Legacy PIN migration ──────────────────────────────────────────────────

  group('legacy PIN migration', () {
    test('validates legacy SHA-256 PIN and auto-migrates to PBKDF2', () async {
      // Simulate a legacy v1 PIN: SHA-256(pin + salt)
      const pin = '9999';
      const legacySalt = '1609459200000'; // timestamp-style salt
      final legacyHash =
          sha256.convert(utf8.encode(pin + legacySalt)).toString();

      // Pre-populate secure storage with legacy data (as if migration from
      // SharedPreferences already happened, but version is still 1).
      fakeSecureStorage['app_pin_hash'] = legacyHash;
      fakeSecureStorage['app_pin_salt'] = legacySalt;
      fakeSecureStorage['app_pin_version'] = '1';
      fakeSecureStorage['pin_migrated_to_keystore'] = '1';

      // Validate with the original PIN — should succeed
      expect(await authService.validatePin(pin), isTrue);

      // After successful validation, PIN should be re-hashed as PBKDF2 (v2)
      expect(fakeSecureStorage['app_pin_version'], '2');
      final newHash = fakeSecureStorage['app_pin_hash']!;
      expect(newHash, isNot(equals(legacyHash)));

      // Validate again — still works with PBKDF2
      expect(await authService.validatePin(pin), isTrue);
    });

    test('rejects wrong PIN against legacy hash', () async {
      const pin = '9999';
      const legacySalt = '1609459200000';
      final legacyHash =
          sha256.convert(utf8.encode(pin + legacySalt)).toString();

      fakeSecureStorage['app_pin_hash'] = legacyHash;
      fakeSecureStorage['app_pin_salt'] = legacySalt;
      fakeSecureStorage['app_pin_version'] = '1';
      fakeSecureStorage['pin_migrated_to_keystore'] = '1';

      expect(await authService.validatePin('0000'), isFalse);
      // Version should NOT have changed (no migration on failure)
      expect(fakeSecureStorage['app_pin_version'], '1');
    });

    test('migrates PIN from SharedPreferences to secure storage', () async {
      const pin = '5555';
      const legacySalt = '1609459200000';
      final legacyHash =
          sha256.convert(utf8.encode(pin + legacySalt)).toString();

      // Set SharedPreferences with legacy PIN data
      SharedPreferences.setMockInitialValues({
        'app_pin_hash': legacyHash,
        'app_pin_salt': legacySalt,
        'app_pin_version': 1,
        'pin_failed_attempts': 2,
      });

      // Migration sentinel is NOT set — migration should happen
      // Calling hasPin triggers migration
      final hasPin = await authService.hasPin();
      expect(hasPin, isTrue);

      // Data should now be in secure storage
      expect(fakeSecureStorage['app_pin_hash'], legacyHash);
      expect(fakeSecureStorage['app_pin_salt'], legacySalt);
      expect(fakeSecureStorage['app_pin_version'], '1');
      expect(fakeSecureStorage['pin_failed_attempts'], '2');
      expect(fakeSecureStorage['pin_migrated_to_keystore'], '1');
    });

    test('migration runs only once', () async {
      SharedPreferences.setMockInitialValues({});
      // Mark migration as already done
      fakeSecureStorage['pin_migrated_to_keystore'] = '1';

      await authService.hasPin();
      // No crash, no changes — migration is a no-op
      expect(fakeSecureStorage['pin_migrated_to_keystore'], '1');
    });
  });

  // ─── Recovery key ──────────────────────────────────────────────────────────

  group('recovery key', () {
    test('hasRecoveryKey returns false when none is set', () async {
      expect(await authService.hasRecoveryKey(), isFalse);
    });

    test('generateRecoveryKey returns XXXX-XXXX-XXXX-XXXX format', () async {
      final key = await authService.generateRecoveryKey();
      expect(key, matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$')));
    });

    test('generateRecoveryKey excludes ambiguous characters (0, O, 1, I)', () async {
      // Generate multiple keys to increase confidence
      for (var i = 0; i < 10; i++) {
        final key = await authService.generateRecoveryKey();
        final raw = key.replaceAll('-', '');
        expect(raw.contains('0'), isFalse);
        expect(raw.contains('O'), isFalse);
        expect(raw.contains('1'), isFalse);
        expect(raw.contains('I'), isFalse);
      }
    });

    test('hasRecoveryKey returns true after generation', () async {
      await authService.generateRecoveryKey();
      expect(await authService.hasRecoveryKey(), isTrue);
    });

    test('validateRecoveryKey succeeds with correct key', () async {
      final key = await authService.generateRecoveryKey();
      expect(await authService.validateRecoveryKey(key), isTrue);
    });

    test('validateRecoveryKey succeeds without dashes', () async {
      final key = await authService.generateRecoveryKey();
      final noDashes = key.replaceAll('-', '');
      expect(await authService.validateRecoveryKey(noDashes), isTrue);
    });

    test('validateRecoveryKey is case-insensitive', () async {
      final key = await authService.generateRecoveryKey();
      expect(await authService.validateRecoveryKey(key.toLowerCase()), isTrue);
    });

    test('validateRecoveryKey fails with wrong key', () async {
      await authService.generateRecoveryKey();
      expect(await authService.validateRecoveryKey('AAAA-BBBB-CCCC-DDDD'), isFalse);
    });

    test('validateRecoveryKey fails with wrong length', () async {
      await authService.generateRecoveryKey();
      expect(await authService.validateRecoveryKey('SHORT'), isFalse);
    });

    test('validateRecoveryKey fails when no key is stored', () async {
      expect(await authService.validateRecoveryKey('AAAA-BBBB-CCCC-DDDD'), isFalse);
    });

    test('clearRecoveryKey removes stored hash and salt', () async {
      await authService.generateRecoveryKey();
      await authService.clearRecoveryKey();
      expect(await authService.hasRecoveryKey(), isFalse);
    });

    test('recovery key hash is PBKDF2 (32 bytes)', () async {
      await authService.generateRecoveryKey();
      final hash = fakeSecureStorage['recovery_key_hash']!;
      final hashBytes = base64Decode(hash);
      expect(hashBytes.length, 32);
    });
  });

  // ─── Brute-force protection ────────────────────────────────────────────────

  group('brute-force protection', () {
    test('failed attempts starts at 0', () async {
      expect(await authService.getFailedAttempts(), 0);
    });

    test('recordFailedPinAttempt increments counter', () async {
      await authService.recordFailedPinAttempt();
      expect(await authService.getFailedAttempts(), 1);

      await authService.recordFailedPinAttempt();
      expect(await authService.getFailedAttempts(), 2);
    });

    test('no lockout before 5 attempts', () async {
      for (var i = 0; i < 4; i++) {
        await authService.recordFailedPinAttempt();
      }
      expect(await authService.getLockoutRemainingSeconds(), 0);
    });

    test('lockout is applied at 5 failed attempts', () async {
      for (var i = 0; i < 5; i++) {
        await authService.recordFailedPinAttempt();
      }
      final remaining = await authService.getLockoutRemainingSeconds();
      // Should be locked out for ~30 seconds
      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(30));
    });

    test('lockout escalates with more attempts', () async {
      // 6 attempts → 60s lockout
      for (var i = 0; i < 6; i++) {
        await authService.recordFailedPinAttempt();
      }
      final remaining6 = await authService.getLockoutRemainingSeconds();
      expect(remaining6, greaterThan(30));
      expect(remaining6, lessThanOrEqualTo(60));
    });

    test('resetFailedPinAttempts clears counter and lockout', () async {
      for (var i = 0; i < 5; i++) {
        await authService.recordFailedPinAttempt();
      }
      await authService.resetFailedPinAttempts();

      expect(await authService.getFailedAttempts(), 0);
      expect(await authService.getLockoutRemainingSeconds(), 0);
    });

    test('expired lockout returns 0 and cleans up', () async {
      // Set lockout to a past timestamp
      fakeSecureStorage['pin_lockout_until'] =
          (DateTime.now().millisecondsSinceEpoch - 10000).toString();

      expect(await authService.getLockoutRemainingSeconds(), 0);
      // Key should be cleaned up
      expect(fakeSecureStorage.containsKey('pin_lockout_until'), isFalse);
    });
  });

  // ─── Biometric type string ─────────────────────────────────────────────────

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

    test('returns Biometric for strong biometric', () {
      expect(
        authService.getBiometricTypeString([BiometricType.strong]),
        'Biometric',
      );
    });

    test('returns Biometric (Weak) for weak biometric', () {
      expect(
        authService.getBiometricTypeString([BiometricType.weak]),
        'Biometric (Weak)',
      );
    });

    test('returns default Biometric for empty list', () {
      expect(
        authService.getBiometricTypeString([]),
        'Biometric',
      );
    });

    test('face takes priority over fingerprint', () {
      expect(
        authService.getBiometricTypeString([
          BiometricType.fingerprint,
          BiometricType.face,
        ]),
        'Face ID',
      );
    });
  });

  // ─── maxAttempts constant ──────────────────────────────────────────────────

  test('maxAttempts is 5', () {
    expect(AuthService.maxAttempts, 5);
  });
}
