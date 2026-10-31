import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/services/export_import_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

void main() {
  late ExportImportService service;

  final DateTime fixedTime = DateTime(2025, 10, 1);

  Account makeAccount({
    String name = 'GitHub',
    String secret = 'JBSWY3DPEHPK3PXP',
    String type = 'totp',
    String? issuer,
    int digits = 6,
    int period = 30,
    String algorithm = 'SHA1',
    int sortOrder = 0,
  }) {
    return Account(
      name: name,
      secret: secret,
      type: type,
      issuer: issuer,
      digits: digits,
      period: period,
      algorithm: algorithm,
      sortOrder: sortOrder,
      createdAt: fixedTime,
    );
  }

  setUp(() {
    service = ExportImportService();
  });

  // ─── v3 encrypt / decrypt round-trip ──────────────────────────────────────

  group('v3 encrypt / decrypt round-trip', () {
    test('encrypts and decrypts with correct password', () {
      const password = 'StrongPassword123!';
      const plainText = '{"accounts":[]}';

      final encrypted = service.encryptDataForTest(plainText, password);
      expect(encrypted, startsWith('v3:'));

      final decrypted = service.decryptDataForTest(encrypted, password);
      expect(decrypted, plainText);
    });

    test('v3 format has four colon-separated parts', () {
      final encrypted = service.encryptDataForTest('test', 'password');
      final parts = encrypted.split(':');
      expect(parts.length, 4);
      expect(parts[0], 'v3');
    });

    test('decrypt fails with wrong password', () {
      final encrypted = service.encryptDataForTest('secret data', 'correct');
      final decrypted = service.decryptDataForTest(encrypted, 'wrong');
      expect(decrypted, isNull);
    });

    test(
      'same plaintext produces different ciphertexts (random salt+nonce)',
      () {
        const password = 'pass';
        const text = 'same content';
        final enc1 = service.encryptDataForTest(text, password);
        final enc2 = service.encryptDataForTest(text, password);
        expect(enc1, isNot(equals(enc2)));

        // Both decrypt to the same value
        expect(service.decryptDataForTest(enc1, password), text);
        expect(service.decryptDataForTest(enc2, password), text);
      },
    );

    test('handles unicode content', () {
      const password = 'pass';
      const text = 'Hello 🔐 Wörld こんにちは';
      final encrypted = service.encryptDataForTest(text, password);
      expect(service.decryptDataForTest(encrypted, password), text);
    });

    test('handles large payloads', () {
      const password = 'pass';
      final text = 'A' * 50000;
      final encrypted = service.encryptDataForTest(text, password);
      expect(service.decryptDataForTest(encrypted, password), text);
    });
  });

  // ─── Malformed input handling ─────────────────────────────────────────────

  group('decrypt error handling', () {
    test('returns null for v3 with wrong number of parts', () {
      expect(service.decryptDataForTest('v3:a:b', 'pass'), isNull);
      expect(service.decryptDataForTest('v3:a:b:c:d', 'pass'), isNull);
    });

    test('returns null for old backup formats', () {
      expect(service.decryptDataForTest('v2:AAAA:AAAA', 'pass'), isNull);
      expect(service.decryptDataForTest('AAAA:AAAA', 'pass'), isNull);
      expect(service.decryptDataForTest('no_colon_at_all', 'pass'), isNull);
    });

    test('returns null for corrupted base64', () {
      expect(service.decryptDataForTest('v3:!!!:!!!:!!!', 'pass'), isNull);
    });
  });

  // ─── JSON serialization / deserialization ─────────────────────────────────

  group('JSON serialization', () {
    test('dataToJson includes version and accounts', () {
      final accounts = [makeAccount(name: 'GitHub', issuer: 'GitHub Inc')];

      final json = service.dataToJsonForTest(accounts);
      final parsed = jsonDecode(json) as Map<String, dynamic>;

      expect(parsed['version'], AppConstants.backupVersion);
      expect(parsed['created'], isNotNull);
      expect((parsed['accounts'] as List).length, 1);
      expect(parsed.containsKey('groups'), isFalse);
    });

    test('dataToJson preserves account fields', () {
      final accounts = [
        makeAccount(
          name: 'AWS',
          secret: 'MYSECRET',
          type: 'hotp',
          issuer: 'Amazon',
          digits: 8,
          period: 60,
          algorithm: 'SHA256',
          sortOrder: 3,
        ),
      ];

      final json = service.dataToJsonForTest(accounts);
      final parsed = jsonDecode(json);
      final acc = (parsed['accounts'] as List).first;

      expect(acc['name'], 'AWS');
      expect(acc['secret'], 'MYSECRET');
      expect(acc['type'], 'hotp');
      expect(acc['issuer'], 'Amazon');
      expect(acc['digits'], 8);
      expect(acc['period'], 60);
      expect(acc['algorithm'], 'SHA256');
      expect(acc['sortOrder'], 3);
    });
  });

  group('JSON parsing', () {
    test('parseBackupJson parses accounts', () {
      final accounts = [makeAccount(name: 'GitHub')];
      final json = service.dataToJsonForTest(accounts);

      final result = service.parseBackupJsonForTest(json);
      expect(result, isNotNull);

      final parsedAccounts = result!['accounts'] as List<Account>;

      expect(parsedAccounts.length, 1);
      expect(parsedAccounts.first.name, 'GitHub');
    });

    test('parseBackupJson handles a backup without a groups key', () {
      final json = jsonEncode({
        'version': '1.0',
        'accounts': [makeAccount(name: 'OldAccount').toMap()],
      });

      final result = service.parseBackupJsonForTest(json);
      expect(result, isNotNull);
      expect((result!['accounts'] as List).length, 1);
    });

    test('parseBackupJson ignores an unknown groups key', () {
      final json = jsonEncode({
        'version': '2.0',
        'accounts': [makeAccount(name: 'A').toMap()],
        'groups': [
          {'id': 1, 'name': 'Work', 'color': 'blue'},
        ],
      });

      final result = service.parseBackupJsonForTest(json);
      expect(result, isNotNull);
      expect((result!['accounts'] as List).length, 1);
      expect(result.containsKey('groups'), isFalse);
    });

    test('parseBackupJson returns null for invalid JSON', () {
      expect(service.parseBackupJsonForTest('not json at all'), isNull);
    });

    test('parseBackupJson returns empty accounts list when key missing', () {
      final result = service.parseBackupJsonForTest('{"version":"2.0"}');
      expect(result, isNotNull);
      expect((result!['accounts'] as List), isEmpty);
    });

    test('round-trip: serialize then parse preserves account data', () {
      final accounts = [
        makeAccount(
          name: 'A',
          issuer: 'Issuer',
          digits: 8,
          algorithm: 'SHA512',
        ),
        makeAccount(name: 'B', type: 'hotp'),
      ];

      final json = service.dataToJsonForTest(accounts);
      final result = service.parseBackupJsonForTest(json)!;
      final parsedAccounts = result['accounts'] as List<Account>;

      expect(parsedAccounts.length, 2);
      expect(parsedAccounts[0].name, 'A');
      expect(parsedAccounts[0].issuer, 'Issuer');
      expect(parsedAccounts[0].digits, 8);
      expect(parsedAccounts[0].algorithm, 'SHA512');
      expect(parsedAccounts[1].name, 'B');
      expect(parsedAccounts[1].type, 'hotp');
    });
  });

  // ─── End-to-end: encrypt JSON backup then decrypt and parse ───────────────

  group('end-to-end backup integrity', () {
    test('encrypt then decrypt and parse produces original account data', () {
      const password = 'BackupPassword!';
      final accounts = [
        makeAccount(name: 'GitHub', issuer: 'GitHub', secret: 'ABCDEF'),
        makeAccount(
          name: 'Google',
          issuer: 'Google',
          secret: 'GHIJKL',
          digits: 8,
        ),
      ];

      final json = service.dataToJsonForTest(accounts);
      final encrypted = service.encryptDataForTest(json, password);
      final decrypted = service.decryptDataForTest(encrypted, password);
      expect(decrypted, isNotNull);

      final parsed = service.parseBackupJsonForTest(decrypted!)!;
      final restoredAccounts = parsed['accounts'] as List<Account>;

      expect(restoredAccounts.length, 2);
      expect(restoredAccounts[0].name, 'GitHub');
      expect(restoredAccounts[0].secret, 'ABCDEF');
      expect(restoredAccounts[1].digits, 8);
    });
  });
}
