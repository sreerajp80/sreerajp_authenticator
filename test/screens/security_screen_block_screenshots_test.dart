import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/security_screen.dart';

import '../providers/provider_test_helpers.dart';

/// The screenshot setting: on by default, saved, warned about, Android only.
void main() {
  configureProviderTestBindings();

  const channel = MethodChannel('screen_protector');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final l10n = lookupAppLocalizations(const Locale('en'));
  late List<String> calls;
  late bool pluginFails;

  setUp(() async {
    await setUpProviderTestEnvironment();
    calls = [];
    pluginFails = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (pluginFails) throw PlatformException(code: 'failed');
      calls.add(call.method);
      return true;
    });
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
    await tearDownProviderTestEnvironment();
  });

  Future<SettingsProvider> newProvider() async {
    final provider = SettingsProvider();
    await provider.initialized;
    return provider;
  }

  group('SettingsProvider', () {
    test('blocks screenshots by default', () async {
      final provider = await newProvider();

      expect(provider.blockScreenshots, isTrue);
      expect(
        SettingsProvider.readBlockScreenshots(
          await SharedPreferences.getInstance(),
        ),
        isTrue,
      );
    });

    test('saves the choice and applies it to the window', () async {
      final provider = await newProvider();

      await provider.setBlockScreenshots(false);

      expect(calls, ['preventScreenshotOff', 'protectDataLeakageOff']);
      expect((await newProvider()).blockScreenshots, isFalse);

      calls.clear();
      await provider.setBlockScreenshots(true);

      expect(calls, ['protectDataLeakageOn', 'preventScreenshotOn']);
      expect((await newProvider()).blockScreenshots, isTrue);
    });

    test('keeps protection on when the plugin call fails', () async {
      final provider = await newProvider();
      pluginFails = true;

      await expectLater(provider.setBlockScreenshots(false), throwsException);

      expect(provider.blockScreenshots, isTrue);
      expect((await newProvider()).blockScreenshots, isTrue);
    });
  });

  group('Security screen', () {
    Future<SettingsProvider> pumpScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      late final SettingsProvider provider;
      await tester.runAsync(() async => provider = await newProvider());
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: provider,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: LocaleConfig.localizationsDelegates,
            supportedLocales: LocaleConfig.supportedLocales,
            home: const SecurityScreen(),
          ),
        ),
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      return provider;
    }

    Future<void> tapSwitch(WidgetTester tester) async {
      await tester.tap(find.text(l10n.labelBlockScreenshots));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('cancelling the warning keeps protection on', (tester) async {
      final provider = await pumpScreen(tester);

      await tapSwitch(tester);
      expect(find.text(l10n.descAllowScreenshotsWarning), findsOneWidget);

      await tester.tap(find.text(l10n.actionCancel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(provider.blockScreenshots, isTrue);
      expect(calls, isEmpty);
    });

    testWidgets('confirming the warning turns protection off', (tester) async {
      final provider = await pumpScreen(tester);

      await tapSwitch(tester);
      await tester.tap(find.text(l10n.actionConfirm));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();

      expect(provider.blockScreenshots, isFalse);
    });

    testWidgets('the switch is hidden on Windows', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpScreen(tester);

      expect(find.text(l10n.labelBlockScreenshots), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
