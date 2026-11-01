---
type: Explainer
id: wiki-reference-scowl
title: SCOWL
description: "The word-list source behind word9: what its levels and categories mean to the build, why the release is pinned, and the licence notice the app must carry."
tags: [reference, scowl, word-data, licence]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: scowl
    resource: http://wordlist.aspell.net/
    title: SCOWL word lists
  - id: build-doc
    resource: repo://tool/build_word_data.py#L13-L17
    title: Build tool, word sources
    last_modified: 2026-11-01
  - id: variants
    resource: repo://tool/build_word_data.py#L27-L38
    title: Lists read per variant, and levels
    last_modified: 2026-11-01
  - id: read-lists
    resource: repo://tool/build_word_data.py#L58-L60
    title: Parsing file names
    last_modified: 2026-11-01
  - id: misc
    resource: repo://tool/build_word_data.py#L77-L77
    title: Offensive and profane lists
    last_modified: 2026-11-01
  - id: notice
    resource: repo://tool/build_word_data.py#L44-L49
    title: SCOWL notice
    last_modified: 2026-11-01
  - id: pin
    resource: repo://tool/check_word_data_rebuild.py#L18-L19
    title: Pinned archive
    last_modified: 2026-11-01
  - id: spec-licence
    resource: repo://specs/feature-word9-flutter-app.md#L132-L132
    title: Spec, Licences entry
    last_modified: 2026-10-31
  - id: plan-order
    resource: repo://specs/feature-word9-flutter-app-plan.md#L177-L183
    title: Plan, steps 9 to 15
    last_modified: 2026-10-31
---

[Home](../../index.md) › [Reference](index.md) › SCOWL

# SCOWL

SCOWL (Spell Checker Oriented Word Lists) is the source of every word in word9.[^scowl] Only the build tool reads it, and the app has no link to it at run time.

## How the build reads it

Files in the release's `final/` folder are named `<category>.<level>`, and the build parses that name.[^read-lists] **A lower level means a more common word.**

| Concept | Used here as |
| ------- | ------------ |
| Level 20 or below | "Very common": seed words for Easy and the test pool |
| Level 35 or below | Answers |
| Levels 40 to 70 | Accepted only |
| `english-words`, `british-words`, `american-words` | Base lists per variant[^variants] |
| `british_variant_1-words`, `variant_1-words` | Alternative spellings: accepted only[^variants] |
| `*-upper` | Capitalised non-name words, lowered, and accepted only. Proper names are never valid[^build-doc] |
| `misc/offensive.*`, `misc/profane.1` | Slurs and strong swear words[^misc] |

## Why the release is pinned

Word9 must match Nine Tile's data exactly, and that was built from 2020.12.07. A newer SCOWL would change the digests. So the rebuild checks the archive's SHA-256 before using it.[^pin]

## Licence obligation

SCOWL's permission requires its copyright and permission notices to appear in supporting documentation.[^notice] The spec satisfies this with a Licences entry in settings.[^spec-licence]

**That entry does not exist yet**, and `SCOWL_NOTICE` in the build tool is not written to the assets or used by any code. The plan's order matters here: Diawi builds reach the team from step 9, while Licences arrive at step 15.[^plan-order]

## Open questions

- Do Diawi builds before step 15 need the notice? They would carry the word data without it.

## Inference on this page

That a lower level means a more common word is general knowledge of SCOWL, consistent with how the build uses levels. The question above is a reading of the licence text, not legal advice.

[^scowl]: SCOWL's site, also named in the build tool's docstring.
[^read-lists]: `cat, _, lvl = f.rpartition('.')`.
[^variants]: `VARIANTS` lists `words`, `alt` and `upper` for each variant.
[^build-doc]: "capitalised non-name words (Latin, Monday)" and "proper names (London, Abigail)" under never.
[^misc]: `read_misc(scowl, 'offensive.1', 'offensive.2')` and `read_misc(scowl, 'profane.1')`.
[^pin]: `SCOWL_SHA256`.
[^notice]: "provided that the above copyright notice appears in all copies and that both that copyright notice and this permission notice appear in supporting documentation".
[^spec-licence]: "A Licences entry in settings shows the SCOWL notice, which SCOWL's licence requires, and the font notices."
[^plan-order]: Step 9 publishes to Diawi; step 15 delivers settings and Licences.
