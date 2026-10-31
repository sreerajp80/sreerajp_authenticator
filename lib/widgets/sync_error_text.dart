import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/sync_provider.dart';
import 'package:sreerajp_authenticator/services/optical_sync_service.dart';
import 'package:sreerajp_authenticator/services/p2p_sync_service.dart';

/// Localized text for a sync failure. Providers and services report codes
/// only; the most specific cause wins (Wi-Fi or optical code first).
String syncErrorText(AppLocalizations l10n, SyncError error) {
  final p2p = error.p2pCode;
  if (p2p != null) return p2pSyncErrorText(l10n, p2p);
  final optical = error.opticalCode;
  if (optical != null) return opticalSyncErrorText(l10n, optical);
  switch (error.code) {
    case SyncErrorCode.hostTimeout:
      return l10n.errorSyncHostTimeout;
    case SyncErrorCode.hostStartFailed:
      return l10n.errorSyncHostStartFailed;
    case SyncErrorCode.noDeviceConnected:
      return l10n.errorSyncNoDevice;
    case SyncErrorCode.nothingSelected:
      return l10n.errorSyncNothingSelected;
    case SyncErrorCode.syncFailed:
      return l10n.errorSyncFailed;
    case SyncErrorCode.opticalStartFailed:
      return l10n.errorOpticalStartFailed;
    case SyncErrorCode.opticalDecodeFailed:
      return l10n.errorOpticalDecodeFailed;
    case SyncErrorCode.opticalCodeInvalid:
      return l10n.errorOpticalCodeInvalid;
  }
}

/// Localized text for a Wi-Fi sync error code.
String p2pSyncErrorText(AppLocalizations l10n, P2pSyncErrorCode code) {
  switch (code) {
    case P2pSyncErrorCode.notSyncQr:
      return l10n.errorSyncNotSyncQr;
    case P2pSyncErrorCode.unsupportedVersion:
      return l10n.errorSyncUnsupportedVersion;
    case P2pSyncErrorCode.missingHost:
      return l10n.errorSyncMissingHost;
    case P2pSyncErrorCode.invalidPort:
      return l10n.errorSyncInvalidPort;
    case P2pSyncErrorCode.missingPairingCode:
      return l10n.errorSyncMissingCode;
    case P2pSyncErrorCode.malformedPayload:
      return l10n.errorSyncMalformed;
    case P2pSyncErrorCode.tooManyAccounts:
      return l10n.errorSyncTooManyAccounts;
    case P2pSyncErrorCode.fieldTooLarge:
      return l10n.errorSyncFieldTooLarge;
    case P2pSyncErrorCode.peerGone:
      return l10n.errorSyncPeerGone;
    case P2pSyncErrorCode.sendFailed:
      return l10n.errorSyncSendFailed;
    case P2pSyncErrorCode.noResponse:
      return l10n.errorSyncNoResponse;
    case P2pSyncErrorCode.invalidResponse:
      return l10n.errorSyncInvalidResponse;
    case P2pSyncErrorCode.connectionClosed:
      return l10n.errorSyncConnectionClosed;
    case P2pSyncErrorCode.wrongPairingCode:
      return l10n.errorSyncWrongCode;
    case P2pSyncErrorCode.timedOut:
      return l10n.errorSyncTimedOut;
    case P2pSyncErrorCode.connectFailed:
      return l10n.errorSyncConnectFailed;
    case P2pSyncErrorCode.connectionError:
      return l10n.errorSyncConnectionError;
  }
}

/// Localized text for an optical sync error code.
String opticalSyncErrorText(AppLocalizations l10n, OpticalSyncErrorCode code) {
  switch (code) {
    case OpticalSyncErrorCode.invalidFrame:
      return l10n.errorOpticalInvalidFrame;
    case OpticalSyncErrorCode.unsupportedVersion:
      return l10n.errorOpticalUnsupportedVersion;
    case OpticalSyncErrorCode.corruptedChunk:
      return l10n.errorOpticalCorruptedChunk;
    case OpticalSyncErrorCode.checksumMismatch:
      return l10n.errorOpticalChecksum;
    case OpticalSyncErrorCode.emptyPayload:
      return l10n.errorOpticalEmpty;
    case OpticalSyncErrorCode.incomplete:
      return l10n.errorOpticalIncomplete;
    case OpticalSyncErrorCode.integrityFailed:
      return l10n.errorOpticalIntegrity;
    case OpticalSyncErrorCode.wrongTransferCode:
      return l10n.errorOpticalWrongCode;
  }
}
