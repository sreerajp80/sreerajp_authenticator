import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

class OtpCodeDisplay extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final String formattedCode;
  final bool isCodeVisible;
  final VoidCallback onToggleVisibility;
  const OtpCodeDisplay({
    super.key,
    required this.fadeAnimation,
    required this.formattedCode,
    required this.isCodeVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eyeLabel = isCodeVisible
        ? l10n.tooltipHideCode
        : l10n.tooltipShowCode;
    final isMasked = formattedCode.contains('*');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Semantics(
            // A hidden code is never read out as a row of asterisks.
            label: isMasked ? l10n.descCodeHidden : null,
            excludeSemantics: isMasked,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Text(
                  formattedCode,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
        Tooltip(
          message: eyeLabel,
          excludeFromSemantics: true,
          child: Semantics(
            button: true,
            label: eyeLabel,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggleVisibility,
                borderRadius: BorderRadius.circular(24),
                // 48 x 48 tap area around the icon (§7.1).
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(
                      isCodeVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
