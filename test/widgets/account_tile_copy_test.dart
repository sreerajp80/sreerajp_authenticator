import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/services/encryption_service.dart';
import 'package:sreerajp_authenticator/widgets/account_tile.dart';

import '../providers/provider_test_helpers.dart';

/// One tap on the tile copies the code, as the help text says. The tile gets
/// an onTap here because the home screen always passes one, which is what
/// used to switch copying off.
void main() {
  configureProviderTestBindings();

  String? clipboard;
  const clipboardChannel = MethodChannel('sreerajp_authenticator/clipboard');

  setUp(() async {
    await setUpProviderTestEnvironment(sharedPreferences: const {});
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          } else if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': clipboard};
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(clipboardChannel, (call) async {
          clipboard = call.arguments as String;
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(clipboardChannel, null);
    await tearDownProviderTestEnvironment();
  });

  Future<int Function()> pumpTile(
    WidgetTester tester, {
    bool selectionMode = false,
  }) async {
    var taps = 0;
    final secret = await tester.runAsync(
      () => EncryptionService().encrypt('JBSWY3DPEHPK3PXP'),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: LocaleConfig.localizationsDelegates,
        supportedLocales: LocaleConfig.supportedLocales,
        home: Scaffold(
          body: AccountTile(
            account: makeAccount(name: 'Acme', secret: secret!),
            isSelectionMode: selectionMode,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    // Let the first code be made from the encrypted secret.
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    return () => taps;
  }

  Future<void> removeTile(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 31));
  }

  testWidgets('a tap copies the real code while it is hidden', (tester) async {
    final taps = await pumpTile(tester);
    expect(find.text('*** ***'), findsOneWidget);

    await tester.tap(find.text('Acme'));
    await tester.pump(const Duration(milliseconds: 50));

    expect(clipboard, matches(RegExp(r'^\d{6}$')));
    expect(taps(), 1);
    expect(find.text('*** ***'), findsOneWidget);
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.descCodeCopied('Acme')), findsOneWidget);
    await removeTile(tester);
  });

  testWidgets('selection mode selects and copies nothing', (tester) async {
    final taps = await pumpTile(tester, selectionMode: true);

    await tester.tap(find.text('Acme'));
    await tester.pump(const Duration(milliseconds: 50));

    expect(clipboard, isNull);
    expect(taps(), 1);
    await removeTile(tester);
  });

  testWidgets('a hidden code is announced as hidden, never read out', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTile(tester);
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(find.bySemanticsLabel(RegExp(l10n.descCodeHidden)), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'\*')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(l10n.tooltipShowCode)), findsOneWidget);
    handle.dispose();
    await removeTile(tester);
  });

  testWidgets('the eye button does not copy', (tester) async {
    final taps = await pumpTile(tester);

    await tester.tap(find.byIcon(Icons.visibility_rounded));
    await tester.pump(const Duration(milliseconds: 50));

    expect(clipboard, isNull);
    expect(taps(), 0);
    expect(find.textContaining(RegExp(r'^\d{3} \d{3}$')), findsOneWidget);
    await removeTile(tester);
  });

  testWidgets('the clipboard clears after 30 seconds', (tester) async {
    await pumpTile(tester);
    await tester.tap(find.text('Acme'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(clipboard, isNotNull);

    await tester.pump(const Duration(seconds: 31));
    await tester.pump();
    expect(clipboard, isEmpty);
    await removeTile(tester);
  });

  testWidgets('a different clipboard value is left alone', (tester) async {
    await pumpTile(tester);
    await tester.tap(find.text('Acme'));
    await tester.pump(const Duration(milliseconds: 50));

    clipboard = 'something else';
    await tester.pump(const Duration(seconds: 31));
    await tester.pump();
    expect(clipboard, 'something else');
    await removeTile(tester);
  });
}
