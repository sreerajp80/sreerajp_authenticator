import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/providers/group_provider.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';

import 'provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  late DatabaseService db;

  setUp(() async {
    await setUpProviderTestEnvironment();
    db = DatabaseService.instance;
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  group('GroupsProvider', () {
    test('loads groups ordered by sortOrder', () async {
      await db.createGroup(makeGroup(name: 'Third', sortOrder: 2));
      await db.createGroup(makeGroup(name: 'First', sortOrder: 0));
      await db.createGroup(makeGroup(name: 'Second', sortOrder: 1));

      final provider = GroupsProvider();

      await waitForCondition(() => provider.groups.length == 3);

      expect(provider.groups.map((group) => group.name).toList(), [
        'First',
        'Second',
        'Third',
      ]);
    });

    test('addGroup persists the new group and reloads state', () async {
      final provider = GroupsProvider();
      await settleAsyncWork();

      await provider.addGroup(
        makeGroup(name: 'Personal', description: 'Personal accounts'),
      );

      final groups = await db.getAllGroups();

      expect(provider.groups, hasLength(1));
      expect(provider.groups.single.name, 'Personal');
      expect(groups, hasLength(1));
      expect(groups.single.description, 'Personal accounts');
    });

    test('deleteGroup unassigns accounts and invokes callback', () async {
      final groupId = await db.createGroup(makeGroup(name: 'Work'));
      await db.createAccount(makeAccount(name: 'Slack', groupId: groupId));

      final provider = GroupsProvider();
      await waitForCondition(() => provider.groups.length == 1);

      var callbackCalled = false;
      await provider.deleteGroup(
        groupId,
        onAccountsUnassigned: () {
          callbackCalled = true;
        },
      );

      final accounts = await db.getAllAccounts();
      final groups = await db.getAllGroups();

      expect(callbackCalled, isTrue);
      expect(groups, isEmpty);
      expect(accounts.single.groupId, isNull);
    });

    test('reorderGroups updates persisted sort order', () async {
      await db.createGroup(makeGroup(name: 'Alpha', sortOrder: 0));
      await db.createGroup(makeGroup(name: 'Beta', sortOrder: 1));
      await db.createGroup(makeGroup(name: 'Gamma', sortOrder: 2));

      final provider = GroupsProvider();
      await waitForCondition(() => provider.groups.length == 3);

      provider.reorderGroups(0, 3);
      await settleAsyncWork();
      await provider.loadGroups();

      expect(provider.groups.map((group) => group.name).toList(), [
        'Beta',
        'Gamma',
        'Alpha',
      ]);
      expect(provider.groups.map((group) => group.sortOrder).toList(), [
        0,
        1,
        2,
      ]);
    });
  });
}
