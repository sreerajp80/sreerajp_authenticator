import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/services/export_import_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

void main() {
  const password = 'correct horse';
  final service = ExportImportService();
  late Directory dir;

  Map<String, dynamic> accountMap({String name = 'GitHub'}) => {
    'name': name,
    'secret': 'JBSWY3DPEHPK3PXP',
    'type': 'totp',
    'digits': 6,
    'period': 30,
    'algorithm': 'SHA1',
    'sortOrder': 0,
    'createdAt': DateTime(2025, 10, 1).toIso8601String(),
  };

  Future<File> writeFile(String content) async {
    final file = File('${dir.path}/backup.aes');
    await file.writeAsString(content);
    return file;
  }

  Future<File> writeBackup(List<Map<String, dynamic>> accounts) => writeFile(
    service.encryptDataForTest(jsonEncode({'accounts': accounts}), password),
  );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('backup_limits');
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  test('reads a valid backup', () async {
    final file = await writeBackup([accountMap()]);

    final result = await service.readBackupFile(file, password);

    final accounts = result['accounts'] as List<Account>;
    expect(accounts.single.name, 'GitHub');
  });

  test('rejects a file above the size limit without reading it', () async {
    final file = File('${dir.path}/backup.aes');
    final raf = await file.open(mode: FileMode.write);
    await raf.truncate(AppConstants.backupMaxFileBytes + 1);
    await raf.close();

    expect(
      service.readBackupFile(file, password),
      throwsA(isA<BackupFileTooLargeException>()),
    );
  });

  test('rejects a wrong password', () async {
    final file = await writeBackup([accountMap()]);

    expect(
      service.readBackupFile(file, 'wrong password'),
      throwsA(isA<BackupPasswordException>()),
    );
  });

  test('rejects a damaged file', () async {
    final file = await writeFile('v3:not:a:backup');

    expect(
      service.readBackupFile(file, password),
      throwsA(isA<BackupPasswordException>()),
    );
  });

  test('rejects a file that is not text', () async {
    final file = File('${dir.path}/backup.aes');
    await file.writeAsBytes([0xFF, 0xFE, 0x00, 0xC3, 0x28]);

    expect(
      service.readBackupFile(file, password),
      throwsA(isA<BackupPasswordException>()),
    );
  });

  test('rejects too many accounts', () async {
    final file = await writeBackup(
      List.filled(AppConstants.syncMaxAccounts + 1, accountMap()),
    );

    expect(
      service.readBackupFile(file, password),
      throwsA(isA<BackupContentException>()),
    );
  });

  test('rejects an over-long field', () async {
    final file = await writeBackup([
      accountMap(name: 'x' * (AppConstants.syncMaxFieldLength + 1)),
    ]);

    expect(
      service.readBackupFile(file, password),
      throwsA(isA<BackupContentException>()),
    );
  });

  test('rejects decrypted content that is not valid JSON', () async {
    final file = await writeFile(service.encryptDataForTest('nope', password));

    expect(
      service.readBackupFile(file, password),
      throwsA(isA<BackupContentException>()),
    );
  });
}
