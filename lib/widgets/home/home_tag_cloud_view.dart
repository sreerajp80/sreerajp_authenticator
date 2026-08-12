// File Path: sreerajp_authenticator/lib/widgets/home/home_tag_cloud_view.dart
// Author: Sreeraj P
// Description: Tag Cloud View widget displaying all account tags with account member counts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../screens/tag_management_screen.dart';
import '../../utils/theme.dart';

class HomeTagCloudView extends StatefulWidget {
  final VoidCallback onTagSelected;

  const HomeTagCloudView({super.key, required this.onTagSelected});

  @override
  State<HomeTagCloudView> createState() => _HomeTagCloudViewState();
}

class _HomeTagCloudViewState extends State<HomeTagCloudView> {
  String _tagSearch = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AccountsProvider>(
      builder: (context, provider, _) {
        final availableTags = provider.allAvailableTags;
        final selectedTags = provider.selectedTags;

        final filteredTags = availableTags.where((tag) {
          if (_tagSearch.isEmpty) return true;
          return tag.toLowerCase().contains(_tagSearch.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tag Cloud',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap any tag to view matching accounts',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TagManagementScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Manage Tags'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search Bar inside Tag Cloud if multiple tags exist
              if (availableTags.length > 5) ...[
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _tagSearch = val),
                  decoration: InputDecoration(
                    hintText: 'Search tags...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _tagSearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _tagSearch = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF161B22)
                        : Colors.white.withValues(alpha: 0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Active filter banner in Tag Cloud view
              if (selectedTags.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Active filter: ${selectedTags.map((t) => t.startsWith('#') ? t : '#$t').join(', ')}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => provider.clearSelectedTags(),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tag Cloud Grid / Wrap
              if (filteredTags.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 48,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          availableTags.isEmpty
                              ? 'No tags created yet'
                              : 'No tags matching "$_tagSearch"',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          availableTags.isEmpty
                              ? 'Add tags when creating or editing an account'
                              : 'Try searching for a different keyword',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filteredTags.map((tag) {
                    final isSelected = selectedTags.any(
                      (t) => t.toLowerCase() == tag.toLowerCase(),
                    );
                    final count = provider.getAccountCountForTag(tag);
                    final displayTag = tag.startsWith('#') ? tag : '#$tag';

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (!isSelected) {
                            provider.toggleTag(tag);
                          }
                          widget.onTagSelected();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark
                                        ? const Color(0xFF334155)
                                        : AppTheme.primaryBlue.withValues(
                                            alpha: 0.25,
                                          )),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      )
                                    : Colors.black.withValues(alpha: 0.04),
                                blurRadius: isSelected ? 8 : 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayTag,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? const Color(0xFFE2E8F0)
                                            : AppTheme.deepBlue),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : AppTheme.primaryBlue.withValues(
                                                alpha: 0.1,
                                              )),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
