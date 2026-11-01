import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/providers/theme_provider.dart';
import 'package:sreerajp_authenticator/utils/theme.dart';

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

    test('setAccent updates state and saves the name', () async {
      final provider = ThemeProvider();
      await provider.setAccent(AppAccent.copper);

      final prefs = await SharedPreferences.getInstance();

      expect(provider.accent, AppAccent.copper);
      expect(prefs.getString('accent_color'), 'copper');
    });

    test('loads the saved accent', () async {
      SharedPreferences.setMockInitialValues({'accent_color': 'teal'});

      final provider = ThemeProvider();

      await waitForCondition(() => provider.accent == AppAccent.teal);
      expect(provider.accent, AppAccent.teal);
    });

    test('an unknown saved accent falls back to blue', () {
      expect(AppAccent.fromName('purple-ish'), AppAccent.blue);
      expect(AppAccent.fromName(null), AppAccent.blue);
    });
  });
}
