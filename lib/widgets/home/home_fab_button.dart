import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';

class HomeFabButton extends StatefulWidget {
  final VoidCallback onQrScan;
  final VoidCallback onManualEntry;
  final Animation<double> fabAnimation;

  const HomeFabButton({
    super.key,
    required this.onQrScan,
    required this.onManualEntry,
    required this.fabAnimation,
  });

  @override
  State<HomeFabButton> createState() => _HomeFabButtonState();
}

class _HomeFabButtonState extends State<HomeFabButton> {
  bool _isButtonPressed = false;
  final GlobalKey _fabKey = GlobalKey();

  void _showAddAccountOptions() {
    HapticFeedback.mediumImpact();

    final RenderBox? renderBox =
        _fabKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final theme = Theme.of(context);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 80,
        position.dy - 120,
        position.dx + size.width,
        position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      elevation: 8,
      items: [
        PopupMenuItem<String>(
          value: 'qr',
          height: 56,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'QR Scanner',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Scan QR code',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'manual',
          height: 56,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Manual Entry',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Enter details manually',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (mounted) {
        if (value == 'qr') {
          widget.onQrScan();
        } else if (value == 'manual') {
          widget.onManualEntry();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaleTransition(
      scale: widget.fabAnimation,
      child: GestureDetector(
        key: _fabKey,
        onTapDown: (_) {
          setState(() => _isButtonPressed = true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          setState(() => _isButtonPressed = false);
          if (mounted) {
            widget.onQrScan();
          }
        },
        onTapCancel: () {
          setState(() => _isButtonPressed = false);
        },
        onLongPress: _showAddAccountOptions,
        child:
            AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : AppTheme.mintGreen.withValues(alpha: 0.4),
                          offset: Offset(0, _isButtonPressed ? 2 : 5),
                          blurRadius: _isButtonPressed ? 3 : 10,
                          spreadRadius: _isButtonPressed ? 0 : 1,
                        ),
                        BoxShadow(
                          color: AppTheme.mintGreen.withValues(alpha: 0.3),
                          offset: Offset(0, _isButtonPressed ? 1 : 2),
                          blurRadius: _isButtonPressed ? 2 : 4,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isButtonPressed
                                ? [
                                    Color.fromARGB(
                                      (AppTheme.mintGreen.a * 255.0).round() &
                                          0xff,
                                      (AppTheme.mintGreen.r * 255.0 * 0.9)
                                              .round() &
                                          0xff,
                                      (AppTheme.mintGreen.g * 255.0 * 0.9)
                                              .round() &
                                          0xff,
                                      (AppTheme.mintGreen.b * 255.0 * 0.9)
                                              .round() &
                                          0xff,
                                    ),
                                    AppTheme.sageGreen,
                                  ]
                                : [AppTheme.mintGreen, AppTheme.sageGreen],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          transform: Matrix4.identity()
                            ..setTranslationRaw(
                              0.0,
                              _isButtonPressed ? 1.0 : 0.0,
                              0.0,
                            ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 28,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
      ),
    );
  }
}
