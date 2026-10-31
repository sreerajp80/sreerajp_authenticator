import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/screens/home_screen.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';

/// Bulk delete after the phone-lock prompt: only success (or a phone with no
/// screen lock at all) may delete.
void main() {
  const expected = {
    LocalAuthOutcome.success: true,
    LocalAuthOutcome.notAvailable: true,
    LocalAuthOutcome.failure: false,
    LocalAuthOutcome.canceled: false,
    LocalAuthOutcome.lockedOut: false,
    LocalAuthOutcome.error: false,
  };

  test('covers every LocalAuthOutcome', () {
    expect(expected.keys.toSet(), LocalAuthOutcome.values.toSet());
  });

  for (final entry in expected.entries) {
    test('${entry.key.name} → ${entry.value ? 'delete' : 'keep'}', () {
      expect(
        bulkDeleteAllowedAfterPhoneLock(LocalAuthResult(entry.key)),
        entry.value,
      );
    });
  }
}
