import 'package:flutter/material.dart';
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

    test('setSyncInProgress(true) suppresses idle auto-lock', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setAppLockPin('1234');
      await provider.setAppLockEnabled(true);
      // Timeout 0 means "lock on the next check".
      await provider.setAutoLockTimeout(0);
      expect(provider.isLocked, isFalse);

      // While a sync is active, an auto-lock check must not lock.
      provider.setSyncInProgress(true);
      provider.checkAndLockApp();
      expect(provider.isLocked, isFalse);

      // Once the sync ends, normal auto-lock resumes.
      provider.setSyncInProgress(false);
      provider.checkAndLockApp();
      expect(provider.isLocked, isTrue);
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

    test('sortBy defaults to alphabetical issuer when unset', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      expect(provider.sortBy, AppConstants.defaultSortBy);
      expect(provider.sortBy, 'issuer');
    });

    test('setSortBy persists and reloads on a fresh provider', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setSortBy('account');
      expect(provider.sortBy, 'account');

      final reloaded = SettingsProvider();
      await reloaded.initialized;
      expect(reloaded.sortBy, 'account');
    });

    test('setSortBy ignores unknown values and keeps the current sort', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setSortBy('manual');
      await provider.setSortBy('not_a_real_sort');

      expect(provider.sortBy, 'manual');
    });

    test('an unknown stored sort value falls back to the default', () async {
      SharedPreferences.setMockInitialValues({
        'sort_by': 'garbage_value',
      });

      final provider = SettingsProvider();
      await provider.initialized;

      expect(provider.sortBy, AppConstants.defaultSortBy);
    });
  });

  group('SettingsProvider sync', () {
    test('syncableSettingsSnapshot exposes only the three syncable settings',
        () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.setThemeMode(ThemeMode.dark);
      await provider.setAutoLockTimeout(120);
      await provider.setSyncHostIdleTimeout(300);

      final snap = provider.syncableSettingsSnapshot();

      expect(snap.keys.toSet(), {
        AppConstants.syncSettingThemeMode,
        AppConstants.syncSettingAutoLockTimeout,
        AppConstants.syncSettingSyncHostIdleTimeout,
      });
      expect(snap[AppConstants.syncSettingThemeMode], ThemeMode.dark.index);
      expect(snap[AppConstants.syncSettingAutoLockTimeout], 120);
      expect(snap[AppConstants.syncSettingSyncHostIdleTimeout], 300);
    });

    test('applySyncedSettings with overwrite applies all values', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      final applied = await provider.applySyncedSettings({
        AppConstants.syncSettingThemeMode: ThemeMode.dark.index,
        AppConstants.syncSettingAutoLockTimeout: 90,
        AppConstants.syncSettingSyncHostIdleTimeout: 240,
      }, overwrite: true);

      expect(applied, 3);
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.autoLockTimeout, 90);
      expect(provider.syncHostIdleTimeout, 240);
    });

    test('applySyncedSettings fill-only never overrides an already-set value',
        () async {
      final provider = SettingsProvider();
      await provider.initialized;

      // The receiver has already chosen a theme and auto-lock.
      await provider.setThemeMode(ThemeMode.light);
      await provider.setAutoLockTimeout(30);

      final applied = await provider.applySyncedSettings({
        AppConstants.syncSettingThemeMode: ThemeMode.dark.index,
        AppConstants.syncSettingAutoLockTimeout: 300,
      }, overwrite: false);

      // Both keys already set → nothing applied, receiver's choices retained.
      expect(applied, 0);
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.autoLockTimeout, 30);
    });

    test('applySyncedSettings clamps the sync idle timeout', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      await provider.applySyncedSettings({
        AppConstants.syncSettingSyncHostIdleTimeout: 99999,
      }, overwrite: true);

      expect(
        provider.syncHostIdleTimeout,
        AppConstants.syncHostIdleTimeoutMax,
      );
    });

    test('applySyncedSettings ignores unknown keys and bad types', () async {
      final provider = SettingsProvider();
      await provider.initialized;

      final applied = await provider.applySyncedSettings({
        'not_a_setting': 5,
        AppConstants.syncSettingThemeMode: 'dark', // wrong type
      }, overwrite: true);

      expect(applied, 0);
    });
  });
}
