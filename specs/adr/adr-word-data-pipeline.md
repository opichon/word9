---
description: word9 builds its word data with a Python tool adapted from Nine Tile, and ships one JSON asset per variant.
generated:
  at: 2026-11-01T01:08:56+07:00
  by: claude-code/2.1.316
id: adr-word-data-pipeline
links:
  - note: The plan that raised this decision
    rel: references
    to: feature-word9-flutter-app-plan
status: draft
tags:
  - adr
  - word-data
title: "ADR: word-data pipeline"
type: ADR
---

# ADR: word-data pipeline

## Context

Raised by [Implementation plan: word9: offline Flutter app with the same features as Nine Tile](/feature-word9-flutter-app-plan.md).

The spec requires word9 to build its own data from SCOWL, match Nine Tile's data at `3543b45` exactly, and not depend on the ninetile repository. Nine Tile's `build_words.py`, rebuilt from SCOWL 2020.12.07 on 2026-11-01, reproduced every field of its committed `DATA` for both variants. Each variant holds about 70,000 words and 670 KB of data. The app must start in at most 3 s on the spec's devices, which are not yet available for measurement.

## Options

### Python tool, JSON assets

- **For:** the rules are already proven to give an exact match, and can be compared line by line with Nine Tile's; the digest applies directly to the assets; the format is simple to inspect.
- **Against:** adds Python as a developer tool; JSON decoding time is unmeasured on target devices.
- **Coupling:** none at run time. The rules are copied, so they can drift from Nine Tile's, which the spec accepts.

### Dart tool, JSON assets

- **For:** one language in the repository.
- **Against:** the exact match must be proven again, with details such as Latin-1 reading and SHA-1 ordering, and it adds a dependency.
- **Coupling:** none.

### Prebuilt SQLite assets

- **For:** fast lookups and low memory.
- **Against:** a native dependency, and the digest needs an export step.
- **Coupling:** `game-rules` on a database package.

### Generated Dart constants

- **For:** no asset loading.
- **Against:** slower builds, and data that's awkward to inspect.
- **Coupling:** none.

## Decision

Python tool adapted from Nine Tile, writing one JSON asset per variant with the same fields as Nine Tile's `DATA`. The owner chose this because it keeps the proven rules and makes the exact match simple to show. Assets are committed, so app builds and CI need neither SCOWL nor Python.

## Consequences

- Only the active variant's asset is loaded, off the UI thread.
- Rebuilding the data is a developer action, checked on demand against stored digests.
- Changing word rules on purpose means updating word9's stored digests, as the two apps may then differ.
- Revisit if the speed targets are missed on the agreed devices. Prebuilt SQLite is the fallback, and it would need a new ADR.
