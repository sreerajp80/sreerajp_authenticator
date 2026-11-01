// File Path: sreerajp_authenticator/lib/widgets/account_tile.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 18
// Description: Widget for displaying individual account tiles with OTP codes and countdown timer.

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';
import '../services/clipboard_service.dart';
import '../services/otp_service.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';
import '../utils/theme.dart';
import 'account_tile/account_avatar.dart';
import 'account_tile/otp_code_display.dart';
import 'account_tile/timer_indicator.dart';

class AccountTile extends StatefulWidget {
  final Account account;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Key? dismissibleKey;
  final bool isSelectionMode;
  final bool isSelected;

  const AccountTile({
    super.key,
    required this.account,
    this.onTap,
    this.onLongPress,
    this.dismissibleKey,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile>
    with SingleTickerProviderStateMixin {
  String _otpCode = AppConstants.otpUnavailablePlaceholder;
  OTPException? _otpError;
  int _remainingTime = 30;
  Timer? _timer;
  Timer? _syncTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;
  bool _isInitialLoad = true;
  bool _isCodeVisible = false;
  Timer? _visibilityTimer;
  bool _isFetchingHotp = false;

  bool get _isHotp => widget.account.type.toLowerCase() == 'hotp';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(_animationController);

    // An HOTP code is made only on request, because each one uses up a counter.
    if (_isHotp) {
      _isInitialLoad = false;
    } else {
      _generateOTPInitial();
      _startSynchronizedTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _syncTimer?.cancel();
    _visibilityTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateOTPInitial() async {
    try {
      final result = await OTPService.generateTOTPAsync(widget.account);
      if (mounted) {
        setState(() {
          _applyOTPResult(result);
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to generate initial OTP', e);
      if (mounted) {
        setState(() {
          _otpCode = AppConstants.otpUnavailablePlaceholder;
          _otpError = OTPUnexpectedException(
            'Failed to generate initial OTP for account "${widget.account.name}"',
            e,
          );
          _isInitialLoad = false;
        });
      }
    }
  }

  void _generateOTP() {
    if (_isInitialLoad) return;

    setState(() {
      try {
        final result = OTPService.generateTOTP(widget.account);
        _applyOTPResult(result);
      } catch (e) {
        AppLogger.error('Failed to refresh OTP', e);
        _otpCode = AppConstants.otpUnavailablePlaceholder;
        _otpError = OTPUnexpectedException(
          'Failed to generate OTP for account "${widget.account.name}"',
          e,
        );
      }
    });
  }

  void _applyOTPResult(OTPGenerationResult result) {
    _otpCode = result.code ?? AppConstants.otpUnavailablePlaceholder;
    _otpError = result.error;
    if (result.isSuccess) {
      _animationController.forward(from: 0.0);
    }
  }

  void _startSynchronizedTimer() {
    _timer?.cancel();
    _syncTimer?.cancel();

    final period = widget.account.period;

    // Calculate exact position in current period using CURRENT time
    var now = DateTime.now();
    var timestamp = now.millisecondsSinceEpoch ~/ 1000;
    var secondsInPeriod = timestamp % period;
    _remainingTime = period - secondsInPeriod;

    // Calculate milliseconds until next exact second
    final msUntilNextSecond = 1000 - now.millisecond;

    // Wait until next second boundary
    _syncTimer = Timer(Duration(milliseconds: msUntilNextSecond), () {
      if (!mounted) return;

      // FIRST tick at exact second boundary - recalculate from actual time
      now = DateTime.now();
      timestamp = now.millisecondsSinceEpoch ~/ 1000;
      secondsInPeriod = timestamp % period;
      final newRemainingTime = period - secondsInPeriod;

      setState(() {
        _remainingTime = newRemainingTime;

        // Check if we should regenerate (at period boundary or just crossed it)
        if (_remainingTime >= period - 1) {
          _generateOTP();
        }
      });

      // Start periodic timer that RECALCULATES time on each tick
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final currentSecondsInPeriod = currentTime % period;
        final actualRemainingTime = period - currentSecondsInPeriod;

        // Skip rebuild if nothing changed
        if (actualRemainingTime == _remainingTime) return;

        // Check if we crossed period boundary (remaining jumped back to high number)
        if (actualRemainingTime > _remainingTime) {
          _generateOTP();
        }

        setState(() {
          _remainingTime = actualRemainingTime;
        });
      });
    });
  }

  void _showHotpError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _nextHotpCode() async {
    if (_isFetchingHotp) return;
    setState(() => _isFetchingHotp = true);
    final result = await context.read<AccountsProvider>().nextHotpCode(
      widget.account,
    );
    if (!mounted) return;
    setState(() {
      _isFetchingHotp = false;
      if (result.isSuccess) _applyOTPResult(result);
    });
    if (!result.isSuccess) {
      _showHotpError(AppLocalizations.of(context).errorHotpNextFailed);
      return;
    }
    HapticFeedback.lightImpact();
    if (!_isCodeVisible) _toggleCodeVisibility();
  }

  void _copyToClipboard() {
    if (_isHotp && _otpCode == AppConstants.otpUnavailablePlaceholder) {
      _showHotpError(AppLocalizations.of(context).descHotpTapForCode);
      return;
    }
    if (_otpError != null ||
        _otpCode == AppConstants.otpUnavailablePlaceholder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .errorCodeUnavailable(widget.account.name),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final copiedCode = _otpCode;
    ClipboardService.copySecret(copiedCode);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context)
                    .descCodeCopied(widget.account.name),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleCodeVisibility() {
    setState(() {
      _isCodeVisible = !_isCodeVisible;

      if (_isCodeVisible) {
        // Start 1-minute timer to auto-hide
        _visibilityTimer?.cancel();
        _visibilityTimer = Timer(const Duration(seconds: 28), () {
          if (mounted) {
            setState(() {
              _isCodeVisible = false;
            });
          }
        });

        HapticFeedback.lightImpact();
      } else {
        // Cancel timer if manually hidden
        _visibilityTimer?.cancel();
      }
    });
  }

  String _getDisplayCode() {
    if (_isHotp && _otpCode == AppConstants.otpUnavailablePlaceholder) {
      return _otpCode;
    }
    if (!_isCodeVisible) {
      // Return asterisks matching the digit count
      return '*' * widget.account.digits;
    }
    return _otpCode;
  }

  String _formatOTP(String otp) {
    if (otp == AppConstants.otpUnavailablePlaceholder) return otp;

    if (otp.length == 5) return otp; // Steam Guard 5-char code

    if (otp.contains('*')) {
      if (otp.length == 6) {
        return '${otp.substring(0, 3)} ${otp.substring(3)}';
      } else if (otp.length == 8) {
        return '${otp.substring(0, 4)} ${otp.substring(4)}';
      }
      return otp;
    }

    if (otp.length == 6) {
      return '${otp.substring(0, 3)} ${otp.substring(3)}';
    } else if (otp.length == 8) {
      return '${otp.substring(0, 4)} ${otp.substring(4)}';
    }
    return otp;
  }

  /// The first tag, then "+N" for the rest. A screen reader hears every tag.
  Widget _buildTags(ThemeData theme) {
    final tags = widget.account.tags
        .map((tag) => tag.startsWith('#') ? tag : '#$tag')
        .toList();
    final muted = theme.colorScheme.onSurfaceVariant;
    return Semantics(
      label: tags.join(', '),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                tags.first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ),
          if (tags.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '+${tags.length - 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasIssuer = widget.account.issuer?.isNotEmpty == true;
    const radius = BorderRadius.all(Radius.circular(14));

    return AnimatedContainer(
      key: widget.dismissibleKey,
      duration: const Duration(milliseconds: 100),
      transform: Matrix4.diagonal3Values(
        _isPressed ? 0.98 : 1.0,
        _isPressed ? 0.98 : 1.0,
        1.0,
      ),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppTheme.cardShadows(isDark: isDark, isPressed: _isPressed),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Material(
              color: theme.colorScheme.surface,
              child: Semantics(
                onTapHint: widget.isSelectionMode
                    ? null
                    : AppLocalizations.of(context).actionCopyCode,
                child: InkWell(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  onTap: () {
                    widget.onTap?.call();
                    if (!widget.isSelectionMode) _copyToClipboard();
                  },
                  onLongPress: widget.onLongPress,
                  highlightColor: theme.colorScheme.primary.withValues(
                    alpha: 0.06,
                  ),
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (widget.isSelectionMode)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  widget.isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: widget.isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                            AccountAvatar(
                              displayLetter:
                                  (hasIssuer
                                          ? widget.account.issuer![0]
                                          : widget.account.name[0])
                                      .toUpperCase(),
                              issuer: widget.account.issuer,
                              accountName: widget.account.name,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    hasIssuer
                                        ? widget.account.issuer!
                                        : widget.account.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasIssuer)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        widget.account.name,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontSize: 12,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!_isHotp)
                              TimerIndicator(
                                remainingTime: _remainingTime,
                                period: widget.account.period,
                              )
                            else if (!widget.isSelectionMode)
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded),
                                tooltip: AppLocalizations.of(context)
                                    .tooltipNextCode,
                                onPressed: _isFetchingHotp
                                    ? null
                                    : _nextHotpCode,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(height: 1, color: theme.dividerColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: OtpCodeDisplay(
                                fadeAnimation: _fadeAnimation,
                                formattedCode: _formatOTP(_getDisplayCode()),
                                isCodeVisible: _isCodeVisible,
                                onToggleVisibility: _toggleCodeVisibility,
                              ),
                            ),
                            if (widget.account.tags.isNotEmpty)
                              Flexible(flex: 2, child: _buildTags(theme)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Thin light top edge, like light catching a raised surface.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1,
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
