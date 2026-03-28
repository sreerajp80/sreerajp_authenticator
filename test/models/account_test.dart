import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';

void main() {
  group('Account model', () {
    late Account account;

    setUp(() {
      account = Account(
        id: 1,
        name: 'Test Account',
        secret: 'JBSWY3DPEHPK3PXP',
        issuer: 'TestIssuer',
        description: 'A test account',
        type: 'totp',
        counter: 0,
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
        groupId: 2,
        createdAt: DateTime.parse('2025-09-25T12:00:00.000'),
        sortOrder: 3,
      );
    });

    test('toMap produces correct map', () {
      final map = account.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Test Account');
      expect(map['secret'], 'JBSWY3DPEHPK3PXP');
      expect(map['issuer'], 'TestIssuer');
      expect(map['description'], 'A test account');
      expect(map['type'], 'totp');
      expect(map['counter'], 0);
      expect(map['digits'], 6);
      expect(map['period'], 30);
      expect(map['algorithm'], 'SHA1');
      expect(map['groupId'], 2);
      expect(map['createdAt'], '2025-09-25T12:00:00.000');
      expect(map['sortOrder'], 3);
    });

    test('fromMap round-trips correctly', () {
      final map = account.toMap();
      final restored = Account.fromMap(map);

      expect(restored.id, account.id);
      expect(restored.name, account.name);
      expect(restored.secret, account.secret);
      expect(restored.issuer, account.issuer);
      expect(restored.description, account.description);
      expect(restored.type, account.type);
      expect(restored.counter, account.counter);
      expect(restored.digits, account.digits);
      expect(restored.period, account.period);
      expect(restored.algorithm, account.algorithm);
      expect(restored.groupId, account.groupId);
      expect(restored.createdAt, account.createdAt);
      expect(restored.sortOrder, account.sortOrder);
    });

    test('fromMap with null optional fields', () {
      final map = {
        'id': null,
        'name': 'Minimal',
        'secret': 'ABC123',
        'issuer': null,
        'description': null,
        'type': 'hotp',
        'counter': null,
        'digits': 8,
        'period': 60,
        'algorithm': 'SHA256',
        'groupId': null,
        'createdAt': '2025-10-01T00:00:00.000',
        'sortOrder': 0,
      };
      final a = Account.fromMap(map);

      expect(a.id, isNull);
      expect(a.name, 'Minimal');
      expect(a.issuer, isNull);
      expect(a.description, isNull);
      expect(a.counter, isNull);
      expect(a.groupId, isNull);
      expect(a.digits, 8);
      expect(a.period, 60);
      expect(a.algorithm, 'SHA256');
    });

    test('copyWith overrides specified fields only', () {
      final copy = account.copyWith(name: 'New Name', digits: 8);

      expect(copy.name, 'New Name');
      expect(copy.digits, 8);
      // Everything else unchanged
      expect(copy.id, account.id);
      expect(copy.secret, account.secret);
      expect(copy.issuer, account.issuer);
      expect(copy.type, account.type);
      expect(copy.period, account.period);
      expect(copy.algorithm, account.algorithm);
      expect(copy.groupId, account.groupId);
      expect(copy.sortOrder, account.sortOrder);
    });

    test('copyWith with no arguments returns identical values', () {
      final copy = account.copyWith();

      expect(copy.name, account.name);
      expect(copy.secret, account.secret);
      expect(copy.issuer, account.issuer);
      expect(copy.type, account.type);
      expect(copy.digits, account.digits);
      expect(copy.period, account.period);
      expect(copy.algorithm, account.algorithm);
    });

    test('default values applied correctly', () {
      final minimal = Account(
        name: 'Default Test',
        secret: 'SECRET',
        type: 'totp',
      );

      expect(minimal.digits, 6);
      expect(minimal.period, 30);
      expect(minimal.algorithm, 'SHA1');
      expect(minimal.sortOrder, 0);
      expect(minimal.createdAt, isNotNull);
    });
  });
}
