// File Path: sreerajp_authenticator/lib/screens/help/help_home_screen.dart
// Author: Sreeraj P
// Description: Help Center and knowledge base hub for SreerajP Authenticator with auto-lock monitoring

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Help Center')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 20),

              _buildSectionHeader(
                context,
                'Authentication & Setup',
                Icons.key_outlined,
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.qr_code_scanner_outlined,
                title: 'Getting Started & Adding Accounts',
                subtitle:
                    'How to scan QR codes, add secret keys manually, and verify your 2FA codes.',
                onTap: () => _push(context, const GettingStartedHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.access_time_outlined,
                title: 'Time Synchronization & Code Drift',
                subtitle:
                    'Fixing invalid codes, device clock offsets, and understanding HOTP event counters.',
                onTap: () => _push(context, const TimeSyncHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.label_outline,
                title: 'Tags & Account Organization',
                subtitle:
                    'Assigning custom tags, filtering accounts, tag cloud view, and batch tag management.',
                onTap: () => _push(context, const TagManagementHelpScreen()),
              ),
              const SizedBox(height: 22),

              _buildSectionHeader(
                context,
                'Security & Vault Protection',
                Icons.security_outlined,
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.fingerprint_outlined,
                title: 'Biometric & App Lock Details',
                subtitle:
                    'Fingerprint and face unlock, device screen lock PIN fallback, and auto-lock rules.',
                onTap: () => _push(context, const BiometricsHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.enhanced_encryption_outlined,
                title: 'AES-256 Vault & Screenshot Guard',
                subtitle:
                    'Hardware-backed encryption keys, FLAG_SECURE window protection, and offline privacy.',
                onTap: () => _push(context, const VaultSecurityHelpScreen()),
              ),
              const SizedBox(height: 22),

              _buildSectionHeader(
                context,
                'Sync & Backups',
                Icons.sync_alt_outlined,
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.wifi_tethering_outlined,
                title: 'Local Wi-Fi P2P Device Sync',
                subtitle:
                    'Direct device-to-device account transfer over local Wi-Fi with end-to-end encryption.',
                onTap: () => _push(context, const P2PSyncHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.qr_code_2_outlined,
                title: 'Optical Air-Gap Transfer',
                subtitle:
                    'Transfer accounts to completely air-gapped devices using animated QR code streams.',
                onTap: () => _push(context, const OpticalSyncHelpScreen()),
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.backup_outlined,
                title: 'Encrypted Backup & Restore',
                subtitle:
                    'Exporting password-protected backup files and restoring tokens on a new phone.',
                onTap: () => _push(context, const BackupHelpScreen()),
              ),
              const SizedBox(height: 22),

              _buildSectionHeader(
                context,
                'Frequently Asked Questions',
                Icons.question_answer_outlined,
              ),
              const SizedBox(height: 10),
              _HelpTopicCard(
                icon: Icons.help_outline,
                title: 'FAQs & Troubleshooting Guide',
                subtitle:
                    'Direct answers to common questions about code issues, backups, permissions, and migration.',
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
                    'Help Center & Knowledge Base',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse in-depth guides and solutions for all features of SreerajP Authenticator.',
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
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
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
