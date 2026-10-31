# Fix copying codes from the home screen

Implements plan: `plans/20261030_190529_fix-copy-code-from-home.md`

**Security impact:** small. No storage, permission or network change. Codes can reach the clipboard
again, and the existing 30-second auto-clear stays.

## What changed

- `lib/widgets/account_tile.dart`
  - One tap on the tile now copies the code. The tile calls `widget.onTap` first, so the home screen
    still records activity and handles selection, then copies unless it is in selection mode.
  - `onDoubleTap` is removed. It was switched off whenever the tile had an `onTap`, and the home
    screen always passes one, so no account's code could be copied.
  - **Beyond the plan:** the "Code copied for {name}" message now wraps. Its text was in a row that
    could not wrap, so a long account name overflowed on a narrow screen. Nobody could see this while
    copying was unreachable. The new tests found it.
- `docs/features.md`: tap copies, and the eye button shows or hides the code.

No translations changed: the help and features screens already said that one tap copies.

## Tests

- New `test/widgets/account_tile_copy_test.dart`, with a mocked clipboard. The tile has an `onTap`,
  as on the home screen:
  - a tap copies the real code while it stays hidden on screen, and `onTap` is still called;
  - selection mode copies nothing and `onTap` is called;
  - the eye button does not copy;
  - the clipboard clears after 30 seconds, and a different value put there is left alone.
- `test/widgets/account_tile_hotp_test.dart`: the "Tap the next code button first" message uses one
  tap, and copying an HOTP code does not move its counter.

## Checks

- `dart format`: no changes left.
- `flutter analyze`: no issues.
- `flutter test`: 354 tests pass.
- `flutter build apk --flavor dev --debug`: built. Gradle daemons stopped afterwards.

## Not checked

- The full home screen was not opened in a widget test, because it needs too much setup. The tests
  use the tile alone, with an `onTap` like the one the home screen passes.
- Not tried on a real phone.
- As the plan warned, a stray tap replaces what is on the clipboard, and the 30-second clear then
  empties it.
