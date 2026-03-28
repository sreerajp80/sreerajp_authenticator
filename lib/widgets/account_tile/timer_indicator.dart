import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TimerIndicator extends StatelessWidget {
  final int remainingTime;
  final int period;
  const TimerIndicator({super.key, required this.remainingTime, required this.period});

  Color _getProgressColor(ThemeData theme) {
    final percentage = remainingTime / period;
    final isDark = theme.brightness == Brightness.dark;

    if (percentage > 0.5) {
      return isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
    } else if (percentage > 0.25) {
      return isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    } else {
      return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = remainingTime / period;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _getProgressColor(
              theme,
            ).withValues(alpha: 0.51),
            const Color.fromARGB(0, 22, 21, 21),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getProgressColor(
              theme,
            ).withValues(alpha: 0.01),
          ),
        ],
      ),
      child: CircularPercentIndicator(
        radius: 20.0,
        lineWidth: 3.0,
        percent: percentage,
        center: Text(
          '$remainingTime',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getProgressColor(theme),
          ),
        ),
        progressColor: _getProgressColor(theme),
        backgroundColor: isDark
            ? const Color.fromARGB(
                255,
                8,
                8,
                8,
              ).withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.53),
        circularStrokeCap: CircularStrokeCap.round,
        animateFromLastPercent: true,
        animation: true,
        animationDuration: 1000,
      ),
    );
  }
}
