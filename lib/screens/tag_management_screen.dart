// File Path: sreerajp_authenticator/lib/screens/tag_management_screen.dart
// Author: Sreeraj P
// Description: Screen for managing tags (viewing member counts, renaming tags across accounts, deleting tags)

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/account_provider.dart';
import '../utils/app_logger.dart';
import '../utils/theme.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    String oldTag,
    AccountsProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: oldTag);
    final formKey = GlobalKey<FormState>();

    final newTag = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.titleRenameTag),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.labelTagName,
                hintText: l10n.descTagNameExample,
                prefixText: '#',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.errorTagNameEmpty;
                }
                if (value.trim().toLowerCase() == oldTag.toLowerCase()) {
                  return l10n.errorTagNameSame;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: Text(l10n.actionRename),
            ),
          ],
        );
      },
    );

    if (newTag != null) {
      try {
        await provider.renameTag(oldTag, newTag);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.descTagRenamed(oldTag, newTag)),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        AppLogger.error('Failed to rename tag', e);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorRenameTagFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    String tag,
    int memberCount,
    AccountsProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.titleDeleteTag),
          content: Text(
            memberCount > 0
                ? l10n.descDeleteTagUsed(tag, memberCount)
                : l10n.descDeleteTagUnused(tag),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await provider.deleteTag(tag);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.descTagDeleted(tag)),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        AppLogger.error('Failed to delete tag', e);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeleteTagFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleManageTags), centerTitle: true),
      body: Consumer<AccountsProvider>(
        builder: (context, provider, _) {
          final allTags = provider.allAvailableTags;
          final filteredTags = allTags.where((tag) {
            if (_searchQuery.isEmpty) return true;
            return tag.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: l10n.labelSearchTags,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            tooltip: l10n.tooltipClearSearch,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF161B22)
                        : theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : AppTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : AppTheme.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: _buildSummaryStat(
                          context,
                          label: l10n.labelTotalTags,
                          value: '${allTags.length}',
                          icon: Icons.label_outlined,
                        ),
                      ),
                      Container(
                        height: 28,
                        width: 1,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      Flexible(
                        child: _buildSummaryStat(
                          context,
                          label: l10n.labelAccountsTagged,
                          value:
                              '${provider.accounts.where((a) => a.tags.isNotEmpty).length}',
                          icon: Icons.shield_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tags List
              Expanded(
                child: filteredTags.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.label_off_outlined,
                              size: 56,
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              allTags.isEmpty
                                  ? l10n.emptyNoTagsFound
                                  : l10n.emptyNoMatchingTags,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              allTags.isEmpty
                                  ? l10n.emptyTagsAppearHere
                                  : l10n.emptyTryDifferentQuery,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: filteredTags.length,
                        itemBuilder: (context, index) {
                          final tag = filteredTags[index];
                          final count = provider.getAccountCountForTag(tag);
                          final displayTag = tag.startsWith('#')
                              ? tag
                              : '#$tag';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF30363D)
                                    : Colors.grey.shade300,
                              ),
                            ),

                            color: isDark
                                ? const Color(0xFF161B22)
                                : Colors.white,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.tag,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                displayTag,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                l10n.labelAccountCount(count),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    tooltip: l10n.tooltipRenameTag,
                                    onPressed: () => _showRenameDialog(
                                      context,
                                      tag,
                                      provider,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Colors.redAccent,
                                    ),
                                    tooltip: l10n.tooltipDeleteTag,
                                    onPressed: () => _showDeleteDialog(
                                      context,
                                      tag,
                                      count,
                                      provider,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
