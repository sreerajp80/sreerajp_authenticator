// File Path: sreerajp_authenticator/lib/screens/help/tag_management_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for tags, tag cloud, filtering, and tag management

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class TagManagementHelpScreen extends StatelessWidget {
  const TagManagementHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Tags & Organization')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'Tags let you organize your 2FA accounts into custom categories like Work, Personal, Banking, Social, and Crypto for effortless filtering.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.label_outline,
                title: 'Assigning Tags to Accounts',
                children: [
                  _Bullet(
                    'When adding or editing an account, enter tag names separated by commas (e.g. "Work, Cloud, Tech").',
                  ),
                  _Bullet(
                    'The tag autocomplete dropdown suggests existing tags as you type, ensuring consistent naming.',
                  ),
                  _Bullet(
                    'Tap "Browse existing tags" to pick from a list of all tags currently in use across your vault.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.filter_alt_outlined,
                title: 'Filtering by Tag',
                children: [
                  _Bullet(
                    'The top tag bar on the home screen displays all your tags as clickable chips.',
                  ),
                  _Bullet(
                    'Tap any tag chip to instantly display only accounts matching that tag. Tap "All" to reset the filter.',
                  ),
                  _Bullet(
                    'You can switch to the Tag Cloud view for an interactive visual representation of all active tags and account counts.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.edit_attributes_outlined,
                title: 'Tag Management Hub',
                children: [
                  _Bullet(
                    'Navigate to Settings -> Manage Tags to rename, merge, or delete tags across all accounts in a single action.',
                  ),
                  _Bullet(
                    'Renaming a tag automatically updates all accounts that carry that tag.',
                  ),
                  _Bullet(
                    'Deleting a tag removes the label from accounts without deleting the accounts themselves.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Tip: Use concise tag names (e.g. "Work", "Finance") for the cleanest display on the home screen filter bar.',
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
