# Localization Part 5d — features and help screens

**Status:** completed

Part 5d (the last part) of `plans/20261029_202317_localization-phase-5.md` (master plan
`plans/20261029_183929_adopt-updated-guidelines.md`, Phase 5).

**Security impact:** none. Text only. Some help text about security is corrected to match the
code (see "Corrections").

## What the issue is

The Features screen and the 9 help screens are the last screens with English literals under
`ml` and `sa`. They are long prose:

| File | Strings | ~Words |
|---|---|---|
| `lib/screens/features_screen.dart` | 103 | 640 |
| `lib/screens/help/help_home_screen.dart` | 25 | 170 |
| `lib/screens/help/faq_troubleshooting_help_screen.dart` | 24 | 340 |
| `lib/screens/help/getting_started_help_screen.dart` | 16 | 230 |
| `lib/screens/help/p2p_sync_help_screen.dart` | 15 | 210 |
| `lib/screens/help/tag_management_help_screen.dart` | 15 | 190 |
| `lib/screens/help/vault_security_help_screen.dart` | 15 | 190 |
| `lib/screens/help/backup_help_screen.dart` | 14 | 190 |
| `lib/screens/help/optical_sync_help_screen.dart` | 14 | 220 |
| `lib/screens/help/time_sync_help_screen.dart` | 14 | 220 |
| `lib/screens/help/biometrics_help_screen.dart` | 12 | 160 |
| **Total** | **~270** | **~2,750** |

While checking the text against the code, I found English help text that is **wrong**. It would
be wrong in all three languages if translated as is.

## Corrections (English, before translating)

| Where | Now says | Code says | New text |
|---|---|---|---|
| Backup help | key derived "using PBKDF2 with 100,000 iterations" | backups use 300,000 (`AppConstants.pbkdf2Iterations`; 100,000 is the app PIN) | "…using PBKDF2 with 300,000 iterations" |
| Backup help | "Save the exported `.json` / backup file" | the backup file is `authenticator_backup_encrypted_<time>.aes` | "Save the encrypted `.aes` backup file" |
| Backup help | "Settings -> Backup & Restore -> tap "Export Encrypted Backup"" / "Import Backup" | buttons are now "Create backup file" / "Restore from backup" | the current button names, from the same ARB keys |
| Biometrics help | "Settings -> Security Settings" | row is "Security settings" | current name, from the ARB key |
| Optical help | "Settings -> Sync to Another Device -> "Air-Gap Optical Transfer"" | "Sync devices" → "Send optical stream" | current names |
| Wi-Fi help | "Settings -> Sync to Another Device -> "Host / Send Accounts"" | "Sync devices" → "Send over Wi-Fi" | current names |
| FAQ | "Sync to Another Device" | "Sync devices" | current name |
| Tags help | "Settings -> Manage Tags" | "Manage tags" | current name |
| Help home, vault help | "Hardware-backed encryption keys" / "hardware-backed Android Keystore" | key is kept by `flutter_secure_storage` (Android Keystore; hardware-backed only when the phone has the hardware) | "…kept in the Android Keystore (hardware-backed on phones that support it)" |
| Help home, Wi-Fi help | "end-to-end encryption" | the payload is sealed with AES-256-GCM using a key from the pairing code | keep, but say "encrypted with a key from the pairing code" |

Menu paths in help text are built from the same ARB keys as the real buttons (placeholders), so a
renamed button can never drift from its help text again, in any language.

I will not change any other meaning. If I find more wrong claims while migrating, I list them in
the change log and ask before changing them.

## Plan for the fix

1. Move every user-visible string in the 11 files to ARB with the long-text prefixes
   (`help…` for help bodies, `desc…` for feature descriptions, `title…` / `label…` for headings,
   kept within the length budget). Menu paths use placeholders filled from the existing button
   keys, for example `helpBackupCreateStep` = "Go to {settings} → {backupRestore} → tap
   “{createBackup}”."
2. Apply the corrections above in English, then write the Malayalam and Sanskrit text from the
   corrected English.
3. Technical names stay as they are in every language where they are names, not words: RFC 6238,
   RFC 4226, TOTP, HOTP, SHA-1/256/512, AES-256-GCM, PBKDF2, Base32, QR, Wi-Fi, FLAG_SECURE,
   Android Keystore. Keys that would then be equal to English (for example a chip that is only
   "SHA-1/256/512") go on the parity test's allow-list with a comment.
4. `flutter gen-l10n`, `dart format` on changed files, `flutter analyze`, `flutter test`.
5. New widget test: the Features screen and every help screen open in `en`, `ml`, `sa` on a
   narrow screen with no exception or overflow. A test that every help menu path still names
   the current button text (it uses the same keys).
6. Build `flutter build apk --flavor dev --debug`; stop Gradle daemons.
7. Docs: `CLAUDE.md`, `AGENTS.md` (localization is complete; the "migration in progress" note is
   removed), `docs/implementation_progress.md` (5d ticked, Phase 5 done),
   `docs/features.md` (same corrections where it repeats them). Change log with the full
   English / Malayalam / Sanskrit table, marked "needs native-reader review". Set this plan and
   the Phase 5 plan to `completed`.

## Files to be changed

- `lib/screens/features_screen.dart`, the 10 files in `lib/screens/help/`.
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`; generated `app_localizations*.dart`.
- `test/l10n/translation_parity_test.dart` (allow-list for pure technical names, if needed).
- New `test/screens/help_screens_l10n_test.dart`.
- `CLAUDE.md`, `AGENTS.md`, `docs/implementation_progress.md`, `docs/features.md`.

Not in this part: the 9 help screens each carry their own copy of the same small layout widgets
(`_Intro`, `_Section`, `_Bullet`, `_Footer`). Merging them into one shared file would be a good
clean-up, but it is a code change, not localization; I list it as a follow-up.

## Translations

About 2,750 English words become about 270 keys per language. I write the Malayalam and Sanskrit
drafts following the language pack and the terms already used in 5a–5c. Every string is listed
for your review in the change log; this is the largest review batch.

## Risks

- Volume: this is the biggest translation set. The parity, length and Hindi-marker tests catch
  missing keys, long labels and Hindi words, but not wrong meaning — that needs your review.
- Long Sanskrit and Malayalam paragraphs are longer than English; the new widget test checks
  layout, and your on-device look checks readability.

## Decisions during implementation (owner, 2026-10-30)

More claims were found that do not match the code. The owner chose to fix all of them in English
before translating:

1. "100+ built-in brands" → the app ships 10 brand icons (Apple, AWS, Binance, Discord, GitHub,
   Google, Microsoft, Nintendo, Proton, Steam).
2. HOTP: the app can read HOTP QR codes, but the home screen has no counter or refresh button, and
   HOTP accounts get time-based codes. Help and features now say HOTP is not supported yet.
   (The wrong codes for HOTP accounts are a bug for a separate plan.)
3. Optical frame speed "250–500 ms per frame" → 10, 12 or 15 frames per second.
4. The optical stream is **not encrypted** (the QR frames carry the account secrets). Help no
   longer says "encrypted vault" and warns to keep the screen away from other people and
   cameras. The owner chose a **separate fix plan** to encrypt the optical stream after 5d.
5. Wi-Fi "pairing QR code and PIN" → "pairing QR code and pairing code"; old button names
   ("Connect / Receive Accounts", "Scan QR Code", "Enter Key Manually", "All") → current names
   through placeholders.
