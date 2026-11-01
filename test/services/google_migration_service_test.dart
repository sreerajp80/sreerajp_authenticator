import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/services/google_migration_service.dart';

import 'google_migration_test_data.dart';

void main() {
  GoogleMigrationBatch parse(List<int> payload) =>
      GoogleMigrationService.parse(migrationLink(payload));

  Matcher throwsCode(GoogleMigrationErrorCode code) => throwsA(
    isA<GoogleMigrationException>().having((e) => e.code, 'code', code),
  );

  group('isMigrationLink', () {
    test('matches only migration links', () {
      expect(
        GoogleMigrationService.isMigrationLink(
          ' OTPAUTH-MIGRATION://offline?data=x',
        ),
        isTrue,
      );
      expect(
        GoogleMigrationService.isMigrationLink('otpauth://totp/a?secret=b'),
        isFalse,
      );
    });
  });

  group('accounts', () {
    test('reads one TOTP account', () {
      final batch = parse(migrationPayload([migrationAccount()]));
      final account = batch.entries.single.account!;
      expect(account.name, 'user@example.com');
      expect(account.issuer, 'Example');
      expect(account.secret, 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ');
      expect(account.type, 'totp');
      expect(account.algorithm, 'SHA1');
      expect(account.digits, 6);
      expect(account.period, 30);
      expect(account.counter, isNull);
      expect(batch.batchSize, 1);
      expect(batch.batchIndex, 0);
    });

    test('reads many accounts in order', () {
      final batch = parse(
        migrationPayload([
          migrationAccount(name: 'one'),
          migrationAccount(name: 'two'),
          migrationAccount(name: 'three'),
        ]),
      );
      expect(batch.entries.map((e) => e.account!.name), [
        'one',
        'two',
        'three',
      ]);
    });

    test('maps each algorithm and digit size', () {
      const algorithms = {0: 'SHA1', 1: 'SHA1', 2: 'SHA256', 3: 'SHA512'};
      algorithms.forEach((value, expected) {
        final batch = parse(
          migrationPayload([migrationAccount(algorithm: value)]),
        );
        expect(batch.entries.single.account!.algorithm, expected);
      });

      const digits = {0: 6, 1: 6, 2: 8};
      digits.forEach((value, expected) {
        final batch = parse(
          migrationPayload([migrationAccount(digits: value)]),
        );
        expect(batch.entries.single.account!.digits, expected);
      });
    });

    test('keeps the HOTP counter, including large values', () {
      for (final counter in [0, 500, 5000000000]) {
        final batch = parse(
          migrationPayload([migrationAccount(type: 1, counter: counter)]),
        );
        final account = batch.entries.single.account!;
        expect(account.type, 'hotp');
        expect(account.counter, counter);
      }
    });

    test('a secret of any length survives without padding', () {
      for (final length in [10, 11, 14, 16, 20, 32]) {
        final secret = List<int>.generate(length, (i) => (i * 37 + 1) & 0xff);
        final batch = parse(
          migrationPayload([migrationAccount(secret: secret)]),
        );
        final encoded = batch.entries.single.account!.secret;
        expect(encoded.contains('='), isFalse);
        expect(base32.decode(encoded), secret);
      }
    });

    test('splits an issuer out of the name', () {
      GoogleMigrationEntry entry(String name, String issuer) => parse(
        migrationPayload([migrationAccount(name: name, issuer: issuer)]),
      ).entries.single;

      final split = entry('Site:me@example.com', '');
      expect(split.account!.issuer, 'Site');
      expect(split.account!.name, 'me@example.com');

      final prefixed = entry('Site:me', 'Site');
      expect(prefixed.account!.issuer, 'Site');
      expect(prefixed.account!.name, 'me');

      final different = entry('Other:me', 'Site');
      expect(different.account!.issuer, 'Site');
      expect(different.account!.name, 'Other:me');
    });

    test('skips unknown fields of every wire type', () {
      final account = [
        ...migrationAccount(),
        ...varintField(30, 7),
        ...fixed64Field(31),
        ...bytesField(32, [1, 2, 3]),
        ...fixed32Field(33),
      ];
      final payload = [
        ...bytesField(1, account),
        ...varintField(40, 1),
        ...fixed64Field(41),
        ...fixed32Field(42),
      ];
      expect(parse(payload).entries.single.account, isNotNull);
    });
  });

  group('batch fields', () {
    test('reads them', () {
      final batch = parse(
        migrationPayload(
          [migrationAccount()],
          batchSize: 3,
          batchIndex: 2,
          batchId: 77,
        ),
      );
      expect(batch.batchSize, 3);
      expect(batch.batchIndex, 2);
      expect(batch.batchId, 77);
    });

    test('an index outside the size is rejected', () {
      expect(
        () => parse(
          migrationPayload([migrationAccount()], batchSize: 2, batchIndex: 2),
        ),
        throwsCode(GoogleMigrationErrorCode.malformedData),
      );
    });
  });

  group('link handling', () {
    test('a raw plus sign in the data is restored', () {
      // These bytes give '+' in Base64. Query parsing would make it a space.
      final payload = migrationPayload([
        migrationAccount(secret: List<int>.filled(20, 0xfb)),
      ]);
      final encoded = base64.encode(payload);
      expect(encoded, contains('+'));
      final batch = GoogleMigrationService.parse(
        'otpauth-migration://offline?data=$encoded',
      );
      expect(base32.decode(batch.entries.single.account!.secret), [
        for (var i = 0; i < 20; i++) 0xfb,
      ]);
    });

    test('data without padding is accepted', () {
      final encoded = base64
          .encode(migrationPayload([migrationAccount(name: 'ab')]))
          .replaceAll('=', '');
      final batch = GoogleMigrationService.parse(
        'otpauth-migration://offline?data=${Uri.encodeQueryComponent(encoded)}',
      );
      expect(batch.entries, hasLength(1));
    });

    test('a link of another kind is refused', () {
      expect(
        () => GoogleMigrationService.parse('otpauth://totp/a?secret=b'),
        throwsCode(GoogleMigrationErrorCode.notMigrationLink),
      );
    });
  });

  group('bad QR codes are rejected, with a code only', () {
    final bad = <String, String>{
      'no data': 'otpauth-migration://offline',
      'empty data': 'otpauth-migration://offline?data=',
      'wrong host': migrationLink(migrationPayload([migrationAccount()]))
          .replaceFirst('offline', 'online'),
      'bad Base64': 'otpauth-migration://offline?data=%21%21%21%21',
      'bad percent code': 'otpauth-migration://offline?data=%zz',
      'oversize input':
          'otpauth-migration://offline?data=${'A' * GoogleMigrationService.maxLinkLength}',
      'no accounts': migrationLink(varintField(3, 1)),
      'length past the end': migrationLink([0x0a, 0x7f, 1, 2]),
      'huge length': migrationLink([
        0x0a,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0x01,
      ]),
      'varint too long': migrationLink([0x18, ...List.filled(11, 0x80), 1]),
      'cut-off varint': migrationLink([0x18, 0x80]),
      'field number zero': migrationLink([0x00, 0x01]),
      'group wire type': migrationLink([0x0b]),
      'wrong wire type for accounts': migrationLink(varintField(1, 5)),
      'oversize batch': migrationLink(
        migrationPayload([
          migrationAccount(),
        ], batchSize: GoogleMigrationService.maxBatchSize + 1),
      ),
    };

    bad.forEach((label, link) {
      test(label, () {
        expect(
          () => GoogleMigrationService.parse(link),
          throwsCode(GoogleMigrationErrorCode.malformedData),
        );
      });
    });

    test('the error text holds no scanned data', () {
      const secretText = 'c2VjcmV0';
      try {
        GoogleMigrationService.parse(
          'otpauth-migration://offline?data=$secretText!',
        );
        fail('should have thrown');
      } on GoogleMigrationException catch (e) {
        expect(e.toString(), isNot(contains(secretText)));
      }
    });
  });

  group('one bad account does not stop the others', () {
    void expectProblem(List<int> account, GoogleMigrationProblem problem) {
      final batch = parse(
        migrationPayload([account, migrationAccount(name: 'good')]),
      );
      expect(batch.entries.first.account, isNull);
      expect(batch.entries.first.problem, problem);
      expect(batch.entries.last.account!.name, 'good');
    }

    test('MD5 and unknown algorithms', () {
      for (final value in [4, 99]) {
        expectProblem(
          migrationAccount(algorithm: value),
          GoogleMigrationProblem.unsupportedAlgorithm,
        );
      }
    });

    test('unknown digit size', () {
      expectProblem(
        migrationAccount(digits: 3),
        GoogleMigrationProblem.unsupportedDigits,
      );
    });

    test('unset and unknown types', () {
      for (final value in [0, 3]) {
        expectProblem(
          migrationAccount(type: value),
          GoogleMigrationProblem.unsupportedType,
        );
      }
    });

    test('missing and short secrets', () {
      expectProblem(
        migrationAccount(secret: const []),
        GoogleMigrationProblem.missingSecret,
      );
      expectProblem(
        migrationAccount(secret: const [1, 2, 3]),
        GoogleMigrationProblem.shortSecret,
      );
    });

    test('oversize secret', () {
      expectProblem(
        migrationAccount(
          secret: List<int>.filled(
            GoogleMigrationService.maxSecretBytes + 1,
            1,
          ),
        ),
        GoogleMigrationProblem.damaged,
      );
    });

    test('invalid UTF-8 in a name', () {
      expectProblem(
        bytesField(2, const [0xff, 0xfe]),
        GoogleMigrationProblem.damaged,
      );
    });

    test('cut-off account', () {
      expectProblem(
        Uint8List.fromList([0x0a, 0x7f, 1]),
        GoogleMigrationProblem.damaged,
      );
    });

    test('no name and no issuer', () {
      expectProblem(
        migrationAccount(name: '', issuer: ''),
        GoogleMigrationProblem.damaged,
      );
    });

    test('negative HOTP counter', () {
      expectProblem(
        migrationAccount(type: 1, counter: -1),
        GoogleMigrationProblem.damaged,
      );
    });

    test('a problem entry keeps its name for the review screen', () {
      final entry = parse(migrationPayload([migrationAccount(digits: 3)]))
          .entries
          .single;
      expect(entry.displayName, 'user@example.com');
      expect(entry.displayIssuer, 'Example');
    });
  });

  group('GoogleMigrationCollector', () {
    GoogleMigrationBatch batch(
      int index, {
      int size = 3,
      int id = 7,
      String name = 'a',
    }) => parse(
      migrationPayload(
        [migrationAccount(name: name)],
        batchSize: size,
        batchIndex: index,
        batchId: id,
      ),
    );

    test('accepts any order and returns the export order', () {
      final collector = GoogleMigrationCollector();
      expect(
        collector.add(batch(2, name: 'c')),
        GoogleMigrationAddResult.added,
      );
      collector.add(batch(0, name: 'a'));
      expect(collector.isComplete, isFalse);
      expect(collector.scanned, 2);
      expect(collector.total, 3);

      collector.add(batch(1, name: 'b'));
      expect(collector.isComplete, isTrue);
      expect(collector.entries.map((e) => e.account!.name), ['a', 'b', 'c']);
    });

    test('ignores a repeated QR code', () {
      final collector = GoogleMigrationCollector()..add(batch(0));
      expect(collector.add(batch(0)), GoogleMigrationAddResult.repeated);
      expect(collector.scanned, 1);
    });

    test('refuses a QR code from another export', () {
      final collector = GoogleMigrationCollector()..add(batch(0));
      expect(
        collector.add(batch(1, id: 8)),
        GoogleMigrationAddResult.otherExport,
      );
      expect(
        collector.add(batch(1, size: 4)),
        GoogleMigrationAddResult.otherExport,
      );
      expect(collector.scanned, 1);
    });

    test('clear drops the data', () {
      final collector = GoogleMigrationCollector()..add(batch(0));
      collector.clear();
      expect(collector.isEmpty, isTrue);
      expect(collector.entries, isEmpty);
      expect(collector.isComplete, isFalse);
    });
  });
}
