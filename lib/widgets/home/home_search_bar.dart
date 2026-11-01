import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

class HomeSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const HomeSearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
        ),
        child: TextField(
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).labelSearchAccounts,
            hintStyle: TextStyle(color: theme.hintColor.withValues(alpha: 0.7)),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    tooltip: AppLocalizations.of(context).tooltipClearSearch,
                    icon: Icon(Icons.clear, color: theme.hintColor),
                    onPressed: onClear,
                  )
                : null,
            filled: false,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3, end: 0);
  }
}
