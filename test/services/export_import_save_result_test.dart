import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/services/export_import_service.dart';

void main() {
  const password = 'test-password';

  test('returns true and hands over the encrypted file when saved', () async {
    String? savedName;
    Uint8List? savedBytes;
    final service = ExportImportService(
      fileSaver: (fileName, bytes) async {
        savedName = fileName;
        savedBytes = bytes;
        return Uri.parse('content://test/backup.aes');
      },
    );

    final result = await service.exportAccountsEncrypted([], password);

    expect(result, isTrue);
    expect(savedName, endsWith('.aes'));
    final content = utf8.decode(savedBytes!);
    expect(content, startsWith('v3:'));
    expect(service.decryptDataForTest(content, password), isNotNull);
  });

  test('returns false when the user cancels the save screen', () async {
    final service = ExportImportService(fileSaver: (_, _) async => null);

    expect(await service.exportAccountsEncrypted([], password), isFalse);
  });

  test('returns false when saving fails', () async {
    final service = ExportImportService(
      fileSaver: (_, _) async => throw const FileSystemException('disk full'),
    );

    expect(await service.exportAccountsEncrypted([], password), isFalse);
  });
}
