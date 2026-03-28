import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/config/app_flavor_config.dart';

void main() {
  group('AppFlavorConfig', () {
    test('parses dev flavor and exposes dev settings', () {
      final config = AppFlavorConfig.fromFlavorValue(' dev ');

      expect(config.flavor, AppFlavor.dev);
      expect(config.isDev, isTrue);
      expect(config.isProd, isFalse);
      expect(config.appName, 'Sreeraj P Authenticator Dev');
      expect(config.environmentName, 'Development');
      expect(config.bannerLabel, 'DEV');
      expect(config.showEnvironmentBanner, isTrue);
      expect(config.enableVerboseLogging, isTrue);
    });

    test('defaults unknown flavor values to prod settings', () {
      final config = AppFlavorConfig.fromFlavorValue('staging');

      expect(config.flavor, AppFlavor.prod);
      expect(config.isDev, isFalse);
      expect(config.isProd, isTrue);
      expect(config.appName, 'Sreeraj P Authenticator');
      expect(config.environmentName, 'Production');
      expect(config.bannerLabel, 'PROD');
      expect(config.showEnvironmentBanner, isFalse);
      expect(config.enableVerboseLogging, isFalse);
    });
  });
}
