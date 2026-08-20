// File Path: sreerajp_authenticator/lib/screens/help/faq_troubleshooting_help_screen.dart
// Author: Sreeraj P
// Description: User-facing FAQ and troubleshooting guide addressing common questions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class FaqTroubleshootingHelpScreen extends StatelessWidget {
  const FaqTroubleshootingHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('FAQs & Troubleshooting')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'Find quick answers to common questions about 2FA codes, account recovery, security safeguards, and troubleshooting.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.key_outlined,
                title: '2FA Codes & Verification',
                children: [
                  _FaqItem(
                    question:
                        'Why are my codes rejected as invalid by websites?',
                    answer:
                        'The most common cause is clock drift on your device. Open Android Settings -> Date & Time and enable "Set time automatically" (network-provided time). This ensures your phone clock matches UTC precisely.',
                  ),
                  _FaqItem(
                    question: 'Can I copy a code with 1 tap?',
                    answer:
                        'Yes! Simply tap anywhere on the account card on your home screen. The 6-digit code is immediately copied to your clipboard with a confirmation snackbar.',
                  ),
                  _FaqItem(
                    question: 'How do HOTP codes differ from TOTP codes?',
                    answer:
                        'TOTP codes update automatically every 30 seconds based on time. HOTP codes update only when you manually tap the refresh icon to advance the counter.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.security_outlined,
                title: 'Security & App Privacy',
                children: [
                  _FaqItem(
                    question:
                        'Why does my screen go blank when switching apps?',
                    answer:
                        'Screenshot Guard enforces Android\'s FLAG_SECURE protection. This prevents screen recording apps and recent task switchers from capturing your sensitive 2FA seeds.',
                  ),
                  _FaqItem(
                    question:
                        'Does SreerajP Authenticator send any data online?',
                    answer:
                        'No. SreerajP Authenticator is 100% offline-first. It contains no analytics beacons, tracking SDKs, or cloud backends. Your data never leaves your device unless you initiate a local P2P sync or backup export.',
                  ),
                  _FaqItem(
                    question: 'What if biometric recognition fails?',
                    answer:
                        'If your fingerprint or face is not recognized, you can authenticate using your device screen lock PIN, pattern, or password.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.sync_outlined,
                title: 'Backups, Transfers & Migration',
                children: [
                  _FaqItem(
                    question: 'How do I transfer my accounts to a new phone?',
                    answer:
                        'You can either use "Sync to Another Device" over local Wi-Fi, scan an animated Optical Air-Gap QR sequence, or export an encrypted backup file from your old phone and import it on the new one.',
                  ),
                  _FaqItem(
                    question: 'What happens if I forget my backup password?',
                    answer:
                        'Because backup files use authenticated AES-256 encryption and there are no central servers, a lost backup password cannot be recovered. Keep your password written down safely.',
                  ),
                  _FaqItem(
                    question:
                        'Will importing a backup erase my existing accounts?',
                    answer:
                        'No. SreerajP Authenticator uses safe, add-only merging. Existing accounts are preserved and new accounts are added without duplicate clashes.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Need further assistance? Check the individual guides in the Help menu or inspect your permissions under Settings -> Permissions.',
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

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.help_outline, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13.5,
                height: 1.4,
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
