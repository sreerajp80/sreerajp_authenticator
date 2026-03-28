import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/providers/theme_provider.dart';

import 'provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  group('ThemeProvider', () {
    test('loads persisted theme mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.dark.index,
      });

      final provider = ThemeProvider();

      await waitForCondition(() => provider.themeMode == ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);
    });

    test('setThemeMode updates state and persists the new value', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.light.index,
      });

      final provider = ThemeProvider();
      await waitForCondition(() => provider.themeMode == ThemeMode.light);

      var notifications = 0;
      provider.addListener(() {
        notifications += 1;
      });

      await provider.setThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);
      expect(prefs.getInt('theme_mode'), ThemeMode.dark.index);
      expect(notifications, greaterThan(0));
    });
  });
}
