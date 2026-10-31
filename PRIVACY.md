# Privacy Policy — Sreeraj P Authenticator

**Last updated:** 31 October 2026

Sreeraj P Authenticator is a two-factor authentication app for Android, made by Sreeraj P. It works
offline. This policy explains what happens to your data when you use it.

## The short version

- Your data stays on your device.
- The developer cannot see your data. The app has no server and no user accounts.
- The app has no analytics, no ads, no crash reporting and no tracking.
- Nothing is collected, sold or shared with anyone.

## Data the app stores on your device

| Data | Where it is kept | How it is protected |
|---|---|---|
| Account names, issuers, tags and notes | App database | Private to the app; account secrets are encrypted |
| Account secrets (the keys that make your codes) | App database | Encrypted with AES-256-GCM |
| Master encryption key | Android secure storage | Backed by the Android Keystore |
| App PIN and recovery key | Android secure storage | Only a one-way hash is stored, never the PIN or key itself |
| Settings, such as theme, language and lock options | App preferences | Private to the app; holds no secrets |

Android's own cloud backup and device transfer are turned off for this app, so this data is not
copied to them.

## When data leaves your device

Data leaves your device only when you start one of these actions yourself. Each one is encrypted.

- **Wi-Fi sync:** sends your accounts, and if you choose, a few settings, directly to another device on your local network. It does not
  go through the internet or any server.
- **Optical sync:** shows your data as encrypted QR codes for another device's camera to read. It uses
  no network.
- **Backup export:** creates a password-encrypted file and opens the Android share sheet. You choose
  where it goes. If you send it to another app or service, that service's own privacy policy applies.

Keep backup files and their passwords safe. The developer cannot recover them.

## Permissions

| Permission | Why it is needed |
|---|---|
| Camera | To scan QR codes. Images are read on the device and are not saved or sent anywhere |
| Biometric / fingerprint | To unlock the app, if you turn this on. Android handles the check; the app never receives your fingerprint or face data |
| Vibrate | For short touch feedback |
| Internet | Only to open a connection to your other device on your local network for Wi-Fi sync. The app does not contact any internet service |

Backup files are chosen with the Android file picker, so the app needs no storage permission.

When you tap a website or email link on the About screen, your browser or mail app opens. Their own
privacy policies apply.

## Clipboard

When you copy a code or key, it goes to the Android clipboard, marked as sensitive. The app clears it
after a time limit (30 or 60 seconds). If the app is closed by force first, this may not happen.

## How long data is kept, and how to delete it

Data is kept until you delete it. You can:

- delete one account in the app;
- delete everything in the app, from **Settings → Security → Delete all data**;
- uninstall the app, which removes its data from the device.

The developer holds no copy of your data, so there is nothing else to delete. Backup files you saved
elsewhere are not removed by these steps; delete those yourself.

## Children

The app does not collect personal data from anyone, including children.

## Changes to this policy

If this policy changes, the new version will be published at this same address, with a new date at
the top.

## Contact

Questions: Sreeraj P, sreerajp@zohomail.in
