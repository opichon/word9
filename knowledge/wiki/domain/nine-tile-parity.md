---
type: Domain Concept
id: wiki-domain-nine-tile-parity
title: Nine Tile Parity
description: "word9 must match the Nine Tile web app at commit 3543b45: what that binds, how it differs on purpose, and how the two are allowed to drift later."
tags: [domain, parity, nine-tile]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: spec-context
    resource: repo://specs/feature-word9-flutter-app.md#L51-L58
    title: Spec, context
    last_modified: 2026-10-31
  - id: spec-parity
    resource: repo://specs/feature-word9-flutter-app.md#L85-L87
    title: Spec, game parity
    last_modified: 2026-10-31
  - id: spec-kept
    resource: repo://specs/feature-word9-flutter-app.md#L97-L100
    title: Spec, behaviours kept deliberately
    last_modified: 2026-10-31
  - id: spec-word-data
    resource: repo://specs/feature-word9-flutter-app.md#L124-L125
    title: Spec, word data
    last_modified: 2026-10-31
  - id: spec-boundaries
    resource: repo://specs/feature-word9-flutter-app.md#L161-L177
    title: Spec, boundaries
    last_modified: 2026-10-31
  - id: spec-personas
    resource: repo://specs/feature-word9-flutter-app.md#L65-L65
    title: Spec, maintainer persona
    last_modified: 2026-10-31
  - id: adr
    resource: repo://specs/adr/adr-word-data-pipeline.md#L61-L61
    title: "ADR: changing word rules on purpose"
    last_modified: 2026-10-31
---

[Home](../../index.md) › [Domain](index.md) › Nine Tile Parity

# Nine Tile Parity

Nine Tile is the owner's word game, delivered as two web pages. word9 brings it to phones so it can be played without a browser or a connection.[^spec-context] **When a rule or a text looks odd, the question to ask is what Nine Tile does at commit `3543b45`**, because that commit is the reference, unless the spec lists a difference.[^spec-parity]

## What parity binds

- Rules, on-screen text and word validation.[^spec-parity]
- Word data, exactly, built with the same rules from the same SCOWL release.[^spec-word-data]

## Behaviour that looks like a bug and is not

These are kept deliberately from Nine Tile:[^spec-kept]

- An accepted word raises the total.
- A puzzle can repeat.
- Shuffle and Delete stay enabled after a reveal.

Do not fix these without a spec change.

## Deliberate differences

- The title reads "word9".[^spec-parity]
- No keyboard input at all: hardware keys are ignored and no on-screen keyboard appears. This is why the game screen has no `TextField`.[^spec-boundaries]
- Language is an in-app setting, and test mode is a gesture, since there are no separate pages or URLs.[^spec-boundaries]

## How the two may drift

word9 keeps its own copy of the build rules and reads nothing from the ninetile repository at any time, so the apps can change independently. The spec accepts the cost, which is that the rules exist in two repositories and can drift.[^spec-personas] A shared pipeline is parked for later discussion.[^spec-boundaries]

The match is a checked property today, not a permanent one. Changing word rules on purpose means updating word9's stored digests, as the two apps may then differ.[^adr] See [Rebuild word data](../operations/rebuild-word-data.md).

## Related pages

- [Word data flow](../architecture/word-data-flow.md) describes how the match is proven.

[^spec-context]: Section 3 of the spec.
[^spec-parity]: "Unless section 6 lists a difference, word9 matches Nine Tile at commit `3543b45` in rules, on-screen text and word validation."
[^spec-word-data]: "It doesn't read or depend on any file in the ninetile repository"; the match is per variant.
[^spec-kept]: "These Nine Tile behaviours are kept deliberately".
[^spec-boundaries]: Section 6 lists the deliberate differences, and "A shared word-build pipeline ... (parked for later discussion)".
[^spec-personas]: "Word-build rules exist in two repositories and can drift apart".
[^adr]: "Changing word rules on purpose means updating word9's stored digests, as the two apps may then differ."
