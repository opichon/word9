---
type: Architecture
id: wiki-architecture-word-data-flow
title: Word Data Flow
description: "How word lists get from SCOWL into the app, why the assets are committed, and the chain of checks that proves they still match Nine Tile."
tags: [word-data, parity, build, assets]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: adr
    resource: repo://specs/adr/adr-word-data-pipeline.md#L53-L62
    title: "ADR: word-data pipeline, decision and consequences"
    last_modified: 2026-10-31
  - id: build-main
    resource: repo://tool/build_word_data.py#L113-L123
    title: Build tool, writing the assets
    last_modified: 2026-11-01
  - id: format
    resource: repo://tool/word_data_format.md
    title: Word-data format
    last_modified: 2026-11-01
  - id: contract-check
    resource: repo://tool/check_word_data.py#L14-L53
    title: Contract check
    last_modified: 2026-11-01
  - id: rebuild-check
    resource: repo://tool/check_word_data_rebuild.py#L38-L56
    title: On-demand rebuild against the digests
    last_modified: 2026-11-01
  - id: it-2
    resource: repo://test/integration/word_data_test.dart#L40-L65
    title: IT-2, packaged word data
    last_modified: 2026-11-01
  - id: ut-2
    resource: repo://test/unit/solve_parity_test.dart#L13-L27
    title: UT-2, solving parity
    last_modified: 2026-11-01
  - id: parity-generator
    resource: repo://tool/generate_parity_fixture.mjs#L1-L7
    title: Parity fixture generator
    last_modified: 2026-11-01
  - id: pubspec-assets
    resource: repo://pubspec.yaml#L22-L25
    title: Declared assets
    last_modified: 2026-11-01
  - id: workflow
    resource: repo://.github/workflows/word-data.yml#L2-L21
    title: Word data workflow
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Architecture](index.md) › Word Data Flow

# Word Data Flow

Word data crosses from Python to Dart once, as a committed file. Nothing in the app build or CI can regenerate it, and that is deliberate: **app builds and CI need neither SCOWL nor Python to ship**.[^adr]

## Stages from source to screen

| Stage | Where | Runs |
| ----- | ----- | ---- |
| SCOWL 2020.12.07 archive | SourceForge | Only on a rebuild |
| Build | `tool/build_word_data.py` | By hand |
| Assets | `assets/words/en-GB.json`, `en-US.json`, committed and declared in `pubspec.yaml`[^pubspec-assets] | Packaged in every build |
| Decode | `WordData.fromJson` splits the strings into lists and sets | At each launch |

The file format is the contract between the two languages.[^format] It has six one-letter or short keys, as in Nine Tile's `DATA`, and it is why those fields are space-separated strings rather than JSON arrays. Both Python and Dart split on spaces, so the format must never gain a word containing a space.

## The chain of checks

Four separate checks hold the data in place, and they catch different things.

| Check | Catches | Runs |
| ----- | ------- | ---- |
| Contract check | Shape: missing fields, unsorted lists, a word in both `v` and `x`, a centre letter not in its word[^contract-check] | Every PR, `word-data.yml`[^workflow] |
| IT-2 | Any edit to the packaged data: counts, level sizes, and a SHA-256 digest[^it-2] | Every PR, in `flutter test` |
| UT-2 | The Dart `solve` diverging from Nine Tile's JavaScript, over 55 puzzles per variant[^ut-2] | Every PR, in `flutter test` |
| IT-1, rebuild | The tool's rules no longer producing the digests[^rebuild-check] | **On demand only**, by `workflow_dispatch`[^workflow] |

Because IT-1 is on demand, **a PR can change `tool/build_word_data.py` in a way that no longer reproduces the data, and every PR check still passes**. The comment in the workflow gives the reason: not depending on SourceForge in every run.[^workflow] Run the rebuild by hand after touching the tool: see [Rebuild word data](../operations/rebuild-word-data.md).

The digest is taken over sorted-key JSON with no whitespace. The committed files are already written in exactly that form,[^build-main] so the digest is also the SHA-256 of the file itself. That was confirmed for both variants on 2026-11-02.

## The parity fixture is frozen

`test/fixtures/solve_parity.json` came from running Nine Tile's own `solve` once, and tests read the result. Neither the script nor a ninetile checkout is needed afterwards.[^parity-generator] It does not need regenerating unless word9 deliberately diverges.

## Related pages

- [Word-data tool](../components/word-data-tool.md) covers the rules inside the build.
- [Word lists](../domain/word-lists.md) explains what the fields mean to a player.
- [Nine Tile parity](../domain/nine-tile-parity.md) explains why an exact match is required at all.

[^adr]: "Assets are committed, so app builds and CI need neither SCOWL nor Python."
[^pubspec-assets]: Each file is listed under `flutter: assets:`.
[^format]: The table of fields `d`, `dict`, `lang`, `p`, `v` and `x`.
[^contract-check]: `problems_in` returns every way the decoded data breaks the contract.
[^workflow]: `contract` has no `if`; `rebuild` runs `if: github.event_name == 'workflow_dispatch'`.
[^it-2]: `matches the digest from Nine Tile` hashes the sorted JSON.
[^ut-2]: The test expects `puzzles.length` to be 55.
[^rebuild-check]: It rebuilds into a temporary folder and compares against `test/fixtures/word_data_digests.json`.
[^build-main]: `json.dump(..., separators=(',', ':'), sort_keys=True)`.
[^parity-generator]: "This ran once, and its output is committed."
