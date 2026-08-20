// File Path: sreerajp_authenticator/lib/screens/help/p2p_sync_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for local Wi-Fi P2P device-to-device account transfer

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class P2PSyncHelpScreen extends StatelessWidget {
  const P2PSyncHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Local Wi-Fi P2P Sync')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'Local Wi-Fi P2P Sync lets you transfer your 2FA accounts directly between two phones on the same Wi-Fi network with end-to-end encryption and zero cloud middleman.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.wifi_tethering_outlined,
                title: 'How P2P Sync Works',
                children: [
                  _Bullet(
                    'Step 1: Connect both devices to the same local Wi-Fi network.',
                  ),
                  _Bullet(
                    'Step 2: On the sending device, open Settings -> Sync to Another Device -> "Host / Send Accounts". The host binds a random local port and generates an out-of-band pairing QR code and PIN.',
                  ),
                  _Bullet(
                    'Step 3: On the receiving device, tap "Connect / Receive Accounts" and scan the host\'s pairing QR code.',
                  ),
                  _Bullet(
                    'Step 4: The two devices establish an encrypted TCP socket session and securely transfer your selected accounts.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.security_outlined,
                title: 'End-to-End Encryption',
                children: [
                  _Bullet(
                    'The sync payload is encrypted with PBKDF2-derived AES-256-GCM using the out-of-band pairing code shown on the screen.',
                  ),
                  _Bullet(
                    'Even if someone is monitoring your local Wi-Fi network traffic, they cannot decrypt or inspect your 2FA seeds.',
                  ),
                  _Bullet(
                    'Opening the sync screen requires unlocking your device, ensuring unauthorized users cannot transmit your vault.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.merge_type_outlined,
                title: 'Safe Account Merging',
                children: [
                  _Bullet(
                    'Syncing only adds and merges accounts. No existing tokens on the receiving device are deleted or replaced.',
                  ),
                  _Bullet(
                    'Duplicate accounts (matching issuer, account name, and secret) are automatically skipped.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Tip: Keep both devices awake and on the same Wi-Fi router until the transfer completes.',
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
