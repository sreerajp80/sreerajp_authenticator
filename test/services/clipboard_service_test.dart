import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/services/clipboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const clipboardChannel = MethodChannel('sreerajp_authenticator/clipboard');
  const clearAfter = Duration(milliseconds: 10);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late String? stored;
  late bool readable;
  late List<String> nativeWrites;

  setUp(() {
    stored = null;
    readable = true;
    nativeWrites = [];
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        stored = (call.arguments as Map)['text'] as String?;
      } else if (call.method == 'Clipboard.getData') {
        return readable && stored != null ? {'text': stored} : null;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(clipboardChannel, (call) async {
      nativeWrites.add(call.arguments as String);
      stored = call.arguments as String;
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    messenger.setMockMethodCallHandler(clipboardChannel, null);
  });

  Future<void> waitForClear() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('uses the sensitive channel on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await ClipboardService.copySecret('123456', clearAfter: clearAfter);

    expect(nativeWrites, ['123456']);
    expect(stored, '123456');
    await waitForClear();
  });

  test('clearPendingSecret clears a copied secret right away', () async {
    await ClipboardService.copySecret('123456', clearAfter: clearAfter);

    await ClipboardService.clearPendingSecret();

    expect(stored, isNot('123456'));
    await waitForClear();
  });

  test('uses the normal clipboard on other platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await ClipboardService.copySecret('123456', clearAfter: clearAfter);

    expect(nativeWrites, isEmpty);
    expect(stored, '123456');
    await waitForClear();
  });

  test('falls back when the native channel is missing', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    messenger.setMockMethodCallHandler(clipboardChannel, null);

    await ClipboardService.copySecret('123456', clearAfter: clearAfter);

    expect(stored, '123456');
    await waitForClear();
  });

  test('clears the copied text after the time limit', () async {
    await ClipboardService.copySecret('123456', clearAfter: clearAfter);
    await waitForClear();

    expect(stored, '');
  });

  test('leaves different text alone', () async {
    await ClipboardService.copySecret('123456', clearAfter: clearAfter);
    stored = 'something else';
    await waitForClear();

    expect(stored, 'something else');
  });

  test(
    'clears when the clipboard cannot be read from the background',
    () async {
      await ClipboardService.copySecret('123456', clearAfter: clearAfter);
      readable = false;
      await waitForClear();

      expect(stored, '');
    },
  );
}
