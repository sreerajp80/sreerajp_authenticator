# Fix copying codes from the home screen

**Status:** completed

Bug found during `plans/20261030_185703_fix-hotp-codes.md`. Master plan:
`plans/20261029_183929_adopt-updated-guidelines.md`.

**Security impact:** small. No storage, permission or network change. Codes can reach the clipboard
again, as the app has always intended, and the existing 30-second auto-clear stays. A one-time code
in the clipboard is short-lived, but other apps on the phone may be able to read it during that time.

## What the issue is

`lib/widgets/account_tile.dart` turns off double-tap copy whenever the tile has an `onTap`:

```dart
onTap: widget.onTap,
onDoubleTap: (widget.isSelectionMode || widget.onTap != null) ? null : _copyToClipboard,
```

The home screen always passes `onTap`, and it is the only screen that uses this tile. So
`_copyToClipboard` cannot be reached, and **no account's code can be copied**. Users must read the
code and type it.

The app also disagrees with itself about how copying should work:

| Where | Says |
|---|---|
| Help (`helpStart14`, `helpFaq07`), Features (`descFeatures25`, `descFeatures26`) | One tap copies |
| `docs/features.md` | Double tap or a copy button copies; tap shows or hides the code |
| Code | Nothing copies; the eye button shows or hides the code |

## Plan for the fix

**One tap on the tile copies the code.** This matches what users are already told in all three
languages, so no translation changes. A separate tap on the eye button still shows or hides the code.

### Widgets: `lib/widgets/account_tile.dart`
- The tile's `onTap` always calls `widget.onTap` first, so the home screen still records the user's
  activity and handles selection. Then, outside selection mode, it calls `_copyToClipboard`.
- `onDoubleTap` is removed. This also removes the short wait that a double-tap detector adds to taps.
- `lib/screens/home_screen.dart` needs no change.

Behaviour that stays the same:
- Selection mode: a tap selects the account and copies nothing.
- Long press still starts selection.
- The eye and "Next code" buttons handle their own taps and do not copy.
- A hidden code (`***`) is still copied, without being shown. The "copied" message does not include
  the code.
- If no code is available, the existing error message shows and nothing is copied.
- HOTP before the first tap of "Next code": "Tap the next code button first." HOTP has no accidental
  cost here, because copying never moves the counter.
- The clipboard is cleared after 30 seconds if it still holds that code.

### Tests
- New `test/widgets/account_tile_copy_test.dart`, with a mocked clipboard:
  - a tap copies the real code, even while it is hidden;
  - the tile's `onTap` is still called;
  - in selection mode, nothing is copied and `onTap` is called;
  - the eye button does not copy;
  - the clipboard clears after 30 seconds, and a different value put there is left alone.
- `test/widgets/account_tile_hotp_test.dart`: the message check uses one tap, and a tap after
  "Next code" copies the HOTP code without moving the counter.
- A check on the real home screen tile, if the home screen can be opened in a widget test without too
  much setup. If not, I will say so in the change log.

### Docs
- `docs/features.md`: tap copies; the eye button shows or hides the code; remove "double-tap or copy
  button".
- Change log.

### Checks
`dart format`, `flutter analyze`, `flutter test`, `flutter build apk --flavor dev --debug`, then stop
the Gradle daemons.

## Files to be changed

- `lib/widgets/account_tile.dart`
- New `test/widgets/account_tile_copy_test.dart`, and `test/widgets/account_tile_hotp_test.dart`
- `docs/features.md`

## Risks

- A stray tap now replaces whatever is on the clipboard, and the 30-second clear then empties it. A
  user who tapped by mistake could lose something they had copied earlier. A separate copy button
  would avoid this, but needs a new control on an already full tile and new help text in three
  languages.

## Not in this plan

- Marking copied codes as sensitive so Android hides them in its clipboard preview. This fits the
  Phase 7 security check.
