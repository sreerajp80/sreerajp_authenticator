// File Path: sreerajp_authenticator/lib/screens/help/vault_security_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for AES-256-GCM vault encryption, Keystore, FLAG_SECURE, and offline privacy

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class VaultSecurityHelpScreen extends StatelessWidget {
  const VaultSecurityHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Vault Security & Privacy')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'SreerajP Authenticator is engineered with a strict zero-trust, offline-first security model. Your seed keys are encrypted with hardware-backed encryption and never touch any remote servers.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.enhanced_encryption_outlined,
                title: 'AES-256-GCM Hardware Vault',
                children: [
                  _Bullet(
                    'All OTP secrets, seed keys, and custom parameters are encrypted with AES-256 in Galois/Counter Mode (GCM), providing authenticated encryption with integrity verification.',
                  ),
                  _Bullet(
                    'The encryption master key is generated on-device and sealed in the hardware-backed Android Keystore / FlutterSecureStorage.',
                  ),
                  _Bullet(
                    'No plaintext secret or raw seed is ever written to the SQLite database on disk.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.screenshot_outlined,
                title: 'Screenshot Guard (FLAG_SECURE)',
                children: [
                  _Bullet(
                    'The app permanently enforces FLAG_SECURE at the OS window level.',
                  ),
                  _Bullet(
                    'This blocks screenshots, video captures, and malicious screen scrapers from recording your 2FA tokens.',
                  ),
                  _Bullet(
                    'When switching apps, the Android Recent Tasks view shows a blank/obscured screen to prevent casual shoulder surfing.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.wifi_off_outlined,
                title: 'Zero Cloud & Zero Telemetry',
                children: [
                  _Bullet(
                    'The app has no backend server, no login portal, and no advertising or analytics SDKs.',
                  ),
                  _Bullet(
                    'No tokens, logs, device identifiers, or usage telemetry ever leave your device.',
                  ),
                  _Bullet(
                    'All operations—including QR scanning, OTP computation, and backup export—are completed entirely offline.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Security Principle: True privacy means no telemetry. Your authentication secrets belong to you alone.',
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
