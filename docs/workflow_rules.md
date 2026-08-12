# Workflow Rules — SreerajP Authenticator

This document describes the mandatory plan-before-changing, explicit user approval gate, and log-after-changing workflow rules for SreerajP Authenticator.

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
