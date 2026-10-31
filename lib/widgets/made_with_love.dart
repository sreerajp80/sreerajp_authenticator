import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/utils/theme.dart';

/// The signature badge at the bottom of the About screen
/// (`docs/guidelines/guideline.md` §1.7). The text is localized; the heart is
/// always a red vector icon, never an emoji.
class MadeWithLove extends StatelessWidget {
  const MadeWithLove({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final base = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    // Split the localized text around the {heart} placeholder so the heart
    // keeps its own colour in every language. The sentinel never appears in
    // translated text, so the split is exact.
    const sentinel = '\u0000';
    final parts = l10n.madeWithLove(sentinel).split(sentinel);

    return Semantics(
      label: l10n.madeWithLoveA11y,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: parts.first, style: base),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.favorite,
                    size: (base.fontSize ?? 12) * 1.1,
                    color: AppTheme.heartRed,
                  ),
                ),
                TextSpan(text: parts.length > 1 ? parts[1] : '', style: base),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
