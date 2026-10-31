import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';

void main() {
  // Use FFI-backed sqflite so tests run without a real Android/iOS host.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService db;

  setUp(() async {
    await DatabaseService.resetForTesting();
    DatabaseService.testDbPath = inMemoryDatabasePath;
    db = DatabaseService.instance;
  });

  tearDown(() async {
    await DatabaseService.resetForTesting();
    DatabaseService.testDbPath = null;
  });

  // ─── HOTP counter ──────────────────────────────────────────────────────────

  group('setHotpCounter', () {
    Account make(String type, int? counter) => Account(
      name: type,
      secret: 'JBSWY3DPEHPK3PXP',
      type: type,
      counter: counter,
      digits: 6,
      period: 30,
      algorithm: 'SHA1',
    );

    Future<int?> stored(int id) async =>
        (await db.getAllAccounts()).firstWhere((a) => a.id == id).counter;

    test('moves an HOTP counter', () async {
      final id = await db.createAccount(make('hotp', 4));
      expect(await db.setHotpCounter(id, 4, 5), 1);
      expect(await stored(id), 5);
    });

    test('a null counter counts as 0', () async {
      final id = await db.createAccount(make('hotp', null));
      expect(await db.setHotpCounter(id, 0, 1), 1);
      expect(await stored(id), 1);
    });

    test('a stale expected value changes nothing', () async {
      final id = await db.createAccount(make('hotp', 4));
      expect(await db.setHotpCounter(id, 3, 4), 0);
      expect(await stored(id), 4);
    });

    test('never changes an account that is not HOTP', () async {
      final id = await db.createAccount(make('totp', 1234));
      expect(await db.setHotpCounter(id, 1234, 1235), 0);
      expect(await stored(id), 1234);
    });
  });

  // ─── Account CRUD ──────────────────────────────────────────────────────────

  group('Account CRUD', () {
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
      );
    }

    test('createAccount returns a positive id', () async {
      final id = await db.createAccount(makeAccount());
      expect(id, greaterThan(0));
    });

    test('getAllAccounts returns empty list initially', () async {
      final accounts = await db.getAllAccounts();
      expect(accounts, isEmpty);
    });

    test('getAllAccounts returns created accounts', () async {
      await db.createAccount(makeAccount(name: 'GitHub'));
      await db.createAccount(makeAccount(name: 'Google', issuer: 'Google'));

      final accounts = await db.getAllAccounts();
      expect(accounts.length, 2);
      expect(accounts.map((a) => a.name), containsAll(['GitHub', 'Google']));
    });

    test('created account preserves all fields', () async {
      final id = await db.createAccount(
        makeAccount(
          name: 'AWS',
          secret: 'MYSECRET',
          type: 'hotp',
          issuer: 'Amazon',
          digits: 8,
          period: 60,
          algorithm: 'SHA256',
          sortOrder: 5,
        ),
      );

      final accounts = await db.getAllAccounts();
      final account = accounts.firstWhere((a) => a.id == id);

      expect(account.name, 'AWS');
      expect(account.secret, 'MYSECRET');
      expect(account.type, 'hotp');
      expect(account.issuer, 'Amazon');
      expect(account.digits, 8);
      expect(account.period, 60);
      expect(account.algorithm, 'SHA256');
      expect(account.sortOrder, 5);
    });

    test('updateAccount modifies existing account', () async {
      await db.createAccount(makeAccount(name: 'Old Name'));
      final accounts = await db.getAllAccounts();
      final original = accounts.first;

      final updated = original.copyWith(name: 'New Name', issuer: 'Updated');
      final rowsAffected = await db.updateAccount(updated);
      expect(rowsAffected, 1);

      final refreshed = await db.getAllAccounts();
      expect(refreshed.first.name, 'New Name');
      expect(refreshed.first.issuer, 'Updated');
    });

    test('deleteAccount removes the account', () async {
      final id = await db.createAccount(makeAccount());
      expect((await db.getAllAccounts()).length, 1);

      final rowsDeleted = await db.deleteAccount(id);
      expect(rowsDeleted, 1);
      expect(await db.getAllAccounts(), isEmpty);
    });

    test('deleteAccount with non-existent id affects 0 rows', () async {
      final rowsDeleted = await db.deleteAccount(9999);
      expect(rowsDeleted, 0);
    });

    test('getAllAccounts orders by sortOrder then createdAt', () async {
      await db.createAccount(makeAccount(name: 'C', sortOrder: 2));
      await db.createAccount(makeAccount(name: 'A', sortOrder: 0));
      await db.createAccount(makeAccount(name: 'B', sortOrder: 1));

      final accounts = await db.getAllAccounts();
      expect(accounts[0].name, 'A');
      expect(accounts[1].name, 'B');
      expect(accounts[2].name, 'C');
    });
  });

  // ─── Tags ─────────────────────────────────────────────────────────────────

  group('Account tags', () {
    test('account with tags round-trips through DB', () async {
      final id = await db.createAccount(
        Account(
          name: 'Work Account',
          secret: 'SECRET',
          type: 'totp',
          tags: ['Work', 'Finance'],
        ),
      );

      final accounts = await db.getAllAccounts();
      final account = accounts.firstWhere((a) => a.id == id);
      expect(account.tags, containsAll(['Work', 'Finance']));
    });

    test('account with no tags has empty list', () async {
      await db.createAccount(
        Account(name: 'Untagged', secret: 'SECRET', type: 'totp'),
      );

      final accounts = await db.getAllAccounts();
      expect(accounts.first.tags, isEmpty);
    });
  });

  // ─── Schema ────────────────────────────────────────────────────────────────

  group('schema', () {
    test('database is created with accounts table', () async {
      // Trigger database initialization
      await db.getAllAccounts();

      // Verify accounts table works
      final id = await db.createAccount(
        Account(name: 'Test', secret: 'S', type: 'totp'),
      );
      expect(id, greaterThan(0));
    });

    test('multiple accounts can be created with auto-increment ids', () async {
      final id1 = await db.createAccount(
        Account(name: 'A', secret: 'S', type: 'totp'),
      );
      final id2 = await db.createAccount(
        Account(name: 'B', secret: 'S', type: 'totp'),
      );
      final id3 = await db.createAccount(
        Account(name: 'C', secret: 'S', type: 'totp'),
      );

      expect(id1, lessThan(id2));
      expect(id2, lessThan(id3));
    });
  });
}
