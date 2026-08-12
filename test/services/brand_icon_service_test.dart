// File Path: sreerajp_authenticator/test/services/brand_icon_service_test.dart
// Description: Unit tests for BrandIconService offline brand vector icon matching engine

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/services/brand_icon_service.dart';

void main() {
  group('BrandIconService Tests', () {
    test('normalizeKey normalizes issuer names correctly', () {
      expect(BrandIconService.normalizeKey('Google LLC'), 'googlellc');
      expect(BrandIconService.normalizeKey('GitHub.com'), 'github');
      expect(
        BrandIconService.normalizeKey('Amazon Web Services'),
        'amazonwebservices',
      );
      expect(BrandIconService.normalizeKey('Binance.US'), 'binance');
    });

    test(
      'getBrandIconPath returns correct brand SVG asset for exact and partial issuer matches',
      () {
        expect(
          BrandIconService.getBrandIconPath('Google', 'user@gmail.com'),
          'assets/icons/brands/google.svg',
        );
        expect(
          BrandIconService.getBrandIconPath('GitHub', 'sreerajp'),
          'assets/icons/brands/github.svg',
        );
        expect(
          BrandIconService.getBrandIconPath('AWS', 'root'),
          'assets/icons/brands/aws.svg',
        );
        expect(
          BrandIconService.getBrandIconPath('Binance', 'crypto'),
          'assets/icons/brands/binance.svg',
        );
        expect(
          BrandIconService.getBrandIconPath('Discord', 'user'),
          'assets/icons/brands/discord.svg',
        );
        expect(
          BrandIconService.getBrandIconPath('ProtonMail', 'user@proton.me'),
          'assets/icons/brands/proton.svg',
        );
        expect(
          BrandIconService.getBrandIconPath('Nintendo', 'player'),
          'assets/icons/brands/nintendo.svg',
        );
        expect(
          BrandIconService.getBrandIconPath('Steam', 'gamer'),
          'assets/icons/brands/steam.svg',
        );
      },
    );

    test('getBrandIconPath matches from account name when issuer is null', () {
      expect(
        BrandIconService.getBrandIconPath(null, 'My Google Account'),
        'assets/icons/brands/google.svg',
      );
      expect(
        BrandIconService.getBrandIconPath('', 'GitHub Access'),
        'assets/icons/brands/github.svg',
      );
    });

    test('getBrandIconPath returns null for unknown brands', () {
      expect(
        BrandIconService.getBrandIconPath('CustomInternalService', 'user'),
        isNull,
      );
    });
  });
}
