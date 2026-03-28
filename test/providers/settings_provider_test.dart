import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';

import 'provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  group('SettingsProvider', () {
    test(
      'initialized loads persisted settings and locks when a PIN exists',
      () async {
        SharedPreferences.setMockInitialValues({
          'app_lock_enabled': true,
          'biometric_enabled': true,
          'auto_lock_timeout': 120,
          'export_format': 'csv',
          'theme_mode': ThemeMode.dark.index,
          'require_authentication': true,
          'lock_type': 'app_pin',
        });
        await AuthService().setPin('1234');

        final provider = SettingsProvider();
        await provider.initialized;

        expect(provider.isAppLockEnabled, isTrue);
        expect(provider.isBiometricEnabled, isTrue);
        expect(provider.autoLockTimeout, 120);
        expect(provider.exportFormat, 'csv');
        expect(provider.themeMode, ThemeMode.dark);
        expect(provider.isDarkMode, isTrue);
        expect(provider.hasPinSet, isTrue);
        expect(provider.lockType, 'app_pin');
        expect(provider.isLocked, isTrue);
      },
    );

    test('setAppLockEnabled(false) clears security state', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setAppLockPin('1234');
      await provider.setBiometricEnabled(true);
      await provider.setAppLockEnabled(true);
      await provider.setAppLockEnabled(false);

      final prefs = await SharedPreferences.getInstance();

      expect(provider.isAppLockEnabled, isFalse);
      expect(provider.requireAuthentication, isFalse);
      expect(provider.isBiometricEnabled, isFalse);
      expect(provider.hasPinSet, isFalse);
      expect(provider.isLocked, isFalse);
      expect(prefs.getBool('app_lock_enabled'), isFalse);
      expect(prefs.getBool('require_authentication'), isFalse);
      expect(prefs.getBool('biometric_enabled'), isFalse);
    });

    test(
      'verifyPin records failures and resets them after a success',
      () async {
        final provider = SettingsProvider();
        await provider.initialized;
        await provider.setAppLockPin('2468');

        expect(await provider.verifyPin('0000'), isFalse);
        expect(await provider.getFailedAttempts(), 1);

        expect(await provider.verifyPin('2468'), isTrue);
        expect(await provider.getFailedAttempts(), 0);
      },
    );

    test(
      'validateAndResetWithRecoveryKey clears the stored PIN state',
      () async {
        final provider = SettingsProvider();
        await provider.initialized;
        await provider.setAppLockPin('2468');

        final recoveryKey = await provider.generateRecoveryKey();
        final reset = await provider.validateAndResetWithRecoveryKey(
          recoveryKey,
        );

        expect(reset, isTrue);
        expect(provider.hasPinSet, isFalse);
        expect(await provider.hasRecoveryKey(), isFalse);
        expect(await provider.verifyPin('2468'), isFalse);
      },
    );

    test('onAppPaused locks the app when app lock is enabled', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setAppLockPin('2468');
      await provider.setAppLockEnabled(true);
      await provider.setLocked(false);
      await provider.onAppPaused();

      expect(provider.isLocked, isTrue);
    });
  });
}
