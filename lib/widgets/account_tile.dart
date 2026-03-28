// File Path: sreerajp_authenticator/lib/widgets/account_tile.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 18
// Description: Widget for displaying individual account tiles with OTP codes and countdown timer.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/group.dart';
import '../services/otp_service.dart';
import '../utils/constants.dart';
import '../providers/group_provider.dart';
import 'account_tile/pattern_painter.dart';
import 'account_tile/account_avatar.dart';
import 'account_tile/otp_code_display.dart';
import 'account_tile/timer_indicator.dart';

class AccountTile extends StatefulWidget {
  final Account account;
  final VoidCallback? onTap;
  final Key? dismissibleKey;

  const AccountTile({
    super.key,
    required this.account,
    this.onTap,
    this.dismissibleKey,
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

    _generateOTPInitial();
    _startSynchronizedTimer();
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
      debugPrint(
        'Failed to generate initial OTP for ${widget.account.name}: $e',
      );
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
        debugPrint('Failed to generate OTP for ${widget.account.name}: $e');
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

  void _copyToClipboard() {
    if (_otpError != null ||
        _otpCode == AppConstants.otpUnavailablePlaceholder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code unavailable for ${widget.account.name}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final copiedCode = _otpCode;
    Clipboard.setData(ClipboardData(text: copiedCode));

    // Auto-clear clipboard after 30 seconds if it still contains the copied code
    Future.delayed(const Duration(seconds: 30), () async {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == copiedCode) {
        Clipboard.setData(const ClipboardData(text: ''));
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Code copied for ${widget.account.name}'),
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
    if (!_isCodeVisible) {
      // Return asterisks matching the digit count
      return '*' * widget.account.digits;
    }
    return _otpCode;
  }

  String _formatOTP(String otp) {
    if (otp == AppConstants.otpUnavailablePlaceholder) return otp;

    // If showing asterisks, format them too
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get group name
    final provider = context.watch<GroupsProvider>();
    Group? group;
    if (widget.account.groupId != null) {
      try {
        group = provider.groups.firstWhere(
          (g) => g.id == widget.account.groupId,
        );
      } catch (e) {
        group = null;
      }
    }

    return Container(
      key: widget.dismissibleKey,
      margin: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.98 : 1.0,
          _isPressed ? 0.98 : 1.0,
          1.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.6)
                          : Colors.grey.shade400.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    if (!isDark)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                        spreadRadius: -5,
                      ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Layer 1: Base gradient background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color.fromARGB(255, 48, 44, 42),
                                const Color.fromARGB(255, 71, 35, 39),
                              ]
                            : [
                                const Color.fromARGB(0, 109, 108, 109),
                                const Color.fromARGB(255, 248, 248, 248),
                              ],
                      ),
                    ),
                  ),
                ),
                // Layer 2: Pattern overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: EnhancedPatternPainter(isDark: isDark),
                  ),
                ),

                // Layer 3: Subtle noise texture
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.7, -0.6),
                        radius: 2.0,
                        colors: isDark
                            ? [
                                const Color.fromARGB(
                                  255,
                                  129,
                                  133,
                                  136,
                                ).withValues(alpha: 0.68),
                                Colors.transparent,
                              ]
                            : [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.34,
                                ),
                                Colors.transparent,
                              ],
                      ),
                    ),
                  ),
                ),

                // Layer 4: Border overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color.fromARGB(
                              255,
                              155,
                              153,
                              153,
                            ).withValues(alpha: 0.15)
                          : const Color.fromARGB(
                              255,
                              163,
                              161,
                              161,
                            ).withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                ),

                // Layer 5: Main content with DYNAMIC HEIGHT
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    onTap: widget.onTap,
                    onDoubleTap: widget.onTap == null ? _copyToClipboard : null,
                    borderRadius: BorderRadius.circular(16),
                    highlightColor: theme.colorScheme.primary.withValues(
                      alpha: 0.85,
                    ),
                    splashColor: theme.colorScheme.primary.withValues(
                      alpha: 0.25,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AccountAvatar(
                              displayLetter:
                                  (widget.account.issuer?.isNotEmpty == true
                                          ? widget.account.issuer![0]
                                          : widget.account.name[0])
                                      .toUpperCase(),
                            ),
                            const SizedBox(width: 12),

                            // Account Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (widget
                                                    .account
                                                    .issuer
                                                    ?.isNotEmpty ==
                                                true)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                                child: Text(
                                                  widget.account.issuer!,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: isDark
                                                            ? Colors
                                                                  .grey
                                                                  .shade400
                                                            : theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 11,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            Text(
                                              widget.account.name,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color: isDark
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (group != null)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary
                                                    .withValues(alpha: 0.25),
                                                theme.colorScheme.primary
                                                    .withValues(alpha: 0.28),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.78),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            group.name,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? const Color.fromARGB(
                                                          255,
                                                          121,
                                                          232,
                                                          240,
                                                        ) // Cyan for dark theme
                                                      : const Color.fromARGB(
                                                          255,
                                                          233,
                                                          36,
                                                          22,
                                                        ), // Darker teal for light theme
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  OtpCodeDisplay(
                                    fadeAnimation: _fadeAnimation,
                                    formattedCode: _formatOTP(
                                      _getDisplayCode(),
                                    ),
                                    isCodeVisible: _isCodeVisible,
                                    onToggleVisibility: _toggleCodeVisibility,
                                  ),
                                ],
                              ),
                            ),

                            TimerIndicator(
                              remainingTime: _remainingTime,
                              period: widget.account.period,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
