// File Path: sreerajp_authenticator/lib/screens/help/getting_started_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for getting started, adding 2FA accounts, QR scanning, and manual setup

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class GettingStartedHelpScreen extends StatelessWidget {
  const GettingStartedHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Getting Started')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'SreerajP Authenticator generates two-factor authentication (2FA) codes to secure your online accounts. All codes are generated locally on your device without an internet connection.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.qr_code_scanner_outlined,
                title: 'Adding an Account via QR Code',
                children: [
                  _Bullet(
                    'On your service provider (e.g., Google, GitHub, Amazon), navigate to Security or 2FA settings and choose "Set up Authenticator App".',
                  ),
                  _Bullet(
                    'In SreerajP Authenticator, tap the "+" floating action button on the home screen and select "Scan QR Code".',
                  ),
                  _Bullet(
                    'Point your camera at the QR code displayed on your computer or secondary screen. The account will be verified and added instantly.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.edit_note_outlined,
                title: 'Adding an Account Manually',
                children: [
                  _Bullet(
                    'If you cannot scan a QR code, choose "Enter Key Manually" from the add account menu.',
                  ),
                  _Bullet(
                    'Enter the Account Name (e.g., your email or username) and Issuer (e.g., GitHub, Google).',
                  ),
                  _Bullet(
                    'Paste the Secret Key (Base32 format) provided by your service.',
                  ),
                  _Bullet(
                    'Under Advanced Settings, you can configure the algorithm (SHA1, SHA256, SHA512), digits (6 or 8), interval (30s), or HOTP counter if needed.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.copy_outlined,
                title: 'Using Your 2FA Codes',
                children: [
                  _Bullet(
                    'Time-based (TOTP) codes refresh automatically every 30 seconds. The circular countdown ring shows remaining validity.',
                  ),
                  _Bullet(
                    'Tap any account tile to copy the active 6-digit code directly to your clipboard.',
                  ),
                  _Bullet(
                    'Paste the code into the login screen of your website or service to complete sign-in.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Tip: Always save backup recovery codes provided by your online services in a secure location in case you lose access to your phone.',
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
