---
type: Technical Debt
id: wiki-technical-debt-release-builds-use-debug-key
title: Release Builds Use the Debug Key
description: "Android release builds on main are signed with the debug key, as Flutter's template leaves them; the fix is on an unmerged branch, partly blocked on the owner."
tags: [technical-debt, signing, android, release]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: gradle
    resource: repo://android/app/build.gradle.kts#L32-L38
    title: Android release build type
    last_modified: 2026-11-01
  - id: pr-14
    resource: https://github.com/opichon/word9/pull/14
    title: "Draft PR #14, step 8, signing"
  - id: signing-commit
    resource: https://github.com/opichon/word9/commit/44dbbe9
    title: "feat: sign android release builds with an upload key"
  - id: plan-step-9
    resource: repo://specs/feature-word9-flutter-app-plan.md#L341-L362
    title: Plan, steps 8 and 9
    last_modified: 2026-10-31
  - id: ci-ios
    resource: repo://.github/workflows/ci.yml#L93-L93
    title: iOS build with no signing
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Technical debt](index.md) › Release Builds Use the Debug Key

# Release Builds Use the Debug Key

## What was left undone

On `main`, the Android `release` build type still signs with the debug key, with the template's `TODO` above it.[^gradle] CI builds iOS with `--no-codesign`.[^ci-ios] So no build from `main` can be distributed.

## Why

Signing is plan step 8, and it needs the owner's accounts.[^plan-step-9]

## What it costs today

Nothing yet: builds go only to simulators and emulators. It blocks the Diawi milestone, step 9, and so everything for testers.[^plan-step-9]

## The way out

Draft PR #14 holds the Android half, on `feat/step-8-signing`:[^pr-14]

- Release builds use an upload key when `android/key.properties` exists, and the debug key otherwise, which keeps PR builds working.[^signing-commit]
- CI signs with a throwaway key and verifies the certificate.
- `docs/signing.md` lists what is needed.

Still blocked on the owner: the Apple Developer account, registered iPhones, distribution certificate, ad hoc profile and Diawi token, plus step 8's own check, that each signed build installs on its phone.[^pr-14]

**That branch is old.** It forked before steps 2 to 7 merged, and `main` has moved a long way, so expect to merge `main` into it.

## How to tell it is paid

The `TODO` is gone from `build.gradle.kts`, `docs/signing.md` exists on `main`, and `flutter build ipa` works with a real profile.

[^gradle]: "TODO: Add your own signing config for the release build. Signing with the debug keys for now, so `flutter run --release` works."
[^ci-ios]: `flutter build ios --release --no-codesign`.
[^plan-step-9]: Step 8's deliverable is a signed build on each platform; step 9 depends on it. The plan's phase table has testers starting from there.
[^pr-14]: "Done" and "Blocked on the owner" in the PR's description.
[^signing-commit]: "Without key.properties, as on pull requests, release builds use the debug key."
