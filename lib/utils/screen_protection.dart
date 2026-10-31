// File Path: sreerajp_authenticator/lib/utils/screen_protection.dart
// Author: Sreeraj P
// Description: Turns on screen capture protection on the platforms that have it.

import 'package:flutter/foundation.dart';
import 'package:screen_protector/screen_protector.dart';

/// Prevent screenshots and screen recording (sets FLAG_SECURE on Android).
///
/// `screen_protector` has no Windows or Linux plugin, so calling it there would
/// throw before the app starts. Those platforms have no protection today
/// (docs/security.md §10).
Future<void> enableScreenProtection() async {
  if (!isScreenProtectionSupported) return;
  await ScreenProtector.protectDataLeakageOn();
  await ScreenProtector.preventScreenshotOn();
}

/// Allow screenshots and screen recording again (clears FLAG_SECURE on Android).
///
/// Only for the user's own choice in Settings. Does nothing on platforms
/// without protection.
Future<void> disableScreenProtection() async {
  if (!isScreenProtectionSupported) return;
  await ScreenProtector.preventScreenshotOff();
  await ScreenProtector.protectDataLeakageOff();
}

/// Whether this platform can block screen capture. The setting is hidden when
/// it cannot.
bool get isScreenProtectionSupported =>
    defaultTargetPlatform == TargetPlatform.android;
