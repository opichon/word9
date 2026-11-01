---
type: Technical Debt
id: wiki-technical-debt-speed-targets-unmeasured
title: Speed Targets Unmeasured
description: "The spec's start and response targets have never been measured, because the named devices are not available; the JSON word-data choice rests on that measurement."
tags: [technical-debt, performance, word-data]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: spec-performance
    resource: repo://specs/feature-word9-flutter-app.md#L153-L157
    title: Spec, performance
    last_modified: 2026-10-31
  - id: plan-problem
    resource: repo://specs/feature-word9-flutter-app-plan.md#L63-L63
    title: Plan, speed on real devices
    last_modified: 2026-10-31
  - id: plan-step-20
    resource: repo://specs/feature-word9-flutter-app-plan.md#L474-L484
    title: Plan, step 20
    last_modified: 2026-10-31
  - id: adr-context
    resource: repo://specs/adr/adr-word-data-pipeline.md#L25-L25
    title: "ADR: context"
    last_modified: 2026-10-31
  - id: adr-revisit
    resource: repo://specs/adr/adr-word-data-pipeline.md#L62-L62
    title: "ADR: revisit"
    last_modified: 2026-10-31
  - id: solve
    resource: repo://lib/game/word_lists.dart#L35-L41
    title: Solving scans the answers
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Technical debt](index.md) › Speed Targets Unmeasured

# Speed Targets Unmeasured

## What was left undone

The spec sets targets on a Pixel 6a and an iPhone 11: cold start in 3 s, a new puzzle or variant switch in 500 ms, and a tap or submission on screen in 100 ms.[^spec-performance] Tests NF-1 to NF-3 are **Blocked**, as plan step 20.[^plan-step-20]

## Why

The owner has neither device, and using substitutes would change the spec.[^plan-step-20]

## What it costs today

The word-data decision rests on it. The ADR chose JSON knowing that decoding time was unmeasured on target devices.[^adr-context] A miss could mean new work late, since Prebuilt SQLite is the named fallback, with its own ADR and a native dependency.[^adr-revisit]

## Where the risk is

These are the parts of the code that scale with the word lists. This list is inference from reading the code, and none of it has been profiled:

- Decoding about 70,000 words off the UI thread on each launch.
- `solve` running on the UI thread, scanning every answer, for each new puzzle.[^solve] This is the operation the 500 ms target covers. See [App startup](../architecture/app-startup.md).

## The way out

The plan offers early impressions from simulators at step 7, and real phones at step 9.[^plan-problem] The open decision is the owner's: which physical devices run NF-1 to NF-3?[^plan-step-20] The plan does not hold steps 21 onward for this unless the owner decides it should.

[^spec-performance]: Section 5 of the spec, "Performance".
[^plan-step-20]: "Which physical devices run NF-1 to NF-3? The spec names a Pixel 6a and an iPhone 11, and the owner has neither."
[^adr-context]: "which are not yet available for measurement".
[^adr-revisit]: "Revisit if the speed targets are missed on the agreed devices. Prebuilt SQLite is the fallback, and it would need a new ADR."
[^solve]: Called from `GameController.start`.
[^plan-problem]: "Step 7 gives an early impression on simulators; step 9 on real phones".
