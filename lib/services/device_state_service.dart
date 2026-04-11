import 'package:flutter/services.dart';

import '../utils/constants.dart';

class DeviceStateService {
  static const MethodChannel _channel = MethodChannel(
    AppConstants.deviceStateChannel,
  );

  Future<int?> getBootCount() async {
    try {
      final count = await _channel.invokeMethod<int>(
        AppConstants.getBootCountMethod,
      );
      return count;
    } on PlatformException {
      return null;
    }
  }
}
