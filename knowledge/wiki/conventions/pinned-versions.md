---
type: Convention
id: wiki-conventions-pinned-versions
title: Pinned Versions
description: "Everything is pinned exactly, from Flutter to GitHub Actions: where each pin lives and which pins are enforced rather than merely followed."
tags: [convention, dependencies, versions]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: mise
    resource: repo://mise.toml#L1-L4
    title: mise tools
    last_modified: 2026-11-02
  - id: pubspec
    resource: repo://pubspec.yaml#L6-L20
    title: pubspec environment and dev dependencies
    last_modified: 2026-11-01
  - id: ci
    resource: repo://.github/workflows/ci.yml#L9-L18
    title: CI pins, on one job
    last_modified: 2026-11-01
  - id: dependabot
    resource: repo://.github/dependabot.yml
    title: Dependabot
    last_modified: 2026-11-01
  - id: flutter-commit
    resource: https://github.com/opichon/word9/commit/f4d994f
    title: "build: install flutter with mise and upgrade to 3.47.9"
  - id: plan-step-1
    resource: repo://specs/feature-word9-flutter-app-plan.md#L261-L263
    title: Plan, step 1 changes
    last_modified: 2026-10-31
---

[Home](../../index.md) › [Conventions](index.md) › Pinned Versions

# Pinned Versions

Every version in this repository is exact: upgrading anything is a deliberate change. The plan asks for it,[^plan-step-1] and the Flutter commit gives the reason.[^flutter-commit]

## Where each pin lives

| What | Where | Form |
| ---- | ----- | ---- |
| Flutter, for developers | `mise.toml`[^mise] | `3.47.9` |
| Flutter and Dart, for the project | `pubspec.yaml`, `environment`[^pubspec] | `3.47.9`, `3.13.7` |
| Flutter, for CI | `ci.yml`, once in each of 5 jobs[^ci] | `flutter-version: 3.47.9` |
| Packages | `pubspec.yaml`, plus `pubspec.lock` | Exact, no `^` |
| GitHub Actions | Every `uses:` line[^ci] | Full commit SHA, with the tag in a comment |
| repokb | `mise.toml`[^mise] | Exact |

## Enforced and observed pins

- **Enforced:** `pubspec.yaml`'s exact `flutter` and `sdk` constraints make a mismatched toolchain fail at `flutter pub get`.[^flutter-commit] So a CI version that drifts from `pubspec.yaml` breaks CI visibly rather than building quietly with the wrong Flutter.
- **Observed:** exact package versions and SHA-pinned actions. No check rejects a `^` or a tag.

Dependabot watches `github-actions` and `pub` weekly, which is what keeps the pins from aging silently.[^dependabot]

## Changing the Flutter version

The pins must move together: see [Upgrade Flutter](../operations/upgrade-flutter.md).

## Inference on this page

That a mismatch fails at `flutter pub get` is inferred from the exact `environment` constraints and the commit message. It was not reproduced.

[^plan-step-1]: "exact dependency versions in `pubspec.yaml`".
[^flutter-commit]: "mise.toml makes the Flutter version part of the project, so upgrading Flutter is a deliberate change. pubspec.yaml requires the exact version, so it, the lockfile and CI move to 3.47.9 and Dart 3.13.7 together."
[^mise]: `flutter = "3.47.9"`.
[^pubspec]: `flutter: 3.47.9`, `sdk: 3.13.7`, `crypto: 3.0.8`, `flutter_lints: 6.0.0`.
[^ci]: `subosito/flutter-action@1a44944... # v2.23.0`, with `flutter-version` in `android-acceptance`, `android-build`, `ios-acceptance`, `ios-build` and `test`.
[^dependabot]: `package-ecosystem: github-actions` and `pub`, `interval: weekly`.
