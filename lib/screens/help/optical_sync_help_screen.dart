// File Path: sreerajp_authenticator/lib/screens/help/optical_sync_help_screen.dart
// Author: Sreeraj P
// Description: User-facing guide for Optical Air-Gap sync via animated QR code series

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class OpticalSyncHelpScreen extends StatelessWidget {
  const OpticalSyncHelpScreen({super.key});

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
          appBar: AppBar(title: const Text('Optical Air-Gap Transfer')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: const [
              _Intro(
                'Optical Air-Gap Transfer allows you to move your entire 2FA vault to an offline or air-gapped device using an animated sequence of high-density QR codes without Wi-Fi, Bluetooth, or cables.',
              ),
              SizedBox(height: 24),

              _Section(
                icon: Icons.qr_code_2_outlined,
                title: 'What is an Optical Air-Gap?',
                children: [
                  _Bullet(
                    'An air-gapped device is completely disconnected from all wireless networks (no Wi-Fi, no Bluetooth, no cellular, and in Airplane Mode).',
                  ),
                  _Bullet(
                    'Optical transfer uses only visible light (screen to camera lens) as the physical data conduit, making network eavesdropping physically impossible.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.play_circle_outline,
                title: 'How to Perform an Optical Transfer',
                children: [
                  _Bullet(
                    'Step 1: On the sending device, go to Settings -> Sync to Another Device -> tap the "Air-Gap Optical Transfer" option.',
                  ),
                  _Bullet(
                    'Step 2: The sender compresses and encodes your encrypted vault into an animated looping series of multi-frame QR codes.',
                  ),
                  _Bullet(
                    'Step 3: On the receiving device, open the Optical QR Scanner and aim the camera at the sender screen.',
                  ),
                  _Bullet(
                    'Step 4: The scanner automatically captures and reassembles all data frames. Once all parts are read, the vault is imported and verified.',
                  ),
                ],
              ),

              _Section(
                icon: Icons.tune_outlined,
                title: 'Frame Rate & Speed Tips',
                children: [
                  _Bullet(
                    'You can adjust frame speed (e.g. 250ms to 500ms per frame) on the sender depending on camera performance.',
                  ),
                  _Bullet(
                    'Hold both devices steady under good ambient lighting and avoid strong screen reflections or glare.',
                  ),
                ],
              ),

              SizedBox(height: 8),
              _Footer(
                'Tip: Optical sync is ideal for transferring tokens to a dedicated offline backup phone kept in a safe.',
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
