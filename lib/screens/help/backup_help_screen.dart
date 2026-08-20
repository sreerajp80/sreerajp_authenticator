// File Path: sreerajp_authenticator/lib/screens/help/backup_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for encrypted backups, password protection, and safe restore

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class BackupHelpScreen extends StatelessWidget {
  const BackupHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Encrypted Backup & Restore')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'Backups protect you against phone damage, loss, or when migrating to a new device. All backup files are strongly encrypted with a password of your choice.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.file_upload_outlined,
                title: 'Creating an Encrypted Backup',
                children: [
                  _Bullet(
                    'Go to Settings -> Backup & Restore -> tap "Export Encrypted Backup".',
                  ),
                  _Bullet(
                    'Choose a strong backup password. The app derives an AES-256 key using PBKDF2 with 100,000 iterations to encrypt the archive.',
                  ),
                  _Bullet(
                    'Save the exported `.json` / backup file to your device storage, an external USB drive, or your personal offline archive.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.password_outlined,
                title: 'Password Security & Recovery',
                children: [
                  _Bullet(
                    'Your backup password is never stored or transmitted. You MUST remember it or keep it written down safely.',
                  ),
                  _Bullet(
                    'Because SreerajP Authenticator is 100% offline, there is no "Forgot Password" or server reset. A lost backup password cannot be recovered.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.file_download_outlined,
                title: 'Restoring & Importing Backups',
                children: [
                  _Bullet(
                    'Go to Settings -> Backup & Restore -> tap "Import Backup".',
                  ),
                  _Bullet(
                    'Select your backup file and enter the password used when creating it.',
                  ),
                  _Bullet(
                    'The app validates the archive integrity and merges new accounts into your existing vault without deleting current tokens.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Tip: Make an updated backup whenever you add critical new 2FA accounts.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Intro extends StatelessWidget {
  final String text;
  const _Intro(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String text;
  const _Footer(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
