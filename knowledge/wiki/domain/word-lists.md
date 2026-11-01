---
type: Domain Concept
id: wiki-domain-word-lists
title: Word Lists
description: "Answers, accepted words and words that are never valid: what each category holds, how they shape a puzzle's total, and how swear words and slurs are treated."
tags: [domain, word-data, rules]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: categories
    resource: repo://tool/build_word_data.py#L13-L18
    title: Build tool, word sources
    last_modified: 2026-11-01
  - id: build-sets
    resource: repo://tool/build_word_data.py#L77-L82
    title: Build tool, computing the categories
    last_modified: 2026-11-01
  - id: accept
    resource: repo://tool/build_word_data.py#L33-L36
    title: Extra accepted spellings for en-US
    last_modified: 2026-11-01
  - id: spec-counts
    resource: repo://specs/feature-word9-flutter-app.md#L125-L130
    title: Spec, counts per variant
    last_modified: 2026-10-31
  - id: spec-total
    resource: repo://specs/feature-word9-flutter-app.md#L97-L98
    title: Spec, accepted words raise the total
    last_modified: 2026-10-31
  - id: tally
    resource: repo://lib/game/word_tally.dart#L3-L7
    title: WordTally
    last_modified: 2026-11-01
  - id: ut-8
    resource: repo://test/unit/word_rules_test.dart#L98-L115
    title: UT-8
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Domain](index.md) › Word Lists

# Word Lists

Each variant sorts words into three categories, and the difference decides whether finding a word moves a player towards the total or past it.[^categories]

## Categories of word

| Category | Field | Holds | In play |
| -------- | ----- | ----- | ------- |
| Answers | `v` | Common words, SCOWL level up to 35, in the variant's spelling | Counts towards the puzzle's total from the start |
| Accepted | `x` | Rarer words (levels 40 to 70), alternative spellings, capitalised non-name words such as Latin and Monday, strong swear words | Valid if entered. Not counted until found |
| Never | none | Proper names, the other variant's spellings, racial slurs | Rejected as not in the word list |

| Variant | Answers | Accepted |
| ------- | ------- | -------- |
| en-GB | 29,223 | 40,941 |
| en-US | 29,270 | 41,000 |

These counts are part of the spec, and IT-2 fails if they change.[^spec-counts]

## Offensive words

Swear words are excluded from answers but still accepted, so a puzzle never requires one and a player who enters one is not told it's wrong. Slurs are excluded from both.[^build-sets]

## The total can grow

A puzzle's solutions are computed from answers only, and an accepted word joins the total once found: "5 of 30" becomes "6 of 31". This is a deliberate match with Nine Tile.[^spec-total][^ut-8] `WordTally` also folds `found` into its solutions at construction, so a restored game keeps its raised total.[^tally]

## Spellings across variants

Strictly, the other variant's spellings are never valid, with one hand-picked exception: en-US also accepts `grey` and its forms, and `judgement`, because some Americans use them and SCOWL files them elsewhere.[^accept]

[^categories]: The docstring of `build_word_data.py` defines all three.
[^spec-counts]: The table in section 5 of the spec.
[^build-sets]: `w not in slurs and w not in swears` for answers, but only `- slurs` for accepted words.
[^spec-total]: "An accepted word outside the answers raises the total when found".
[^ut-8]: The test goes from 5 of 22 to "6 of 23" on `moil`.
[^tally]: `_solutions = {...solutions, ...found}.toList()..sort()`.
[^accept]: "spellings some Americans use that SCOWL files under other variants: accepted, never counted".
