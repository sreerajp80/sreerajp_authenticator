import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/models/group.dart';
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
      final id = await db.createAccount(makeAccount(
        name: 'AWS',
        secret: 'MYSECRET',
        type: 'hotp',
        issuer: 'Amazon',
        digits: 8,
        period: 60,
        algorithm: 'SHA256',
        sortOrder: 5,
      ));

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

  // ─── Group CRUD ────────────────────────────────────────────────────────────

  group('Group CRUD', () {
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
        createdAt: DateTime.now(),
      );
    }

    test('createGroup returns a positive id', () async {
      final id = await db.createGroup(makeGroup());
      expect(id, greaterThan(0));
    });

    test('getAllGroups returns empty list initially', () async {
      final groups = await db.getAllGroups();
      expect(groups, isEmpty);
    });

    test('getAllGroups returns created groups', () async {
      await db.createGroup(makeGroup(name: 'Work'));
      await db.createGroup(makeGroup(name: 'Personal'));

      final groups = await db.getAllGroups();
      expect(groups.length, 2);
      expect(groups.map((g) => g.name), containsAll(['Work', 'Personal']));
    });

    test('created group preserves all fields', () async {
      final id = await db.createGroup(makeGroup(
        name: 'Finance',
        description: 'Banking apps',
        color: 'green',
        icon: 'bank',
        sortOrder: 3,
      ));

      final groups = await db.getAllGroups();
      final group = groups.firstWhere((g) => g.id == id);

      expect(group.name, 'Finance');
      expect(group.description, 'Banking apps');
      expect(group.color, 'green');
      expect(group.icon, 'bank');
      expect(group.sortOrder, 3);
    });

    test('updateGroup modifies existing group', () async {
      await db.createGroup(makeGroup(name: 'Old'));
      final groups = await db.getAllGroups();
      final original = groups.first;

      final updated = original.copyWith(name: 'New', color: 'red');
      final rowsAffected = await db.updateGroup(updated);
      expect(rowsAffected, 1);

      final refreshed = await db.getAllGroups();
      expect(refreshed.first.name, 'New');
      expect(refreshed.first.color, 'red');
    });

    test('deleteGroup removes the group', () async {
      final id = await db.createGroup(makeGroup());
      expect((await db.getAllGroups()).length, 1);

      final rowsDeleted = await db.deleteGroup(id);
      expect(rowsDeleted, 1);
      expect(await db.getAllGroups(), isEmpty);
    });

    test('deleteGroup with non-existent id affects 0 rows', () async {
      final rowsDeleted = await db.deleteGroup(9999);
      expect(rowsDeleted, 0);
    });

    test('getAllGroups orders by sortOrder then name', () async {
      await db.createGroup(makeGroup(name: 'C', sortOrder: 2));
      await db.createGroup(makeGroup(name: 'A', sortOrder: 0));
      await db.createGroup(makeGroup(name: 'B', sortOrder: 1));

      final groups = await db.getAllGroups();
      expect(groups[0].name, 'A');
      expect(groups[1].name, 'B');
      expect(groups[2].name, 'C');
    });
  });

  // ─── Foreign key behavior ─────────────────────────────────────────────────

  group('foreign key: groupId', () {
    test('account can reference a group', () async {
      final groupId = await db.createGroup(Group(name: 'Work', createdAt: DateTime.now()));
      await db.createAccount(Account(
        name: 'Slack',
        secret: 'SECRET',
        type: 'totp',
        groupId: groupId,
      ));

      final accounts = await db.getAllAccounts();
      expect(accounts.first.groupId, groupId);
    });

    test('account groupId is nullable', () async {
      await db.createAccount(Account(
        name: 'Ungrouped',
        secret: 'SECRET',
        type: 'totp',
      ));

      final accounts = await db.getAllAccounts();
      expect(accounts.first.groupId, isNull);
    });
  });

  // ─── Schema ────────────────────────────────────────────────────────────────

  group('schema', () {
    test('database is created with correct tables', () async {
      // Trigger database initialization
      await db.getAllAccounts();

      // Verify by inserting and reading — if tables don't exist, these throw
      final groupId = await db.createGroup(Group(name: 'Test'));
      final accountId = await db.createAccount(Account(
        name: 'Test',
        secret: 'S',
        type: 'totp',
        groupId: groupId,
      ));

      expect(groupId, greaterThan(0));
      expect(accountId, greaterThan(0));
    });

    test('multiple accounts can be created with auto-increment ids', () async {
      final id1 = await db.createAccount(Account(name: 'A', secret: 'S', type: 'totp'));
      final id2 = await db.createAccount(Account(name: 'B', secret: 'S', type: 'totp'));
      final id3 = await db.createAccount(Account(name: 'C', secret: 'S', type: 'totp'));

      expect(id1, lessThan(id2));
      expect(id2, lessThan(id3));
    });
  });
}
