---
type: Security
id: wiki-security-supply-chain-controls
title: Supply-chain Controls
description: "What controls what enters the repository and builds: pinned actions, workflow token scopes, a checksummed word source, and where signing secrets are planned to live."
tags: [security, supply-chain, ci, secrets]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: ci-permissions
    resource: repo://.github/workflows/ci.yml#L117-L118
    title: CI token scope
    last_modified: 2026-11-01
  - id: approve-permissions
    resource: repo://.github/workflows/okf-approve.yml#L2-L6
    title: okf-approve token scope
    last_modified: 2026-10-31
  - id: ci-pins
    resource: repo://.github/workflows/ci.yml#L9-L14
    title: Actions pinned by SHA
    last_modified: 2026-11-01
  - id: dependabot
    resource: repo://.github/dependabot.yml
    title: Dependabot
    last_modified: 2026-11-01
  - id: scowl-pin
    resource: repo://tool/check_word_data_rebuild.py#L18-L19
    title: Pinned SCOWL archive digest
    last_modified: 2026-11-01
  - id: scowl-extract
    resource: repo://tool/check_word_data_rebuild.py#L42-L48
    title: Checking and unpacking the archive
    last_modified: 2026-11-01
  - id: plan-diawi
    resource: repo://specs/feature-word9-flutter-app-plan.md#L115-L118
    title: Plan, Diawi secrets
    last_modified: 2026-10-31
  - id: signing-commit
    resource: https://github.com/opichon/word9/commit/44dbbe9
    title: "feat: sign android release builds with an upload key (unmerged)"
---

[Home](../../index.md) › [Security](index.md) › Supply-chain Controls

# Supply-chain Controls

The repository is public, and the app holds no user data, so what matters is the integrity of what goes into a build.

## Current controls

| Control | Mechanism |
| ------- | --------- |
| Third-party Actions | Pinned to a full commit SHA, kept current by Dependabot[^ci-pins][^dependabot] |
| Workflow tokens | `contents: read` by default. `okf-approve` alone has `contents: write`, for its merge commit[^ci-permissions][^approve-permissions] |
| Word source | The rebuild refuses an archive whose SHA-256 differs, and unpacks with `filter='data'`[^scowl-pin][^scowl-extract] |
| Word data in the app | Checked against stored digests on every PR, so a data change is visible: see [Word data flow](../architecture/word-data-flow.md) |
| Run-time dependencies | None beyond Flutter |

## Secrets

**No workflow on `main` reads a secret today**, and no signing material is in the repository.

The plan is for signing keys and a Diawi token to go into GitHub secrets, used only by the workflow on `main` and never on pull requests.[^plan-diawi] The unmerged step 8 branch keeps the Android key's details in an uncommitted `android/key.properties` file.[^signing-commit] Treat any step that adds a secret to a PR-triggered workflow as breaking this rule.

[^ci-pins]: `actions/checkout@3d3c42e... # v7.0.1`.
[^dependabot]: Weekly, for `github-actions` and `pub`.
[^ci-permissions]: `permissions: contents: read`.
[^approve-permissions]: `contents: write`, `pull-requests: read`.
[^scowl-pin]: `SCOWL_SHA256`.
[^scowl-extract]: `tar.extractall(temp, filter='data')`.
[^plan-diawi]: "Secrets are only used by the `main` workflow, never on pull requests."
[^signing-commit]: "The key is kept out of the repo."
