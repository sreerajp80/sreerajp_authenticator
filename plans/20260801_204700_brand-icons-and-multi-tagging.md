# Implementation Plan — Brand Icons & Multi-Dimensional Tagging System

**Status:** Proposed (Awaiting User Approval)

## Issue / Rationale
1. **Improvement 4 (Bundled Offline Vector Brand Icon Engine)**: Account tiles currently show generic colored circles with initials. Users need automatic recognition of account issuers (e.g. GitHub, AWS, Google, Binance, Discord, Proton, Nintendo, Steam, Microsoft, etc.) using crisp offline vector SVG logos with zero network calls.
2. **Improvement 5 (Multi-Dimensional Tagging System)**: Accounts are currently constrained to a single group. Users need multi-tag support (e.g. `#Work`, `#Crypto`, `#Personal`, `#VIP`, `#Finance`) with horizontal combination filtering (e.g., `#Work` AND `#Crypto`) on `HomeScreen`.

---

## Files to Change

### New Files
- `assets/icons/brands/*.svg` — Vector SVG brand icons bundle
- `lib/services/brand_icon_service.dart` — Issuer/account name to SVG asset matching engine
- `lib/widgets/home/home_tag_filter_bar.dart` — Horizontal multi-select filter chip bar widget
- `test/services/brand_icon_service_test.dart` — Unit tests for brand icon matching engine
- `test/models/account_tags_test.dart` — Unit tests for account tag serialization & filtering

### Modified Files
- [pubspec.yaml](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/pubspec.yaml) — Register brand icon asset paths
- [lib/utils/constants.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/utils/constants.dart) — Bump database version for tags column
- [lib/models/account.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/models/account.dart) — Add `tags` property (`List<String>`), update `toMap`, `fromMap`, `copyWith`
- [lib/services/database_service.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/services/database_service.dart) — Update `accounts` table schema and upgrade logic for `tags` column
- [lib/providers/account_provider.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/providers/account_provider.dart) — Add tag aggregation, active tag filtering (`#Work` AND `#Crypto`), export/import tag serialization
- [lib/widgets/account_tile/account_avatar.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/widgets/account_tile/account_avatar.dart) — Integrate `BrandIconService` with `flutter_svg` and graceful fallback
- [lib/widgets/account_tile.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/widgets/account_tile.dart) — Render tag chips on account cards
- [lib/widgets/add_account/account_info_card.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/widgets/add_account/account_info_card.dart) — Add tag chip input/selection field
- [lib/screens/add_account_screen.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/add_account_screen.dart) — Manage tags state during account creation/editing
- [lib/screens/home_screen.dart](file:///l:/Android/SreerajP_Authenticator/sreerajp_authenticator/lib/screens/home_screen.dart) — Embed `HomeTagFilterBar` for multi-tag combination filtering

---

## Detailed Technical Changes

### 1. Brand Icon Engine (Improvement 4)
- **Asset Bundle**: Add curated SVG brand icons under `assets/icons/brands/` (Google, GitHub, AWS, Binance, Discord, Proton, Nintendo, Microsoft, Apple, Steam, Epic Games, Telegram, Signal, WhatsApp, Facebook, Instagram, X/Twitter, Reddit, Spotify, PayPal, Coinbase, Bitwarden, etc.).
- **`BrandIconService`**:
  - Implements lookup with alias normalization (stripping spaces, symbols, `.com`, `.org`, lowercase matching).
  - Map aliases: e.g. `gsuite` / `gmail` -> `google.svg`, `aws` / `amazon web services` -> `aws.svg`, `protonmail` -> `proton.svg`, etc.
  - Returns asset path or `null` if unmapped.
- **`AccountAvatar`**:
  - Checks `BrandIconService.getBrandIconPath(issuer, name)`.
  - If match found, renders SVG using `SvgPicture.asset` inside a clean styled container.
  - If no match, falls back to letter avatar.

### 2. Multi-Dimensional Tagging System (Improvement 5)
- **`Account` Model**:
  - `List<String> tags`: stored as SQLite `TEXT` (comma-separated string e.g. `#Work,#Crypto`).
- **`DatabaseService`**:
  - Database schema upgrade (v2 -> v3) adding `tags TEXT` to `accounts` table.
- **`AccountsProvider`**:
  - Active selected tags `Set<String> _selectedTags`.
  - Aggregates `allAvailableTags`.
  - Combination filter in `filteredAccounts`: accounts must match ALL selected tags (AND logic).
- **UI & UX**:
  - `HomeTagFilterBar`: Scrollable horizontal chip bar with toggleable tags.
  - `AccountTile`: Visual display of account tags.
  - `AddAccountScreen` / `AccountInfoCard`: Input chip selector for managing tags.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` (must pass with zero warnings).
- Run `flutter test` (all unit and widget tests must pass).
- Added test coverage:
  - BrandIconService matching tests.
  - Account tag serialization and database migration tests.
  - Tag combination filtering logic tests in AccountsProvider.

### Manual Verification
- Verify brand SVG icons render crisply on account tiles for GitHub, AWS, Google, Binance, Discord, Proton, Nintendo, etc.
- Verify fallback to letter avatar for unrecognized issuers.
- Create accounts with multiple tags (#Work, #Crypto, #Personal).
- Verify combination filtering (#Work AND #Crypto) on HomeScreen.
