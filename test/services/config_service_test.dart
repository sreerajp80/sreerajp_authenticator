import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';
import 'package:sreerajp_authenticator/services/config_service.dart';

void main() {
  group('AppConfig Model Tests', () {
    test('AppConfig.fromJson parses valid JSON fields correctly', () {
      final jsonMap = {
        'appName': 'Test App',
        'description': 'Test Description',
        'version': '1.2.3',
        'build': '45',
        'details': {
          'Author': 'Jane Doe',
          'Email': 'jane@example.com',
          'License': 'MIT',
        },
      };

      final config = AppConfig.fromJson(jsonMap);

      expect(config.appName, equals('Test App'));
      expect(config.description, equals('Test Description'));
      expect(config.version, equals('1.2.3'));
      expect(config.build, equals('45'));
      expect(config.details['Author'], equals('Jane Doe'));
      expect(config.details['Email'], equals('jane@example.com'));
      expect(config.details['License'], equals('MIT'));
    });

    test(
      'AppConfig.fromJson falls back safely on missing or invalid types',
      () {
        final jsonMap = {
          'appName': 123, // Invalid type
          'description': null,
          // version missing
          'build': false, // Invalid type
          'details': 'not a map',
        };

        final config = AppConfig.fromJson(jsonMap);

        expect(config.appName, equals(AppConfig.fallback.appName));
        expect(config.description, equals(AppConfig.fallback.description));
        expect(config.version, equals(AppConfig.fallback.version));
        expect(config.build, equals(AppConfig.fallback.build));
        expect(config.details, isEmpty);
      },
    );
  });

  group('ConfigService Loader Tests', () {
    test('ConfigService.load parses valid asset text', () async {
      final jsonString = jsonEncode({
        'appName': 'Custom Authenticator',
        'description': 'Custom Description',
        'version': '2.0.0',
        'build': '10',
        'details': {'Developer': 'Sreeraj'},
      });

      final service = ConfigService(loadAsset: (path) async => jsonString);

      final config = await service.load();

      expect(config.appName, equals('Custom Authenticator'));
      expect(config.version, equals('2.0.0'));
      expect(config.details['Developer'], equals('Sreeraj'));
    });

    test('ConfigService.load returns fallback on asset load error', () async {
      final service = ConfigService(
        loadAsset: (path) async => throw Exception('Asset missing'),
      );

      final config = await service.load();

      expect(config.appName, equals(AppConfig.fallback.appName));
      expect(config.version, equals(AppConfig.fallback.version));
    });

    test('ConfigService.load returns fallback on malformed JSON', () async {
      final service = ConfigService(
        loadAsset: (path) async => '{ invalid json ',
      );

      final config = await service.load();

      expect(config.appName, equals(AppConfig.fallback.appName));
    });

    test(
      'ConfigService.loadAndVerify handles package info gracefully',
      () async {
        final jsonString = jsonEncode({
          'appName': 'Verified App',
          'description': 'Description',
          'version': '1.0.0',
          'build': '1',
          'details': {},
        });

        final service = ConfigService(loadAsset: (path) async => jsonString);

        final packageInfo = PackageInfo(
          appName: 'Verified App',
          packageName: 'in.sreerajp.test',
          version: '1.0.0',
          buildNumber: '1',
        );

        final config = await service.loadAndVerify(packageInfo: packageInfo);

        expect(config.appName, equals('Verified App'));
      },
    );
  });
}
