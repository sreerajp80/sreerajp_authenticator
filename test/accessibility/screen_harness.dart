import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/providers/locale_provider.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/providers/sync_provider.dart';
import 'package:sreerajp_authenticator/providers/theme_provider.dart';
import 'package:sreerajp_authenticator/screens/about_screen.dart';
import 'package:sreerajp_authenticator/screens/add_account_screen.dart';
import 'package:sreerajp_authenticator/screens/appearance_screen.dart';
import 'package:sreerajp_authenticator/screens/backup_restore_screen.dart';
import 'package:sreerajp_authenticator/screens/features_screen.dart';
import 'package:sreerajp_authenticator/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/help_home_screen.dart';
import 'package:sreerajp_authenticator/screens/home_screen.dart';
import 'package:sreerajp_authenticator/screens/lock_screen.dart';
import 'package:sreerajp_authenticator/screens/language_settings_screen.dart';
import 'package:sreerajp_authenticator/screens/permissions_screen.dart';
import 'package:sreerajp_authenticator/screens/security_screen.dart';
import 'package:sreerajp_authenticator/screens/settings_screen.dart';
import 'package:sreerajp_authenticator/screens/sync_screen.dart';
import 'package:sreerajp_authenticator/screens/tag_management_screen.dart';
import 'package:sreerajp_authenticator/screens/theme_mode_settings_screen.dart';
import 'package:sreerajp_authenticator/utils/theme.dart';

import '../providers/provider_test_helpers.dart';

/// The screens every accessibility check runs on. Camera screens are left out:
/// they need a real camera.
final Map<String, Widget> a11yScreens = {
  'Home': const HomeScreen(),
  'Settings': const SettingsScreen(),
  'Security': const SecurityScreen(),
  'Backup': const BackupRestoreScreen(),
  'Tags': const TagManagementScreen(),
  'Sync': const SyncScreen(),
  'Add account': const AddAccountScreen(),
  'About': const AboutScreen(),
  'Permissions': const PermissionsScreen(),
  'Appearance': const AppearanceScreen(),
  'Language': const LanguageSettingsScreen(),
  'Theme mode': const ThemeModeSettingsScreen(),
  'Lock': const LockScreen(),
  'Features': const FeaturesScreen(),
  'Help home': const HelpHomeScreen(),
  'Help FAQ': const FaqTroubleshootingHelpScreen(),
};

var _fontsLoaded = false;

/// The default test font draws every letter as a wide square, which makes
/// widths meaningless. Inter is close to the phone's own font, and the Noto
/// fonts are what the app itself falls back to for Malayalam and Sanskrit.
Future<void> _loadRealFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  const families = {
    'Inter': ['Inter-Regular', 'Inter-Medium', 'Inter-Bold'],
    'NotoSansMalayalam': [
      'NotoSansMalayalam-Regular',
      'NotoSansMalayalam-Bold',
    ],
    'NotoSansDevanagari': [
      'NotoSansDevanagari-Regular',
      'NotoSansDevanagari-Bold',
    ],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      final bytes = File('fonts/$file.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

ThemeData _withRealFont(ThemeData theme) => theme.copyWith(
  textTheme: theme.textTheme.apply(fontFamily: 'Inter'),
  primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Inter'),
);

Future<void> setUpA11yEnvironment() async {
  await _loadRealFonts();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (call) async => call.method == 'checkPermissionStatus' ? 1 : null,
      );
  rootBundle.clear();
  PackageInfo.setMockInitialValues(
    appName: 'Sreeraj P Authenticator',
    packageName: 'in.sreerajp.sreerajp_authenticator',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await setUpProviderTestEnvironment(sharedPreferences: const {});
}

/// Lets real asynchronous work (database, secure storage, assets) finish.
Future<void> settleScreen(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Opens [screen] with the app's real providers and themes, and a TOTP and an
/// HOTP account in the list.
Future<void> pumpA11yScreen(
  WidgetTester tester,
  Widget screen, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  double textScale = 1.0,
  Size size = const Size(360, 780),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late final LocaleProvider localeProvider;
  late final SettingsProvider settings;
  late final AccountsProvider accounts;
  await tester.runAsync(() async {
    localeProvider = LocaleProvider(await SharedPreferences.getInstance());
    settings = SettingsProvider();
    await settings.initialized;
    accounts = AccountsProvider();
    await settleAsyncWork();
    await accounts.addAccount(
      makeAccount(name: 'user@example.com', issuer: 'GitHub', tags: ['Work']),
    );
    await accounts.addAccount(
      makeAccount(name: 'Counter', type: 'hotp', counter: 0, tags: ['Bank']),
    );
    await waitForCondition(() => accounts.accounts.length == 2);
    await settleAsyncWork();
  });

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        Provider<AppConfig>.value(value: AppConfig.fallback),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: accounts),
        // A value provider: the app's own one is never disposed, and screens
        // reset it from their dispose.
        ChangeNotifierProvider.value(value: SyncProvider()),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: LocaleConfig.supportedLocales,
        localizationsDelegates: LocaleConfig.localizationsDelegates,
        theme: _withRealFont(AppTheme.lightTheme),
        darkTheme: _withRealFont(AppTheme.darkTheme),
        themeMode: themeMode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child ?? const SizedBox.shrink(),
        ),
        home: screen,
      ),
    ),
  );
  await settleScreen(tester);
}

/// Takes the screen away and lets its timers end.
Future<void> removeA11yScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}
