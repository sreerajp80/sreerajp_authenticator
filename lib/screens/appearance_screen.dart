// File Path: sreerajp_authenticator/lib/screens/appearance_screen.dart
// Author: Sreeraj P
// Description: Appearance preferences hub reached from Settings -> Appearance with auto-lock monitoring

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import 'accent_color_settings_screen.dart';
import 'theme_mode_settings_screen.dart';

/// Appearance preferences hub reached from Settings -> Appearance.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);
    final appName = context.read<AppConfig>().appName.resolve(
      Localizations.localeOf(context).languageCode,
    );

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.titleAppearance)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildAppearanceCard(
                context: context,
                icon: Icons.brightness_6_outlined,
                title: l10n.titleThemeMode,
                subtitle: _getThemeModeSubtitle(l10n, themeProvider.themeMode),
                onTap: () => _push(context, const ThemeModeSettingsScreen()),
              ),
              const SizedBox(height: 12),
              _buildAppearanceCard(
                context: context,
                icon: Icons.palette_outlined,
                title: l10n.titleAccentColor,
                subtitle: accentColorName(l10n, themeProvider.accent),
                onTap: () => _push(context, const AccentColorSettingsScreen()),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel(
                context,
                l10n.titleThemeInformation.toUpperCase(),
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.titleVisualDesign,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.descVisualDesign(appName),
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAppearanceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeModeSubtitle(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.descThemeSummarySystem;
      case ThemeMode.light:
        return l10n.descThemeSummaryLight;
      case ThemeMode.dark:
        return l10n.descThemeSummaryDark;
    }
  }
}
