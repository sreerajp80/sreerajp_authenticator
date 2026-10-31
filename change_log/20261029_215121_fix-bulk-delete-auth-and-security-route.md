# Fix bulk-delete verification and the "Open security" crash

Implements plan: `plans/20261029_214802_fix-bulk-delete-auth-and-security-route.md`
(found during `change_log/20261029_214641_localization-part-5b-core-flows.md`)

## What changed

### 1. Bulk delete can no longer skip verification (security fix)
- `lib/screens/home_screen.dart` — `_verifyBiometricOrPinForBulkDelete()` ended with
  `return true;` after the phone-lock prompt, whatever the result. It now returns
  `bulkDeleteAllowedAfterPhoneLock(phoneResult)`, a new top-level function
  (`@visibleForTesting`):
  - `success` → delete;
  - `failure`, `canceled`, `lockedOut`, `error` → no delete (the existing
    "Authentication failed. Deletion canceled." snackbar shows);
  - `notAvailable` (the phone has no screen lock and app lock is off) → delete, as before; the
    user already confirmed in the delete dialog and there is nothing to check.
- The biometric and app-PIN paths before it are unchanged.

### 2. "Open security" opens the Security screen
- `lib/screens/add_account_screen.dart` — both "App lock required" dialogs called
  `Navigator.pushNamed(context, '/security')`, but the app defines no named routes, so the button
  threw. They now push `SecurityScreen` with `MaterialPageRoute`, like the other screens.

### Tests
- New `test/screens/home_bulk_delete_auth_test.dart` — one case per `LocalAuthOutcome`, plus a
  check that every outcome is covered.
- New `test/screens/add_account_security_route_test.dart` — opens an existing account with app
  lock off, taps "Enable app lock", then "Open security", and expects `SecurityScreen` with no
  exception. Checked that this test **fails** with the old `pushNamed` line ("Could not find a
  generator for route /security") and passes with the fix.

## Checks
- `dart format` on the 4 changed files (no changes needed).
- `flutter analyze` — no issues.
- `flutter test` — all 274 tests passed (266 before).
- `flutter build apk --flavor dev --debug` — built. Gradle daemons stopped; none left.

## Not done
- Manual check on a phone: with no fingerprint enrolled and app lock off, delete two selected
  accounts and cancel the phone-lock prompt — they must stay; and "Open security" from an edited
  account must open the Security screen.
