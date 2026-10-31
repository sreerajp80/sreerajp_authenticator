import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/services/data_wipe_service.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';

import '../providers/provider_test_helpers.dart';

/// "Delete all data" removes every store, and one failure does not stop the rest.
void main() {
  configureProviderTestBindings();

  late Directory folder;

  setUp(() async {
    await setUpProviderTestEnvironment(sharedPreferences: {'theme_mode': 2});
    folder = await Directory.systemTemp.createTemp('wipe_test');
    DatabaseService.testDbPath = '${folder.path}/test.db';
    fakeSecureStorage['authenticator_key'] = 'key';
    await DatabaseService.instance.createAccount(makeAccount());
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
    if (await folder.exists()) await folder.delete(recursive: true);
  });

  test('empties every store and leaves the folder itself', () async {
    final files = await Directory.systemTemp.createTemp('wipe_files');
    addTearDown(() => files.delete(recursive: true));
    await File('${files.path}/backup.aes').writeAsString('x');
    await Directory('${files.path}/sub').create();

    final result = await DataWipeService(appDirectories: () async => [files])
        .wipeAll();

    expect(result, isTrue);
    expect(fakeSecureStorage, isEmpty);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    expect(await files.exists(), isTrue);
    expect(await files.list().isEmpty, isTrue);
    expect(await File(DatabaseService.testDbPath!).exists(), isFalse);
  });

  test('the database works again afterward, empty', () async {
    await DataWipeService(appDirectories: () async => []).wipeAll();

    expect(await DatabaseService.instance.getAllAccounts(), isEmpty);
    await DatabaseService.instance.createAccount(makeAccount());
    expect(await DatabaseService.instance.getAllAccounts(), hasLength(1));
  });

  test('a failed step is reported and does not stop the others', () async {
    final result = await DataWipeService(
      appDirectories: () async => throw const FileSystemException('failed'),
    ).wipeAll();

    expect(result, isFalse);
    expect(fakeSecureStorage, isEmpty);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    expect(await File(DatabaseService.testDbPath!).exists(), isFalse);
  });

  test('a missing folder is not a failure', () async {
    final result = await DataWipeService(
      appDirectories: () async => [Directory('${folder.path}/missing')],
    ).wipeAll();

    expect(result, isTrue);
  });
}
