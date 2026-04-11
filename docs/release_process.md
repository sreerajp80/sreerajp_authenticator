# Release Process

This repository is Android-first. The app includes iOS and Windows runners, but the current
tracked release process is centered on Android builds and Android validation.

---

## 1. Release Scope

- App: `Sreeraj P Authenticator`
- Current release profile: `internal`
- Supported tracked release platform:
  - `Android`
- Repository version source of truth:
  - [`pubspec.yaml`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/pubspec.yaml)
- Current app version:
  - `2.4.0+1`

---

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Coordinates readiness, builds artifacts, and signs off | `Sreeraj P` |
| Engineering | Code changes, regression fixes, and release validation | `Sreeraj P` |
| QA | Manual smoke and regression verification | `Sreeraj P` |
| Distribution owner | Handles signed APK/AAB distribution | `Sreeraj P` |

---

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD`
- Source of truth: `pubspec.yaml`
- Build-number increment rule: increment `+BUILD` for every distributable Android release build
- Git tag format: `vX.Y.Z`

---

## 4. Branch And Merge Policy

- Release branch strategy: `main only`
- Hotfix strategy: patch `main`, rebuild the prod artifact, and tag a new version
- Required checks before merge:
  - `flutter analyze`
  - `flutter test`
  - Manual Android smoke validation for changed flows
  - Review of permissions and security-sensitive changes when applicable

---

## 5. Environment And Flavor Matrix

| Flavor | Mode | Purpose | Example Command |
|--------|------|---------|-----------------|
| `dev` | `debug` | Local development | `flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev` |
| `dev` | `release` | Release-like manual QA | `flutter build apk --flavor dev --release --dart-define=FLUTTER_APP_FLAVOR=dev` |
| `prod` | `release` | Signed release artifact | See section 9 |

Notes:

- Android flavors are defined in [`android/app/build.gradle.kts`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/android/app/build.gradle.kts).
- `prod` has the release app name and base application ID.
- `dev` adds `.dev` to the application ID and appends `-dev` to the version name.

---

## 6. Release Build Hardening

All production builds should be treated as security-sensitive artifacts.

### 6.1 Dart Obfuscation And Symbols

Production builds should include:

```powershell
--obfuscate
--split-debug-info=build/symbols/android-prod-2.4.0+1/
```

When the version changes, update the symbol directory to match the current `pubspec.yaml` version.

### 6.2 Android Shrinking And ProGuard / R8

Current Android release configuration in
[`android/app/build.gradle.kts`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/android/app/build.gradle.kts):

- `isMinifyEnabled = true`
- `isShrinkResources = true`
- Uses `proguard-android-optimize.txt`
- Includes [`android/app/proguard-rules.pro`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/android/app/proguard-rules.pro)

Current caution:

- The checked-in ProGuard rules file is intentionally minimal and currently includes
  `-dontobfuscate`.
- Revalidate `proguard-rules.pro` whenever adding plugins that rely on reflection or release-only
  code paths.

### 6.3 Debuggable Verification

Before distributing a prod artifact, verify the merged release manifest does not mark the app
debuggable.

---

## 7. Signing And Secret Handling

- Signing config location: local `android/key.properties` file outside source control, based on
  [`android/key.properties.example`](/l:/Android/SreerajP_Authenticator/sreerajp_authenticator/android/key.properties.example)
- Keystore ownership: `Sreeraj P`
- Secret rotation process:
  - Replace keystore material in the secure owner-controlled location
  - Update local signing configuration
  - Rebuild and validate a signed prod artifact
- Rules:
  - Never commit keystore files or passwords
  - Never print signing secrets in logs
  - Keep at least two secure backups of release signing material

---

## 8. Release Checklist

Complete these items before every release.

### Code And Quality

- [ ] `dart format --output=none --set-exit-if-changed .` passed
- [ ] `flutter analyze` passed
- [ ] `flutter test` passed
- [ ] Manual smoke test completed on the changed flows
- [ ] No known release-blocking defects remain

### Security

- [ ] Production build uses `--obfuscate`
- [ ] Production build uses `--split-debug-info`
- [ ] Debug-symbol archive stored securely
- [ ] Android merged release manifest reviewed for permissions
- [ ] `android:debuggable=false` verified in the release manifest
- [ ] Backup, lock, and secret-storage flows rechecked for changed code

### Product And Documentation

- [ ] Version in `pubspec.yaml` is correct
- [ ] Release notes or changelog updated
- [ ] Any user-visible behavior change is documented

### Artifact Validation

- [ ] Intended prod artifact built successfully
- [ ] Artifact installs on a clean device or emulator
- [ ] App launches with the correct prod name and no dev banner
- [ ] Version name and build number are correct
- [ ] QR scan, account creation, unlock, and backup/restore smoke tests completed

---

## 9. Android Release Steps

1. Verify the working tree is clean enough for release work.
2. Confirm the version in `pubspec.yaml`.
3. Fetch dependencies with `flutter pub get`.
4. Run formatting, analysis, and tests.
5. Build the prod artifact with release hardening flags.
6. Install the artifact on a clean device or emulator and run the smoke checklist.
7. Archive the symbol directory.
8. Distribute the APK or AAB through the intended internal channel.
9. Tag the release commit if the build is accepted.

### Android Build Commands

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# Split APKs for direct internal distribution
flutter build apk `
  --flavor prod `
  --release `
  --dart-define=FLUTTER_APP_FLAVOR=prod `
  --obfuscate `
  --split-debug-info=build/symbols/android-prod-2.4.0+1/ `
  --split-per-abi

# App Bundle if Play-style distribution is needed
flutter build appbundle `
  --flavor prod `
  --release `
  --dart-define=FLUTTER_APP_FLAVOR=prod `
  --obfuscate `
  --split-debug-info=build/symbols/android-prod-2.4.0+1/

# Optional size analysis
flutter build apk `
  --flavor prod `
  --release `
  --dart-define=FLUTTER_APP_FLAVOR=prod `
  --analyze-size
```

---

## 10. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Internal Android QA | `APK` | Developer / internal testers | Usually `prod` split APKs installed directly |
| Android store-style packaging | `AAB` | Future external or store distribution | Build on demand; validate signing and symbols first |

---

## 11. Rollback And Hotfix Process

- Rollback trigger: release-blocking crash, broken lock flow, bad migration, or incorrect signing/build config
- Rollback method: stop distribution of the bad artifact and ship a new prod build from a fixed commit
- Hotfix branch naming: use `main` unless a temporary release branch is created for coordination
- Verification after rollback or hotfix:
  - Run the full Android release checklist again
  - Archive symbols for the replacement build

---

## 12. Release Evidence

Store or record the following for each accepted release:

- Git commit SHA
- `pubspec.yaml` version
- Test run result
- Analyzer result
- Artifact filename
- Symbol archive location
- Release notes location
- Distribution record or recipient list

---

## 13. Post-Release Checks

- [ ] Install and launch verified from the final distributed artifact
- [ ] No immediate crashes or lock-screen regressions observed
- [ ] Symbol archive confirmed present
- [ ] Release tag created if applicable
- [ ] Follow-up bugs or hardening tasks recorded

---

## 14. Platforms Not Yet Tracked Here

- `iOS`: runner exists, but a full signing, archive, and distribution process is not yet documented
  in this repository
- `Windows`: runner exists, but a Windows packaging and release process is not yet documented in
  this repository
