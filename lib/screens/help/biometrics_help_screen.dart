// File Path: sreerajp_authenticator/lib/screens/help/biometrics_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for biometric authentication, device lock, PIN fallback, and auto-lock

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class BiometricsHelpScreen extends StatelessWidget {
  const BiometricsHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Biometric & App Lock')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'SreerajP Authenticator can guard your 2FA tokens behind your phone\'s biometric sensors (fingerprint / face unlock) or your device screen lock PIN.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.fingerprint_outlined,
                title: 'How App Lock Works',
                children: [
                  _Bullet(
                    'When enabled under Settings -> Security Settings, the app requires authentication whenever you open it or return from the background.',
                  ),
                  _Bullet(
                    'Decrypted OTP secrets are kept in volatile memory only while the app is active and unlocked.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.lock_clock_outlined,
                title: 'Automatic Inactivity Lock',
                children: [
                  _Bullet(
                    'Whenever you minimize the app, switch to another application, or lock your phone screen, the app immediately locks.',
                  ),
                  _Bullet(
                    'Decrypted OTP seeds are purged from memory to prevent memory-dump attacks or unauthorized physical access.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.password_outlined,
                title: 'Fallback & Device PIN',
                children: [
                  _Bullet(
                    'If biometric recognition fails (e.g. wet fingers or low lighting), you can authenticate with your device screen lock PIN, pattern, or password.',
                  ),
                  _Bullet(
                    'Authentication is processed by the secure Android OS system framework. SreerajP Authenticator never sees or stores your biometric data or device passcode.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Tip: Ensure you have a secure screen lock configured in your Android System Settings for maximum biometric security.',
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
