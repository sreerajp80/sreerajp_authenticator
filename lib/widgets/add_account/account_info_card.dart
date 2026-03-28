// File Path: sreerajp_authenticator/lib/widgets/add_account/account_info_card.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';

class AccountInfoCard extends StatelessWidget {
  final bool isEditing;
  final bool showSecretLocked;
  final bool isSecretUnlocked;
  final bool isLoadingSecret;
  final bool isAppLockEnabled;
  final TextEditingController nameController;
  final TextEditingController issuerController;
  final TextEditingController secretController;
  final int? selectedGroupId;
  final ValueChanged<int?> onGroupChanged;
  final VoidCallback onSecretEditTap;
  final VoidCallback onQrScan;
  final String? Function(String?) secretValidator;

  const AccountInfoCard({
    super.key,
    required this.isEditing,
    required this.showSecretLocked,
    required this.isSecretUnlocked,
    required this.isLoadingSecret,
    required this.isAppLockEnabled,
    required this.nameController,
    required this.issuerController,
    required this.secretController,
    required this.selectedGroupId,
    required this.onGroupChanged,
    required this.onSecretEditTap,
    required this.onQrScan,
    required this.secretValidator,
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
            Text(
              'ACCOUNT INFORMATION',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name *',
                hintText: 'e.g., john@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Account name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: issuerController,
              decoration: const InputDecoration(
                labelText: 'Issuer (Optional)',
                hintText: 'e.g., Google, GitHub',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),

            const SizedBox(height: 16),

            Consumer<GroupsProvider>(
              builder: (context, provider, _) {
                final groups = provider.groups;

                return DropdownButtonFormField<int?>(
                  value: selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Group',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.folder),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('No Group'),
                    ),
                    ...groups.map((group) {
                      return DropdownMenuItem<int?>(
                        value: group.id,
                        child: Text(group.name),
                      );
                    }),
                  ],
                  onChanged: onGroupChanged,
                );
              },
            ),

            const SizedBox(height: 16),

            if (showSecretLocked)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSecretEditTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: theme
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.key,
                          color:
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secret Key *',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(
                                      letterSpacing: 2,
                                      color: theme
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAppLockEnabled
                                  ? 'Tap to unlock'
                                  : 'Enable app lock',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Stack(
                children: [
                  if (isLoadingSecret)
                    const LinearProgressIndicator(),
                  TextFormField(
                    controller: secretController,
                    decoration: InputDecoration(
                      labelText: 'Secret Key *',
                      hintText: 'Base32 encoded secret',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: isEditing
                          ? (isSecretUnlocked
                                ? const Icon(
                                    Icons.lock_open,
                                    color: Colors.green,
                                  )
                                : null)
                          : IconButton(
                              icon: const Icon(
                                Icons.qr_code_scanner,
                              ),
                              onPressed: () => onQrScan(),
                              tooltip: 'Scan QR Code',
                            ),
                    ),
                    validator: secretValidator,
                    textCapitalization:
                        TextCapitalization.characters,
                    enabled: !isLoadingSecret,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
