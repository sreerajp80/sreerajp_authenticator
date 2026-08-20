// File Path: sreerajp_authenticator/lib/screens/settings_screen.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2026 August 20
// Description: Enhanced settings screen with 3D neumorphic design, Appearance, Features, Help, and auto-lock monitoring

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import 'appearance_screen.dart';
import 'features_screen.dart';
import 'help/help_home_screen.dart';
import 'backup_restore_screen.dart';
import 'security_screen.dart';
import 'sync_screen.dart';
import 'about_screen.dart';
import 'permissions_screen.dart';
import 'tag_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    // ✅ Monitor lock state and auto-pop when locked
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // If app gets locked while on this screen, pop back
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance', theme),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: AppTheme.get3DDecoration(context: context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        _buildGlossyOverlay(theme),
                        _build3DListTile(
                          context: context,
                          icon: Icons.palette_outlined,
                          title: 'Appearance',
                          subtitle: _getAppearanceSubtitle(
                            themeProvider.themeMode,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AppearanceScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Security Section
              _buildSectionHeader('Security', theme),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: AppTheme.get3DDecoration(context: context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        _buildGlossyOverlay(theme),
                        // Content
                        Column(
                          children: [
                            _build3DListTile(
                              context: context,
                              icon: Icons.lock_outlined,
                              title: 'Security Settings',
                              subtitle: 'Configure app lock and biometric',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SecurityScreen(),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            _build3DListTile(
                              context: context,
                              icon: Icons.backup_outlined,
                              title: 'Backup & Restore',
                              subtitle: 'Export or import your accounts',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BackupRestoreScreen(),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            _build3DListTile(
                              context: context,
                              icon: Icons.label_outlined,
                              title: 'Manage Tags',
                              subtitle: 'Edit, rename, or cleanup account tags',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TagManagementScreen(),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            _build3DListTile(
                              context: context,
                              icon: Icons.sync_outlined,
                              title: 'Sync to Another Device',
                              subtitle:
                                  'Transfer accounts via Wi-Fi or Optical Air-Gap',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SyncScreen(),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            _build3DListTile(
                              context: context,
                              icon: Icons.timer_outlined,
                              title: 'Sync Host Timeout',
                              subtitle:
                                  'Stop hosting after '
                                  '${settingsProvider.syncHostIdleTimeout}s '
                                  'if no device connects',
                              onTap: () => _showSyncTimeoutDialog(
                                context,
                                settingsProvider,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            _build3DListTile(
                              context: context,
                              icon: Icons.admin_panel_settings_outlined,
                              title: 'Permissions',
                              subtitle: 'View app permissions and status',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PermissionsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Explore & Information Section
              _buildSectionHeader('Explore & Support', theme),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: AppTheme.get3DDecoration(context: context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        _buildGlossyOverlay(theme),
                        Column(
                          children: [
                            _build3DListTile(
                              context: context,
                              icon: Icons.stars_outlined,
                              title: 'Features',
                              subtitle:
                                  'Explore all features of SreerajP Authenticator',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FeaturesScreen(),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            _build3DListTile(
                              context: context,
                              icon: Icons.help_outline,
                              title: 'Help',
                              subtitle:
                                  'Guides, troubleshooting, and sync details',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HelpHomeScreen(),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            _build3DListTile(
                              context: context,
                              icon: Icons.info_outlined,
                              title: 'About',
                              subtitle: 'Version, author, and license details',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AboutScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlossyOverlay(ThemeData theme) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.03),
                  ]
                : [
                    const Color.fromARGB(
                      255,
                      78,
                      78,
                      78,
                    ).withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.4),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _build3DListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSyncTimeoutDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    const options = [30, 60, 120, 300, 600];
    final current = settingsProvider.syncHostIdleTimeout;
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sync Host Timeout'),
        children: [
          for (final seconds in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, seconds),
              child: Row(
                children: [
                  Icon(
                    seconds == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text('$seconds seconds'),
                ],
              ),
            ),
        ],
      ),
    );
    if (selected != null) {
      await settingsProvider.setSyncHostIdleTimeout(selected);
    }
  }

  String _getAppearanceSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Theme mode: System default';
      case ThemeMode.light:
        return 'Theme mode: Light';
      case ThemeMode.dark:
        return 'Theme mode: Dark';
    }
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
