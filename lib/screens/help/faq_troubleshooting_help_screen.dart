// File Path: sreerajp_authenticator/lib/screens/help/faq_troubleshooting_help_screen.dart
// Author: Sreeraj P
// Description: User-facing FAQ and troubleshooting guide addressing common questions

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';

import '../../providers/settings_provider.dart';

class FaqTroubleshootingHelpScreen extends StatelessWidget {
  const FaqTroubleshootingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations.of(context);
        final appName = context.read<AppConfig>().appName.resolve(
          Localizations.localeOf(context).languageCode,
        );
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.helpFaq01)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              _Intro(l10n.helpFaq02),
              const SizedBox(height: 24),

              _Section(
                icon: Icons.key_outlined,
                title: l10n.helpFaq03,
                children: [
                  _FaqItem(question: l10n.helpFaq04, answer: l10n.helpFaq05),
                  _FaqItem(question: l10n.helpFaq06, answer: l10n.helpFaq07),
                  _FaqItem(question: l10n.helpFaq08, answer: l10n.helpFaq09),
                ],
              ),

              _Section(
                icon: Icons.security_outlined,
                title: l10n.helpFaq10,
                children: [
                  _FaqItem(question: l10n.helpFaq11, answer: l10n.helpFaq12),
                  _FaqItem(
                    question: l10n.helpFaq13(appName),
                    answer: l10n.helpFaq14(appName),
                  ),
                  _FaqItem(question: l10n.helpFaq15, answer: l10n.helpFaq16),
                ],
              ),

              _Section(
                icon: Icons.sync_outlined,
                title: l10n.helpFaq17,
                children: [
                  _FaqItem(
                    question: l10n.helpFaq18,
                    answer: l10n.helpFaq19(l10n.titleSyncDevice),
                  ),
                  _FaqItem(question: l10n.helpFaq20, answer: l10n.helpFaq21),
                  _FaqItem(
                    question: l10n.helpFaq22,
                    answer: l10n.helpFaq23(appName),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              _Footer(
                l10n.helpFaq24(l10n.titleSettings, l10n.titlePermissions),
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
