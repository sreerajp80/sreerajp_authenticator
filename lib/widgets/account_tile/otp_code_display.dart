import 'package:flutter/material.dart';

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
    return Row(
      children: [
        FadeTransition(
          opacity: fadeAnimation,
          child: Text(
            formattedCode,
            style: theme.textTheme.headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.w900,
                  color:
                      theme.colorScheme.primary,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      color: theme
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.secondary,
                theme.colorScheme.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(
              8,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(1, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.2,
                ),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.only(
                          topLeft:
                              Radius.circular(8),
                          topRight:
                              Radius.circular(8),
                        ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(
                          alpha: 0.85,
                        ),
                        Colors.white.withValues(
                          alpha: 0.25,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggleVisibility,
                  borderRadius:
                      BorderRadius.circular(8),
                  child: Center(
                    child: Icon(
                      isCodeVisible
                          ? Icons
                                .visibility_off_rounded
                          : Icons
                                .visibility_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
