# Implementation Progress — Sreeraj P Authenticator

This document tracks live implementation status and completed tasks for Sreeraj P Authenticator.

**Last updated:** 2026-10-29

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [implementation_plan.md](implementation_plan.md)

---

## 1. Status Overview

- **Current Release Version:** see `pubspec.yaml`
- **Profiles Active:** `Core Baseline`, `Production App Extension`, `Sensitive Data Extension`
- **Documentation Compliance Status:** Adopting the updated guidelines — see [`../plans/20261029_183929_adopt-updated-guidelines.md`](../plans/20261029_183929_adopt-updated-guidelines.md)

---

## 2. Completed Milestones

- [x] **Core TOTP/HOTP Engine**: Dynamic truncation, RFC 4226 / RFC 6238 vector verification.
- [x] **AES-256-GCM Vault Encryption**: 12-byte IV nonce encryption for SQLite database fields.
- [x] **Biometric & App Lock**: Biometric integration via `local_auth` and PIN authentication.
- [x] **Screen Protection**: Screenshot and screen recording prevention via `screen_protector` (`FLAG_SECURE`). On by default, with a "Block screenshots" setting on Android.
- [x] **Build Flavors**: `dev` and `prod` flavor setup with Android Gradle configuration.
- [x] **Guidelines Submodule Integration**: Added `docs/guidelines` submodule pointing to `https://github.com/sreerajp80/Flutter_Guidelines`.
- [x] **Baseline Documentation Set**: All 9 mandatory baseline documents under `docs/`, including `PROJECT_PROFILE.md`.
- [x] **Multi-Algorithm Support**: Steam Guard (5-char alphanumeric), Blizzard (8-digit) and YubiKey (hex seed). mOTP was removed before the first release (`plans/20261031_085346_first-release-cleanup.md`).
- [x] **Tag-Based Organization & Brand Icons**: Free-form multi-tagging, autocomplete filtering, and bundled brand SVG icons.
- [x] **Dual Offline Device Sync**: Wi-Fi LAN P2P transfer and camera-only Optical Air-Gap animated QR stream.
- [x] **Database Schema v4**: Migrated legacy group structures to flexible account tags and streamlined persistence.

---

## 3. Active Task Checklist

### Guideline adoption (plan `20261029_183929_adopt-updated-guidelines.md`)

- [x] **Phase 1 — Project profile**: `docs/PROJECT_PROFILE.md` created and confirmed.
- [x] **Phase 2 — Agent and docs files**: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, baseline docs reshaped.
- [x] **Phase 3 — Toolchain**: AGP 9.4.1, Kotlin 2.4.10, Gradle 9.8.0, Java 17, `minSdk 29`.
- [x] **Phase 3b — `material_ui` migration**: `material_ui ^1.8.0`, imports migrated, compatibility bridge.
- [x] **Phase 4 — Platforms**: `ios/`, `macos/`, `web/` removed. `windows/` and `linux/` removed later (`plans/20261031_074327_remove-windows-linux.md`): the app is Android only.
- [x] **Phase 5a — Localization foundation**: `l10n.yaml`, ARB `en`/`ml`/`sa`, Sanskrit fallback, language picker, fonts, About config and badge, `test/l10n/` checks.
- [x] **Phase 5b — Core flows**: lock, home, add account, QR scanner, account and tag widgets, PIN dialog, permissions.
- [x] **Phase 5c — Security, backup and sync**: screens migrated; sync and backup errors are codes.
- [x] **Phase 5d — Long text**: features and help screens migrated; wrong help claims fixed (brand count, HOTP, optical speed and encryption, Wi-Fi pairing code, button names).
- [x] **Phase 6 — Tooltips and accessibility**: tooltips, add button keyboard access, 48 dp eye button, contrast and text scaling fixed; `test/accessibility/` guards them. Screen reader runs are on the release checklist.
- [x] **Phase 7 — Security Baseline check**: `docs/security.md` §1.1, §3.1, §12 filled. §12 is not signed off.
- [x] **Phase 8 — CI**: checks-only GitHub workflow (`.github/workflows/ci.yml`).
- [x] **Release blockers**: "Delete all data" and `PRIVACY.md` added (`plans/20261031_081352_android-release-blockers.md`). Still open: push `PRIVACY.md`, and the owner's phone test and §12 sign-off.

### Features

- [ ] **Argon2id Key Derivation**: Upgrade local PIN hash storage from PBKDF2 to Argon2id.
- [ ] **Custom Tag Color Customization**: Allow assigning per-tag custom palette colors.
