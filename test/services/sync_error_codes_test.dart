import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Locale;
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/sync_provider.dart';
import 'package:sreerajp_authenticator/services/optical_sync_service.dart';
import 'package:sreerajp_authenticator/services/p2p_sync_service.dart';
import 'package:sreerajp_authenticator/widgets/sync_error_text.dart';

/// Sync failures carry codes (services hold no UI text), and every code has
/// its own localized text in every declared language.
void main() {
  Matcher p2pCode(P2pSyncErrorCode code) =>
      throwsA(isA<P2pSyncException>().having((e) => e.code, 'code', code));

  group('P2pSyncService.parseSyncQrPayload codes', () {
    test('foreign scheme → notSyncQr', () {
      expect(
        () => P2pSyncService.parseSyncQrPayload(
          'otpauth://totp/Acme?secret=JBSWY3DPEHPK3PXP',
        ),
        p2pCode(P2pSyncErrorCode.notSyncQr),
      );
    });

    test('wrong version → unsupportedVersion', () {
      expect(
        () => P2pSyncService.parseSyncQrPayload(
          'spauth://sync?v=9&ip=10.0.0.2&port=4040&code=ABCD',
        ),
        p2pCode(P2pSyncErrorCode.unsupportedVersion),
      );
    });

    test('missing host → missingHost', () {
      expect(
        () => P2pSyncService.parseSyncQrPayload(
          'spauth://sync?v=1&port=4040&code=ABCD',
        ),
        p2pCode(P2pSyncErrorCode.missingHost),
      );
    });

    test('bad port → invalidPort', () {
      expect(
        () => P2pSyncService.parseSyncQrPayload(
          'spauth://sync?v=1&ip=10.0.0.2&port=99999&code=ABCD',
        ),
        p2pCode(P2pSyncErrorCode.invalidPort),
      );
    });

    test('missing code → missingPairingCode', () {
      expect(
        () => P2pSyncService.parseSyncQrPayload(
          'spauth://sync?v=1&ip=10.0.0.2&port=4040',
        ),
        p2pCode(P2pSyncErrorCode.missingPairingCode),
      );
    });
  });

  test('a malformed optical frame → invalidFrame', () {
    expect(
      () => OpticalSyncFrame.fromJsonString('invalid json string'),
      throwsA(
        isA<OpticalSyncException>().having(
          (e) => e.code,
          'code',
          OpticalSyncErrorCode.invalidFrame,
        ),
      ),
    );
  });

  group('every error code has distinct localized text', () {
    for (final locale in LocaleConfig.supportedLocales) {
      test(locale.languageCode, () {
        final l10n = lookupAppLocalizations(locale);

        final p2p = {
          for (final code in P2pSyncErrorCode.values)
            p2pSyncErrorText(l10n, code),
        };
        expect(p2p, hasLength(P2pSyncErrorCode.values.length));

        final optical = {
          for (final code in OpticalSyncErrorCode.values)
            opticalSyncErrorText(l10n, code),
        };
        expect(optical, hasLength(OpticalSyncErrorCode.values.length));

        final sync = {
          for (final code in SyncErrorCode.values)
            syncErrorText(l10n, SyncError(code)),
        };
        expect(sync, hasLength(SyncErrorCode.values.length));

        for (final text in [...p2p, ...optical, ...sync]) {
          expect(text.trim(), isNotEmpty);
        }
      });
    }
  });

  test('the most specific cause wins', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      syncErrorText(
        l10n,
        const SyncError(
          SyncErrorCode.syncFailed,
          p2pCode: P2pSyncErrorCode.wrongPairingCode,
        ),
      ),
      l10n.errorSyncWrongCode,
    );
    expect(
      syncErrorText(
        l10n,
        const SyncError(
          SyncErrorCode.opticalDecodeFailed,
          opticalCode: OpticalSyncErrorCode.checksumMismatch,
        ),
      ),
      l10n.errorOpticalChecksum,
    );
  });
}
