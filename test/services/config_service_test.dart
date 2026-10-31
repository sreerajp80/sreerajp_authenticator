import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';
import 'package:sreerajp_authenticator/services/config_service.dart';

void main() {
  group('LocalizedText Tests', () {
    test('plain text resolves the same for every language', () {
      const text = LocalizedText.plain('hello');
      expect(text.resolve('en'), 'hello');
      expect(text.resolve('sa'), 'hello');
    });

    test('locale map resolves exact locale, then en, then any', () {
      final text = LocalizedText.fromJson({'en': 'Hi', 'ml': 'നമസ്കാരം'});
      expect(text.resolve('ml'), 'നമസ്കാരം');
      expect(text.resolve('sa'), 'Hi');
      expect(LocalizedText.fromJson({'ml': 'x'}).resolve('en'), 'x');
    });

    test('invalid input falls back without throwing', () {
      expect(LocalizedText.fromJson(42, fallback: 'f').resolve('en'), 'f');
      expect(LocalizedText.fromJson({'en': 1}).isEmpty, isTrue);
    });
  });

  group('AppConfig Model Tests', () {
    test('AppConfig.fromJson parses plain and locale-map fields', () {
      final jsonMap = {
        'appName': {'en': 'Test App', 'ml': 'ടെസ്റ്റ് ആപ്പ്'},
        'description': 'Test Description',
        'version': '1.2.3',
        'build': '45',
        'details': {
          'author': {'en': 'Jane Doe', 'ml': 'ജെയിൻ ഡോ'},
          'email': 'jane@example.com',
          'license': 'MIT',
        },
      };

      final config = AppConfig.fromJson(jsonMap);

      expect(config.appName.resolve('en'), 'Test App');
      expect(config.appName.resolve('ml'), 'ടെസ്റ്റ് ആപ്പ്');
      expect(config.description.resolve('sa'), 'Test Description');
      expect(config.version, '1.2.3');
      expect(config.build, '45');
      expect(config.details['author']!.resolve('ml'), 'ജെയിൻ ഡോ');
      expect(config.details['email']!.resolve('en'), 'jane@example.com');
      expect(config.details['license']!.resolve('en'), 'MIT');
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

        expect(
          config.appName.resolve('en'),
          AppConfig.fallback.appName.resolve('en'),
        );
        expect(config.description.isEmpty, isTrue);
        expect(config.version, AppConfig.fallback.version);
        expect(config.build, AppConfig.fallback.build);
        expect(config.details, isEmpty);
      },
    );

    test('fallback app name exists in every declared language', () {
      final name = AppConfig.fallback.appName;
      expect(name.resolve('en'), 'Sreeraj P Authenticator');
      expect(name.resolve('ml'), 'ശ്രീരാജ് പി പ്രമാണീകാരി');
      expect(name.resolve('sa'), 'श्रीराज पी प्रमाणीकारकः');
    });
  });

  group('ConfigService Loader Tests', () {
    test('ConfigService.load parses valid asset text', () async {
      final jsonString = jsonEncode({
        'appName': 'Custom Authenticator',
        'description': 'Custom Description',
        'version': '2.0.0',
        'build': '10',
        'details': {'developer': 'Sreeraj'},
      });

      final service = ConfigService(loadAsset: (path) async => jsonString);

      final config = await service.load();

      expect(config.appName.resolve('en'), 'Custom Authenticator');
      expect(config.version, '2.0.0');
      expect(config.details['developer']!.resolve('en'), 'Sreeraj');
    });

    test('ConfigService.load returns fallback on asset load error', () async {
      final service = ConfigService(
        loadAsset: (path) async => throw Exception('Asset missing'),
      );

      final config = await service.load();

      expect(identical(config, AppConfig.fallback), isTrue);
    });

    test('ConfigService.load returns fallback on malformed JSON', () async {
      final service = ConfigService(
        loadAsset: (path) async => '{ invalid json ',
      );

      final config = await service.load();

      expect(identical(config, AppConfig.fallback), isTrue);
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

        expect(config.appName.resolve('en'), 'Verified App');
      },
    );

    test('bundled app_config.json matches pubspec.yaml version', () {
      final config = AppConfig.fromJson(
        jsonDecode(File('assets/config/app_config.json').readAsStringSync())
            as Map<String, dynamic>,
      );
      final version = RegExp(
        r'^version:\s*(\S+)',
        multiLine: true,
      ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!;
      expect('${config.version}+${config.build}', version);
    });
  });
}
