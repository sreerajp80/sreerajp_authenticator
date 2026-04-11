import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/lock_screen.dart';
import 'package:sreerajp_authenticator/screens/security_screen.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

import '../providers/provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  Future<void> pumpWithProviders(
    WidgetTester tester,
    SettingsProvider settingsProvider,
    Widget child,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
        ],
        child: MaterialApp(home: child),
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('lock screen says Enter your App PIN when pin is required', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'app_lock_enabled': true,
      'require_authentication': true,
      'phone_lock_quick_unlock_enabled': true,
      'last_strong_auth_at_ms': DateTime.now()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch,
    });
    await tester.runAsync(() => AuthService().setPin('1234'));
    final settingsProvider = SettingsProvider();
    await settingsProvider.initialized;

    await pumpWithProviders(tester, settingsProvider, const LockScreen());

    expect(find.text('Enter your App PIN'), findsWidgets);
    expect(find.text('App PIN required after 1 hour'), findsOneWidget);
  });

  testWidgets('lockout banner does not overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'app_lock_enabled': true,
      'require_authentication': true,
      'phone_lock_quick_unlock_enabled': true,
      'last_strong_auth_at_ms': DateTime.now()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch,
    });
    await tester.runAsync(() => AuthService().setPin('1234'));
    fakeSecureStorage[AppConstants.lockoutUntilKey] = DateTime.now()
        .add(const Duration(seconds: 1795))
        .millisecondsSinceEpoch
        .toString();
    final settingsProvider = SettingsProvider();
    await settingsProvider.initialized;

    await pumpWithProviders(tester, settingsProvider, const LockScreen());

    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock with App PIN'));
    await tester.pump();

    expect(
      find.textContaining('Too many attempts. Try again in'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lock screen shows Phone Screen Lock guidance when quick unlock is allowed',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/local_auth'),
            (methodCall) async {
              switch (methodCall.method) {
                case 'isDeviceSupported':
                  return true;
                case 'deviceSupportsBiometrics':
                  return true;
                case 'getAvailableBiometrics':
                  return <String>['fingerprint'];
                case 'authenticate':
                  return false;
                default:
                  return null;
              }
            },
          );
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
      });
      await tester.runAsync(() => AuthService().setPin('1234'));
      final settingsProvider = SettingsProvider();
      await settingsProvider.initialized;

      await pumpWithProviders(tester, settingsProvider, const LockScreen());

      expect(
        find.text('Use your Phone Screen Lock or enter your App PIN'),
        findsOneWidget,
      );
      expect(find.text('Use Phone Screen Lock'), findsOneWidget);
    },
  );

  testWidgets('mandatory pin setup does not re-trigger phone lock on resume', (
    tester,
  ) async {
    var authenticateCalls = 0;
    const localAuthChannel = MethodChannel('plugins.flutter.io/local_auth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localAuthChannel, (methodCall) async {
          switch (methodCall.method) {
            case 'isDeviceSupported':
              return true;
            case 'authenticate':
              authenticateCalls += 1;
              return true;
            default:
              return null;
          }
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(localAuthChannel, null);
    });
    SharedPreferences.setMockInitialValues({
      'app_lock_enabled': true,
      'require_authentication': true,
      'lock_type': 'device_lock',
    });
    final settingsProvider = SettingsProvider();
    await settingsProvider.initialized;

    await pumpWithProviders(tester, settingsProvider, const LockScreen());
    await tester.pumpAndSettle();

    expect(find.text('Set Up App PIN'), findsOneWidget);
    expect(authenticateCalls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Set Up App PIN'), findsOneWidget);
    expect(authenticateCalls, 1);
  });

  testWidgets('security screen shows App PIN and Phone Screen Lock guidance', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'app_lock_enabled': true,
      'require_authentication': true,
      'phone_lock_quick_unlock_enabled': true,
      'last_strong_auth_at_ms': DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch,
    });
    await tester.runAsync(() => AuthService().setPin('1234'));
    final settingsProvider = SettingsProvider();
    await settingsProvider.initialized;

    await pumpWithProviders(tester, settingsProvider, const SecurityScreen());

    expect(
      find.text('Required for app protection and all secret access'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Optional quick unlock for opening the app'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text('Optional quick unlock for opening the app'),
      findsOneWidget,
    );
  });
}
