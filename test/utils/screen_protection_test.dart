import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/utils/screen_protection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('screen_protector');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String> calls;

  setUp(() {
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('turns protection on for Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await enableScreenProtection();

    expect(calls, ['protectDataLeakageOn', 'preventScreenshotOn']);
  });

  test('turns protection off for Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await disableScreenProtection();

    expect(calls, ['preventScreenshotOff', 'protectDataLeakageOff']);
  });

  for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
    test('does not call the plugin on ${platform.name}', () async {
      debugDefaultTargetPlatformOverride = platform;

      await enableScreenProtection();
      await disableScreenProtection();

      expect(calls, isEmpty);
      expect(isScreenProtectionSupported, isFalse);
    });
  }
}
