import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/services/otp_service.dart';

void main() {
  // RFC 4226 Appendix D test secret: ASCII "12345678901234567890"
  // Base32 encoded: GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ
  const rfcSecret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';

  // RFC 4226 Appendix D expected HOTP values (SHA1, 6 digits)
  const rfcHotpValues = {
    0: '755224',
    1: '287082',
    2: '359152',
    3: '969429',
    4: '338314',
    5: '254676',
    6: '287922',
    7: '162583',
    8: '399871',
    9: '520489',
  };

  setUp(() {
    OTPService.clearCache();
  });

  group('HOTP — RFC 4226 test vectors', () {
    for (final entry in rfcHotpValues.entries) {
      test('counter ${entry.key} → ${entry.value}', () {
        final account = Account(
          name: 'RFC Test',
          secret: rfcSecret,
          type: 'hotp',
          counter: entry.key,
          digits: 6,
          algorithm: 'SHA1',
        );

        final result = OTPService.generateHOTP(account);
        expectSuccess(result, expectedCode: entry.value);
      });
    }
  });

  group('HOTP — edge cases', () {
    test('8-digit HOTP', () {
      final account = Account(
        name: 'Eight Digits',
        secret: rfcSecret,
        type: 'hotp',
        counter: 0,
        digits: 8,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateHOTP(account);
      expectSuccess(result);
      expect(result.code!.length, 8);
      expect(int.tryParse(result.code!), isNotNull);
    });

    test('null counter defaults to 0', () {
      final account = Account(
        name: 'No Counter',
        secret: rfcSecret,
        type: 'hotp',
        counter: null,
        digits: 6,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateHOTP(account);
      expectSuccess(result, expectedCode: rfcHotpValues[0]);
    });

    test('invalid base32 secret returns typed failure', () {
      final account = Account(
        name: 'Bad Secret',
        secret: '!!!invalid!!!',
        type: 'hotp',
        counter: 0,
        digits: 6,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateHOTP(account);
      expectFailure<OTPInvalidSecretException>(result);
    });

    test('secret with spaces and dashes is cleaned', () {
      final account = Account(
        name: 'Spaced Secret',
        secret: 'GEZD GNBV GY3T QOJQ GEZD GNBV GY3T QOJQ',
        type: 'hotp',
        counter: 0,
        digits: 6,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateHOTP(account);
      expectSuccess(result, expectedCode: rfcHotpValues[0]);
    });

    test('lowercase secret is handled', () {
      final account = Account(
        name: 'Lowercase',
        secret: rfcSecret.toLowerCase(),
        type: 'hotp',
        counter: 1,
        digits: 6,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateHOTP(account);
      expectSuccess(result, expectedCode: rfcHotpValues[1]);
    });
  });

  group('HOTP — SHA256 and SHA512', () {
    test('SHA256 produces 6-digit code', () {
      final account = Account(
        name: 'SHA256',
        secret: rfcSecret,
        type: 'hotp',
        counter: 1,
        digits: 6,
        algorithm: 'SHA256',
      );

      final result = OTPService.generateHOTP(account);
      expectSuccess(result);
      expect(result.code!.length, 6);
      expect(int.tryParse(result.code!), isNotNull);
      expect(result.code, isNot(equals(rfcHotpValues[1])));
    });

    test('SHA512 produces 6-digit code', () {
      final account = Account(
        name: 'SHA512',
        secret: rfcSecret,
        type: 'hotp',
        counter: 1,
        digits: 6,
        algorithm: 'SHA512',
      );

      final result = OTPService.generateHOTP(account);
      expectSuccess(result);
      expect(result.code!.length, 6);
      expect(int.tryParse(result.code!), isNotNull);
      expect(result.code, isNot(equals(rfcHotpValues[1])));
    });
  });

  group('TOTP — basic checks', () {
    test('generates a 6-digit numeric code', () {
      final account = Account(
        name: 'TOTP Test',
        secret: rfcSecret,
        type: 'totp',
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateTOTP(account);
      expectSuccess(result);
      expect(result.code!.length, 6);
      expect(int.tryParse(result.code!), isNotNull);
    });

    test('same account returns same code within same time step', () {
      final account = Account(
        name: 'Consistency',
        secret: rfcSecret,
        type: 'totp',
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
      );

      final result1 = OTPService.generateTOTP(account);
      final result2 = OTPService.generateTOTP(account);
      expectSuccess(result1);
      expectSuccess(result2);
      expect(result1.code, result2.code);
    });

    test('invalid secret returns typed failure', () {
      final account = Account(
        name: 'Bad TOTP',
        secret: '!!!invalid!!!',
        type: 'totp',
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateTOTP(account);
      expectFailure<OTPInvalidSecretException>(result);
    });

    test('short secret returns typed failure', () {
      final account = Account(
        name: 'Short',
        secret: 'AB',
        type: 'totp',
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
      );

      final result = OTPService.generateTOTP(account);
      expectFailure<OTPInvalidSecretException>(result);
    });

    test('async generation returns a 6-digit numeric code', () async {
      final account = Account(
        name: 'Async TOTP',
        secret: rfcSecret,
        type: 'totp',
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
      );

      final result = await OTPService.generateTOTPAsync(account);
      expectSuccess(result);
      expect(result.code!.length, 6);
      expect(int.tryParse(result.code!), isNotNull);
    });

    test('async invalid secret returns typed failure', () async {
      final account = Account(
        name: 'Async Bad TOTP',
        secret: '!!!invalid!!!',
        type: 'totp',
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
      );

      final result = await OTPService.generateTOTPAsync(account);
      expectFailure<OTPInvalidSecretException>(result);
    });
  });

  group('getRemainingSeconds', () {
    test('returns value in range [1, period]', () {
      final remaining = OTPService.getRemainingSeconds(30);
      expect(remaining, greaterThanOrEqualTo(1));
      expect(remaining, lessThanOrEqualTo(30));
    });

    test('works with non-standard periods', () {
      final remaining = OTPService.getRemainingSeconds(60);
      expect(remaining, greaterThanOrEqualTo(1));
      expect(remaining, lessThanOrEqualTo(60));
    });
  });

  group('parseOtpAuthUri', () {
    test('parses standard TOTP URI', () {
      const uri =
          'otpauth://totp/TestIssuer:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=TestIssuer&algorithm=SHA1&digits=6&period=30';
      final account = OTPService.parseOtpAuthUri(uri);

      expect(account, isNotNull);
      expect(account!.name, 'user@example.com');
      expect(account.issuer, 'TestIssuer');
      expect(account.secret, 'JBSWY3DPEHPK3PXP');
      expect(account.type, 'totp');
      expect(account.digits, 6);
      expect(account.period, 30);
      expect(account.algorithm, 'SHA1');
    });

    test('parses HOTP URI with counter', () {
      const uri =
          'otpauth://hotp/Example:alice?secret=JBSWY3DPEHPK3PXP&counter=5';
      final account = OTPService.parseOtpAuthUri(uri);

      expect(account, isNotNull);
      expect(account!.type, 'hotp');
      expect(account.counter, 5);
      expect(account.name, 'alice');
      expect(account.issuer, 'Example');
    });

    test('uses defaults for missing optional params', () {
      const uri = 'otpauth://totp/MyService:me?secret=JBSWY3DPEHPK3PXP';
      final account = OTPService.parseOtpAuthUri(uri);

      expect(account, isNotNull);
      expect(account!.digits, 6);
      expect(account.period, 30);
      expect(account.algorithm, 'SHA1');
    });

    test('parses URI without issuer prefix', () {
      const uri = 'otpauth://totp/user@example.com?secret=JBSWY3DPEHPK3PXP';
      final account = OTPService.parseOtpAuthUri(uri);

      expect(account, isNotNull);
      expect(account!.name, 'user@example.com');
    });

    test('parses SHA256 algorithm', () {
      const uri =
          'otpauth://totp/Test:user?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=8';
      final account = OTPService.parseOtpAuthUri(uri);

      expect(account, isNotNull);
      expect(account!.algorithm, 'SHA256');
      expect(account.digits, 8);
    });

    test('returns null for invalid scheme', () {
      const uri = 'https://example.com/not-an-otp-uri';
      expect(OTPService.parseOtpAuthUri(uri), isNull);
    });

    test('returns null for unsupported OTP type', () {
      const uri = 'otpauth://steam/Test:user?secret=JBSWY3DPEHPK3PXP';
      expect(OTPService.parseOtpAuthUri(uri), isNull);
    });
  });

  group('generateOtpAuthUri', () {
    test('generates valid TOTP URI', () {
      final account = Account(
        name: 'user@example.com',
        secret: 'encrypted-doesnt-matter',
        issuer: 'TestIssuer',
        type: 'totp',
        digits: 6,
        period: 30,
        algorithm: 'SHA1',
      );

      final uri = OTPService.generateOtpAuthUri(account, 'JBSWY3DPEHPK3PXP');
      expect(uri, contains('otpauth://totp/'));
      expect(uri, contains('TestIssuer'));
      expect(uri, contains('user%40example.com'));
      expect(uri, contains('secret=JBSWY3DPEHPK3PXP'));
      expect(uri, contains('digits=6'));
      expect(uri, contains('period=30'));
      expect(uri, contains('algorithm=SHA1'));
    });

    test('cleans secret (removes spaces/dashes, uppercases)', () {
      final account = Account(
        name: 'test',
        secret: 'x',
        issuer: 'Issuer',
        type: 'totp',
      );

      final uri = OTPService.generateOtpAuthUri(account, 'jbsw y3dp ehpk 3pxp');
      expect(uri, contains('secret=JBSWY3DPEHPK3PXP'));
    });

    test('round-trips with parseOtpAuthUri', () {
      final original = Account(
        name: 'roundtrip',
        secret: 'x',
        issuer: 'MyApp',
        type: 'totp',
        digits: 8,
        period: 60,
        algorithm: 'SHA256',
      );

      final uri = OTPService.generateOtpAuthUri(original, 'JBSWY3DPEHPK3PXP');
      final parsed = OTPService.parseOtpAuthUri(uri);

      expect(parsed, isNotNull);
      expect(parsed!.name, 'roundtrip');
      expect(parsed.issuer, 'MyApp');
      expect(parsed.secret, 'JBSWY3DPEHPK3PXP');
      expect(parsed.digits, 8);
      expect(parsed.period, 60);
      expect(parsed.algorithm, 'SHA256');
    });
  });

  group('cache management', () {
    test('clearCache does not break subsequent generation', () {
      final account = Account(
        name: 'Cache Test',
        secret: rfcSecret,
        type: 'hotp',
        counter: 0,
        digits: 6,
        algorithm: 'SHA1',
      );

      final firstResult = OTPService.generateHOTP(account);
      expectSuccess(firstResult, expectedCode: rfcHotpValues[0]);
      OTPService.clearCache();
      final secondResult = OTPService.generateHOTP(account);
      expectSuccess(secondResult, expectedCode: rfcHotpValues[0]);
    });
  });
}

void expectSuccess(OTPGenerationResult result, {String? expectedCode}) {
  expect(result.isSuccess, isTrue);
  expect(result.isFailure, isFalse);
  expect(result.error, isNull);
  if (expectedCode != null) {
    expect(result.code, expectedCode);
  } else {
    expect(result.code, isNotNull);
  }
}

void expectFailure<T extends OTPException>(OTPGenerationResult result) {
  expect(result.isSuccess, isFalse);
  expect(result.isFailure, isTrue);
  expect(result.code, isNull);
  expect(result.error, isA<T>());
}
