// File Path: sreerajp_authenticator/lib/widgets/add_account/browse_tags_bottom_sheet.dart
// Author: Sreeraj P
// Description: Modal bottom sheet allowing users to browse and multi-select existing vault tags

import 'package:flutter/material.dart';

class BrowseTagsBottomSheet extends StatefulWidget {
  final List<String> availableTags;
  final List<String> currentlySelectedTags;
  final ValueChanged<List<String>> onTagsSelected;

  const BrowseTagsBottomSheet({
    super.key,
    required this.availableTags,
    required this.currentlySelectedTags,
    required this.onTagsSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<String> availableTags,
    required List<String> currentlySelectedTags,
    required ValueChanged<List<String>> onTagsSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BrowseTagsBottomSheet(
        availableTags: availableTags,
        currentlySelectedTags: currentlySelectedTags,
        onTagsSelected: onTagsSelected,
      ),
    );
  }

  @override
  State<BrowseTagsBottomSheet> createState() => _BrowseTagsBottomSheetState();
}

class _BrowseTagsBottomSheetState extends State<BrowseTagsBottomSheet> {
  late final Set<String> _selectedTags;
  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    // Normalize existing selection into a set for fast lookup
    _selectedTags = widget.currentlySelectedTags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredTags {
    if (_searchFilter.trim().isEmpty) {
      return widget.availableTags;
    }
    final query = _searchFilter.trim().toLowerCase();
    return widget.availableTags
        .where((tag) => tag.toLowerCase().contains(query))
        .toList();
  }

  void _toggleTag(String tag) {
    setState(() {
      final existing = _selectedTags.firstWhere(
        (t) => t.toLowerCase() == tag.toLowerCase(),
        orElse: () => '',
      );
      if (existing.isNotEmpty) {
        _selectedTags.remove(existing);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _applyAndClose() {
    widget.onTagsSelected(_selectedTags.toList());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.75),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sell_outlined,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Browse Existing Tags',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_selectedTags.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedTags.clear();
                            });
                          },
                          child: const Text('Clear All'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Search field if tags exist
                if (widget.availableTags.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search existing tags...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchFilter.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchFilter = '');
                                },
                              )
                            : null,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _searchFilter = val);
                      },
                    ),
                  ),
                ],

                // Tag list / empty state
                Flexible(
                  child: widget.availableTags.isEmpty
                      ? _buildEmptyState(
                          context,
                          'No existing tags found',
                          'Type new tags in the text field to assign them to this entry.',
                        )
                      : _filteredTags.isEmpty
                      ? _buildEmptyState(
                          context,
                          'No matching tags',
                          'No existing tags match "$_searchFilter".',
                        )
                      : _buildTagsList(theme, isDark),
                ),

                const Divider(height: 1),

                // Bottom action button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _applyAndClose,
                    icon: const Icon(Icons.check),
                    label: Text(
                      _selectedTags.isEmpty
                          ? 'Done'
                          : 'Apply (${_selectedTags.length} selected)',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_off_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList(ThemeData theme, bool isDark) {
    final tags = _filteredTags;

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final isSelected = _selectedTags.any(
          (t) => t.toLowerCase() == tag.toLowerCase(),
        );
        final tagDisplay = tag.startsWith('#') ? tag : '#$tag';

        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) => _toggleTag(tag),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : (isDark
                            ? const Color(0xFF21262D)
                            : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagDisplay,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      },
    );
  }
}
