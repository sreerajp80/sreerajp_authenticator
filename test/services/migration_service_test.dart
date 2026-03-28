import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/services/encryption_service.dart';
import 'package:sreerajp_authenticator/services/migration_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService db;
  late EncryptionService encryptionService;
  late MigrationService migrationService;
  final Map<String, String> fakeSecureStorage = {};

  final List<bool> migrationStatuses = [];

  void statusCallback(bool isMigrating) {
    migrationStatuses.add(isMigrating);
  }

  setUp(() async {
    fakeSecureStorage.clear();
    migrationStatuses.clear();

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

    SharedPreferences.setMockInitialValues({});

    await DatabaseService.resetForTesting();
    DatabaseService.testDbPath = inMemoryDatabasePath;
    db = DatabaseService.instance;
    encryptionService = EncryptionService();
    migrationService = MigrationService(db: db, encryption: encryptionService);
  });

  tearDown(() async {
    await DatabaseService.resetForTesting();
    DatabaseService.testDbPath = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  // Helper: create a XOR-encrypted secret using the same key the encryption service uses
  Future<String> xorEncrypt(String plainText) async {
    // Trigger key creation
    await encryptionService.encrypt('init');
    final key = fakeSecureStorage[AppConstants.encryptionKeyAlias]!;
    final keyBytes = base64.decode(key);
    final plainBytes = utf8.encode(plainText);
    final xorBytes = List<int>.generate(
      plainBytes.length,
      (i) => plainBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64.encode(xorBytes);
  }

  // Helper: create a CBC-encrypted secret (24-char base64 IV prefix)
  Future<String> cbcEncrypt(String plainText) async {
    await encryptionService.encrypt('init');
    final key = fakeSecureStorage[AppConstants.encryptionKeyAlias]!;
    // Use the encryption service to encrypt, then manually check format
    // For CBC, we'd need 16-byte IV → 24 base64 chars. Since the current service
    // uses GCM (12-byte → 16 base64), we simulate a CBC-format value.
    final keyBytes = base64.decode(key);

    // Use the encrypt package directly to create CBC-encrypted data
    final encKey = enc.Key(Uint8List.fromList(keyBytes));
    final iv = enc.IV.fromSecureRandom(16); // 16-byte IV → 24 base64 chars
    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return '${iv.base64}:${encrypted.base64}';
  }

  // ─── XOR → AES migration ─────────────────────────────────────────────────

  group('XOR → AES migration', () {
    test('migrates XOR-encrypted accounts to AES-GCM', () async {
      final xorSecret = await xorEncrypt('JBSWY3DPEHPK3PXP');
      // XOR secrets have no ':' separator
      expect(xorSecret.contains(':'), isFalse);

      await db.createAccount(Account(
        name: 'Test',
        secret: xorSecret,
        type: 'totp',
      ));

      final didMigrate = await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );
      expect(didMigrate, isTrue);

      final accounts = await db.getAllAccounts();
      final migratedSecret = accounts.first.secret;
      // Should now be in GCM format (<16-char nonce>:<ciphertext>)
      expect(migratedSecret, contains(':'));
      final parts = migratedSecret.split(':');
      expect(parts[0].length, AppConstants.gcmNonceBase64Length);

      // Should decrypt back to original
      final decrypted = await encryptionService.decrypt(migratedSecret);
      expect(decrypted, 'JBSWY3DPEHPK3PXP');
    });

    test('skips accounts already in AES format', () async {
      // Create an AES-GCM encrypted secret
      final aesSecret = await encryptionService.encrypt('ALREADY_AES');
      expect(aesSecret, contains(':'));

      await db.createAccount(Account(
        name: 'Already Migrated',
        secret: aesSecret,
        type: 'totp',
      ));

      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );

      final accounts = await db.getAllAccounts();
      // Secret should still decrypt correctly
      final decrypted = await encryptionService.decrypt(accounts.first.secret);
      expect(decrypted, 'ALREADY_AES');
    });

    test('sets migration flag after completion', () async {
      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );

      expect(await migrationService.isMigrationComplete(), isTrue);
    });

    test('does not re-run if migration flag is already set', () async {
      // First run
      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );
      migrationStatuses.clear();

      // Second run — should be a no-op
      final didMigrate = await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );
      expect(didMigrate, isFalse);
    });
  });

  // ─── CBC → GCM migration ─────────────────────────────────────────────────

  group('CBC → GCM migration', () {
    test('migrates CBC-encrypted accounts to GCM', () async {
      final cbcSecret = await cbcEncrypt('CBC_SECRET');
      // CBC secrets have 24-char base64 IV prefix
      final ivPart = cbcSecret.split(':')[0];
      expect(ivPart.length, AppConstants.cbcIvBase64Length);

      await db.createAccount(Account(
        name: 'CBC Account',
        secret: cbcSecret,
        type: 'totp',
      ));

      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );

      final accounts = await db.getAllAccounts();
      final migratedSecret = accounts.first.secret;
      // Should now be in GCM format (16-char nonce prefix)
      final parts = migratedSecret.split(':');
      expect(parts[0].length, AppConstants.gcmNonceBase64Length);

      final decrypted = await encryptionService.decrypt(migratedSecret);
      expect(decrypted, 'CBC_SECRET');
    });

    test('leaves GCM-encrypted accounts unchanged', () async {
      final gcmSecret = await encryptionService.encrypt('GCM_SECRET');
      final originalParts = gcmSecret.split(':');
      expect(originalParts[0].length, AppConstants.gcmNonceBase64Length);

      await db.createAccount(Account(
        name: 'GCM Account',
        secret: gcmSecret,
        type: 'totp',
      ));

      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );

      final accounts = await db.getAllAccounts();
      // GCM account should still decrypt correctly
      final decrypted = await encryptionService.decrypt(accounts.first.secret);
      expect(decrypted, 'GCM_SECRET');
    });

    test('sets GCM migration flag after completion', () async {
      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConstants.gcmMigrationKey), isTrue);
    });
  });

  // ─── Empty database ───────────────────────────────────────────────────────

  group('empty database', () {
    test('handles empty accounts list without error', () async {
      final didMigrate = await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );
      // XOR migration returns false (no accounts), but GCM migration returns true (flag was unset)
      expect(didMigrate, isTrue);
      expect(await migrationService.isMigrationComplete(), isTrue);
    });
  });

  // ─── Status callbacks ─────────────────────────────────────────────────────

  group('status callbacks', () {
    test('calls onStatusChanged(true) then onStatusChanged(false)', () async {
      final xorSecret = await xorEncrypt('SECRET');
      await db.createAccount(Account(
        name: 'Test',
        secret: xorSecret,
        type: 'totp',
      ));

      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );

      // Should have been called with true (start) and false (end) for each migration
      expect(migrationStatuses, contains(true));
      expect(migrationStatuses.last, isFalse);
    });
  });

  // ─── Force migration ──────────────────────────────────────────────────────

  group('forceMigration', () {
    test('resets flag and re-runs XOR→AES migration', () async {
      // First run sets the flag
      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );
      expect(await migrationService.isMigrationComplete(), isTrue);

      // Force migration resets and re-runs
      await migrationService.forceMigration(onStatusChanged: statusCallback);
      expect(await migrationService.isMigrationComplete(), isTrue);
    });
  });

  // ─── Multiple accounts with mixed encryption ─────────────────────────────

  group('mixed encryption accounts', () {
    test('migrates only XOR accounts, leaves AES accounts intact', () async {
      final xorSecret = await xorEncrypt('XOR_PLAIN');
      final aesSecret = await encryptionService.encrypt('AES_PLAIN');

      await db.createAccount(Account(name: 'XOR', secret: xorSecret, type: 'totp'));
      await db.createAccount(Account(name: 'AES', secret: aesSecret, type: 'totp'));

      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );

      final accounts = await db.getAllAccounts();
      for (final account in accounts) {
        expect(account.secret, contains(':'));
        final decrypted = await encryptionService.decrypt(account.secret);
        if (account.name == 'XOR') {
          expect(decrypted, 'XOR_PLAIN');
        } else {
          expect(decrypted, 'AES_PLAIN');
        }
      }
    });
  });

  // ─── isMigrationComplete ──────────────────────────────────────────────────

  group('isMigrationComplete', () {
    test('returns false before migration', () async {
      expect(await migrationService.isMigrationComplete(), isFalse);
    });

    test('returns true after migration', () async {
      await migrationService.runPendingMigrations(
        onStatusChanged: statusCallback,
      );
      expect(await migrationService.isMigrationComplete(), isTrue);
    });
  });
}
