# Fix Settings Icon & AppBar Actions Clipping on Home Screen

**Status:** Approved & Implemented

## Issue
On the Home screen header, the settings gear icon and sort icon pill containers are vertically clipped/truncated at the top edge.

## Root Cause
In `lib/screens/home_screen.dart`, `Scaffold.appBar` is wrapped inside a `PreferredSize` widget with `preferredSize: const Size.fromHeight(kToolbarHeight + 46.0)`.
Flutter's `AppBar` automatically incorporates status bar top padding (`MediaQuery.of(context).padding.top`) into its height when laying out its internal toolbar and bottom tabs. Because `PreferredSize` fixed the container height to 102.0 px without including status bar padding, the toolbar containing the title and action buttons is pushed upward into the status bar space, causing the top portion of action icons to be clipped.

## Proposed Fix
Update `PreferredSize` in `lib/screens/home_screen.dart` to include `MediaQuery.paddingOf(context).top`:
`preferredSize: Size.fromHeight(kToolbarHeight + 46.0 + MediaQuery.paddingOf(context).top)`

## Files to Change
- `lib/screens/home_screen.dart`

## Verification
- `flutter analyze`
- `flutter test`
