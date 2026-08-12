// File Path: sreerajp_authenticator/test/models/account_tags_test.dart
// Description: Unit tests for Account tags serialization and parsing

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';

void main() {
  group('Account Tags Tests', () {
    test('toMap and fromMap correctly serialize and deserialize tags list', () {
      final account = Account(
        name: 'Crypto Exchange',
        secret: 'JBSWY3DPEHPK3PXP',
        issuer: 'Binance',
        type: 'totp',
        tags: ['Work', 'Crypto', 'VIP'],
      );

      final map = account.toMap();
      expect(map['tags'], 'Work,Crypto,VIP');

      final reconstructed = Account.fromMap(map);
      expect(reconstructed.tags, ['Work', 'Crypto', 'VIP']);
    });

    test('fromMap handles comma-separated string tags and trimming', () {
      final map = {
        'id': 1,
        'name': 'Test Account',
        'secret': 'JBSWY3DPEHPK3PXP',
        'type': 'totp',
        'digits': 6,
        'period': 30,
        'algorithm': 'SHA1',
        'tags': ' Personal ,  Finance ,Work ',
        'createdAt': DateTime.now().toIso8601String(),
        'sortOrder': 0,
      };

      final account = Account.fromMap(map);
      expect(account.tags, ['Personal', 'Finance', 'Work']);
    });

    test('copyWith preserves and updates tags correctly', () {
      final account = Account(
        name: 'Original Account',
        secret: 'JBSWY3DPEHPK3PXP',
        type: 'totp',
        tags: ['Personal'],
      );

      final updated = account.copyWith(tags: ['Personal', 'VIP']);
      expect(updated.tags, ['Personal', 'VIP']);
      expect(account.tags, ['Personal']);
    });
  });
}
