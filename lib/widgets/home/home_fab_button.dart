import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

/// Keyboard route to the same options a long press opens.
class _OpenAddOptionsIntent extends Intent {
  const _OpenAddOptionsIntent();
}

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
  bool _isFocused = false;
  final GlobalKey _fabKey = GlobalKey();

  void _showAddAccountOptions() {
    HapticFeedback.mediumImpact();

    final RenderBox? renderBox =
        _fabKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                      l10n.labelQrScanner,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.descScanQrCode,
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
                      l10n.labelManualEntry,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.descEnterDetailsManually,
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
    final l10n = AppLocalizations.of(context);

    return ScaleTransition(
      scale: widget.fabAnimation,
      child: Tooltip(
        message: l10n.tooltipAddAccount,
        excludeFromSemantics: true,
        // A touch long press opens the options, not this tooltip.
        triggerMode: TooltipTriggerMode.manual,
        child: Semantics(
          button: true,
          label: l10n.tooltipAddAccount,
          onTapHint: l10n.tooltipScanQr,
          onLongPressHint: l10n.tooltipAddOptions,
          child: FocusableActionDetector(
            onShowFocusHighlight: (focused) =>
                setState(() => _isFocused = focused),
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.f10, shift: true):
                  _OpenAddOptionsIntent(),
            },
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onQrScan();
                  return null;
                },
              ),
              _OpenAddOptionsIntent: CallbackAction<_OpenAddOptionsIntent>(
                onInvoke: (_) {
                  _showAddAccountOptions();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              key: _fabKey,
              onTapDown: (_) {
                setState(() => _isButtonPressed = true);
                HapticFeedback.lightImpact();
              },
              onTapUp: (_) {
                setState(() => _isButtonPressed = false);
              },
              onTap: widget.onQrScan,
              onSecondaryTap: _showAddAccountOptions,
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
                            border: _isFocused
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: Offset(0, _isButtonPressed ? 2 : 5),
                                blurRadius: _isButtonPressed ? 3 : 10,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isButtonPressed
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.primary,
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
                                    color: theme.colorScheme.onPrimary,
                                    size: 28,
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
          ),
        ),
      ),
    );
  }
}
