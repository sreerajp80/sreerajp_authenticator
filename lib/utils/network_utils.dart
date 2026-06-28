// File Path: sreerajp_authenticator/lib/utils/network_utils.dart
// Author: Sreeraj P
// Description: Helpers for local network discovery used by P2P LAN sync.

import 'dart:io';

class NetworkUtils {
  NetworkUtils._();

  /// Returns the first non-loopback IPv4 address of this device, or
  /// `127.0.0.1` if none can be determined. Used to display the host address
  /// the peer must connect to.
  static Future<String> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final intf in interfaces) {
        for (final addr in intf.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {
      // Ignore and fall back to loopback.
    }
    return '127.0.0.1';
  }
}
