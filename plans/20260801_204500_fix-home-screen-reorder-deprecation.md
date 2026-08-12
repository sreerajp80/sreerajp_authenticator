# Plan: Fix Home Screen Reorder Deprecation Warning

**Status:** Approved

## Context & Objective
The IDE analysis surfaced a Flutter deprecation warning in [`lib/screens/home_screen.dart`](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/home_screen.dart#L442):
`'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead.`

We will update [`lib/screens/home_screen.dart`](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/home_screen.dart) to replace `onReorder` with `onReorderItem` (or update `onReorderItem` callback signature).

---

## Targeted Files & Changes

### 1. `lib/screens/home_screen.dart`
- Replace `onReorder: (oldIndex, newIndex) { ... }` with `onReorderItem: (oldIndex, newIndex) { _onUserInteraction(); provider.reorderAccounts(oldIndex, newIndex); }` in `ReorderableListView.builder`.

---

## Verification Plan

### Automated Verification
- Run `flutter analyze` to ensure zero deprecation warnings or errors.
- Run `flutter test` to ensure all tests continue to pass.
