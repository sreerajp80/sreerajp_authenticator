// File Path: sreerajp_authenticator/lib/main.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 14
// Description: Main entry point for the Sreeraj Authenticator app with lock screen check using routing wrapper pattern

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/account_provider.dart';
import 'providers/group_provider.dart';
import 'providers/settings_provider.dart';
import 'services/otp_service.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';

// Theme
import 'config/app_flavor_config.dart';
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

  // Prevent screenshots and screen recording (sets FLAG_SECURE on Android)
  await ScreenProtector.protectDataLeakageOn();
  await ScreenProtector.preventScreenshotOn();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider for managing app theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Settings Provider for managing security and app settings (must be before AccountsProvider)
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // Groups Provider for managing account groups
        ChangeNotifierProvider(create: (_) => GroupsProvider()),
        // Accounts Provider for managing authenticator accounts
        ChangeNotifierProvider(create: (_) => AccountsProvider()),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, child) {
          return MaterialApp(
            title: AppFlavorConfig.instance.appName,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final app = child ?? const SizedBox.shrink();
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
    // Load accounts and groups
    context.read<AccountsProvider>().loadAccounts();
    context.read<GroupsProvider>().loadGroups();
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

              // App Name
              Text(
                'Sreeraj P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                'Authenticator',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
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
                'Securing your accounts...',
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
