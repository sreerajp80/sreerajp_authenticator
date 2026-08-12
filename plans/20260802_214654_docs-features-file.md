# Create docs/features.md — full feature inventory

**Status:** completed

## Files to be changed

- `docs/features.md` (new file only — no other files touched)

## What the issue is

The user wants a single reference document that lists, in plain language, what
"SreerajP Authenticator" is and every feature it currently has. This is meant
to be handed to another LLM as ground truth before that LLM implements a new
feature in a *different* app, so it can check "does this already exist / how
does this app do it" without re-reading the whole codebase.

## The plan for the fix

Create `docs/features.md` with the following sections, written in simple
English, based on a full read-through of the code (screens, services,
providers, models, widgets, constants, pubspec, Android manifest/gradle, and
recent change logs):

1. **What this app is** — short description (offline TOTP/HOTP authenticator,
   no cloud, Flutter, Android-first).
2. **OTP types and algorithms supported** — TOTP, HOTP, Steam Guard, Blizzard
   Authenticator, YubiKey HMAC-SHA1, mOTP; SHA1/SHA256/SHA512; Base32 and Hex
   secrets; 6/8 digit and custom periods.
3. **Account management** — add (manual + QR), edit, delete, reorder
   (manual/issuer/name/date sort), search, tags (replacing the old removed
   "Groups" feature) with a Tag Cloud tab and Tag Management screen, offline
   brand icons with letter-avatar fallback, masked/visible OTP display with
   auto-hide and clipboard auto-clear.
4. **Security** — App PIN (PBKDF2 hashed), Phone Screen Lock (biometric/
   device credential via local_auth), recovery key for forgotten PIN,
   adaptive re-auth (boot detection, inactivity timeout, failed-attempt
   lockout, Lockdown Mode), PIN-gated secret/advanced-field editing,
   AES-256-GCM encryption at rest with legacy-format migration, FLAG_SECURE
   screen protection, no telemetry/no internet backend.
5. **Backup and restore** — password-encrypted `.aes` JSON export/import via
   share/file picker, duplicate-skipping on import, backward-compatible
   decrypt of older backup formats.
6. **Device-to-device sync** — three channels: P2P LAN sync (TCP + pairing
   code + QR, full or selective sync), Optical Air-Gap Sync (animated QR /
   fountain codes, camera-only, no network), and single-account QR import.
7. **UI and settings** — theme modes, sort options, sync host timeout,
   About/Permissions/Privacy screens, dev/prod build flavors.
8. **Platform/permissions** — Android permissions used and why, no cloud
   SDKs, offline-only guarantee.

The content will be written directly from the verified codebase analysis
already performed in this session (screens, services, providers, models,
widgets, constants, pubspec.yaml, AndroidManifest/gradle, and change_log
entries) — no new exploration needed. No existing files are modified; this
is a pure documentation addition.

## Note on the removed "Groups" feature

Git status shows `group_provider.dart`, `group_management_screen.dart`,
`group.dart` (model), and related tests as deleted. This was already
replaced by the multi-tag system per `change_log/20260801_204900_remove-groups-migrate-tags.md`.
The new features.md will describe tags, not groups, so it reflects current
app behavior, not a stale/removed feature.
