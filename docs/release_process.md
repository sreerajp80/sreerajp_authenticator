# Release Process — Authenticator SP

This document describes the step-by-step build, versioning, signing, hardening, and release runbook for Authenticator SP. Read this before preparing or tag-releasing a build.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [PROJECT_PROFILE.md](PROJECT_PROFILE.md) | [security.md](security.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [guidelines/release_process.md](guidelines/release_process.md) | [guidelines/platform_store_readiness.md](guidelines/platform_store_readiness.md) | [guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md)

The `Production App Extension` applies, so this file is filled in **in full**.

---

## 1. Release Scope

- App: `Authenticator SP`
- Release profile: `internal` (direct APK); first public Google Play release not yet done
- Supported release platforms (from [`PROJECT_PROFILE.md`](PROJECT_PROFILE.md) §3):
  - `Android` — channels: Google Play, direct APK
- Store gates in force: `docs/guidelines/platform_store_readiness.md` §1 (every store), §2 (Google
  Play, and §2.5A for direct APK).
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`
- Version source of truth: [`pubspec.yaml`](../pubspec.yaml) (read the current version there; it is
  not copied into this file).

> **Security sign-off.** [`security.md`](security.md) §12 was signed off for 2.10.4 (32) on
> 15 November 2026, after the "Delete all data" phone test. Every later release needs its own
> sign-off (§8).

---

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Coordinates readiness, builds artifacts, and signs off | Developer (Sreeraj P) |
| Engineering | Code changes, regression fixes, and release validation | Developer (Sreeraj P) |
| QA | Manual smoke and regression verification | Developer (Sreeraj P) |
| Translation review | Malayalam and Sanskrit text | Developer (Sreeraj P) |
| Distribution owner | Handles Play Console uploads and signed APK distribution | Developer (Sreeraj P) |

---

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD`
- Source of truth: `pubspec.yaml`
- Build-number increment rule: increment `+BUILD` for every distributable release build (Google
  Play rejects a `versionCode` it has already seen)
- Git tag format: `vX.Y.Z` (version without `+BUILD`)

---

## 4. Branch And Merge Policy

- Release branch strategy: `main only`
- Hotfix strategy: patch `main`, rebuild the prod artifact, and tag a new version
- Required checks before merge (GitHub CI runs the first four, engineering standard §19):
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
  - Manual Android smoke validation for changed flows
  - Review of permissions and security-sensitive changes when applicable

---

## 5. Environment And Flavor Matrix

| Flavor | Mode | Purpose | Example Command |
|--------|------|---------|-----------------|
| `dev` | `debug` | Local development | `flutter run --flavor dev` |
| `dev` | `release` | Release-like manual QA | `flutter build apk --flavor dev --release` |
| `prod` | `release` | Signed release artifact | See §9 |

Notes:

- Android flavors are defined in [`android/app/build.gradle.kts`](../android/app/build.gradle.kts).
  Flutter sets `FLUTTER_APP_FLAVOR` itself from `--flavor`; never pass it with `--dart-define`.
- `prod` has the release app name and base application ID. `dev` adds `.dev` to the application ID
  and `-dev` to the version name.
- `pubspec.yaml` sets `default-flavor: dev`, and Flutter applies it on **every** platform. A build
  without `--flavor` is a **dev** build (verbose logging, dev banner). Always pass
  `--flavor prod` for release builds.

---

## 6. Release Build Hardening

All production builds are security-sensitive artifacts.

### 6.1 Obfuscation And Debug Symbols

```bash
--obfuscate
--split-debug-info=build/symbols/<platform>-prod-<version>/
```

`<platform>` is `android`; `<version>` is the full `pubspec.yaml` version,
for example `2.9.3+27`. See [`security.md`](security.md) §8.1 for why.

The APK and the App Bundle are separate compiles, so each has its own symbols. The release script
(§9) keeps them apart:

- App Bundle: `build/symbols/android-prod-<version>/`
- APKs: `build/symbols/android-prod-<version>-apk/`

Symbol archive policy:

- Archive **both** symbols folders securely after every production build, **outside the
  repository**, next to the release artifacts (for example `<archive>/v2.9.3/symbols-aab/` and
  `<archive>/v2.9.3/symbols-apk/`), and record the locations in §14. A crash from a Play install
  needs the AAB symbols; a crash from a direct APK install needs the APK symbols.
- Keep symbols for the lifetime of the released version. Never commit them (`build/` is in
  `.gitignore`).
- Decode a stack trace with
  `flutter symbolize -i <stack trace file> -d <symbols>/app.<platform>-<arch>.symbols`.

### 6.2 ProGuard / R8 (Android)

Current Android release configuration in
[`android/app/build.gradle.kts`](../android/app/build.gradle.kts):

- `isMinifyEnabled = true`
- `isShrinkResources = true`
- Uses `proguard-android-optimize.txt`
- Includes [`android/app/proguard-rules.pro`](../android/app/proguard-rules.pro)

Current caution:

- The checked-in ProGuard rules file is intentionally minimal. It does not set `-dontobfuscate`.
- Revalidate `proguard-rules.pro` whenever adding plugins that rely on reflection or release-only
  code paths.

### 6.3 App Size Analysis

1. **Size of the real artifact.** After the hardened build, record the size of each artifact you
   ship (and the Play Console download size after upload).
2. **Optional breakdown with `--analyze-size`.** A **separate, throw-away build**: it cannot be
   combined with `--split-debug-info`, needs one ABI on Android, and writes to the same output
   folders. **Run it before the hardened build.** Never ship or archive it.

```bash
flutter build apk --release --flavor prod --target-platform android-arm64 \
  --analyze-size --code-size-directory=build/size-analysis/android/
```

Open the JSON in DevTools (`dart devtools` → App Size). A size increase of more than 10% without
a documented reason is a review item.

### 6.4 Debuggable And Backup Verification (Android)

- `android:debuggable` must be absent or `false` in the merged release manifest.
- Backup: `android:allowBackup="false"` and `android:fullBackupContent="false"` are set
  ([`security.md`](security.md) §10). The app targets API 31+, where `allowBackup="false"` does
  **not** stop device-to-device transfer, so `android:dataExtractionRules` must exclude every
  sensitive path from both `<cloud-backup>` and `<device-transfer>`. Done in
  `android/app/src/main/res/xml/data_extraction_rules.xml`.

```bash
# bash / zsh
aapt2 dump xmltree --file AndroidManifest.xml \
  build/app/outputs/flutter-apk/SreerajP_Authenticator-arm64-v<x.y.z>_<n>-prod-release.apk | grep -iE "debuggable|allowBackup|dataExtractionRules|fullBackupContent"
```

```powershell
# PowerShell (Windows)
aapt2 dump xmltree --file AndroidManifest.xml `
  build\app\outputs\flutter-apk\SreerajP_Authenticator-arm64-v<x.y.z>_<n>-prod-release.apk | Select-String -Pattern "debuggable|allowBackup|dataExtractionRules|fullBackupContent"
```

### 6.5 Network Security Configuration And Cleartext Traffic

- The app has no HTTP client. Wi-Fi sync uses raw TCP sockets on the local network, which
  cleartext settings do not govern; its traffic is sealed at the payload layer
  ([`security.md`](security.md) §5.1).
- Still set `android:usesCleartextTraffic="false"` in the merged manifest, and if a
  `network_security_config.xml` is ever added, it must not trust user-installed certificates.
  `usesCleartextTraffic="false"` is set in the main manifest.

### 6.6 Pre-Release Asset And Secret Leak Audit

Files in the APK's `assets/` and `res/` are not encrypted. Before release, list them:

```bash
# bash / zsh
unzip -l build/app/outputs/flutter-apk/SreerajP_Authenticator-arm64-v<x.y.z>_<n>-prod-release.apk "assets/*"
```

```powershell
# PowerShell (Windows)
tar -tf build\app\outputs\flutter-apk\SreerajP_Authenticator-arm64-v<x.y.z>_<n>-prod-release.apk | Select-String "assets/"
```

- [ ] No `.env` or credentials files in `assets/`.
- [ ] No private keys, `.pem`, `.p12`, or keystores in assets.
- [ ] No database files with test data.
- [ ] Only declared runtime config (`assets/config/app_config.json`) plus images, icons and fonts.

### 6.7 Exported Component Audit

- Only the launcher activity may be exported (`android:exported="true"`, required for `MAIN` /
  `LAUNCHER`). Every other activity, service and receiver in the merged manifest (including those
  added by plugins) must be `android:exported="false"` or justified in
  [`security.md`](security.md) §10.

---

## 7. Signing And Secret Handling

- Android: local `android/key.properties` (outside source control), based on
  [`android/key.properties.example`](../android/key.properties.example); keystore
  `android/release-keystore.jks` (gitignored). Follow `docs/guidelines/guideline.md` §2.
- Google Play: use Play App Signing; the release keystore is the upload key.
- Keystore ownership: Developer (Sreeraj P).
- Secret rotation process:
  - Replace keystore material in the secure owner-controlled location
  - Update local signing configuration
  - Rebuild and validate a signed prod artifact
- Rules:
  - Never commit keystore files or passwords
  - Never print signing secrets in logs
  - Keep at least two secure backups of release signing material, at least one offline
  - CI never holds signing secrets (engineering standard §19.3)

---

## 8. Release Checklist

Complete these items before every release.

### Code And Quality

- [ ] `dart format --output=none --set-exit-if-changed .` passed
- [ ] `flutter analyze` passed
- [ ] `flutter test` passed (including the localization parity test)
- [ ] GitHub CI checks green on the release commit
- [ ] Manual smoke test completed on the changed flows
- [ ] No known release-blocking defects remain

### Performance

- [ ] Release build checked for jank on the main flows (home list, add account, unlock)
- [ ] App size recorded and compared with the last release (§6.3)
- [ ] Startup time under 2 seconds on a mid-range device

### Security

- [ ] Every line of [`security.md`](security.md) §1.1 is `verified` or `n/a` with a reason
- [ ] No secrets in code, assets, `--dart-define` values, or native config files
- [ ] No debug menus, test accounts, or backdoors in the production build
- [ ] `--obfuscate` and `--split-debug-info` applied to every release build
- [ ] No `--analyze-size` build was shipped or archived (§6.3)
- [ ] Debug symbols archived securely for this version (both the AAB and the APK folders, §6.1)
- [ ] Every published APK and AAB has a `.sha256` file next to it, and no `.sha1` file is left (§9)
- [ ] ProGuard / R8 rules verified (§6.2)
- [ ] `android:debuggable=false` confirmed in the merged release manifest (§6.4)
- [ ] Backup settings and `dataExtractionRules` match [`security.md`](security.md) §10 (§6.4)
- [ ] Cleartext traffic disabled (§6.5)
- [ ] Asset audit passed (§6.6)
- [ ] Exported component audit passed (§6.7)
- [ ] Permissions reviewed for every declared platform ([`security.md`](security.md) §11)
- [ ] OWASP Mobile Top 10 signed off in [`security.md`](security.md) §12
- [ ] Backup, lock, migration, and secret-storage flows rechecked for changed code
- [ ] Data retention and purge behavior verified

### Localization

- [ ] `app_en.arb`, `app_ml.arb`, `app_sa.arb` complete; parity test passes (standard §8.7)
- [ ] No English value left in the `ml` or `sa` file
- [ ] `docs/guidelines/language_packs/sanskrit_malayalam.md` checklist passes
- [ ] New or changed translations reviewed by the translation reviewer (§2)
- [ ] Short-label length budget respected in every language (standard §8.6)
- [ ] Every screen opened in `en`, `ml` and `sa` on a clean device — no missing glyphs, overflow or clipping
- [ ] In-app language picker works: System default + each language by its own name, saved, applied without restart
- [ ] `bundle.language.enableSplit = false` in Gradle so Play users get every language (standard §8.1)
- [ ] Date pickers and dialogs verified under `sa` (fallback delegate, standard §8.3.1)
- [ ] Every icon-only control has a localized tooltip (standard §7.8)
- [ ] About screen ends with the localized "Made with {heart} in India" badge (`docs/guidelines/guideline.md` §1.7)

### Store Readiness (Every Declared Channel)

- [ ] `docs/guidelines/platform_store_readiness.md` §1 (every store) passes
- [ ] Google Play: §2 gate — target API re-checked, `versionCode` increased, App Bundle + Play App
      Signing, Data safety form, privacy policy URL live, listings in `en-US` and `ml-IN`,
      screenshots, internal testing and pre-launch report clean, staged rollout planned
- [ ] Direct APK: §2.5A — signed with the release keystore; Android developer verification checked
- [ ] Split APK `versionCode` equals the `pubspec.yaml` build number (no 1000/2000/4000 added),
      same as the `.aab` (§9, §12)

### Product And Documentation

- [ ] Version in `pubspec.yaml` updated
- [ ] Release notes or changelog updated
- [ ] User-visible behavior changes documented
- [ ] Store metadata ready

### Artifact Validation

- [ ] Intended prod artifact built successfully
- [ ] Artifact installs on a clean device, emulator or VM
- [ ] App launches with the correct prod name and no dev banner
- [ ] Version name and build number are correct
- [ ] QR scan, account creation, unlock, backup/restore and Wi-Fi sync smoke tests completed
- [ ] Release build tested end-to-end (not just a debug build)

---

## 9. Android Release Steps

1. Verify the working tree is clean enough for release work.
2. Confirm the version in `pubspec.yaml` and increase `+BUILD`.
3. Fetch dependencies with `flutter pub get`.
4. Run formatting, analysis, and tests.
5. Optional: run the size-analysis build first (§6.3).
6. Build the prod artifacts with `tool\build_release.ps1` (below) and record their sizes.
7. Run the manifest checks (§6.4, §6.5, §6.7) and the asset audit (§6.6).
8. Install a split APK on a clean device or emulator and run the smoke checklist.
9. Archive both symbol folders, AAB and APK (§6.1).
10. Google Play: complete the §2 gate, upload the `.aab`, and use a staged rollout.
    Direct APK: publish the signed split APKs, each with its `.sha256` file.
11. Tag the release commit: `git tag vX.Y.Z` and push.
12. Run `android\gradlew --stop` and end any leftover `GradleDaemon` / `KotlinCompileDaemon`.

### Android Build Commands

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# App Bundle for Google Play
.\tool\build_release.ps1 -Name SreerajP_Authenticator -Target aab

# Split APKs for direct distribution
.\tool\build_release.ps1 -Name SreerajP_Authenticator -Target apk
```

### Release Build Script (`tool/build_release.ps1`)

Use this script for every Android build you keep or publish. It runs `flutter build`, gives the
files proper names, deletes the weak SHA-1 file (`.sha1`) Flutter writes next to each APK, and
writes a SHA-256 checksum file (`.sha256`) for each APK and AAB. It works in Windows PowerShell
5.1 and PowerShell 7, writes only inside `build/`, and never reads `android/key.properties` or
the keystore (Gradle does the signing). At the end it runs `android\gradlew.bat --stop`.

Flutter writes `.sha1` after Gradle ends, and it has no SHA-256 option, so this cannot be done
in Gradle; it has to happen in a script that runs after `flutter build`.

| Option | Values | Default |
|--------|--------|---------|
| `-Name` | Base file name, letters, digits, `.`, `_`, `-` | Required (no default) |
| `-Target` | `apk`, `aab` | Required |
| `-Flavor` | `prod`, `dev` | `prod` |
| `-Mode` | `release`, `profile`, `debug` | `release` |
| `-NoSplit` | Switch: one universal APK, without `--split-per-abi` | Off |
| `-NoObfuscate` | Switch: leave out `--obfuscate` and `--split-debug-info` | Off |
| `-SymbolsDir` | Folder for `--split-debug-info`, inside `build/` | AAB: `build/symbols/android-<flavor>-<version>/`; APK: `build/symbols/android-<flavor>-<version>-apk/` |

`<version>` is the full `pubspec.yaml` version (`x.y.z+n`). The script stops if the `+n` build
number is missing.

Rules (checked before Flutter runs; a refused build exits with code 1):

- `-NoObfuscate` is refused for `-Flavor prod -Mode release`. A prod release is always obfuscated.
- `-SymbolsDir` is refused when the build is not obfuscated (`-NoObfuscate` or `-Mode debug`),
  and when it points outside `build/`.
- `-Mode debug` leaves out `--obfuscate` and `--split-debug-info` by itself, with a message.
- `-NoSplit` with `-Target aab` is ignored, with a message.
- If `flutter build` fails, nothing is renamed or hashed.
- Old Flutter-named outputs are deleted before the build, so a stale file is never renamed as
  this build. A file with the final name is replaced, with a message.

Examples:

```powershell
# Prod App Bundle for Google Play
.\tool\build_release.ps1 -Name SreerajP_Authenticator -Target aab

# Prod split APKs for direct download
.\tool\build_release.ps1 -Name SreerajP_Authenticator -Target apk

# One universal prod APK
.\tool\build_release.ps1 -Name SreerajP_Authenticator -Target apk -NoSplit

# Dev debug APKs for testing
.\tool\build_release.ps1 -Name SreerajP_Authenticator -Target apk -Flavor dev -Mode debug
```

File names: `<Name>-[<abi>-]v<x.y.z>_<n>-<flavor>-<mode>.<apk|aab>`, with short ABI names
`armeabi` (`armeabi-v7a`), `arm64` (`arm64-v8a`) and `x86_64`. For version `2.10.6+34`:

| Build | Folder | Files |
|-------|--------|-------|
| AAB | `build/app/outputs/bundle/prodRelease/` | `SreerajP_Authenticator-v2.10.6_34-prod-release.aab` |
| Split APKs | `build/app/outputs/flutter-apk/` | `SreerajP_Authenticator-armeabi-v2.10.6_34-prod-release.apk`, `SreerajP_Authenticator-arm64-v2.10.6_34-prod-release.apk`, `SreerajP_Authenticator-x86_64-v2.10.6_34-prod-release.apk` |
| Universal APK | `build/app/outputs/flutter-apk/` | `SreerajP_Authenticator-v2.10.6_34-prod-release.apk` |

Each file has a `<file>.sha256` next to it, in the standard `sha256sum` format:
`<lower-case hash>  <file name>` (two spaces, UTF-8 without BOM, one line). Publish it with the
file. To check a file:

```powershell
Get-FileHash <file> -Algorithm SHA256
```

```bash
sha256sum -c <file>.sha256
```

`Get-FileHash` prints the hash in upper case; compare it with the `.sha256` file ignoring case.

What the script runs with the defaults (for reference; prefer the script):

```powershell
# -Target apk
flutter build apk --flavor prod --release --obfuscate `
  --split-debug-info=build/symbols/android-prod-<version>-apk/ --split-per-abi

# -Target aab
flutter build appbundle --flavor prod --release --obfuscate `
  --split-debug-info=build/symbols/android-prod-<version>/
```

```bash
# bash / zsh
flutter build apk --flavor prod --release --obfuscate \
  --split-debug-info=build/symbols/android-prod-<version>-apk/ --split-per-abi
flutter build appbundle --flavor prod --release --obfuscate \
  --split-debug-info=build/symbols/android-prod-<version>/
```

Run by hand, these leave Flutter's names and `.sha1` files; rename and hash the files yourself.

**Split APK version code.** `android/gradle.properties` sets
`force-version-code-ignoring-abi=true`. So every split APK (`armeabi-v7a`, `arm64-v8a`,
`x86_64`) gets the same `versionCode` as the App Bundle: the `+BUILD` number from `pubspec.yaml`,
with no 1000/2000/4000 added. Check each APK after the build (Android SDK build-tools):

```powershell
aapt2 dump badging build\app\outputs\flutter-apk\SreerajP_Authenticator-arm64-v<x.y.z>_<n>-prod-release.apk
```

The first line shows `versionCode` and `versionName`. All split APKs and the `.aab` must show the
same values. (The `.aab` manifest is protobuf; read it with `bundletool` or a small script, not
`aapt2`.)

---

## 10. iOS Release Steps

Not a declared platform. Not used.

---

## 11. Windows Release Steps

Not a declared platform. Not used.

---

## 11A. macOS Release Steps

Not a declared platform. Not used.

---

## 11B. Linux Release Steps

Not a declared platform. Not used.

---

## 11C. Web Release Steps

Not a declared platform. Not used.

---

## 12. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Google Play | `.aab` | Public | Staged rollout; gate §2. Not yet released |
| Direct APK | split `.apk` | Public / testers | Signed with the release keystore; gate §2.5A |

**Why split APKs share the bundle's `versionCode`.** By default Flutter adds 1000, 2000 or 4000
to the build number of each split APK, but not to the App Bundle. A phone with a direct APK
(for example `+34` → `1034`) would then see every Play build (`+37` → `37`) as older, and Play
would never update it. The only way out would be to uninstall, which deletes the vault
(`android:allowBackup="false"`). `force-version-code-ignoring-abi=true` in
`android/gradle.properties` removes the offset, so a direct APK user can move to Play builds.
Play can update a direct APK only when Play's app signing key matches the release keystore.

---

## 13. Rollback And Hotfix Process

- Rollback trigger: release-blocking crash, broken lock flow, bad migration, data loss in
  backup/import/sync, or incorrect signing/build config
- Rollback method: halt the Play staged rollout; stop distributing the bad APK; ship a hotfix
  build from a fixed commit (Play cannot install a lower `versionCode`)
- Hotfix branch naming: use `main` unless a temporary `hotfix/vX.Y.Z` branch is needed
- Verification after rollback or hotfix:
  - The full release checklist MUST be completed even for hotfixes
  - Debug symbols for the hotfix build MUST be archived

---

## 14. Release Evidence

Record these for each accepted release:

- Git commit SHA and tag
- `pubspec.yaml` version
- CI run identifier
- Test and analyzer results
- Size analysis output and artifact sizes
- Artifact file names
- Debug symbols archive location
- Release notes location
- Play Console rollout record / direct APK publish record
- OWASP checklist sign-off ([`security.md`](security.md) §12): signed by / date

---

## 15. Post-Release Checks

- [ ] Install and launch verified from the final distributed artifact on a clean device
- [ ] No immediate crashes or lock-screen regressions observed (offline app: no crash reporting,
      so test by hand)
- [ ] User-reported issues triaged
- [ ] Release tag created and pushed: `git tag vX.Y.Z && git push origin vX.Y.Z`
- [ ] Symbol archive confirmed present
- [ ] Follow-up bugs or hardening tasks recorded

## Accessibility Checks Before Each Release

The tests in `test/accessibility/` cover tap targets, labels, contrast and text scaling, but only for what
is on screen in a test. A person must check the rest (engineering standard §7.5 to §7.7) and record the
result for the release:

- [ ] TalkBack on Android: unlock, add an account, copy a code, get an HOTP code, create a backup, and an
      error message. Each control is named, and a hidden code is never read out.
- [ ] Text at 2x on a real phone: no clipped text, in English, Malayalam and Sanskrit.
- [ ] Camera screens (QR scanner, optical receive), which the tests cannot open.
