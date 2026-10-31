# Stale code cleanup

**Status:** completed

**Security impact:** Touches dependencies and security-related code. It removes three unused
packages and unused code that handles secrets or secure storage. Phase 2 also removes a flag
from the lock screen logic. The flag is never `true`, so lock behaviour must stay the same. Phase 3
removes old encryption and backup formats, including weak ones (XOR, AES-CBC, unsalted SHA-256
backup keys). Data in those formats can no longer be read. The current formats do not change, and
no permission or network behaviour changes. The sync payload loses its empty `groups` list.

## The issue

`flutter analyze` is clean, but it does not report unused public code. A scan, checked by hand,
found code that nothing in the app uses. This code makes the app harder to read and adds packages
to the build. Some of it handles secrets: `exportData` builds a list of decrypted secrets, and
`clearAllSecureData` wipes all secure storage.

## Files to change

**Phase 1: remove**
- `lib/widgets/home/home_tag_filter_bar.dart` (delete)
- `lib/utils/app_version.g.dart` (delete)
- `tool/generate_app_version.dart` (delete)
- `sreerajp_authenticator/` (delete; empty, not tracked by Git)
- `pubspec.yaml`, `pubspec.lock` (the lock file changes only through `flutter pub get`)
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb`, generated `lib/l10n/app_localizations*.dart`
- `lib/providers/settings_provider.dart`
- `lib/providers/account_provider.dart`
- `lib/providers/sync_provider.dart`
- `lib/services/auth_service.dart`
- `lib/services/encryption_service.dart`
- `lib/services/otp_service.dart`
- `lib/services/p2p_sync_service.dart`
- `lib/utils/theme.dart`
- `lib/utils/constants.dart`
- `docs/dependencies.md`, `docs/architecture.md`
- `test/providers/account_provider_test.dart`
- `test/providers/settings_provider_test.dart`
- `test/services/auth_service_test.dart`
- `test/services/encryption_service_test.dart`

**Phase 2: remove the dead PIN migration flag**
- `lib/providers/settings_provider.dart`
- `lib/screens/lock_screen.dart`
- `lib/screens/security_screen.dart`
- the three ARB files and generated l10n files, for keys that become unused
- `test/providers/settings_provider_test.dart`
- `test/widgets/security_auth_widgets_test.dart`

**Phase 3: remove old data formats**
- `lib/services/migration_service.dart` (delete)
- `test/services/migration_service_test.dart` (delete)
- `lib/providers/account_provider.dart`
- `lib/providers/settings_provider.dart`
- `lib/providers/sync_provider.dart`
- `lib/screens/send_to_device_screen.dart`
- `lib/services/encryption_service.dart`
- `lib/services/export_import_service.dart`
- `lib/services/database_service.dart`
- `lib/services/p2p_sync_service.dart` (comment only)
- `lib/utils/constants.dart`
- `test/services/encryption_service_test.dart`
- `test/services/export_import_service_test.dart`
- `test/services/p2p_sync_service_test.dart`
- `test/providers/settings_provider_test.dart`
- `test/widgets/security_auth_widgets_test.dart`
- `docs/security.md`, `docs/features.md`, `docs/architecture.md`, `docs/project_structure.md`

## The fix

### Phase 1

1. **Files:** delete the four items listed above. `HomeTagFilterBar` and `kAppVersion` have no users.
2. **Packages:** remove `animations`, `shimmer` and `cupertino_icons` from `pubspec.yaml`. Fix the
   `docs/dependencies.md` table and the package list in `docs/architecture.md`.
3. **`pubspec.yaml` small fixes:** remove the stray `[[5]]` comment text and the `assets/images/`
   line (the folder is empty and Git does not track it).
4. **ARB:** remove `labelClearCount` and its `@` entry from all three files, then run
   `flutter gen-l10n`. Keep `labelAllTags`, because the help screen uses it.
5. **Unused members:**
   - `settings_provider.dart`: `adaptiveAuthAvailable`, `hasQuickUnlockAvailable`,
     `isBackupInProgress`, `isSyncInProgress`, `isBiometricEnabled`, `setBiometricEnabled`,
     `lockType`, `setLockType`, `exportFormat`, `setExportFormat`, `needsMandatoryPinMigration()`,
     plus `_exportFormat` and `_keyExportFormat`, which are then unused. The private
     `_isBackupInProgress` and `_isSyncInProgress` fields stay, because the lock logic reads them.
   - `account_provider.dart`: `exportData`.
   - `auth_service.dart`: `authenticateWithDeviceLock`, `isScreenLockEnabled`.
   - `encryption_service.dart`: `storeSecureData`, `getSecureData`, `deleteSecureData`.
   - `otp_service.dart`: `getDebugInfo`, `compareSecrets`, `generateTimeWindowCodes`, plus
     `_debugToolsEnabled`, which is then unused.
   - `p2p_sync_service.dart`: `hasConnectedClient`.
   - `sync_provider.dart`: `isFull`.
   - `theme.dart`: `build3DListTile`, `get3DButtonDecoration`, `get3DSegmentDecoration`,
     `warmCoral`, `buttonHighlight`, `buttonShadowLight`. Keep `get3DDecoration`, which is in use.
   - `constants.dart`: `accountsTable`, `defaultDigits`, `defaultPeriod`, `defaultAlgorithm`,
     `defaultSortOrder`, `encryptedBackupExtension`, `jsonBackupExtension`,
     `syncCategoryAccounts`, `syncCategorySettings`.
6. **Members used only by tests:** remove these and the tests that exist only for them:
   - `account_provider.dart`: `setSearchQuery`, `clearSearch`, `filteredAccounts`, `searchQuery`,
     `_searchQuery`. The home screen has its own search.
   - `settings_provider.dart`: `requireAuthentication`, its field and `_keyRequireAuth`.
   - `auth_service.dart`: `getBiometricTypeString`.
   - `encryption_service.dart`: `clearAllSecureData`.
7. **`docs/architecture.md` §21:** correct the bridge risk note. `animations` and `shimmer` leave
   the list. `flutter_zxing`, `qr_flutter`, `camera` and others import the old library, but the
   app renders no widget from them that reads the old theme.
8. Any private helper that the compiler reports as unused after these steps is removed too.

### Phase 2

1. Remove `_needsMandatoryPinMigration` and `needsMandatoryPinMigrationSync` from
   `settings_provider.dart`, and simplify each condition as if the value were `false`.
2. In `lock_screen.dart` and `security_screen.dart`, remove the branches that need it to be
   `true`. Remove `_showMandatoryPinSetup` if nothing else calls it.
3. Remove `UnlockInstruction.setUpPinWithPhoneLock` and its switch case.
4. Remove ARB keys used only by those branches (to check: `titleSetUpYourPin`,
   `descUnlockSetUpPin`, `descFinishPinSetup`), then run `flutter gen-l10n`.
5. Remove the two test lines that check the flag.

### Phase 3

The app has never been released to the public, so no outside user holds data in these formats.

1. **Account secrets:** in `encryption_service.dart`, remove `_legacyDecrypt` and `migrateToAES`.
   `decrypt` accepts only the GCM format and throws for anything else, so callers keep their
   existing safe failure path.
2. **`MigrationService`:** delete the service and its test. In `account_provider.dart`, remove
   `_migration`, `_isMigrating` and `isMigrating`, so `_initialize` only loads accounts. Remove
   `aesMigrationKey`, `gcmMigrationKey` and `cbcIvBase64Length` from `constants.dart`.
3. **Backups:** in `export_import_service.dart`, keep only `v3`. Remove the `v2` and CTR branches
   and `_legacyPadPassword`. Any other format returns `null`, which shows the existing friendly
   error (hard rule 4). Replace the old format tests with tests that these inputs return `null`.
4. **Database:** remove `_onUpgrade`, `_migrateGroupsToTags` and the `groupId` column from
   `_createDB`. Keep `databaseVersion` at 4. Lowering it could make existing test installs fail to
   open, and a leftover `groupId` column on those installs does no harm because no code reads it.
5. **`groups` key:** stop writing it to backups and sync payloads. Remove the `groups` and
   `includeGroups` parameters from `sync_provider.dart` and their arguments in
   `send_to_device_screen.dart`. Fix the comments and test fixtures. Incoming files that still
   have the key keep working, because the parser ignores it.
6. **Legacy settings:** remove `_keyLegacyLockType`, `_keyBiometricEnabled` and the fallback that
   reads them. Quick unlock defaults to off when its current setting is not saved. Two tests set up
   phone-lock-only mode through `lock_type`; rewrite them to use the current setting, because that
   mode is still a real feature.
7. **Docs:** remove the old format claims from `docs/security.md`, `docs/features.md`,
   `docs/architecture.md` and `docs/project_structure.md`. Keep the database version table as
   history, with a note that upgrades from older versions are no longer supported.

### Left in on purpose

- **Old PIN storage:** `_migrateLegacyPinIfNeeded` and PIN version handling in `auth_service.dart`.
  They were not part of the request and touch the unlock path, so they need a separate review.
- **Saved settings:** `export_format`, the require-auth setting and the old lock settings stay on
  existing devices. They are harmless, and no code will read them.
- **`MaterialUiCompatibilityBridge`:** `flutter_slidable` and `percent_indicator` still render old
  Material widgets. Removing the bridge needs its own visual check.
- **`checkAndLockApp`:** its test guards lock behaviour, so it needs its own review.
- **`getReconstructedPayload`:** its test checks the whole flow.
- **Test helpers:** `resetForTesting` and the `...ForTest` helpers.
- **`.metadata`:** the file says it must not be edited by hand, and the old `ios`, `macos` and
  `web` entries do no harm. This replaces the earlier suggestion to clean it.

## How it will be checked

Run after each phase:

- `flutter pub get`
- `flutter gen-l10n`
- `dart format .`
- `flutter analyze` (must report zero issues)
- `flutter test` (must pass)

After Phase 2, the lock screen also needs a manual check on a real device, because tests may not
cover every unlock path: unlock with App PIN, unlock with phone lock, and fall back from phone
lock to PIN.

## Risks

- The working tree already has many uncommitted changes, so this cleanup would be hard to review
  or undo on its own. Commit the current work first.
- Phase 2 touches the unlock path. Each change should be a simple "value is always false" change,
  and the manual check above is there to catch a mistake.
- Phase 3 cannot read old data. Any test device with accounts still in XOR or CBC format will fail
  to decrypt them, and any old `v2` or CTR backup can no longer be restored. Before this phase,
  open the app once on the current build on each device you care about, then export a new backup
  (`v3`). The current build upgrades stored secrets when it starts.
- Removing `filteredAccounts` also removes its tests. The home screen's own search keeps whatever
  test coverage it has today.
