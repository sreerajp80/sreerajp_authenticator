// File Path: sreerajp_authenticator/lib/widgets/add_account/advanced_settings_card.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';

class AdvancedSettingsCard extends StatelessWidget {
  final bool isEditing;
  final bool showAdvancedLocked;
  final bool isAdvancedUnlocked;
  final bool isAppLockEnabled;
  final int digits;
  final int period;
  final String algorithm;
  final ValueChanged<int?> onDigitsChanged;
  final ValueChanged<int?> onPeriodChanged;
  final ValueChanged<String?> onAlgorithmChanged;
  final VoidCallback onAdvancedEditTap;

  const AdvancedSettingsCard({
    super.key,
    required this.isEditing,
    required this.showAdvancedLocked,
    required this.isAdvancedUnlocked,
    required this.isAppLockEnabled,
    required this.digits,
    required this.period,
    required this.algorithm,
    required this.onDigitsChanged,
    required this.onPeriodChanged,
    required this.onAlgorithmChanged,
    required this.onAdvancedEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ADVANCED SETTINGS',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (showAdvancedLocked)
                  IconButton(
                    icon: const Icon(Icons.lock),
                    color: theme.colorScheme.primary,
                    onPressed: onAdvancedEditTap,
                    tooltip: isAppLockEnabled
                        ? 'Unlock to view and edit'
                        : 'Enable app lock first',
                  ),
                if (isEditing && isAdvancedUnlocked)
                  const Icon(
                    Icons.lock_open,
                    color: Colors.green,
                  ),
              ],
            ),

            if (showAdvancedLocked)
              Column(
                children: [
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onAdvancedEditTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.numbers,
                                  size: 20,
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Digits: ',
                                  style:
                                      theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  '\u25CF\u25CF',
                                  style: theme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        letterSpacing: 2,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 20,
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Period: ',
                                  style:
                                      theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  '\u25CF\u25CF seconds',
                                  style: theme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        letterSpacing: 2,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 20,
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Algorithm: ',
                                  style:
                                      theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  '\u25CF\u25CF\u25CF\u25CF\u25CF',
                                  style: theme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        letterSpacing: 2,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color:
                                      theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isAppLockEnabled
                                      ? 'Tap to unlock and view settings'
                                      : 'Enable app lock to edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: digits,
                    decoration: const InputDecoration(
                      labelText: 'Digits',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 6,
                        child: Text('6'),
                      ),
                      DropdownMenuItem(
                        value: 8,
                        child: Text('8'),
                      ),
                    ],
                    onChanged: onDigitsChanged,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: period,
                    decoration: const InputDecoration(
                      labelText: 'Period (seconds)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 30,
                        child: Text('30 seconds'),
                      ),
                      DropdownMenuItem(
                        value: 60,
                        child: Text('60 seconds'),
                      ),
                    ],
                    onChanged: onPeriodChanged,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: algorithm,
                    decoration: const InputDecoration(
                      labelText: 'Algorithm',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'SHA1',
                        child: Text('SHA-1'),
                      ),
                      DropdownMenuItem(
                        value: 'SHA256',
                        child: Text('SHA-256'),
                      ),
                      DropdownMenuItem(
                        value: 'SHA512',
                        child: Text('SHA-512'),
                      ),
                    ],
                    onChanged: onAlgorithmChanged,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
