// File Path: sreerajp_authenticator/lib/widgets/add_account/account_info_card.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import 'tag_autocomplete_field.dart';

class AccountInfoCard extends StatelessWidget {
  final bool isEditing;
  final bool showSecretLocked;
  final bool isSecretUnlocked;
  final bool isLoadingSecret;
  final bool isAppLockEnabled;
  final TextEditingController nameController;
  final TextEditingController issuerController;
  final TextEditingController secretController;
  final TextEditingController tagsController;
  final List<String> availableTags;
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
    required this.tagsController,
    this.availableTags = const [],
    required this.onSecretEditTap,
    required this.onQrScan,
    required this.secretValidator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.titleAccountInformation.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.labelAccountName,
                hintText: l10n.descAccountNameExample,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.errorAccountNameRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: issuerController,
              decoration: InputDecoration(
                labelText: l10n.labelIssuer,
                hintText: l10n.descIssuerExample,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
              ),
            ),

            const SizedBox(height: 16),

            TagAutocompleteField(
              controller: tagsController,
              availableTags: availableTags,
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
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(4),
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.key,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.labelSecretKey,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF\u25CF',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  letterSpacing: 2,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock, color: theme.colorScheme.primary),
                            const SizedBox(height: 2),
                            Text(
                              isAppLockEnabled
                                  ? l10n.labelTapToUnlock
                                  : l10n.labelEnableAppLock,
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
                  if (isLoadingSecret) const LinearProgressIndicator(),
                  TextFormField(
                    controller: secretController,
                    decoration: InputDecoration(
                      labelText: l10n.labelSecretKey,
                      hintText: l10n.descSecretKeyBase32,
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
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () => onQrScan(),
                              tooltip: l10n.tooltipScanQr,
                            ),
                    ),
                    validator: secretValidator,
                    textCapitalization: TextCapitalization.characters,
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
