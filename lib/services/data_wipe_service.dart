// File Path: sreerajp_authenticator/lib/services/data_wipe_service.dart
// Author: Sreeraj P
// Description: Deletes all local app data for the "Delete all data" action
// (docs/security.md §13).

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';
import 'database_service.dart';

class DataWipeService {
  DataWipeService({Future<List<Directory>> Function()? appDirectories})
    : _appDirectories = appDirectories ?? _defaultDirectories;

  static const _secureStorage = FlutterSecureStorage();

  final Future<List<Directory>> Function() _appDirectories;

  static Future<List<Directory>> _defaultDirectories() async => [
    await getTemporaryDirectory(),
    await getApplicationDocumentsDirectory(),
    await getApplicationSupportDirectory(),
  ];

  /// Runs every step, even after one fails, and returns whether all worked.
  /// The database goes first: if it cannot be deleted, the key and PIN remain,
  /// so nothing is half lost and the user can try again.
  Future<bool> wipeAll() async {
    final steps = <String, Future<void> Function()>{
      'database': DatabaseService.instance.deleteAllData,
      'secure storage': _secureStorage.deleteAll,
      'preferences': _clearPreferences,
      'files': _deleteFiles,
    };

    var success = true;
    for (final step in steps.entries) {
      try {
        await step.value();
      } catch (e) {
        AppLogger.error('Could not delete ${step.key}', e);
        success = false;
      }
    }
    return success;
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _deleteFiles() async {
    for (final directory in await _appDirectories()) {
      if (!await directory.exists()) continue;
      await for (final entry in directory.list()) {
        await entry.delete(recursive: true);
      }
    }
  }
}
