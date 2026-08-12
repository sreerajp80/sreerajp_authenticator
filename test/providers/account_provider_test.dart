import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

import 'provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  late DatabaseService db;

  setUp(() async {
    await setUpProviderTestEnvironment(
      sharedPreferences: const {
        AppConstants.aesMigrationKey: true,
        AppConstants.gcmMigrationKey: true,
      },
    );
    db = DatabaseService.instance;
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  group('AccountsProvider', () {
    test('loads accounts ordered by sortOrder', () async {
      await db.createAccount(makeAccount(name: 'Third', sortOrder: 2));
      await db.createAccount(makeAccount(name: 'First', sortOrder: 0));
      await db.createAccount(makeAccount(name: 'Second', sortOrder: 1));

      final provider = AccountsProvider();

      await waitForCondition(
        () =>
            provider.accounts.length == 3 &&
            !provider.isLoading &&
            !provider.isPreDecrypting,
      );

      expect(provider.accounts.map((account) => account.name).toList(), [
        'First',
        'Second',
        'Third',
      ]);
    });

    test('addAccount encrypts the secret before persisting', () async {
      final provider = AccountsProvider();
      await settleAsyncWork();

      const plainSecret = 'JBSWY3DPEHPK3PXP';
      await provider.addAccount(
        makeAccount(name: 'GitHub', secret: plainSecret),
      );

      await waitForCondition(
        () => provider.accounts.length == 1 && !provider.isLoading,
      );

      final storedAccount = (await db.getAllAccounts()).single;

      expect(storedAccount.secret, isNot(plainSecret));
      expect(storedAccount.secret, contains(':'));
      expect(provider.accounts.single.secret, storedAccount.secret);
    });

    test('searchQuery filters accounts by name and issuer', () async {
      await db.createAccount(makeAccount(name: 'GitHub', issuer: 'GitHub'));
      await db.createAccount(makeAccount(name: 'Workspace', issuer: 'Google'));
      await db.createAccount(makeAccount(name: 'Slack', issuer: 'Slack'));

      final provider = AccountsProvider();
      await waitForCondition(
        () =>
            provider.accounts.length == 3 &&
            !provider.isLoading &&
            !provider.isPreDecrypting,
      );

      provider.setSearchQuery('goo');

      expect(
        provider.filteredAccounts.map((account) => account.name).toList(),
        ['Workspace'],
      );

      provider.setSearchQuery('git');

      expect(
        provider.filteredAccounts.map((account) => account.name).toList(),
        ['GitHub'],
      );
    });

    test(
      'deleteMultipleAccounts removes records from memory and database',
      () async {
        final id1 = await db.createAccount(makeAccount(name: 'One'));
        final id2 = await db.createAccount(makeAccount(name: 'Two'));
        await db.createAccount(makeAccount(name: 'Three'));

        final provider = AccountsProvider();
        await waitForCondition(
          () =>
              provider.accounts.length == 3 &&
              !provider.isLoading &&
              !provider.isPreDecrypting,
        );

        await provider.deleteMultipleAccounts([id1, id2]);

        expect(provider.accounts.map((account) => account.name).toList(), [
          'Three',
        ]);
        expect(
          (await db.getAllAccounts()).map((account) => account.name).toList(),
          ['Three'],
        );
      },
    );

    test(
      'importData reports added/skipped counts and retains existing data',
      () async {
        // The receiver already has one account.
        await db.createAccount(makeAccount(name: 'GitHub', issuer: 'GitHub'));

        final provider = AccountsProvider();
        await waitForCondition(
          () =>
              provider.accounts.length == 1 &&
              !provider.isLoading &&
              !provider.isPreDecrypting,
        );

        final data = <String, dynamic>{
          'accounts': [
            // Duplicate (name + issuer + type) → skipped, existing retained.
            makeAccount(name: 'GitHub', issuer: 'GitHub'),
            // New → added.
            makeAccount(name: 'Slack', issuer: 'Slack'),
          ],
        };

        final result = await provider.importData(data);

        expect(result.accountsAdded, 1);
        expect(result.accountsSkipped, 1);
        expect(provider.accounts.length, 2);
      },
    );

    test('renameTag renames tag across all member accounts', () async {
      await db.createAccount(
        makeAccount(name: 'GitHub', tags: ['Work', 'Dev']),
      );
      await db.createAccount(makeAccount(name: 'AWS', tags: ['Work', 'Cloud']));

      final provider = AccountsProvider();
      await waitForCondition(
        () =>
            provider.accounts.length == 2 &&
            !provider.isLoading &&
            !provider.isPreDecrypting,
      );

      expect(provider.getAccountCountForTag('Work'), 2);

      await provider.renameTag('Work', 'Job');

      expect(provider.getAccountCountForTag('Work'), 0);
      expect(provider.getAccountCountForTag('Job'), 2);

      final accounts = await db.getAllAccounts();
      for (final a in accounts) {
        expect(a.tags.contains('Job'), isTrue);
        expect(a.tags.contains('Work'), isFalse);
      }
    });

    test('deleteTag removes tag across all member accounts', () async {
      await db.createAccount(
        makeAccount(name: 'GitHub', tags: ['Work', 'Dev']),
      );

      final provider = AccountsProvider();
      await waitForCondition(
        () =>
            provider.accounts.length == 1 &&
            !provider.isLoading &&
            !provider.isPreDecrypting,
      );

      await provider.deleteTag('Work');

      expect(provider.getAccountCountForTag('Work'), 0);
      final stored = (await db.getAllAccounts()).single;
      expect(stored.tags, ['Dev']);
    });

    test(
      'bulkUpdateTags appends or replaces tags on selected accounts',
      () async {
        final id1 = await db.createAccount(
          makeAccount(name: 'GitHub', tags: ['Dev']),
        );
        final id2 = await db.createAccount(
          makeAccount(name: 'AWS', tags: ['Cloud']),
        );

        final provider = AccountsProvider();
        await waitForCondition(
          () =>
              provider.accounts.length == 2 &&
              !provider.isLoading &&
              !provider.isPreDecrypting,
        );

        // Append tags
        await provider.bulkUpdateTags([id1, id2], ['VIP']);

        expect(provider.getAccountCountForTag('VIP'), 2);

        final accountsAfterAppend = await db.getAllAccounts();
        final github = accountsAfterAppend.firstWhere((a) => a.id == id1);
        final aws = accountsAfterAppend.firstWhere((a) => a.id == id2);

        expect(github.tags, ['Dev', 'VIP']);
        expect(aws.tags, ['Cloud', 'VIP']);

        // Replace tags
        await provider.bulkUpdateTags([id1], ['Reassigned'], replace: true);

        final accountsAfterReplace = await db.getAllAccounts();
        final githubReplaced = accountsAfterReplace.firstWhere(
          (a) => a.id == id1,
        );
        expect(githubReplaced.tags, ['Reassigned']);
      },
    );
  });
}
