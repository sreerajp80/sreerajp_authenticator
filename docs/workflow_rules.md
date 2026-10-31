# Workflow Rules — Sreeraj P Authenticator

This document describes the mandatory plan-before-changing, explicit user approval gate, and log-after-changing workflow rules for Sreeraj P Authenticator.

[Read first: AGENTS.md](../AGENTS.md) | [CLAUDE.md](../CLAUDE.md) | [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) | [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md)

---

## 1. Overview

Every non-trivial modification to this repository follows a two-phase workflow: plan-before-changing and log-after-changing. This workflow applies to all developers and automated agents working on the codebase.

---

## 2. Plan Before Changing

Before editing, creating, or deleting any project code file (other than the plan itself):

1. Create a detailed plan document in `plans/`.
2. File naming format: `yyyymmdd_hhMMss_<short-slug>.md`.
3. Include a `**Status:**` line at the top.
4. Detail the background, scope, exact files to modify/add/delete, and proposed fix.
5. A plan that touches network, storage, sign-in, permissions, deep links, WebViews, platform
   folders or dependencies has a short **"Security impact"** line (engineering standard §22.2).
6. Keep the `**Status:**` line current: `draft` → `approval_pending` → `in_progress` →
   `completed` (or `dropped` / `partial_completion`).

---

## 3. Explicit Approval Gate

- Once the plan is written, **STOP**.
- Request explicit approval from the user or project lead.
- A question, partial comment, or ambiguous reply does NOT constitute approval.
- No source code edits or file system modifications (outside `plans/`) may occur until explicit approval is granted.

---

## 4. Log After Changing

After completing implementation and verifying changes:

1. Create a change log document in `change_log/`.
2. File naming format: `yyyymmdd_hhMMss_<short-slug>.md`.
3. Reference the original plan in `plans/`.
4. Detail the actual changes made, tests run, and verification results achieved.

---

## 5. Relative Paths And Privacy

`plans/` and `change_log/` files are committed and may become public. They use relative
repository paths only and contain no local system details (user names, machine names, drive
letters, LAN addresses, local URLs, device serials, personal emails) and no secrets
(engineering standard §21.1.1).

---

## 6. The Guidelines Submodule Is Read-Only

`docs/guidelines/` is read-only for this project. Never edit, pull, check out or commit the
submodule or its version from here. Only the project owner updates its version. If a guideline
needs a change, write a note for the owner instead (`guidelines/DOCS_FOLDER_GUIDELINE.md` §1.1).
If the folder is empty or missing, stop and ask.

---

## 7. CI Is Checks Only

GitHub CI runs only `flutter pub get`, the format check, `flutter analyze`, `flutter test`, and
other pass/fail check scripts. No Dependabot or other update bot: dependencies are updated by
hand. CI never builds release artifacts, signs, holds signing secrets, uploads, or publishes.
Release builds are done locally (engineering standard §19).
