// File Path: sreerajp_authenticator/lib/screens/theme_mode_settings_screen.dart
// Author: Sreeraj P
// Description: Configuration screen for Light / Dark / System theme mode selection with live feedback

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

/// Configuration screen for Light / Dark / System theme mode selection.
class ThemeModeSettingsScreen extends StatelessWidget {
  const ThemeModeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);

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
          appBar: AppBar(title: Text(l10n.titleThemeMode)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildSectionLabel(
                context,
                l10n.titleSelectThemeMode.toUpperCase(),
              ),
              const SizedBox(height: 12),
              _buildThemeOptionCard(
                context: context,
                mode: ThemeMode.system,
                currentMode: themeProvider.themeMode,
                icon: Icons.brightness_auto_outlined,
                title: l10n.labelThemeSystem,
                subtitle: l10n.descThemeSystem,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              ),
              const SizedBox(height: 12),
              _buildThemeOptionCard(
                context: context,
                mode: ThemeMode.light,
                currentMode: themeProvider.themeMode,
                icon: Icons.light_mode_outlined,
                title: l10n.labelThemeLight,
                subtitle: l10n.descThemeLight,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(height: 12),
              _buildThemeOptionCard(
                context: context,
                mode: ThemeMode.dark,
                currentMode: themeProvider.themeMode,
                icon: Icons.dark_mode_outlined,
                title: l10n.labelThemeDark,
                subtitle: l10n.descThemeDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel(
                context,
                l10n.titleCurrentStatus.toUpperCase(),
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          themeProvider.isDarkMode
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
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
                              themeProvider.isDarkMode
                                  ? l10n.labelActiveDark
                                  : l10n.labelActiveLight,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _getThemeModeDescription(
                                l10n,
                                themeProvider.themeMode,
                              ),
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
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

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = mode == currentMode;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? accent : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent.withValues(alpha: 0.15)
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? accent
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
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
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? accent : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeModeDescription(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.descThemeStatusSystem;
      case ThemeMode.light:
        return l10n.descThemeStatusLight;
      case ThemeMode.dark:
        return l10n.descThemeStatusDark;
    }
  }
}
