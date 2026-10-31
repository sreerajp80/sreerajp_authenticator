// File Path: sreerajp_authenticator/lib/screens/help/getting_started_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for getting started, adding 2FA accounts, QR scanning, and manual setup

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';

import '../../providers/settings_provider.dart';

class GettingStartedHelpScreen extends StatelessWidget {
  const GettingStartedHelpScreen({super.key});

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
          appBar: AppBar(title: Text(l10n.helpStart01)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              _Intro(l10n.helpStart02(appName)),
              const SizedBox(height: 24),

              _Section(
                icon: Icons.qr_code_scanner_outlined,
                title: l10n.helpStart03,
                children: [
                  _Bullet(l10n.helpStart04),
                  _Bullet(l10n.helpStart05(appName, l10n.labelQrScanner)),
                  _Bullet(l10n.helpStart06),
                ],
              ),

              _Section(
                icon: Icons.edit_note_outlined,
                title: l10n.helpStart07,
                children: [
                  _Bullet(l10n.helpStart08(l10n.labelManualEntry)),
                  _Bullet(l10n.helpStart09),
                  _Bullet(l10n.helpStart10),
                  _Bullet(l10n.helpStart11),
                ],
              ),

              _Section(
                icon: Icons.copy_outlined,
                title: l10n.helpStart12,
                children: [
                  _Bullet(l10n.helpStart13),
                  _Bullet(l10n.helpStart14),
                  _Bullet(l10n.helpStart15),
                ],
              ),

              const SizedBox(height: 8),
              _Footer(l10n.helpStart16),
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
