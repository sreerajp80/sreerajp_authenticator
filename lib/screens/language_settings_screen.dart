// File Path: sreerajp_authenticator/lib/screens/language_settings_screen.dart
// Author: Sreeraj P
// Description: In-app language picker (System default, English, Malayalam, Sanskrit) with auto-lock monitoring

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/locale_provider.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';

/// Language picker reached from Settings (engineering standard §8.4).
/// The change applies at once, app-wide, without a restart.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locales = context.watch<LocaleProvider>();

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        final options = <_LanguageOption>[
          _LanguageOption(
            value: LocaleProvider.systemValue,
            icon: Icons.phone_android_outlined,
            title: l10n.labelLanguageSystem,
            subtitle: l10n.descLanguageSystem,
          ),
          _LanguageOption(
            value: 'en',
            icon: Icons.translate,
            title: LocaleConfig.endonyms['en']!,
            subtitle: l10n.labelLanguageNameEn,
          ),
          _LanguageOption(
            value: 'ml',
            icon: Icons.translate,
            title: LocaleConfig.endonyms['ml']!,
            subtitle: l10n.labelLanguageNameMl,
          ),
          _LanguageOption(
            value: 'sa',
            icon: Icons.translate,
            title: LocaleConfig.endonyms['sa']!,
            subtitle: l10n.labelLanguageNameSa,
          ),
        ];

        return Scaffold(
          appBar: AppBar(title: Text(l10n.titleLanguage)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildSectionLabel(context, l10n.titleSelectLanguage),
              const SizedBox(height: 12),
              for (final option in options) ...[
                _buildLanguageCard(
                  context: context,
                  option: option,
                  isSelected: locales.selection == option.value,
                  onTap: () => locales.setLanguage(option.value),
                ),
                const SizedBox(height: 12),
              ],
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
        text.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required _LanguageOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
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
      child: Semantics(
        selected: isSelected,
        button: true,
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
                    option.icon,
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
                        option.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
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
                  color: isSelected
                      ? accent
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

class _LanguageOption {
  final String value;
  final IconData icon;
  final String title;
  final String subtitle;

  const _LanguageOption({
    required this.value,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
