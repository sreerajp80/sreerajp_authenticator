# Stale code cleanup

Implements plan: `plans/20261031_065655_stale-code-cleanup.md`

## What changed

### Phase 1: unused code

- **Deleted:** `lib/widgets/home/home_tag_filter_bar.dart`, `lib/utils/app_version.g.dart`,
  `tool/generate_app_version.dart`, and the empty `sreerajp_authenticator/` folder.
- **Packages removed:** `animations`, `shimmer`, `cupertino_icons`.
- **`pubspec.yaml`:** removed the `assets/images/` line and a stray comment.
- **ARB:** removed `labelClearCount`.
- **Unused members removed from:** `settings_provider.dart`, `account_provider.dart`,
  `sync_provider.dart`, `auth_service.dart`, `encryption_service.dart`, `otp_service.dart`,
  `p2p_sync_service.dart`, `theme.dart`, `constants.dart`. This includes `exportData` (built a list
  of decrypted secrets), `clearAllSecureData` (wiped secure storage) and the debug helpers in
  `otp_service.dart`.
- **Test-only members removed:** `setSearchQuery`, `clearSearch`, `filteredAccounts`, `searchQuery`,
  `requireAuthentication`, `getBiometricTypeString`, and the tests that existed only for them.
- **`docs/architecture.md` §21:** corrected the list of packages that need
  `MaterialUiCompatibilityBridge`. It is now `flutter_slidable` and `percent_indicator`.

### Phase 2: dead PIN migration flag

- Removed `_needsMandatoryPinMigration`, which was never `true`, and every branch that depended on
  it in `settings_provider.dart`, `lock_screen.dart` and `security_screen.dart`.
- Removed `_showMandatoryPinSetup`, `_isPinSetupFlowActive` and
  `UnlockInstruction.setUpPinWithPhoneLock`.
- **ARB keys removed:** `descUnlockSetUpPin`, `titleSetUpPin`, `descSetUpPin`, `titleSetUpYourPin`,
  `descFinishPinSetup`.

### Phase 3: old data formats

- **Account secrets:** `decrypt` now accepts only AES-256-GCM and throws for anything else. XOR and
  CBC support and `migrateToAES` are gone.
- **`MigrationService`:** deleted with its test and its flags in `constants.dart`.
- **Backups:** only `v3` can be read. Any other format returns `null`, which shows the existing
  friendly error.
- **Database:** removed `_onUpgrade`, `_migrateGroupsToTags` and the `groupId` column for new
  installs. `databaseVersion` stays at 4.
- **`groups` key:** no longer written to backups or sync payloads, and the related parameters are
  removed. Incoming files that still have the key are accepted, and the key is ignored.
- **Legacy settings:** removed `lock_type` and `biometric_enabled`. Quick unlock defaults to off
  when its current setting is not saved.
- **Tests:** added tests that old secret and backup formats are rejected. Phone-lock-only tests now
  use the current setting.
- **Docs updated:** `docs/security.md`, `docs/features.md`, `docs/architecture.md`,
  `docs/project_structure.md`, `docs/dependencies.md`.

## Left in on purpose

- Old PIN storage code in `auth_service.dart` and the `app_lock_pin` cleanup in
  `settings_provider.dart`.
- `MaterialUiCompatibilityBridge`, `checkAndLockApp`, `getReconstructedPayload`, `.metadata`, and
  the `resetForTesting` and `...ForTest` test helpers.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: all 558 tests pass. There were 576 before Phase 3; the drop comes from removing
  the old format and migration tests.
- `dart format .`: no changes needed.
- **Not done:** the manual lock screen check on a real device (App PIN, phone lock, and fall back
  from phone lock to PIN). No Android build was run.

## Translations

No new text was added, so no translation needs review.
