// File Path: sreerajp_authenticator/lib/main.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 14
// Description: Main entry point for the Sreeraj P Authenticator app with lock screen check using routing wrapper pattern

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/locale_provider.dart';
import 'package:sreerajp_authenticator/services/config_service.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/account_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'services/otp_service.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';

// Theme
import 'config/app_flavor_config.dart';
import 'utils/screen_protection.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  await enableScreenProtection();

  // Read the saved language and the About config before the first frame, so
  // the app never flashes the wrong language (engineering standard §8.4).
  final prefs = await SharedPreferences.getInstance();

  // Protection stays on unless the user turned it off in Settings.
  if (!SettingsProvider.readBlockScreenshots(prefs)) {
    await disableScreenProtection();
  }

  final localeProvider = LocaleProvider(prefs);
  final appConfig = await ConfigService().load();

  runApp(MyApp(localeProvider: localeProvider, appConfig: appConfig));
}

class MyApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final AppConfig appConfig;

  const MyApp({
    super.key,
    required this.localeProvider,
    required this.appConfig,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        Provider.value(value: appConfig),
        // Theme Provider for managing app theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Settings Provider for managing security and app settings (must be before AccountsProvider)
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // Accounts Provider for managing authenticator accounts
        ChangeNotifierProvider(create: (_) => AccountsProvider()),
        // Sync Provider for P2P LAN sync state (lazily created when used)
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer3<ThemeProvider, SettingsProvider, LocaleProvider>(
        builder: (context, themeProvider, settingsProvider, locales, child) {
          return MaterialApp(
            // The OS task title follows the active language (guideline.md §1.8).
            onGenerateTitle: (context) => appConfig.appName.resolve(
              Localizations.localeOf(context).languageCode,
            ),
            debugShowCheckedModeBanner: false,

            // Localization (engineering standard §8.1, §8.4)
            locale: locales.locale,
            supportedLocales: LocaleConfig.supportedLocales,
            localizationsDelegates: LocaleConfig.localizationsDelegates,
            localeResolutionCallback: LocaleConfig.localeResolution,
            builder: (context, child) {
              // Some packages still use package:flutter/material.dart; the bridge
              // gives their widgets the app theme (engineering standard §6.1).
              // It is deprecated on purpose as a temporary migration helper; remove
              // it when those packages move to material_ui (docs/architecture.md §21).
              // ignore: deprecated_member_use
              final app = MaterialUiCompatibilityBridge(
                child: child ?? const SizedBox.shrink(),
              );
              if (!AppFlavorConfig.instance.showEnvironmentBanner) {
                return app;
              }

              return Banner(
                message: AppFlavorConfig.instance.bannerLabel,
                location: BannerLocation.topEnd,
                color: const Color(0xFFE65100),
                child: app,
              );
            },

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Determine initial screen based on lock status
            home: _AppInitializer(settingsProvider: settingsProvider),
          );
        },
      ),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const _AppInitializer({required this.settingsProvider});

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for SettingsProvider to finish loading all persisted settings
    // (including lock state) before deciding which screen to show.
    await widget.settingsProvider.initialized;

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      // Load app data if not locked
      if (!widget.settingsProvider.isLocked) {
        _loadAppData();
      }
    }
  }

  void _loadAppData() {
    context.read<AccountsProvider>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildSplashScreen();
    }

    // Use the routing wrapper instead of conditionally returning screens
    return const _AppRoot();
  }

  Widget _buildSplashScreen() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final appName = context.read<AppConfig>().appName.resolve(
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
                : [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // App Name (from app_config.json, in the active language)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.descSplashLoading,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Routing wrapper that automatically switches between lock and home screen
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final settingsProvider = context.read<SettingsProvider>();

    switch (state) {
      case AppLifecycleState.paused:
        // App fully in background — lock now.
        settingsProvider.onAppPaused();
        // Clear decrypted secrets from memory when app is backgrounded.
        OTPService.clearCache();
        break;
      case AppLifecycleState.inactive:
        // Transient state (system dialog, notification shade, incoming call).
        // Do NOT lock here — the app is still partially visible and locking
        // would force re-authentication after every system overlay.
        break;
      case AppLifecycleState.resumed:
        // App coming to foreground
        settingsProvider.onAppResumed();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Always check lock status before deciding which screen to show
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          return const LockScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
