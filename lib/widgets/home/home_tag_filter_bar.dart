// File Path: sreerajp_authenticator/lib/widgets/home/home_tag_filter_bar.dart
// Author: Sreeraj P
// Description: Horizontal filter chip bar for multi-tag combination filtering (#Work AND #Crypto)

import 'package:flutter/material.dart';

class HomeTagFilterBar extends StatelessWidget {
  final Set<String> selectedTags;
  final List<String> availableTags;
  final ValueChanged<String> onTagToggled;
  final VoidCallback onClearTags;

  const HomeTagFilterBar({
    super.key,
    required this.selectedTags,
    required this.availableTags,
    required this.onTagToggled,
    required this.onClearTags,
  });

  @override
  Widget build(BuildContext context) {
    if (availableTags.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" / Clear Chip
          FilterChip(
            selected: selectedTags.isEmpty,
            label: Text(
              selectedTags.isEmpty
                  ? 'All Tags'
                  : 'Clear (${selectedTags.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selectedTags.isEmpty
                    ? (isDark ? Colors.white : theme.colorScheme.primary)
                    : Colors.white,
              ),
            ),
            avatar: selectedTags.isNotEmpty
                ? const Icon(Icons.close, size: 14, color: Colors.white)
                : null,
            selectedColor: selectedTags.isEmpty
                ? theme.colorScheme.primary.withValues(alpha: 0.25)
                : Colors.redAccent,
            backgroundColor: isDark
                ? const Color(0xFF21262D)
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(
              color: selectedTags.isEmpty
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.redAccent.withValues(alpha: 0.8),
            ),
            onSelected: (_) {
              if (selectedTags.isNotEmpty) {
                onClearTags();
              }
            },
          ),
          const SizedBox(width: 8),

          // Dynamic Tag Chips
          ...availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            final tagDisplay = tag.startsWith('#') ? tag : '#$tag';

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(
                  tagDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? Colors.grey.shade300
                              : theme.colorScheme.onSurface),
                  ),
                ),
                selectedColor: theme.colorScheme.primary,
                backgroundColor: isDark
                    ? const Color(0xFF21262D)
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark
                            ? const Color(0xFF30363D)
                            : theme.colorScheme.outline.withValues(alpha: 0.3)),
                  width: 1,
                ),
                onSelected: (_) => onTagToggled(tag),
              ),
            );
          }),
        ],
      ),
    );
  }
}
