import 'package:flutter/material.dart';
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

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: iconPath != null
              ? [
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.surface,
                ]
              : [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconPath != null
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(2, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: iconPath != null
                ? SvgPicture.asset(
                    iconPath,
                    width: 26,
                    height: 26,
                    placeholderBuilder: (_) => _buildLetterAvatar(),
                  )
                : _buildLetterAvatar(),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterAvatar() {
    return Text(
      displayLetter,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
