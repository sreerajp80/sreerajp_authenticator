// File Path: sreerajp_authenticator/lib/screens/accent_color_settings_screen.dart
// Author: Sreeraj P
// Description: Configuration screen for choosing the app's accent colour with live feedback

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

/// The name of an accent colour in the active language.
String accentColorName(AppLocalizations l10n, AppAccent accent) {
  switch (accent) {
    case AppAccent.blue:
      return l10n.labelAccentBlue;
    case AppAccent.teal:
      return l10n.labelAccentTeal;
    case AppAccent.indigo:
      return l10n.labelAccentIndigo;
    case AppAccent.green:
      return l10n.labelAccentGreen;
    case AppAccent.copper:
      return l10n.labelAccentCopper;
    case AppAccent.graphite:
      return l10n.labelAccentGraphite;
  }
}

/// Configuration screen for choosing the accent colour.
class AccentColorSettingsScreen extends StatelessWidget {
  const AccentColorSettingsScreen({super.key});

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
          appBar: AppBar(title: Text(l10n.titleAccentColor)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l10n.titleSelectAccentColor.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final accent in AppAccent.values) ...[
                _buildAccentCard(
                  context: context,
                  accent: accent,
                  isSelected: accent == themeProvider.accent,
                  onTap: () => themeProvider.setAccent(accent),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccentCard({
    required BuildContext context,
    required AppAccent accent,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final swatch = theme.brightness == Brightness.dark
        ? accent.dark
        : accent.light;

    return Semantics(
      selected: isSelected,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? swatch : Colors.transparent,
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: swatch,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    accentColorName(l10n, accent),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? swatch
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
