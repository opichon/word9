---
type: Runbook
id: wiki-operations-rebuild-word-data
title: Rebuild Word Data
description: "How to prove the build tool still reproduces the assets, how to regenerate them, and everything else that must change if word rules change on purpose."
tags: [runbook, word-data, parity]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: rebuild
    resource: repo://tool/check_word_data_rebuild.py#L1-L6
    title: Rebuild check usage
    last_modified: 2026-11-01
  - id: build-usage
    resource: repo://tool/build_word_data.py#L4-L7
    title: Build usage
    last_modified: 2026-11-01
  - id: workflow
    resource: repo://.github/workflows/word-data.yml#L12-L21
    title: The rebuild job
    last_modified: 2026-11-01
  - id: adr
    resource: repo://specs/adr/adr-word-data-pipeline.md#L60-L61
    title: "ADR: rebuilding and changing rules"
    last_modified: 2026-10-31
  - id: it-2
    resource: repo://test/integration/word_data_test.dart#L16-L27
    title: IT-2 expected values
    last_modified: 2026-11-01
  - id: at-puzzle
    resource: repo://integration_test/play_test.dart#L12-L21
    title: The acceptance tests' first Easy puzzle
    last_modified: 2026-11-01
  - id: test-plan-data
    resource: repo://specs/feature-word9-flutter-app-test-plan.md#L394-L397
    title: Test plan, test data
    last_modified: 2026-10-31
---

[Home](../../index.md) › [Operations](index.md) › Rebuild Word Data

# Rebuild Word Data

Rebuilding is a developer action, checked on demand.[^adr] App builds and CI never do it.

## Prove the tool still matches

Run this after any change to `tool/build_word_data.py`, because PR checks will not notice: see [Word data flow](../architecture/word-data-flow.md).

```sh
python3 -B tool/check_word_data_rebuild.py
```

Or run the **Word data** workflow by hand, which triggers its `rebuild` job.[^workflow]

The script downloads SCOWL 2020.12.07 from SourceForge, checks the archive's SHA-256, rebuilds both variants into a temporary folder, and compares digests. It exits 0 only when all match, and `--archive <file>` uses a local copy.[^rebuild] It writes nothing into the repository.

## Regenerate the assets

```sh
curl -L -o scowl.tar.gz https://downloads.sourceforge.net/wordlist/scowl-2020.12.07.tar.gz
tar xzf scowl.tar.gz
python3 -B tool/build_word_data.py --scowl scowl-2020.12.07
```

This overwrites `assets/words/`.[^build-usage] Without a rules change, the result is byte-identical and `git status` shows nothing. Do not commit the SCOWL folder.

## If you change the word rules on purpose

This ends exact parity with Nine Tile, which the spec requires today, so **get a spec change first**.[^adr] Then all of these move together:

1. `tool/build_word_data.py` and the regenerated assets.
2. `test/fixtures/word_data_digests.json`, and the digests quoted in the test plan.[^test-plan-data]
3. The counts in IT-2, and in the spec's table.[^it-2]
4. `test/fixtures/solve_parity.json`, which is frozen from Nine Tile and would no longer apply, so UT-2 needs rethinking.
5. If the first Easy puzzle changes from `nominally`, the acceptance tests and their "1 of 22".[^at-puzzle] See [Test seams and fixtures](../testing/test-seams-and-fixtures.md).

The rebuild has not been run as part of writing this page. The last recorded proof is in the test plan, dated 2026-11-01.[^test-plan-data]

[^adr]: "Rebuilding the data is a developer action, checked on demand against stored digests", and "Changing word rules on purpose means updating word9's stored digests".
[^workflow]: `if: github.event_name == 'workflow_dispatch'`.
[^rebuild]: "Exits with 0 only when the archive and both variants match."
[^build-usage]: The docstring gives these commands, and `--out` defaults to `assets/words`.
[^test-plan-data]: Word-data digests and SCOWL archive rows: "Rebuilding with Nine Tile's script reproduced `DATA` exactly on 2026-11-01."
[^it-2]: `answers: 29223`, `accepted: 40941`, and the en-US equivalents.
[^at-puzzle]: "the first Easy puzzle, `nominally` with centre `L`".
