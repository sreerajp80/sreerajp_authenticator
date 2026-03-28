import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/models/group.dart';
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
    int? groupId,
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
      groupId: groupId,
      sortOrder: sortOrder,
      createdAt: fixedTime,
    );
  }

  Group makeGroup({
    String name = 'Work',
    String? description,
    String color = 'blue',
    String? icon,
    int sortOrder = 0,
  }) {
    return Group(
      name: name,
      description: description,
      color: color,
      icon: icon,
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
      const plainText = '{"accounts":[],"groups":[]}';

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

    test('same plaintext produces different ciphertexts (random salt+nonce)', () {
      const password = 'pass';
      const text = 'same content';
      final enc1 = service.encryptDataForTest(text, password);
      final enc2 = service.encryptDataForTest(text, password);
      expect(enc1, isNot(equals(enc2)));

      // Both decrypt to the same value
      expect(service.decryptDataForTest(enc1, password), text);
      expect(service.decryptDataForTest(enc2, password), text);
    });

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

  // ─── Legacy v2 format decryption ──────────────────────────────────────────

  group('legacy v2 format decryption', () {
    String legacyPadPassword(String password) {
      final bytes = utf8.encode(password);
      final hash = sha256.convert(bytes);
      return hash.toString().substring(0, 32);
    }

    test('decrypts v2 format (SHA-256 key + AES-256-GCM)', () {
      const password = 'legacypass';
      const plainText = '{"accounts":[]}';

      // Manually create a v2 encrypted payload
      final legacyKey = encrypt.Key.fromUtf8(legacyPadPassword(password));
      final iv = encrypt.IV.fromSecureRandom(12);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(legacyKey, mode: encrypt.AESMode.gcm),
      );
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final v2Data = 'v2:${iv.base64}:${encrypted.base64}';

      final decrypted = service.decryptDataForTest(v2Data, password);
      expect(decrypted, plainText);
    });

    test('v2 decrypt fails with wrong password', () {
      const password = 'legacypass';
      final legacyKey = encrypt.Key.fromUtf8(legacyPadPassword(password));
      final iv = encrypt.IV.fromSecureRandom(12);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(legacyKey, mode: encrypt.AESMode.gcm),
      );
      final encrypted = encrypter.encrypt('data', iv: iv);
      final v2Data = 'v2:${iv.base64}:${encrypted.base64}';

      expect(service.decryptDataForTest(v2Data, 'wrongpass'), isNull);
    });
  });

  // ─── Legacy CTR/SIC format decryption ─────────────────────────────────────

  group('legacy CTR/SIC format decryption', () {
    String legacyPadPassword(String password) {
      final bytes = utf8.encode(password);
      final hash = sha256.convert(bytes);
      return hash.toString().substring(0, 32);
    }

    test('decrypts legacy CTR/SIC format', () {
      const password = 'oldpass';
      const plainText = '{"accounts":[]}';

      final legacyKey = encrypt.Key.fromUtf8(legacyPadPassword(password));
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(legacyKey, mode: encrypt.AESMode.sic),
      );
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final legacyData = '${iv.base64}:${encrypted.base64}';

      final decrypted = service.decryptDataForTest(legacyData, password);
      expect(decrypted, plainText);
    });
  });

  // ─── Malformed input handling ─────────────────────────────────────────────

  group('decrypt error handling', () {
    test('returns null for v3 with wrong number of parts', () {
      expect(service.decryptDataForTest('v3:a:b', 'pass'), isNull);
      expect(service.decryptDataForTest('v3:a:b:c:d', 'pass'), isNull);
    });

    test('returns null for v2 with wrong number of parts', () {
      expect(service.decryptDataForTest('v2:only_one', 'pass'), isNull);
    });

    test('returns null for legacy format with wrong parts', () {
      expect(service.decryptDataForTest('no_colon_at_all', 'pass'), isNull);
    });

    test('returns null for corrupted base64', () {
      expect(service.decryptDataForTest('v3:!!!:!!!:!!!', 'pass'), isNull);
    });
  });

  // ─── JSON serialization / deserialization ─────────────────────────────────

  group('JSON serialization', () {
    test('dataToJson includes version, accounts, and groups', () {
      final accounts = [makeAccount(name: 'GitHub', issuer: 'GitHub Inc')];
      final groups = [makeGroup(name: 'Work')];

      final json = service.dataToJsonForTest(accounts, groups);
      final parsed = jsonDecode(json) as Map<String, dynamic>;

      expect(parsed['version'], AppConstants.backupVersion);
      expect(parsed['created'], isNotNull);
      expect((parsed['accounts'] as List).length, 1);
      expect((parsed['groups'] as List).length, 1);
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

      final json = service.dataToJsonForTest(accounts, []);
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

    test('dataToJson preserves group fields', () {
      final groups = [
        makeGroup(name: 'Finance', description: 'Banking', color: 'green', icon: 'bank'),
      ];

      final json = service.dataToJsonForTest([], groups);
      final parsed = jsonDecode(json);
      final grp = (parsed['groups'] as List).first;

      expect(grp['name'], 'Finance');
      expect(grp['description'], 'Banking');
      expect(grp['color'], 'green');
      expect(grp['icon'], 'bank');
    });
  });

  group('JSON parsing', () {
    test('parseBackupJson parses accounts and groups', () {
      final accounts = [makeAccount(name: 'GitHub')];
      final groups = [makeGroup(name: 'Work')];
      final json = service.dataToJsonForTest(accounts, groups);

      final result = service.parseBackupJsonForTest(json);
      expect(result, isNotNull);

      final parsedAccounts = result!['accounts'] as List<Account>;
      final parsedGroups = result['groups'] as List<Group>;

      expect(parsedAccounts.length, 1);
      expect(parsedAccounts.first.name, 'GitHub');
      expect(parsedGroups.length, 1);
      expect(parsedGroups.first.name, 'Work');
    });

    test('parseBackupJson handles old format without groups', () {
      final json = jsonEncode({
        'version': '1.0',
        'accounts': [
          makeAccount(name: 'OldAccount').toMap(),
        ],
      });

      final result = service.parseBackupJsonForTest(json);
      expect(result, isNotNull);
      expect((result!['accounts'] as List).length, 1);
      expect((result['groups'] as List), isEmpty);
    });

    test('parseBackupJson returns null for invalid JSON', () {
      expect(service.parseBackupJsonForTest('not json at all'), isNull);
    });

    test('parseBackupJson returns null for JSON missing accounts key', () {
      final result = service.parseBackupJsonForTest('{"version":"2.0"}');
      expect(result, isNotNull);
      expect((result!['accounts'] as List), isEmpty);
    });

    test('round-trip: serialize then parse preserves data', () {
      final accounts = [
        makeAccount(name: 'A', issuer: 'Issuer', digits: 8, algorithm: 'SHA512'),
        makeAccount(name: 'B', type: 'hotp'),
      ];
      final groups = [
        makeGroup(name: 'G1', color: 'red'),
        makeGroup(name: 'G2'),
      ];

      final json = service.dataToJsonForTest(accounts, groups);
      final result = service.parseBackupJsonForTest(json)!;
      final parsedAccounts = result['accounts'] as List<Account>;
      final parsedGroups = result['groups'] as List<Group>;

      expect(parsedAccounts.length, 2);
      expect(parsedAccounts[0].name, 'A');
      expect(parsedAccounts[0].issuer, 'Issuer');
      expect(parsedAccounts[0].digits, 8);
      expect(parsedAccounts[0].algorithm, 'SHA512');
      expect(parsedAccounts[1].name, 'B');
      expect(parsedAccounts[1].type, 'hotp');

      expect(parsedGroups.length, 2);
      expect(parsedGroups[0].name, 'G1');
      expect(parsedGroups[0].color, 'red');
      expect(parsedGroups[1].name, 'G2');
    });
  });

  // ─── CSV generation ───────────────────────────────────────────────────────

  group('CSV export', () {
    test('CSV header includes expected columns', () {
      final csv = service.accountsToCsvForTest([]);
      expect(csv, startsWith('Name,Issuer,Secret,Digits,Period,Algorithm,Group ID,Created At'));
    });

    test('CSV includes account data', () {
      final accounts = [
        makeAccount(name: 'GitHub', secret: 'SECRET', issuer: 'GitHub Inc', digits: 6),
      ];
      final csv = service.accountsToCsvForTest(accounts);
      final lines = csv.trim().split('\n');

      expect(lines.length, 2); // header + 1 row
      expect(lines[1], contains('"GitHub"'));
      expect(lines[1], contains('"GitHub Inc"'));
      expect(lines[1], contains('"SECRET"'));
      expect(lines[1], contains('6'));
    });

    test('CSV handles null issuer as empty string', () {
      final accounts = [makeAccount(name: 'NoIssuer', issuer: null)];
      final csv = service.accountsToCsvForTest(accounts);
      final lines = csv.trim().split('\n');
      // issuer field should be empty quotes
      expect(lines[1], contains('"",'));
    });

    test('CSV handles multiple accounts', () {
      final accounts = [
        makeAccount(name: 'A'),
        makeAccount(name: 'B'),
        makeAccount(name: 'C'),
      ];
      final csv = service.accountsToCsvForTest(accounts);
      final lines = csv.trim().split('\n');
      expect(lines.length, 4); // header + 3 rows
    });

    test('CSV handles null groupId', () {
      final accounts = [makeAccount(name: 'NoGroup', groupId: null)];
      final csv = service.accountsToCsvForTest(accounts);
      final lines = csv.trim().split('\n');
      // groupId should be empty (not "null")
      expect(lines[1], isNot(contains('null')));
    });
  });

  // ─── End-to-end: encrypt JSON backup then decrypt and parse ───────────────

  group('end-to-end backup integrity', () {
    test('encrypt then decrypt and parse produces original data', () {
      const password = 'BackupPassword!';
      final accounts = [
        makeAccount(name: 'GitHub', issuer: 'GitHub', secret: 'ABCDEF'),
        makeAccount(name: 'Google', issuer: 'Google', secret: 'GHIJKL', digits: 8),
      ];
      final groups = [makeGroup(name: 'Work'), makeGroup(name: 'Personal')];

      final json = service.dataToJsonForTest(accounts, groups);
      final encrypted = service.encryptDataForTest(json, password);
      final decrypted = service.decryptDataForTest(encrypted, password);
      expect(decrypted, isNotNull);

      final parsed = service.parseBackupJsonForTest(decrypted!)!;
      final restoredAccounts = parsed['accounts'] as List<Account>;
      final restoredGroups = parsed['groups'] as List<Group>;

      expect(restoredAccounts.length, 2);
      expect(restoredAccounts[0].name, 'GitHub');
      expect(restoredAccounts[0].secret, 'ABCDEF');
      expect(restoredAccounts[1].digits, 8);

      expect(restoredGroups.length, 2);
      expect(restoredGroups[0].name, 'Work');
      expect(restoredGroups[1].name, 'Personal');
    });
  });
}
