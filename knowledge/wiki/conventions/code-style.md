---
type: Convention
id: wiki-conventions-code-style
title: Code Style
description: "The style rules CI enforces on Dart, and the patterns every file follows with nothing enforcing them: alphabetical order, private initializing formals, UK spelling."
tags: [convention, dart, style, lint]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: ci-test
    resource: repo://.github/workflows/ci.yml#L104-L107
    title: CI format, analyze and test steps
    last_modified: 2026-11-01
  - id: analysis
    resource: repo://analysis_options.yaml#L10-L16
    title: Analyzer configuration
    last_modified: 2026-11-01
  - id: formal-commit
    resource: https://github.com/opichon/word9/commit/49750e6
    title: "fix: use an initializing formal for accepted words"
  - id: word-lists-ctor
    resource: repo://lib/game/word_lists.dart#L4-L16
    title: WordLists constructor
    last_modified: 2026-11-01
  - id: controller-ctor
    resource: repo://lib/state/game_controller.dart#L23-L35
    title: GameController constructor and fields
    last_modified: 2026-11-01
  - id: workflow-order
    resource: repo://.github/workflows/word-data.yml
    title: Word data workflow, key order
    last_modified: 2026-11-01
  - id: pubspec-sdk
    resource: repo://pubspec.yaml#L8-L8
    title: Dart SDK pin
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Conventions](index.md) › Code Style

# Code Style

## Enforced rules

| Rule | Check |
| ---- | ----- |
| `dart format` on `lib`, `test`, `integration_test` | CI fails on any change[^ci-test] |
| `flutter_lints` with no local overrides, excluding `build`, `android` and `ios` | `flutter analyze` in CI[^ci-test][^analysis] |

Python and the `.mjs` script have no formatter or linter. Markdown has no formatter either, so nothing reformats `knowledge/`.

## Observed patterns

Nothing checks these. They hold across `lib/`, `test/` and the workflows, so follow them.

- **Alphabetical order, unless order has meaning.** Class fields, constructor parameters, named arguments, enum values (`bad, good`), and even top-level workflow keys (`jobs`, `name`, `on`, `permissions`).[^controller-ctor][^workflow-order] Widget trees and steps keep their real order.
- **Private initializing formals.** A constructor takes `required this._accepted` and callers pass `accepted:`. This relies on the pinned Dart 3.13 and looks like a typo if you haven't met it.[^word-lists-ctor][^formal-commit][^pubspec-sdk] The form was adopted on purpose over a separate initializer.
- **British spelling in identifiers and comments**: `centre`, `isCentre`. Only en-US player text says "center".
- **Short doc comments on public members**, saying what things mean rather than repeating their names.
- **`package:` imports in tests, relative imports in `lib/`.**

## Inference on this page

The list is a reading of the code as of 2026-11-02, not a rule anyone wrote down, apart from the enforced table.

[^ci-test]: `dart format --output=none --set-exit-if-changed lib test integration_test`, then `flutter analyze`.
[^analysis]: `include: package:flutter_lints/flutter.yaml`, with an empty `rules:`.
[^controller-ctor]: `GameController({required this.lang, required this._random})`, and sorted fields.
[^workflow-order]: `jobs`, `name`, `on`, `permissions` in that order. The scaffolded `kb-catalog.yml` is the exception.
[^word-lists-ctor]: `required this._accepted`, with `accepted:` at the call in `fromJson`.
[^formal-commit]: The diff replaces `required Set<String> accepted` and `_accepted = accepted`.
[^pubspec-sdk]: `sdk: 3.13.7`. That this feature needs this Dart version is inferred from the code compiling here.
