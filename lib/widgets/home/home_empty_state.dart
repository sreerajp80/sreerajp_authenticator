import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';

class HomeEmptyState extends StatelessWidget {
  final String searchQuery;

  const HomeEmptyState({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1E3A5F).withValues(alpha: 0.2),
                        const Color(0xFF2D4A3D).withValues(alpha: 0.2),
                      ]
                    : [
                        AppTheme.primaryBlue.withValues(alpha: 0.1),
                        AppTheme.mintGreen.withValues(alpha: 0.1),
                      ],
              ),
            ),
            child: Icon(
              Icons.security,
              size: 80,
              color: isDark ? const Color(0xFF64B5F6) : AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty ? 'No accounts found' : 'No accounts yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE1E4E8) : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Tap the + button to add your first account',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1565C0).withValues(alpha: 0.15),
                        const Color(0xFF0D47A1).withValues(alpha: 0.15),
                      ]
                    : [
                        AppTheme.primaryBlue.withValues(alpha: 0.08),
                        AppTheme.deepBlue.withValues(alpha: 0.08),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF30363D)
                    : AppTheme.primaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: isDark ? const Color(0xFFFFD700) : AppTheme.goldAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tip: Long press + button for more options',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFB1BAC4) : AppTheme.deepBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
