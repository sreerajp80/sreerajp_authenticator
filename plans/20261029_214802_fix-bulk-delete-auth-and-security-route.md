# Fix bulk-delete verification and the "Open security" crash

**Status:** completed

Found during `change_log/20261029_214641_localization-part-5b-core-flows.md` (items 1 and 2).

**Security impact:** fixes a verification bypass. Deleting selected accounts will no longer go
ahead after a failed or canceled phone-lock prompt. No change to storage, network or
permissions.

## What the issues are

### 1. Bulk delete can skip verification

`lib/screens/home_screen.dart`, `_verifyBiometricOrPinForBulkDelete()`:

```dart
final phoneResult = await authService.authenticateWithPhoneLock(...);
if (phoneResult.isSuccess) return true;

return true;   // ← also true when the check failed, was canceled or was locked out
```

This last path runs when biometrics are not available (or failed without being canceled) and
app lock is off. Whatever the phone-lock result, the method returns `true`, so the selected
accounts are deleted even when the user failed or canceled the phone-lock prompt.

### 2. "Open security" button crashes

`lib/screens/add_account_screen.dart` (two places, the "App lock required" dialogs) calls
`Navigator.pushNamed(context, '/security')`. `MaterialApp` in `lib/main.dart` defines no named
routes, so the call throws ("Could not find a generator for route") instead of opening the
security settings.

## Files to be changed

- `lib/screens/home_screen.dart` — the decision after the phone-lock prompt moves into a small
  top-level function, so it can be tested:

  ```dart
  /// Whether a bulk delete may go ahead after the phone-lock prompt.
  @visibleForTesting
  bool bulkDeleteAllowedAfterPhoneLock(LocalAuthResult result) =>
      result.isSuccess || result.outcome == LocalAuthOutcome.notAvailable;
  ```

  - `success` → delete.
  - `failure`, `canceled`, `lockedOut`, `error` → do not delete; the existing
    "Authentication failed. Deletion canceled." snackbar shows.
  - `notAvailable` (the phone has no screen lock at all, and app lock is off) → delete, as today.
    The user has already confirmed in the delete dialog, and there is no lock to check. Blocking
    here would make bulk delete impossible on such phones.
- `lib/screens/add_account_screen.dart` — replace both `Navigator.pushNamed(context, '/security')`
  with `Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen()))`, the
  way every other screen opens settings pages.
- `test/screens/home_bulk_delete_auth_test.dart` (new) — one case per `LocalAuthOutcome` for
  `bulkDeleteAllowedAfterPhoneLock`.
- `test/screens/add_account_security_route_test.dart` (new) — pump `AddAccountScreen` for an
  existing account with app lock off, open the "App lock required" dialog, tap "Open security",
  and expect `SecurityScreen` with no exception. If the screen needs more setup than the test
  helpers give, I will say so in the change log and leave this check to a manual test.
- `docs/security.md` — §17 (open risks) gets no new entry; the change log records the fix.

## Plan for the fix

1. Make the two code changes.
2. Add the tests.
3. `dart format` on changed files, `flutter analyze`, `flutter test`.
4. Build `flutter build apk --flavor dev --debug`; stop Gradle daemons.
5. Write the change log; set this plan to `completed`.

## Manual check (for you)

On a phone with no fingerprint enrolled and app lock off: select two accounts, delete, and
cancel the phone-lock prompt — the accounts must stay. Then open an account for editing with
app lock off, tap the secret key lock, and tap "Open security" — the Security screen must open.
