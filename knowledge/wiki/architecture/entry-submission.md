---
type: Architecture
id: wiki-architecture-entry-submission
title: Entry Submission
description: "The path of a tap and an Enter through UI, controller and rules: the order of the checks, what each control clears, and what never changes the state."
tags: [gameplay, state, validation]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: tap
    resource: repo://lib/state/game_controller.dart#L75-L95
    title: GameController tapTile, delete and shuffle
    last_modified: 2026-11-01
  - id: submit
    resource: repo://lib/state/game_controller.dart#L98-L117
    title: GameController.submit
    last_modified: 2026-11-01
  - id: validate
    resource: repo://lib/game/word_validation.dart#L53-L74
    title: validateEntry
    last_modified: 2026-11-01
  - id: spec-order
    resource: repo://specs/feature-word9-flutter-app.md#L88-L95
    title: Spec, validation order
    last_modified: 2026-10-31
  - id: tally-add
    resource: repo://lib/game/word_tally.dart#L28-L35
    title: WordTally.add
    last_modified: 2026-11-01
  - id: empty-test
    resource: repo://test/widgets/game_screen_test.dart#L28-L42
    title: CT-1, controls on an empty entry
    last_modified: 2026-11-01
  - id: validation-tests
    resource: repo://test/unit/word_rules_test.dart#L35-L57
    title: UT-1, word validation
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Architecture](index.md) › Entry Submission

# Entry Submission

All gameplay input is four methods on `GameController`. The widgets hold no game state, and they learn of changes only by listening.

## What each control changes

| Control | Entry | Message | Notifies when |
| ------- | ----- | ------- | ------------- |
| Free tile | Adds the tile's position | Clears it | The tile is free[^tap] |
| Delete | Removes the last tile | **Keeps it** | The entry is not empty[^tap] |
| Shuffle | Clears it | **Keeps it** | Always[^tap] |
| Enter | Clears it, accepted or not | Replaces it | The entry is not empty[^submit] |

Enter and Delete on an empty entry do nothing at all, not even a notification, and CT-1 pins that down.[^empty-test]

## What the entry is made of

The entry is a list of **tile positions**, not letters. The word is derived when needed, from the positions and the current grid.[^validate] That is what makes "the centre tile was used" answerable: a puzzle can show the centre's letter on an outer tile as well. See [Puzzle model](../domain/puzzle-model.md).

## The order of the checks

`validateEntry` returns at the first failure, in the order the spec fixes.[^spec-order]

1. Fewer than 4 letters.
2. The centre tile is not in the entry.
3. The word is already found.
4. The word is not in the answers or the accepted words.

The order is visible to players. A 3-letter entry without the centre reports "too short", not "must include the centre", and UT-1 tests exactly that.[^validation-tests]

There is no check that the letters are available, because tiles are the only input. Each tile can be picked once and the keyboard is ignored, so an entry cannot spell something the grid does not hold.

## After the checks

- **Rejected:** a bad message, `_shakes` rises, the entry clears.[^submit]
- **Accepted:** the tally records the word and a good message shows. An accepted word outside the puzzle's solutions joins the total, so "5 of 22" becomes "6 of 23".[^tally-add]

The rejected branch clears the entry in the same step as the shake starts. The consequence on screen is in [Game screen](../ui/game-screen.md#what-a-rejected-entry-looks-like).

## What this flow does not do yet

Accepting a word does not call `BannerTracker`, and nothing is saved: see [Built versus planned](built-versus-planned.md).

[^tap]: `tapTile` and `delete` return early on a no-op; `shuffle` has no guard and calls `_board?.shuffle`.
[^submit]: `board.clearEntry()` runs after both branches.
[^validate]: `entryWord` maps positions through `letters`; `picked.contains(centreIndex)` tests the tile.
[^spec-order]: The table in section 5 of the spec gives the order and the messages.
[^tally-add]: `add` appends to `_found`, and adds to `_solutions` when the word is new.
[^empty-test]: The test counts listener calls and expects 0.
[^validation-tests]: "too short comes before a missing centre tile".
