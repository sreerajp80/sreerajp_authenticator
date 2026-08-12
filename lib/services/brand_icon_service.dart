// File Path: sreerajp_authenticator/lib/services/brand_icon_service.dart
// Author: Sreeraj P
// Description: Offline brand icon matching engine mapping issuer names and account names to vector SVG assets.

class BrandIconService {
  BrandIconService._();

  // Mapping of normalized brand keys to asset path
  static const Map<String, String> _brandIconMap = {
    'google': 'assets/icons/brands/google.svg',
    'gmail': 'assets/icons/brands/google.svg',
    'gsuite': 'assets/icons/brands/google.svg',

    'github': 'assets/icons/brands/github.svg',

    'aws': 'assets/icons/brands/aws.svg',
    'amazon': 'assets/icons/brands/aws.svg',

    'binance': 'assets/icons/brands/binance.svg',

    'discord': 'assets/icons/brands/discord.svg',

    'proton': 'assets/icons/brands/proton.svg',
    'protonmail': 'assets/icons/brands/proton.svg',
    'protonvpn': 'assets/icons/brands/proton.svg',

    'nintendo': 'assets/icons/brands/nintendo.svg',

    'steam': 'assets/icons/brands/steam.svg',
    'valve': 'assets/icons/brands/steam.svg',

    'microsoft': 'assets/icons/brands/microsoft.svg',
    'outlook': 'assets/icons/brands/microsoft.svg',
    'azure': 'assets/icons/brands/microsoft.svg',

    'apple': 'assets/icons/brands/apple.svg',
    'icloud': 'assets/icons/brands/apple.svg',
  };

  /// Normalizes an input string by removing spaces, punctuation, and domain extensions.
  static String normalizeKey(String input) {
    var cleaned = input.trim().toLowerCase();

    // Strip out common domain extensions
    cleaned = cleaned.replaceAll(
      RegExp(r'\.(com|org|net|io|app|co|us|dev|me|tech|info|ai|gg)\b'),
      '',
    );

    // Replace non-alphanumeric characters with empty string
    cleaned = cleaned.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned;
  }

  /// Finds the vector SVG brand icon asset path for a given issuer and account name.
  /// Returns null if no brand vector icon match is found offline.
  static String? getBrandIconPath(String? issuer, String accountName) {
    if (issuer != null && issuer.trim().isNotEmpty) {
      final normalizedIssuer = normalizeKey(issuer);
      for (final entry in _brandIconMap.entries) {
        if (normalizedIssuer == entry.key ||
            normalizedIssuer.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    if (accountName.trim().isNotEmpty) {
      final normalizedName = normalizeKey(accountName);
      for (final entry in _brandIconMap.entries) {
        if (normalizedName == entry.key || normalizedName.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    return null;
  }
}
