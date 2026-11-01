// File Path: sreerajp_authenticator/lib/screens/google_import_review_screen.dart
// Author: Sreeraj P
// Description: Lets the user review and choose the accounts found in a Google
// Authenticator export before they are saved.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';
import '../services/google_migration_service.dart';

class GoogleImportReviewScreen extends StatefulWidget {
  final List<GoogleMigrationEntry> entries;

  const GoogleImportReviewScreen({super.key, required this.entries});

  @override
  State<GoogleImportReviewScreen> createState() =>
      _GoogleImportReviewScreenState();
}

class _GoogleImportReviewScreenState extends State<GoogleImportReviewScreen> {
  /// Indexes in [GoogleImportReviewScreen.entries] of accounts already in the
  /// app, or repeated earlier in this export.
  final Set<int> _duplicates = {};

  /// Indexes of the accounts the user has chosen.
  final Set<int> _selected = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final seen = context.read<AccountsProvider>().existingDuplicateKeys;
    for (var i = 0; i < widget.entries.length; i++) {
      final account = widget.entries[i].account;
      if (account == null) continue;
      if (seen.add(AccountsProvider.duplicateKey(account))) {
        _selected.add(i);
      } else {
        _duplicates.add(i);
      }
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<AccountsProvider>();
    final indexes = _selected.toList()..sort();
    final accounts = <Account>[
      for (final index in indexes) widget.entries[index].account!,
    ];

    setState(() => _isSaving = true);
    try {
      final result = await provider.importData({'accounts': accounts});
      final hasHotp = accounts.any((a) => a.type == 'hotp');
      final added = result.accountsSkipped > 0
          ? l10n.descAddedAccountsSkipped(
              result.accountsAdded,
              result.accountsSkipped,
            )
          : l10n.descAddedAccounts(result.accountsAdded);
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            hasHotp ? '$added\n${l10n.descImportHotpReminder}' : added,
          ),
          duration: Duration(seconds: hasHotp ? 8 : 4),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorImportFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String? _reason(AppLocalizations l10n, int index) {
    if (_duplicates.contains(index)) return l10n.labelAlreadyInApp;
    return switch (widget.entries[index].problem) {
      null => null,
      GoogleMigrationProblem.damaged => l10n.errorEntryDamaged,
      GoogleMigrationProblem.missingSecret => l10n.errorEntryNoSecret,
      GoogleMigrationProblem.shortSecret => l10n.errorEntryShortSecret,
      GoogleMigrationProblem.unsupportedAlgorithm => l10n.errorEntryAlgorithm,
      GoogleMigrationProblem.unsupportedDigits => l10n.errorEntryDigits,
      GoogleMigrationProblem.unsupportedType => l10n.errorEntryType,
    };
  }

  String _title(AppLocalizations l10n, GoogleMigrationEntry entry) {
    final name = entry.displayName;
    if (name.isEmpty) return l10n.labelUnnamedAccount;
    final issuer = entry.displayIssuer;
    return issuer == null || issuer == name ? name : '$issuer ($name)';
  }

  Widget _buildEntry(AppLocalizations l10n, int index) {
    final entry = widget.entries[index];
    final reason = _reason(l10n, index);
    return CheckboxListTile(
      value: _selected.contains(index),
      title: Text(_title(l10n, entry)),
      subtitle: reason == null ? null : Text(reason),
      onChanged: reason != null || _isSaving
          ? null
          : (checked) => setState(() {
              if (checked == true) {
                _selected.add(index);
              } else {
                _selected.remove(index);
              }
            }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleImportAccounts)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.descImportReviewHint),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.entries.length,
              itemBuilder: (_, index) => _buildEntry(l10n, index),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving || _selected.isEmpty ? null : _import,
                  child: Text(l10n.actionImportCount(_selected.length)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
