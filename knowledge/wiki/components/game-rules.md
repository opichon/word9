---
type: Component
id: wiki-components-game-rules
title: Game Rules
description: "lib/game/: the Flutter-free rules of a puzzle, how its pieces divide the work, and which of them the app does not call yet."
tags: [component, dart, rules]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: plan-subsystems
    resource: repo://specs/feature-word9-flutter-app-plan.md#L238-L238
    title: Plan, dependency direction
    last_modified: 2026-10-31
  - id: plan-table
    resource: repo://specs/feature-word9-flutter-app-plan.md#L125-L129
    title: Plan, sub-systems
    last_modified: 2026-10-31
  - id: board
    resource: repo://lib/game/board.dart#L5-L17
    title: Board, centre index and deal
    last_modified: 2026-11-01
  - id: validation-const
    resource: repo://lib/game/word_validation.dart#L4-L5
    title: The public centre index
    last_modified: 2026-11-01
  - id: banners
    resource: repo://lib/game/banners.dart#L50-L73
    title: BannerTracker.onWordFound
    last_modified: 2026-11-01
  - id: rejection
    resource: repo://lib/game/word_validation.dart#L11-L51
    title: Rejection types
    last_modified: 2026-11-01
  - id: banner-tests
    resource: repo://test/unit/puzzle_rules_test.dart#L102-L161
    title: UT-5, banner selection
    last_modified: 2026-11-01
  - id: solve
    resource: repo://lib/game/word_lists.dart#L34-L41
    title: WordLists.solve
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Components](index.md) › Game Rules

# Game Rules

`lib/game/` holds the rules as plain Dart, with no Flutter import.[^plan-table] It imports only `dart:math` and itself, which is why most of its tests are unit tests. Nothing enforces the rule except review.

## Responsibilities by file

| File | Owns | Does not own |
| ---- | ---- | ------------ |
| `puzzles.dart` | Parsing `p` and `d`, and choosing a puzzle | The grid |
| `board.dart` | The nine letters and the entry, as positions | Whether a word is valid |
| `word_lists.dart` | Answers, accepted words, solving, dictionary address | Found words |
| `word_tally.dart` | Found words and the growing total | Validation |
| `word_validation.dart` | The checks and their messages | State |
| `banners.dart` | Which banners a found word earns, once each | Showing them, or their timing |

## Relationships

Dependencies run one way: `ui` → `app-state` → `game-rules`.[^plan-subsystems] The rules read word data only through the format in `tool/word_data_format.md`, with no link to the tool itself.

## Details a reader could get wrong

- **The centre position is defined twice:** a private `_centreIndex` in `board.dart`, and a public `centreIndex` in `word_validation.dart`, both 4.[^board][^validation-const] Nothing ties them together, so change both or neither.
- **Messages depend on the variant through a parameter.** A `Rejection` takes `lang` when asked for its text, and only `MissingCentre` uses it, for "centre" or "center".[^rejection]
- **`solve` tests the centre letter, not the tile.** That is safe: any word with that letter can be spelled using the centre tile.[^solve]

## Banner selection

Only the highest milestone newly reached shows, but **every milestone reached is marked as shown**, so one jump from 30% to 70% can never produce "Good start!" later.[^banners] The nine-letter banner comes first and has its own id. `shown` is exposed so that a saved game can restore it.

The milestones compare `found / total`, and an accepted word raises both, so the share at the moment of checking uses the raised total. UT-5 tests all of this.[^banner-tests] **The app does not call `BannerTracker` yet**: see [Built versus planned](../architecture/built-versus-planned.md).

## Extension seam

A new rejection is a new `Rejection` subclass. The class is `sealed`, and `validateEntry` decides the order, so add the check at the position the spec requires.

[^plan-table]: "`game-rules` ... New: plain Dart rules, with no Flutter import."
[^plan-subsystems]: "dependencies run one way: `ui` → `app-state` → `game-rules`".
[^board]: `const _centreIndex = 4;`
[^validation-const]: `const centreIndex = 4;`
[^rejection]: `lang == 'en-US' ? 'center' : 'centre'`.
[^solve]: `word.contains(centre) && _fits(word, pool)`.
[^banners]: `banners.add(reached.last.banner); _shown.addAll(reached.map(...))`.
[^banner-tests]: Exact boundaries, a jump past two thresholds, nine-letter first, no repeats, and restored state.
