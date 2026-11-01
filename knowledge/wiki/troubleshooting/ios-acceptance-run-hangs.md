---
type: Troubleshooting
id: wiki-troubleshooting-ios-acceptance-run-hangs
title: iOS Acceptance Run Hangs
description: "The iOS acceptance job sometimes hangs on the CI simulator: the workaround in place, how to read its warnings, and what is still unknown."
tags: [troubleshooting, ci, ios, flaky]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: ci-retry
    resource: repo://.github/workflows/ci.yml#L72-L82
    title: iOS acceptance retry
    last_modified: 2026-11-01
  - id: commit
    resource: https://github.com/opichon/word9/commit/ffd2fcd
    title: "ci: limit acceptance test time and retry hung ios runs"
---

[Home](../../index.md) › [Troubleshooting](index.md) › iOS Acceptance Run Hangs

# iOS Acceptance Run Hangs

## Symptom

`ios-acceptance` runs for a very long time with no test output, or shows the warning `Acceptance tests failed or hung on attempt 1`.[^ci-retry]

## Cause

The workflow's own comment says "the test run sometimes hangs on the runner's simulator".[^ci-retry] **The root cause is not recorded** in the code or the commit.[^commit]

## Workaround in place

Each attempt is limited to 25 minutes (1,500 s), with `perl`'s `alarm` killing the process, and there is one retry. The job as a whole has 60 minutes.[^ci-retry]

## Reading the result

| Result | Means |
| ------ | ----- |
| Green, no warning | Passed first time |
| Green, one warning | Attempt 1 failed **or** hung. Look at its log, because the retry hides a real test failure too |
| Red, two warnings | Failed or hung twice. Re-run once. If a test failed, as opposed to a time-out, treat it as real |

The loop does not distinguish a hang from a test failure, so a genuinely flaky test passes as long as it passes once.

## Open questions

- What causes the hang, and does it still occur? The `macos-latest` image may have moved on since 2026-11-01. If the warning stops appearing, the retry could go.

## Related pages

- [Pull request checks](../ci/pull-request-checks.md) describes the job in context.

[^ci-retry]: The comment and the `for attempt in 1 2` loop in `ci.yml`.
[^commit]: `ffd2fcd` has no body beyond its title.
