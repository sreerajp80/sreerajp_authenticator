import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';

class HomeGroupTabs extends StatelessWidget {
  final int? selectedGroupId;
  final ValueChanged<int?> onGroupSelected;

  const HomeGroupTabs({
    super.key,
    required this.selectedGroupId,
    required this.onGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<GroupsProvider>(
      builder: (context, provider, _) {
        final groups = provider.groups;
        if (groups.isNotEmpty) {
          return Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF30363D)
                      : const Color(0xFFE0E7FF),
                  width: 1,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: groups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildTab(
                    label: 'All',
                    isSelected: selectedGroupId == null,
                    onTap: () {
                      onGroupSelected(null);
                    },
                    theme: theme,
                  );
                } else {
                  final group = groups[index - 1];
                  return _buildTab(
                    label: group.name,
                    isSelected: selectedGroupId == group.id,
                    onTap: () {
                      onGroupSelected(
                        selectedGroupId == group.id ? null : group.id,
                      );
                    },
                    theme: theme,
                  );
                }
              },
            ),
          ).animate().fadeIn(delay: 200.ms);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
