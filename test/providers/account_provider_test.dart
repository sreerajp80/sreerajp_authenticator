import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/services/google_migration_service.dart';

import '../services/google_migration_test_data.dart';
import 'provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  late DatabaseService db;

  setUp(() async {
    await setUpProviderTestEnvironment(sharedPreferences: const {});
    db = DatabaseService.instance;
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  group('nextHotpCode', () {
    const rfcSecret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';

    Future<AccountsProvider> withHotp() async {
      final provider = AccountsProvider();
      await settleAsyncWork();
      await provider.addAccount(
        makeAccount(type: 'hotp', counter: 0, secret: rfcSecret),
      );
      await waitForCondition(
        () => provider.accounts.length == 1 && !provider.isLoading,
      );
      return provider;
    }

    test('steps through the RFC 4226 values and saves the counter', () async {
      final provider = await withHotp();
      for (final expected in ['755224', '287082', '359152']) {
        final result = await provider.nextHotpCode(provider.accounts.first);
        expect(result.code, expected);
      }
      expect(provider.accounts.first.counter, 3);
      final saved = await db.getAllAccounts();
      expect(saved.single.counter, 3);
    });

    test('a stale save gives no code and does not move the counter', () async {
      final provider = await withHotp();
      final account = provider.accounts.first;
      // Another writer moved the counter after the list was loaded.
      await db.setHotpCounter(account.id!, 0, 9);

      final result = await provider.nextHotpCode(account);
      expect(result.isSuccess, isFalse);
      expect(result.code, isNull);
      expect((await db.getAllAccounts()).single.counter, 9);
    });
  });

  group('Google Authenticator import', () {
    test('an imported HOTP account continues from its counter', () async {
      final provider = AccountsProvider();
      await settleAsyncWork();
      final account = GoogleMigrationService.parse(
        migrationLink(
          migrationPayload([migrationAccount(type: 1, counter: 1)]),
        ),
      ).entries.single.account!;

      final result = await provider.importData({
        'accounts': [account],
      });
      expect(result.accountsAdded, 1);

      // RFC 4226 test value for counter 1.
      final code = await provider.nextHotpCode(provider.accounts.single);
      expect(code.code, '287082');
      expect((await db.getAllAccounts()).single.counter, 2);
    });

    test('the duplicate check matches what import skips', () async {
      final provider = AccountsProvider();
      await settleAsyncWork();
      final account = makeAccount(name: 'Me', issuer: 'Site');
      await provider.importData({
        'accounts': [account],
      });

      final same = makeAccount(name: 'ME', issuer: 'SITE');
      expect(
        provider.existingDuplicateKeys,
        contains(AccountsProvider.duplicateKey(same)),
      );
      final result = await provider.importData({
        'accounts': [same],
      });
      expect(result.accountsAdded, 0);
      expect(result.accountsSkipped, 1);
    });

    test('a failed save leaves no accounts', () async {
      final provider = AccountsProvider();
      await settleAsyncWork();
      // The second account breaks a NOT NULL column inside the transaction.
      final database = await db.database;
      await database.execute(
        "CREATE TRIGGER fail_second BEFORE INSERT ON accounts "
        "WHEN NEW.name = 'bad' BEGIN SELECT RAISE(ABORT, 'test'); END",
      );

      await expectLater(
        provider.importData({
          'accounts': [makeAccount(name: 'good'), makeAccount(name: 'bad')],
        }),
        throwsA(anything),
      );
      expect(await db.getAllAccounts(), isEmpty);
    });
  });

  group('AccountsProvider', () {
    test('reports a failed load, and clears it after a good load', () async {
      final provider = AccountsProvider();
      await waitForCondition(() => !provider.isLoading);
      expect(provider.loadFailed, isFalse);

      // A folder cannot be opened as a database.
      await DatabaseService.resetForTesting();
      final goodPath = DatabaseService.testDbPath;
      DatabaseService.testDbPath = Directory.systemTemp.path;
      await provider.loadAccounts();
      expect(provider.loadFailed, isTrue);
      expect(provider.accounts, isEmpty);

      DatabaseService.testDbPath = goodPath;
      await provider.loadAccounts();
      expect(provider.loadFailed, isFalse);
    });

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

    test('importData saves all new accounts with encrypted secrets', () async {
      final provider = AccountsProvider();
      await waitForCondition(() => !provider.isLoading);

      const plainSecret = 'JBSWY3DPEHPK3PXP';
      final result = await provider.importData({
        'accounts': [
          makeAccount(name: 'One', secret: plainSecret),
          makeAccount(name: 'Two', secret: plainSecret),
        ],
      });

      expect(result.accountsAdded, 2);
      final stored = await db.getAllAccounts();
      expect(stored.length, 2);
      for (final account in stored) {
        expect(account.secret, isNot(plainSecret));
      }
    });

    test('importData saves nothing if a write fails midway', () async {
      await db.createAccount(makeAccount(name: 'Existing'));
      final provider = AccountsProvider();
      await waitForCondition(
        () => provider.accounts.length == 1 && !provider.isLoading,
      );

      // Make the insert of the second new account fail.
      final database = await db.database;
      await database.execute('''
        CREATE TRIGGER fail_insert BEFORE INSERT ON accounts
        WHEN NEW.name = 'Bad'
        BEGIN SELECT RAISE(ABORT, 'test failure'); END
      ''');

      final data = <String, dynamic>{
        'accounts': [
          makeAccount(name: 'Good'),
          makeAccount(name: 'Bad'),
          makeAccount(name: 'Late'),
        ],
      };

      await expectLater(provider.importData(data), throwsA(anything));
      expect((await db.getAllAccounts()).map((a) => a.name).toList(), [
        'Existing',
      ]);

      // Running it again after the cause is gone adds every account.
      await database.execute('DROP TRIGGER fail_insert');
      final result = await provider.importData(data);
      expect(result.accountsAdded, 3);
      expect((await db.getAllAccounts()).length, 4);
    });

    test('importData saves nothing if an item is malformed', () async {
      final provider = AccountsProvider();
      await waitForCondition(() => !provider.isLoading);

      await expectLater(
        provider.importData({
          'accounts': [makeAccount(name: 'Good'), 'not an account'],
        }),
        throwsA(anything),
      );
      expect(await db.getAllAccounts(), isEmpty);
    });

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
