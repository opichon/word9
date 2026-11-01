---
type: CI
id: wiki-ci-pull-request-checks
title: Pull Request Checks
description: "What runs on each pull request and push to main, how long it may take, and what is special about each job, including the iOS retry."
tags: [ci, github-actions, tests, builds]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: ci
    resource: repo://.github/workflows/ci.yml
    title: CI workflow
    last_modified: 2026-11-01
  - id: ci-concurrency
    resource: repo://.github/workflows/ci.yml#L1-L3
    title: CI concurrency
    last_modified: 2026-11-01
  - id: ci-triggers
    resource: repo://.github/workflows/ci.yml#L111-L115
    title: CI triggers
    last_modified: 2026-11-01
  - id: ci-retry
    resource: repo://.github/workflows/ci.yml#L72-L82
    title: iOS acceptance retry
    last_modified: 2026-11-01
  - id: word-data
    resource: repo://.github/workflows/word-data.yml
    title: Word data workflow
    last_modified: 2026-11-01
  - id: plan-checks
    resource: repo://specs/feature-word9-flutter-app-plan.md#L100-L109
    title: Plan, pull request checks decision
    last_modified: 2026-10-31
  - id: simulator-pick
    resource: repo://.github/workflows/ci.yml#L66-L71
    title: Picking a simulator
    last_modified: 2026-11-01
---

[Home](../../index.md) › [CI](index.md) › Pull Request Checks

# Pull Request Checks

The owner chose to run **all automated test levels on each PR**, including on an emulator and a simulator, accepting slower checks so that a failure cannot reach `main`.[^plan-checks]

## Jobs by workflow

All run on `pull_request` and on pushes to `main`,[^ci-triggers] except `rebuild`. The two workflows are `ci.yml`[^ci] and `word-data.yml`.[^word-data]

| Workflow | Job | Runner | Does | Limit |
| -------- | --- | ------ | ---- | ----- |
| CI | `test` | Ubuntu | `dart format` check, `flutter analyze`, `flutter test` | Default |
| CI | `android-build` | Ubuntu | Release APK, then NF-4: no `INTERNET` | Default |
| CI | `android-acceptance` | Ubuntu | `flutter test integration_test` on an API 34 emulator | 40 min |
| CI | `ios-build` | macOS | `flutter build ios --release --no-codesign` | Default |
| CI | `ios-acceptance` | macOS | `flutter test integration_test` on a simulator | 60 min |
| Word data | `contract` | Ubuntu | Python tests, contract check on both assets | Default |
| Word data | `rebuild` | Ubuntu | IT-1: **`workflow_dispatch` only** | Default |

Document checks are in [Document workflows](document-workflows.md).

## Things to know about these jobs

- **There is no `paths` filter on CI.** A docs-only PR still runs all five jobs, macOS included.[^ci-triggers]
- **Concurrency cancels by ref, on `main` too.** `cancel-in-progress` is set for every ref, so a second merge in quick succession cancels the CI of the first.[^ci-concurrency]
- **The iOS simulator is chosen at run time**: the first available iPhone on the newest iOS on the runner, so `macos-latest` image updates change it silently.[^simulator-pick]
- **`ios-acceptance` retries, and a pass on attempt 2 is green.** Each attempt is limited to 25 minutes, using `perl`'s `alarm`, and a failure on attempt 1 is only a warning.[^ci-retry] So a real intermittent failure can hide behind a green tick. Read the warnings: see [iOS acceptance run hangs](../troubleshooting/ios-acceptance-run-hangs.md).
- **The emulator job builds in debug**, so NF-4's permission check is only meaningful in `android-build`.

## Diagnosing a failure

| Failing step | Usually means | Reproduce with |
| ------------ | ------------- | -------------- |
| `dart format` | Unformatted Dart | `dart format lib test integration_test` |
| `flutter test` on IT-2 | The assets changed | [Rebuild word data](../operations/rebuild-word-data.md) |
| Android permission check | A dependency added `INTERNET` | `aapt2 dump permissions` on the APK |
| `flutter pub get` on every job | Flutter pins out of step | [Upgrade Flutter](../operations/upgrade-flutter.md) |

## Open questions

- Which of these are required for merging is a GitHub setting, not visible in the repository. This page does not say which checks actually block a merge.

[^ci]: Five jobs, in alphabetical order, with their limits in `timeout-minutes`.
[^word-data]: `contract` and `rebuild`.
[^plan-checks]: "All automated levels on each PR, by the owner. This matters more because merging also publishes to Diawi." Publishing to Diawi is planned, not built.
[^ci-triggers]: `pull_request:` with no filter, and `push: branches: [main]`.
[^ci-concurrency]: `cancel-in-progress: true`, `group: ci-${{ github.ref }}`.
[^simulator-pick]: `sorted(d, reverse=True)` over runtimes, and the first name starting with `iPhone`. Sorting strings rather than versions is what the code does; "newest" is inferred.
[^ci-retry]: `for attempt in 1 2`, `perl -e 'alarm shift; exec @ARGV' 1500`.
