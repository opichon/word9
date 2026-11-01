---
type: CI
id: wiki-ci-document-workflows
title: Document Workflows
description: "okf-validate, okf-approve and kb-catalog: how specs and knowledge pages are checked and approved, the bot commit they add to main, and what their rules files cover."
tags: [ci, okf, specs, knowledge]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: validate-rules
    resource: repo://.github/okf-validate.yml
    title: okf-validate rules
    last_modified: 2026-10-31
  - id: approve-rules
    resource: repo://.github/okf-approve.yml
    title: okf-approve rules
    last_modified: 2026-11-02
  - id: approve-workflow
    resource: repo://.github/okf-approve.yml#L3-L7
    title: The knowledge rule
    last_modified: 2026-11-02
  - id: approve-job
    resource: repo://.github/workflows/okf-approve.yml#L2-L15
    title: okf-approve workflow
    last_modified: 2026-10-31
  - id: catalog-workflow
    resource: repo://.github/workflows/kb-catalog.yml#L9-L33
    title: kb-catalog check
    last_modified: 2026-11-02
  - id: okf-actions
    resource: https://github.com/dzangolab/okf-actions/tree/main/approve#rules
    title: okf-actions approve documentation
  - id: okf-actions-validate
    resource: https://github.com/dzangolab/okf-actions/tree/main/validate#rules
    title: okf-actions validate documentation
  - id: approval-commit
    resource: https://github.com/opichon/word9/commit/0dca297
    title: "docs: record the approval of OKF documents merged in #20"
stale_after: 2027-05-02
---

[Home](../../index.md) › [CI](index.md) › Document Workflows

# Document Workflows

Three workflows treat markdown as checked artifacts. They cover two separate bundles: `specs/` and `knowledge/`.

## Workflows and what they do

| Workflow | On | Does |
| -------- | -- | ---- |
| `okf-validate` | PR, push to `main` | Checks frontmatter and structure of the files its rules match[^validate-rules] |
| `okf-approve` | PR opened, updated, merged | Reports what will happen; on merge, sets `status` and `verified`[^approve-job] |
| `kb-catalog` | PR touching `knowledge/` or the repokb scripts | Fails if `knowledge/.catalog.sqlite` does not match the merged pages[^catalog-workflow] |

## A bot commits to main after a merge

On merge, `okf-approve` commits to the base branch as `github-actions[bot]`, and adds a line to the nearest `log.md`.[^okf-actions] That is why `git log` on `main` shows "docs: record the approval of OKF documents merged in #20", with no PR of its own.[^approval-commit] So **pull before branching after a docs merge**, or `specs/log.md` conflicts. It also explains why this workflow alone has `contents: write`.

## What the rules files cover today

Files that no rule matches are left alone, so the rules files decide everything.

| Path | Validated | Approval |
| ---- | --------- | -------- |
| `specs/**` | AI-XF 0.5[^validate-rules] | **No rule** in `.github/okf-approve.yml`[^approve-rules] |
| `knowledge/wiki/**`, `knowledge/_sources/**` | **No rule**[^validate-rules][^okf-actions-validate] | `verify: [owners]`, stable on verification[^approve-workflow] |

Three consequences as of 2026-11-02:

- **`specs/` may have stopped being approved.** Up to PR #20 no rules file existed, so the action's defaults applied, which is how specs were marked stable on merge. The defaults apply only "without a rules file", and documents no rule matches are left alone.[^okf-actions] So the file added with the knowledge base appears to end that for `specs/`. This is read from the action's documentation and has not been observed in a run.
- **`knowledge/` is not validated in CI**, although its contract says it is, because `.github/okf-validate.yml` has only the `specs/**` rule.
- **Knowledge pages cannot become stable through this action yet.** `verify: [owners]` reads the rule's `owners`, else `CODEOWNERS`. There is neither, so nobody qualifies and pages stay `draft`, with a warning in the run.[^okf-actions]

## Fixing a catalog failure

Never pick a side on the binary. Merge or rebase on `main`, run `python3 .claude/skills/repokb/scripts/catalog.py knowledge`, and commit the result.[^catalog-workflow]

## Related pages

- [Spec-driven delivery](../conventions/spec-driven-delivery.md) explains what the specs are.

[^validate-rules]: One rule: `paths: [specs/**]`, `spec: ai-xf`, `version: "0.5"`.
[^approve-rules]: The file has one rule, for `knowledge/wiki/**` and `knowledge/_sources/**`.
[^approve-job]: `types: [closed, opened, reopened, synchronize]`.
[^catalog-workflow]: `catalog.py --check knowledge/`, and the error message gives the fix.
[^okf-actions]: Read from the action's README on 2026-11-02, for the rules defaults, `owners`, and the commit to the base branch.
[^approval-commit]: Commit `0dca297` sits directly on `main` after merge `d2a22df`.
[^approve-workflow]: `verify: [owners]`, `stable: on-verify`. The file's comment states the intent.
[^okf-actions-validate]: "files no rule matches aren't validated".
