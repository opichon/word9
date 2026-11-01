---
type: Troubleshooting
id: wiki-troubleshooting-merged-pr-missing-from-main
title: A Merged PR Is Missing from Main
description: "A PR shows as merged, but its commits never reached main, because its stacked base branch had already been merged: how it happened with step 3, and how to fix it."
tags: [troubleshooting, git, process, stacked-prs]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: pr-18
    resource: https://github.com/opichon/word9/pull/18
    title: "PR #18, land step 3, word data, on main"
  - id: pr-9
    resource: https://github.com/opichon/word9/pull/9
    title: "PR #9, step 3"
  - id: pr-7
    resource: https://github.com/opichon/word9/pull/7
    title: "PR #7, step 1"
---

[Home](../../index.md) › [Troubleshooting](index.md) › A Merged PR Is Missing from Main

# A Merged PR Is Missing from Main

## Symptom

GitHub shows a pull request as merged, but its commits are not on `main`. Later work fails to find what it delivered.

## Cause

The PR's base was another feature branch, and that branch had **already** been merged into `main`. Merging into it then moves only the feature branch.

This happened on 2026-11-01. PR #9 (step 3) was based on `feat/step-1-app-shell`,[^pr-9] and merged about two minutes after that branch had gone into `main` through #7.[^pr-7] So step 3's word data was on no path to `main`.[^pr-18]

## Fix

Open a new PR from the old base branch to `main`. It adds no new work, since the commits were already reviewed. PR #18 did this.[^pr-18]

## How to avoid it

When merging a stack, merge from the bottom up, and confirm each PR's base is `main` first. GitHub retargets a PR when its base branch is deleted on merge. Keeping the merged branch around leaves the stacked PR pointing at it, without warning.

## How to check

```sh
git branch -r --contains <commit-of-the-pr> | grep origin/main
```

No output means the commit is not on `main`.

## Inference on this page

The dates and bases come from the PRs. The avoidance advice and the note on retargeting are general knowledge of GitHub, not something recorded here.

[^pr-9]: Base `feat/step-1-app-shell`, merged at 2026-11-01T11:49:50Z.
[^pr-7]: Base `main`, merged at 2026-11-01T11:48:06Z.
[^pr-18]: "PR #9 ... merged into `feat/step-1-app-shell` after that branch had already merged into `main` through #7, so step 3 never reached `main`. This PR brings it across. It adds no new work."
