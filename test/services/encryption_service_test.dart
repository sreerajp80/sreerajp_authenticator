import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/services/encryption_service.dart';

import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EncryptionService encryptionService;

  // In-memory store that simulates FlutterSecureStorage via platform channels.
  final Map<String, String> fakeStorage = {};

  setUp(() {
    fakeStorage.clear();
    encryptionService = EncryptionService();

    // Mock the FlutterSecureStorage method channel
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'read':
              final key = methodCall.arguments['key'] as String;
              return fakeStorage[key];
            case 'write':
              final key = methodCall.arguments['key'] as String;
              final value = methodCall.arguments['value'] as String;
              fakeStorage[key] = value;
              return null;
            case 'delete':
              final key = methodCall.arguments['key'] as String;
              fakeStorage.remove(key);
              return null;
            case 'deleteAll':
              fakeStorage.clear();
              return null;
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
  });

  group('encrypt / decrypt round-trip', () {
    test('encrypts and decrypts to original text', () async {
      const plainText = 'JBSWY3DPEHPK3PXP';

      final encrypted = await encryptionService.encrypt(plainText);
      expect(encrypted, isNot(equals(plainText)));
      expect(encrypted, contains(':'));

      final decrypted = await encryptionService.decrypt(encrypted);
      expect(decrypted, plainText);
    });

    test('different plaintexts produce different ciphertexts', () async {
      final enc1 = await encryptionService.encrypt('secret_one');
      final enc2 = await encryptionService.encrypt('secret_two');
      expect(enc1, isNot(equals(enc2)));
    });

    test(
      'same plaintext produces different ciphertexts (random nonce)',
      () async {
        final enc1 = await encryptionService.encrypt('same_text');
        final enc2 = await encryptionService.encrypt('same_text');
        expect(enc1, isNot(equals(enc2)));

        // But both decrypt to the same value
        final dec1 = await encryptionService.decrypt(enc1);
        final dec2 = await encryptionService.decrypt(enc2);
        expect(dec1, dec2);
        expect(dec1, 'same_text');
      },
    );

    test('handles unicode text', () async {
      const unicode = 'Hello 🔐 Wörld こんにちは';
      final encrypted = await encryptionService.encrypt(unicode);
      final decrypted = await encryptionService.decrypt(encrypted);
      expect(decrypted, unicode);
    });

    test('handles long text', () async {
      final longText = 'A' * 10000;
      final encrypted = await encryptionService.encrypt(longText);
      final decrypted = await encryptionService.decrypt(encrypted);
      expect(decrypted, longText);
    });

    test('empty string returns empty string (no encryption)', () async {
      final result = await encryptionService.encrypt('');
      expect(result, '');

      final decResult = await encryptionService.decrypt('');
      expect(decResult, '');
    });
  });

  group('GCM nonce format', () {
    test('encrypted output has format <16-char-nonce>:<ciphertext>', () async {
      final encrypted = await encryptionService.encrypt('test');
      final parts = encrypted.split(':');

      expect(parts.length, 2);
      // 12-byte nonce → 16 base64 chars
      expect(parts[0].length, 16);
    });
  });

  group('key management', () {
    test('generates and reuses encryption key', () async {
      await encryptionService.encrypt('first');
      expect(fakeStorage.containsKey('authenticator_key'), isTrue);

      final keyAfterFirst = fakeStorage['authenticator_key'];

      await encryptionService.encrypt('second');
      expect(fakeStorage['authenticator_key'], keyAfterFirst);
    });

    test('key is valid 32-byte base64', () async {
      await encryptionService.encrypt('trigger key gen');
      final key = fakeStorage['authenticator_key']!;
      final keyBytes = base64.decode(key);
      expect(keyBytes.length, 32);
    });
  });

  group('error handling', () {
    test('decrypt throws on malformed input', () async {
      // Trigger key creation first
      await encryptionService.encrypt('init');

      expect(
        () => encryptionService.decrypt('bad:data:extra'),
        throwsA(isA<Exception>()),
      );
    });

    test('decrypt rejects old formats', () async {
      await encryptionService.encrypt('init');

      // XOR had no separator; CBC had a 16-byte IV (24 base64 chars).
      expect(
        () => encryptionService.decrypt('TUlHUkFURV9NRQ=='),
        throwsA(isA<Exception>()),
      );
      expect(
        () => encryptionService.decrypt('AAAAAAAAAAAAAAAAAAAAAA==:AAAA'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
