import 'package:material_ui/material_ui.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../../utils/theme.dart';

class TimerIndicator extends StatelessWidget {
  final int remainingTime;
  final int period;
  const TimerIndicator({
    super.key,
    required this.remainingTime,
    required this.period,
  });

  // The accent, then red when the code is about to expire.
  Color _getProgressColor(ThemeData theme) => remainingTime <= 5
      ? AppTheme.statusError(theme.brightness)
      : theme.colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getProgressColor(theme);
    return CircularPercentIndicator(
      radius: 18.0,
      lineWidth: 2.5,
      percent: (remainingTime / period).clamp(0.0, 1.0),
      center: Text(
        '$remainingTime',
        semanticsLabel: AppLocalizations.of(context)
            .labelSecondsCount(remainingTime),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      progressColor: color,
      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      circularStrokeCap: CircularStrokeCap.round,
      animateFromLastPercent: true,
      animation: true,
      animationDuration: 1000,
    );
  }
}
