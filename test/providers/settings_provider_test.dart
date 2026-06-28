import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

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
    test('legacy phone-lock-only users keep phone-lock-only mode', () async {
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'lock_type': 'device_lock',
      });

      final provider = SettingsProvider();
      await provider.initialized;

      expect(provider.isAppLockEnabled, isTrue);
      expect(provider.hasPinSet, isFalse);
      expect(provider.phoneLockQuickUnlockEnabled, isTrue);
      expect(provider.needsMandatoryPinMigrationSync, isFalse);
      expect(provider.isLocked, isTrue);
      expect(provider.unlockInstructionText, 'Use your Phone Screen Lock');
    });

    test('does not enable app lock with no unlock method', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setAppLockEnabled(true);

      expect(provider.isAppLockEnabled, isFalse);
    });

    test('sync host idle timeout defaults, persists, and clamps to bounds',
        () async {
      final provider = SettingsProvider();
      await provider.initialized;

      expect(
        provider.syncHostIdleTimeout,
        AppConstants.syncHostIdleTimeoutDefault,
      );

      await provider.setSyncHostIdleTimeout(300);
      expect(provider.syncHostIdleTimeout, 300);

      // Out-of-range values are clamped.
      await provider.setSyncHostIdleTimeout(5);
      expect(provider.syncHostIdleTimeout, AppConstants.syncHostIdleTimeoutMin);

      await provider.setSyncHostIdleTimeout(99999);
      expect(provider.syncHostIdleTimeout, AppConstants.syncHostIdleTimeoutMax);

      // Persisted value is reloaded by a fresh provider.
      await provider.setSyncHostIdleTimeout(60);
      final reloaded = SettingsProvider();
      await reloaded.initialized;
      expect(reloaded.syncHostIdleTimeout, 60);
    });

    test('enables app lock with phone lock only (no app pin)', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setPhoneLockQuickUnlockEnabled(true);
      await provider.setAppLockEnabled(true);

      expect(provider.isAppLockEnabled, isTrue);
      expect(provider.hasPinSet, isFalse);
      expect(provider.phoneLockQuickUnlockEnabled, isTrue);
      expect(provider.requiresAppPinForUnlock, isFalse);
      expect(provider.canUsePhoneLockQuickUnlock, isTrue);
    });

    test('setAppLockEnabled(true) keeps session unlocked until pause or timeout',
        () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setAppLockPin('1234');
      await provider.setAppLockEnabled(true);

      expect(provider.isAppLockEnabled, isTrue);
      expect(provider.isLocked, isFalse);
    });

    test('idle timeout requires app pin even when quick unlock is enabled', () async {
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
      });
      await AuthService().setPin('1234');

      final provider = SettingsProvider();
      await provider.initialized;

      expect(provider.pinRequiredReason, PinRequiredReason.idleTimeout);
      expect(provider.requiresAppPinForUnlock, isTrue);
      expect(provider.unlockInstructionText, 'Enter your App PIN');
    });

    test('successful app pin unlock clears idle timeout and enables quick unlock',
        () async {
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
      });
      await AuthService().setPin('1234');

      final provider = SettingsProvider();
      await provider.initialized;
      await provider.handleSuccessfulAppPinUnlock();

      expect(provider.pinRequiredReason, PinRequiredReason.none);
      expect(provider.canUsePhoneLockQuickUnlock, isTrue);
      expect(provider.unlockInstructionText,
          'Use your Phone Screen Lock or enter your App PIN');
    });

    test('three quick unlock failures require app pin', () async {
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
      });
      await AuthService().setPin('1234');

      final provider = SettingsProvider();
      await provider.initialized;

      await provider.handleQuickUnlockResult(
        const LocalAuthResult(LocalAuthOutcome.failure),
      );
      await provider.handleQuickUnlockResult(
        const LocalAuthResult(LocalAuthOutcome.failure),
      );
      await provider.handleQuickUnlockResult(
        const LocalAuthResult(LocalAuthOutcome.failure),
      );

      expect(provider.pinRequiredReason, PinRequiredReason.quickUnlockFailures);
      expect(provider.requiresAppPinForUnlock, isTrue);
    });

    test('quick unlock cancel does not escalate to app pin', () async {
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
      });
      await AuthService().setPin('1234');

      final provider = SettingsProvider();
      await provider.initialized;

      await provider.handleQuickUnlockResult(
        const LocalAuthResult(LocalAuthOutcome.canceled),
      );
      await provider.handleQuickUnlockResult(
        const LocalAuthResult(LocalAuthOutcome.canceled),
      );
      await provider.handleQuickUnlockResult(
        const LocalAuthResult(LocalAuthOutcome.canceled),
      );

      expect(provider.pinRequiredReason, PinRequiredReason.none);
      expect(provider.canUsePhoneLockQuickUnlock, isTrue);
    });

    test('lockdown always requires app pin', () async {
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
      });
      await AuthService().setPin('1234');

      final provider = SettingsProvider();
      await provider.initialized;
      await provider.setLockdownEnabled(true);

      expect(provider.pinRequiredReason, PinRequiredReason.lockdown);
      expect(provider.requiresAppPinForUnlock, isTrue);
    });

    test('reboot detection requires app pin until successful pin refreshes state',
        () async {
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
        'last_known_boot_count': 41,
      });
      await AuthService().setPin('1234');

      final provider = SettingsProvider();
      await provider.initialized;

      expect(provider.pinRequiredReason, PinRequiredReason.reboot);

      await provider.handleSuccessfulAppPinUnlock();

      expect(provider.pinRequiredReason, PinRequiredReason.none);
      expect(provider.canUsePhoneLockQuickUnlock, isTrue);
    });

    test('missing boot count skips reboot escalation', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AppConstants.deviceStateChannel),
        (methodCall) async => null,
      );
      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
      });
      await AuthService().setPin('1234');

      final provider = SettingsProvider();
      await provider.initialized;

      expect(provider.pinRequiredReason, PinRequiredReason.none);
      expect(provider.canUsePhoneLockQuickUnlock, isTrue);
    });

    test('setAppLockEnabled(false) clears security state', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setAppLockPin('1234');
      await provider.setPhoneLockQuickUnlockEnabled(true);
      await provider.setLockdownEnabled(true);
      await provider.setAppLockEnabled(true);
      await provider.setAppLockEnabled(false);

      final prefs = await SharedPreferences.getInstance();

      expect(provider.isAppLockEnabled, isFalse);
      expect(provider.requireAuthentication, isFalse);
      expect(provider.phoneLockQuickUnlockEnabled, isFalse);
      expect(provider.hasPinSet, isFalse);
      expect(provider.isLocked, isFalse);
      expect(provider.lockdownEnabled, isFalse);
      expect(prefs.getBool('app_lock_enabled'), isFalse);
      expect(prefs.getBool('require_authentication'), isFalse);
      expect(prefs.getBool('phone_lock_quick_unlock_enabled'), isFalse);
    });
  });
}
