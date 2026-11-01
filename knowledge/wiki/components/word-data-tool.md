---
type: Component
id: wiki-components-word-data-tool
title: Word-data Tool
description: "tool/: the Python build and checks for word data, the rules that decide which words and puzzles exist, and the details the exact match depends on."
tags: [component, python, word-data, tooling]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: build-doc
    resource: repo://tool/build_word_data.py#L1-L18
    title: Build tool description
    last_modified: 2026-11-01
  - id: variants
    resource: repo://tool/build_word_data.py#L27-L42
    title: Variants and level rules
    last_modified: 2026-11-01
  - id: read-lists
    resource: repo://tool/build_word_data.py#L55-L68
    title: read_lists
    last_modified: 2026-11-01
  - id: build
    resource: repo://tool/build_word_data.py#L75-L110
    title: The build function
    last_modified: 2026-11-01
  - id: adr-options
    resource: repo://specs/adr/adr-word-data-pipeline.md#L29-L39
    title: "ADR: options"
    last_modified: 2026-10-31
  - id: unit-tests
    resource: repo://tool/test_check_word_data.py#L12-L57
    title: Contract check tests
    last_modified: 2026-11-01
  - id: rebuild
    resource: repo://tool/check_word_data_rebuild.py#L18-L19
    title: Pinned SCOWL archive
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Components](index.md) › Word-data Tool

# Word-data Tool

`tool/` builds and checks the word data. It has no link to the app at run time, and it is the only Python in the repository. The rules are a copy of Nine Tile's, kept separately on purpose so the two apps can change independently.[^build-doc]

## Scripts by purpose

| Script | Purpose | Runs |
| ------ | ------- | ---- |
| `build_word_data.py` | Writes `assets/words/` from an unpacked SCOWL | By hand |
| `check_word_data.py` | Contract check on any files | Every PR |
| `check_word_data_rebuild.py` | IT-1: downloads the pinned SCOWL archive,[^rebuild] rebuilds, compares digests | On demand |
| `test_check_word_data.py` | Proves the contract check can fail[^unit-tests] | Every PR |
| `generate_parity_fixture.mjs` | Node, needing a ninetile checkout. Ran once | Not again |

## How a puzzle gets chosen

Each nine-letter answer with each of its distinct letters is one candidate. For each candidate, the build counts the answers that fit.[^build] Level rules then select by that count:

| Pool | Answers in the puzzle | Seed word's SCOWL level | Share of very common answers |
| ---- | --------------------- | ----------------------- | ---------------------------- |
| Easy | 15 to 30 | up to 20 | any |
| Medium | 31 to 50 | up to 35 | any |
| Hard | 51 to 80 | up to 35 | any |
| Test pool | 6 to 14 | up to 20 | at least half |

Candidates are ordered by a SHA-1 of the word and centre letter, which is a stable shuffle, and the first 2,500 are taken per level.[^build] The levels run in order, so a pair taken by one level is excluded from later ones. The test pool starts again from an empty set, and on the current assets none of its 25 puzzles appears in `p`.

## Details the exact match depends on

The ADR lists Latin-1 reading and SHA-1 ordering as details that would have to be proven again in a port.[^adr-options] So a rewrite, or a refactor that changes either of these, is not safe without running IT-1:

- SCOWL files are opened as `latin-1`.[^read-lists]
- `os.listdir` order does not matter, because a word keeps its lowest level with `min`.[^read-lists]
- Capitalised non-name words are lowered only from the `upper` lists, and only up to level 35.[^build]

## Extension seam

A new variant means a new `VARIANTS` entry,[^variants] plus `LANGS` in the contract check, the asset line in `pubspec.yaml`, and new digests. No other language is in scope for the spec.

## Related pages

- [Word data flow](../architecture/word-data-flow.md) places the tool in the pipeline.
- [SCOWL](../reference/scowl.md) explains the source lists.

[^rebuild]: `SCOWL_URL` and `SCOWL_SHA256`.
[^build-doc]: "word9 keeps its own copy, so the two apps can change independently".
[^unit-tests]: Each test breaks the fixture in one way and expects a named problem.
[^build]: `candidates.append(...)`, `pick`, and `read_lists(final, cfg['upper'], ANSWER_LEVEL, lower=True)`.
[^adr-options]: "the exact match must be proven again, with details such as Latin-1 reading and SHA-1 ordering".
[^read-lists]: `encoding='latin-1'`; `out[w] = min(out.get(w, 99), int(lvl))`.
[^variants]: `VARIANTS` holds the lists, the dictionary address and any extra accepted spellings.
