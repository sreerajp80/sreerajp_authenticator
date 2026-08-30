import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/about_screen.dart';
import 'package:sreerajp_authenticator/utils/build_date.g.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

import '../providers/provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    PackageInfo.setMockInitialValues(
      appName: 'SreerajP Authenticator',
      packageName: 'in.sreerajp.sreerajp_authenticator',
      version: '2.9.3',
      buildNumber: '27',
      buildSignature: '',
    );

    await setUpProviderTestEnvironment(
      sharedPreferences: const {
        AppConstants.aesMigrationKey: true,
        AppConstants.gcmMigrationKey: true,
      },
    );
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  Widget buildTestableWidget(SettingsProvider settingsProvider) {
    return MaterialApp(
      home: ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: const AboutScreen(),
      ),
    );
  }

  group('AboutScreen Widget Tests', () {
    testWidgets('displays app information and build date chip', (tester) async {
      late final SettingsProvider settingsProvider;
      await tester.runAsync(() async {
        settingsProvider = SettingsProvider();
        await settingsProvider.initialized;
      });

      await tester.pumpWidget(buildTestableWidget(settingsProvider));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsWidgets);
      expect(find.text(kBuildDate), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
