---
type: Convention
id: wiki-conventions-spec-driven-delivery
title: Spec-driven Delivery
description: "How work moves from spec to pull request here: the four specs documents, plan steps as branches, test ids in test names, and what to do when the plan is wrong."
tags: [convention, process, specs, git]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: specs-index
    resource: repo://specs/index.md
    title: Specs index
    last_modified: 2026-11-02
  - id: plan-constraint
    resource: repo://specs/feature-word9-flutter-app-plan.md#L49-L49
    title: Plan, constraint
    last_modified: 2026-10-31
  - id: plan-ownership
    resource: repo://specs/feature-word9-flutter-app-plan.md#L247-L247
    title: Plan, who takes which steps
    last_modified: 2026-10-31
  - id: pr-13
    resource: https://github.com/opichon/word9/pull/13
    title: "PR #13, step 7"
  - id: commit-step-3
    resource: https://github.com/opichon/word9/commit/c3fe449
    title: "feat: build word data from scowl and bundle it"
  - id: test-names
    resource: repo://test/unit/word_rules_test.dart#L25-L25
    title: A test group named by its id
    last_modified: 2026-11-01
  - id: test-plan-refs
    resource: repo://specs/feature-word9-flutter-app-test-plan.md#L57-L59
    title: Test plan, spec references
    last_modified: 2026-10-31
---

[Home](../../index.md) › [Conventions](index.md) › Spec-driven Delivery

# Spec-driven Delivery

Nothing here is enforced by tooling; all of it is observed from the history of PRs #1 to #20.

## The documents in specs

| Document | Answers | Written |
| -------- | ------- | ------- |
| Spec | What word9 must do | First |
| Test plan | What proves it, by id | Second |
| Implementation plan and ADR | In what steps, and why these choices | Third |
| Design | How the sub-systems work together | After step 7 |

These are the target, not a record of the code: see [Built versus planned](../architecture/built-versus-planned.md). They form their own AI-XF bundle, separate from `knowledge/`.[^specs-index]

## Steps become pull requests

- A plan step is one PR on a branch named `feat/step-<n>-<topic>`, titled `feat: step <n>, ...`.
- The commit says which step it delivers and which tests it brings: "Delivers step 3 of the implementation plan: IT-1 and IT-2".[^commit-step-3]
- The plan's constraint is that the test plan's tests pass at the end of the last step.[^plan-constraint]
- Steps needing the owner's accounts or reviews (8, 21, 23) wait for the owner.[^plan-ownership] A PR that can only partly deliver one stays a draft: see #14.

## Tests carry their ids

Test names start with the test plan's id, such as `UT-1: word validation`.[^test-names] So a failure names the spec item at risk, through the coverage table in the test plan.[^test-plan-refs] Keep the id when adding or renaming a test that the plan names.

## When the plan is wrong

Say so in the PR rather than bending the code. PR #13 records that the plan lists steps 1, 3, 4 and 5 as dependencies of step 7, but the total needs step 6's `solve`, so it was stacked on step 6.[^pr-13]

Stacking has a trap: see [A merged PR is missing from main](../troubleshooting/merged-pr-missing-from-main.md).

## Related pages

- [Document workflows](../ci/document-workflows.md) covers how specs are validated and approved.

[^specs-index]: `specs/manifest.ai-xf.yaml` and `specs/index.md` make it a bundle.
[^commit-step-3]: The body of `c3fe449`.
[^plan-constraint]: "All the tests in the test plan pass at the end of the last step, apart from NF-1, NF-2 and NF-3 while they are Blocked".
[^plan-ownership]: "The owner takes the account steps (8, 21) and the review in step 23."
[^pr-13]: "The plan lists steps 1, 3, 4 and 5 as dependencies, but the total needs step 6's `solve`, so this stacks on step 6."
[^test-names]: `group('UT-1: word validation', ...)`.
[^test-plan-refs]: Section 3 of the test plan numbers the spec items.
