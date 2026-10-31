// File Path: sreerajp_authenticator/lib/services/clipboard_service.dart
// Author: Sreeraj P
// Description: Copies secrets to the clipboard, marks them as sensitive on
// Android and clears them after a time limit.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/app_logger.dart';
import '../utils/constants.dart';

class ClipboardService {
  ClipboardService._();

  static const MethodChannel _channel = MethodChannel(
    'sreerajp_authenticator/clipboard',
  );

  /// The last copied secret, until its time limit ends.
  static String? _pending;

  /// Copy [text] and clear it after [clearAfter].
  ///
  /// Android 10+ does not let an app read the clipboard from the background,
  /// so the read comes back empty when the user has switched apps to paste.
  /// That case is cleared too. Only text that can be read and is different
  /// is left alone.
  static Future<void> copySecret(
    String text, {
    Duration clearAfter = AppConstants.clipboardClearDefault,
  }) async {
    _pending = text;
    Future.delayed(clearAfter, () => _clearIfUnchanged(text));
    await _write(text);
  }

  /// Clear a copied secret now instead of waiting for its time limit.
  static Future<void> clearPendingSecret() async {
    final pending = _pending;
    if (pending != null) await _clearIfUnchanged(pending);
  }

  static Future<void> _write(String text) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod<void>('setSensitiveText', text);
        return;
      } on MissingPluginException {
        // Fall through to the normal clipboard.
      } on PlatformException catch (e) {
        AppLogger.error('Failed to set sensitive clipboard text', e);
      }
    }
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> _clearIfUnchanged(String copied) async {
    if (_pending == copied) _pending = null;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final current = data?.text;
    if (current == null || current == copied) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  }
}
