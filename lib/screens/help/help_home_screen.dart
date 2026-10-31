// File Path: sreerajp_authenticator/lib/screens/help/help_home_screen.dart
// Author: Sreeraj P
// Description: Help Center and knowledge base hub for Sreeraj P Authenticator with auto-lock monitoring

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';

import '../../providers/settings_provider.dart';
import 'backup_help_screen.dart';
import 'biometrics_help_screen.dart';
import 'faq_troubleshooting_help_screen.dart';
import 'getting_started_help_screen.dart';
import 'optical_sync_help_screen.dart';
import 'p2p_sync_help_screen.dart';
import 'tag_management_help_screen.dart';
import 'time_sync_help_screen.dart';
import 'vault_security_help_screen.dart';

/// Help Center and knowledge base hub reached from Settings -> Help.
class HelpHomeScreen extends StatelessWidget {
  const HelpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations.of(context);
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.helpHome01)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 20),

              _buildSectionHeader(context, l10n.helpHome02, Icons.key_outlined),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.qr_code_scanner_outlined,
                title: l10n.helpHome03,
                subtitle: l10n.helpHome04,
                onTap: () => _push(context, const GettingStartedHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.access_time_outlined,
                title: l10n.helpHome05,
                subtitle: l10n.helpHome06,
                onTap: () => _push(context, const TimeSyncHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.label_outline,
                title: l10n.helpHome07,
                subtitle: l10n.helpHome08,
                onTap: () => _push(context, const TagManagementHelpScreen()),
              ),
              const SizedBox(height: 22),

              _buildSectionHeader(
                context,
                l10n.helpHome09,
                Icons.security_outlined,
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.fingerprint_outlined,
                title: l10n.helpHome10,
                subtitle: l10n.helpHome11,
                onTap: () => _push(context, const BiometricsHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.enhanced_encryption_outlined,
                title: l10n.helpHome12,
                subtitle: l10n.helpHome13,
                onTap: () => _push(context, const VaultSecurityHelpScreen()),
              ),
              const SizedBox(height: 22),

              _buildSectionHeader(
                context,
                l10n.helpHome14,
                Icons.sync_alt_outlined,
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.wifi_tethering_outlined,
                title: l10n.helpHome15,
                subtitle: l10n.helpHome16,
                onTap: () => _push(context, const P2PSyncHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.qr_code_2_outlined,
                title: l10n.helpHome17,
                subtitle: l10n.helpHome18,
                onTap: () => _push(context, const OpticalSyncHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.backup_outlined,
                title: l10n.helpHome19,
                subtitle: l10n.helpHome20,
                onTap: () => _push(context, const BackupHelpScreen()),
              ),
              const SizedBox(height: 22),

              _buildSectionHeader(
                context,
                l10n.helpHome21,
                Icons.question_answer_outlined,
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.help_outline,
                title: l10n.helpHome22,
                subtitle: l10n.helpHome23,
                onTap: () =>
                    _push(context, const FaqTroubleshootingHelpScreen()),
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

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final appName = context.read<AppConfig>().appName.resolve(
      Localizations.localeOf(context).languageCode,
    );
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
              theme.colorScheme.secondary.withValues(
                alpha: isDark ? 0.1 : 0.05,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_center_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.helpHome24,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.helpHome25(appName),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single help topic row, styled to match the settings cards.
class _HelpTopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTopicCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
}
