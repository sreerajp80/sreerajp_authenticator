// File Path: sreerajp_authenticator/lib/screens/help/time_sync_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for time synchronization, clock drift, and HOTP counters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class TimeSyncHelpScreen extends StatelessWidget {
  const TimeSyncHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Time Sync & Code Drift')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'TOTP codes depend on precise device time. If your phone clock is even a few seconds ahead or behind, your generated codes will be rejected by websites.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.access_time_outlined,
                title: 'How TOTP Time Works',
                children: [
                  _Bullet(
                    'Time-based one-time passwords calculate a numeric code by hashing your secret key together with the current Unix epoch timestamp divided into 30-second steps.',
                  ),
                  _Bullet(
                    'Both your phone and the server must agree on the current time in UTC (Coordinated Universal Time). Time zone changes do not affect UTC.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.sync_problem_outlined,
                title: 'Fixing Invalid or Rejected Codes',
                children: [
                  _Bullet(
                    'Open your Android System Settings and go to System -> Date & Time.',
                  ),
                  _Bullet(
                    'Turn ON "Set time automatically" and "Set time zone automatically" (or use network-provided time).',
                  ),
                  _Bullet(
                    'If already enabled, toggle it OFF and back ON to force an immediate NTP network time sync with your cellular carrier.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.pin_outlined,
                title: 'Understanding HOTP Counter Codes',
                children: [
                  _Bullet(
                    'HOTP codes are event-based rather than time-based. They advance only when you manually generate a code.',
                  ),
                  _Bullet(
                    'If you tap the refresh button multiple times without logging in, your phone counter and the server counter may get out of sync.',
                  ),
                  _Bullet(
                    'Most servers allow a small lookahead window of 10 to 20 codes. Try generating and entering the next consecutive code.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Tip: 99% of invalid code issues are caused by manual device clock offsets. Automatic network time solves this permanently.',
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
