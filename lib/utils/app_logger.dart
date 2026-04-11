import 'package:flutter/foundation.dart';

import '../config/app_flavor_config.dart';

class AppLogger {
  static bool get _shouldLog => AppFlavorConfig.instance.enableVerboseLogging;

  static void verbose(String message) {
    if (!_shouldLog) {
      return;
    }

    debugPrint(message);
  }

  static void error(String operation, [Object? error]) {
    if (!_shouldLog) {
      return;
    }

    final suffix = error == null ? '' : ' (${error.runtimeType})';
    debugPrint('$operation$suffix');
  }
}
