# Project Profile — Sreeraj P Authenticator

**Last updated:** 2026-10-29

> Filled in from the code and confirmed by the project owner through the intake in
> `docs/guidelines/AI_AGENT_START_HERE.md` §3. Remaining `TODO` values name the gate they block.
>
> Template: `docs/guidelines/PROJECT_PROFILE_TEMPLATE.md`. Every rule that depends on a platform,
> store or language applies only when this file declares it.
>
> **Privacy:** this file is committed. Only public information goes here.

---

## 0. Product brief

| Item | Value |
|---|---|
| What the app does | Offline-first TOTP/HOTP two-factor authenticator with an AES-256-GCM encrypted vault |
| Main features (current version) | TOTP/HOTP codes (RFC 6238 / RFC 4226); QR code onboarding; encrypted local vault; PIN and biometric lock; tags; encrypted backup export/import; optical (QR) and local-network device-to-device sync; brand icons; light/dark themes |
| Who uses it | General public — anyone who needs two-factor codes |
| Out of scope for now | Cloud backup, user accounts, any internet backend |

### 0.1 Data and privacy

| Item | Value |
|---|---|
| Works offline / needs the network | Offline only; local network used only for device-to-device sync |
| Backend or third-party API | none |
| User accounts / sign-in | none |
| Data the app stores, and where | OTP accounts and secrets (encrypted SQLite), settings — device only |
| Personal, health, finance or secret data | Secret data: OTP seeds, PIN / recovery verifiers |
| Analytics | none |
| Crash reporting | none |
| Ads | none |
| Other third-party SDKs that send data | none |
| In-app purchases or subscriptions | none |
| Device permissions | CAMERA — scan QR codes; USE_BIOMETRIC / USE_FINGERPRINT — biometric unlock; VIBRATE — haptic feedback; INTERNET — Wi-Fi sync ("Sync to Another Device") opens a local-network socket between two devices (needed). Optical Air-Gap sync uses only the camera and needs no network permission. Added by a library: USE_FINGERPRINT (`androidx.biometric`). Other library permissions the app does not use are removed in the manifest (`docs/security.md` §11) |

## 1. Identity

| Item | Value |
|---|---|
| App display name | `en` Sreeraj P Authenticator · `ml` ശ്രീരാജ് പി പ്രമാണീകാരി · `sa` श्रीराज पी प्रमाणीकारकः (confirmed by user) |
| Short description (one line) | Privacy-first, offline-first TOTP/HOTP authenticator app with AES-256-GCM vault encryption. |
| Organization / publisher | Sreeraj P |
| Reverse-DNS app id | `in.sreerajp.sreerajp_authenticator` (prod), `in.sreerajp.sreerajp_authenticator.dev` (dev) |
| Dart package name (`pubspec.yaml` `name`) | `sreerajp_authenticator` |
| Public support contact | sreerajp@zohomail.in |
| Website | `https://github.com/sreerajp80/sreerajp_authenticator` (proposed, confirmed by user) |
| Privacy policy URL | `https://github.com/sreerajp80/sreerajp_authenticator/blob/main/PRIVACY.md` — the file is in the repository root; the link works once it is pushed to `main` (needed before first Google Play release) |
| Copyright line | © 2026 Sreeraj P |
| License of the app's own code | MIT |

## 2. Applicability profiles (engineering standard §1.2)

- [x] `Core Baseline` (always)
- [x] `Production App Extension` — shipped to real users and stores (proposed, confirmed by user)
- [x] `Sensitive Data Extension` — stores OTP secrets in a local encrypted store (proposed, confirmed by user)

## 3. Target platforms and distribution

| Platform | Ship? | Minimum OS | Distribution channels |
|---|---|---|---|
| Android | yes | `minSdk 29` (Android 10) — the oldest version the app is tested on; matches the owner's other apps. The build file is set to this in Phase 3 of the adoption plan | Google Play; direct APK download |
| iOS | no | — | — |
| Windows | no | — | — |
| macOS | no | — | — |
| Linux | no | — | — |
| Web | no | — | — |

The `ios/`, `macos/` and `web/` folders were removed (adoption Phase 4). The `windows/` and
`linux/` folders were removed later, when the owner decided the app is Android only.

Build flavors: dev + prod.

## 4. Languages (engineering standard §8)

| Locale | Language | Script | Role | Language pack |
|---|---|---|---|---|
| `en` | English | Latin | Template ARB, ultimate fallback | — |
| `ml` | Malayalam | Malayalam | Full UI translation | `language_packs/sanskrit_malayalam.md` |
| `sa` | Sanskrit | Devanagari | Full UI translation | `language_packs/sanskrit_malayalam.md` |

- In-app language picker: required — 3 languages, plus "System default".
- Languages without a Flutter framework translation (need the fallback delegate, §8.3.1): `sa`.
- Store-listing languages per store: Google Play `en-US` and `ml-IN` (proposed, confirmed by
  user).
- Native-reader reviewer for each non-template language: Developer (Sreeraj P) — `ml` and `sa`.

## 5. About screen (`guideline.md` §1)

| Item | Value |
|---|---|
| `details` rows to show | author, email, website, privacyPolicy, license, aiUsed, ideUsed |
| Signature badge (§1.7) | on |
| Badge text — template language | "Made with {heart} in India" (proposed, confirmed by user) |
| Badge text — each other language | `ml` സ്നേഹത്തോടെ {heart} ഇന്ത്യയിൽ നിർമ്മിച്ചത് · `sa` सस्नेहं निर्मितम् {heart} भारते (draft, TODO — reviewer confirmation before release) |
| Badge screen-reader text — each language | `en`: "Made with love in India" (proposed, confirmed by user); `ml`: സ്നേഹത്തോടെ ഇന്ത്യയിൽ നിർമ്മിച്ചത് · `sa`: सस्नेहं निर्मितम् भारते (draft, TODO — reviewer confirmation before release) |

## 6. Optional project-specific values

| Item | Value |
|---|---|
| App size budget override (§10.7) | default |
| State management | Provider (from code) |
| Structure tier (§3.1) | Tier 1 layer-first (from code) |
| Brand colours | Seed colour `#4A90E2` (blue), from `lib/utils/theme.dart` |
| Theme modes | light + dark (from code) |
| App icon source | supplied (`assets/icons/app_icon.png`) |

## 7. Tools and workflow

| Item | Value |
|---|---|
| AI agents used on the project | Claude Code, Gemini |
| IDE | VS Code / Android Studio |
| Can build iOS / macOS locally | not needed |
| Git hosting | GitHub |
| CI checks | GitHub CI — analyze/test only (required on GitHub, engineering standard §19) — `.github/workflows/ci.yml` |
| Release owner (role) | Developer (Sreeraj P) |
