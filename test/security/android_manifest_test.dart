import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  test('permissions the app does not use stay out of our manifest', () {
    expect(manifest, isNot(contains('ACCESS_WIFI_STATE')));
    expect(manifest, isNot(contains('USE_FINGERPRINT')));
  });

  test('unused library permissions stay stripped', () {
    for (final name in [
      'RECORD_AUDIO',
      'WRITE_EXTERNAL_STORAGE',
      'READ_EXTERNAL_STORAGE',
      'ACCESS_NETWORK_STATE',
    ]) {
      expect(
        manifest,
        contains(
          '<uses-permission android:name="android.permission.$name" '
          'tools:node="remove" />',
        ),
        reason: name,
      );
    }
  });

  test('backup and cleartext settings stay on', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  test('backup rules exclude all data from backup and transfer', () {
    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml')
        .readAsStringSync();

    for (final section in ['cloud-backup', 'device-transfer']) {
      final body = RegExp(
        '<$section>(.*?)</$section>',
        dotAll: true,
      ).firstMatch(rules)?.group(1);
      expect(body, isNotNull, reason: section);
      for (final domain in [
        'root',
        'file',
        'database',
        'sharedpref',
        'external',
      ]) {
        expect(
          body,
          contains('<exclude domain="$domain" path="." />'),
          reason: '$section $domain',
        );
      }
    }
  });
}
