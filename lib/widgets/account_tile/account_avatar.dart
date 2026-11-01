import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/brand_icon_service.dart';

class AccountAvatar extends StatelessWidget {
  final String displayLetter;
  final String? issuer;
  final String? accountName;

  const AccountAvatar({
    super.key,
    required this.displayLetter,
    this.issuer,
    this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = BrandIconService.getBrandIconPath(
      issuer,
      accountName ?? '',
    );

    final accent = theme.colorScheme.primary;

    // Brand icons keep a white tile, because some are dark and would be lost
    // on the dark card.
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconPath != null ? Colors.white : accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: iconPath != null ? Border.all(color: theme.dividerColor) : null,
      ),
      child: iconPath != null
          ? SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              placeholderBuilder: (_) => _buildLetterAvatar(accent),
            )
          : _buildLetterAvatar(accent),
    );
  }

  Widget _buildLetterAvatar(Color color) {
    return Text(
      displayLetter,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: color),
    );
  }
}
