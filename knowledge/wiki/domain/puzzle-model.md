---
type: Domain Concept
id: wiki-domain-puzzle-model
title: Puzzle Model
description: "What a puzzle is: a nine-letter word plus a centre letter, why the same word recurs, and why the centre letter and the centre tile are different things."
tags: [domain, puzzle, rules]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: puzzle
    resource: repo://lib/game/puzzles.dart#L3-L33
    title: Puzzle and PuzzleBook.fromJson
    last_modified: 2026-11-01
  - id: pick
    resource: repo://lib/game/puzzles.dart#L40-L51
    title: PuzzleBook.pick
    last_modified: 2026-11-01
  - id: deal
    resource: repo://lib/game/board.dart#L12-L17
    title: Board.deal
    last_modified: 2026-11-01
  - id: shuffle
    resource: repo://lib/game/board.dart#L40-L45
    title: Board.shuffle
    last_modified: 2026-11-01
  - id: spec-context
    resource: repo://specs/feature-word9-flutter-app.md#L55-L58
    title: Spec, puzzle and rules
    last_modified: 2026-10-31
  - id: spec-labels
    resource: repo://specs/feature-word9-flutter-app.md#L99-L101
    title: Spec, repeats and level labels
    last_modified: 2026-10-31
  - id: outer-tile-test
    resource: repo://test/unit/word_rules_test.dart#L43-L45
    title: UT-1, outer tile with the centre letter
    last_modified: 2026-11-01
  - id: levels
    resource: repo://tool/build_word_data.py#L41-L42
    title: Level rules
    last_modified: 2026-11-01
  - id: assets-gb
    resource: repo://assets/words/en-GB.json
    title: en-GB asset
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Domain](index.md) › Puzzle Model

# Puzzle Model

A puzzle is a nine-letter word, its **seed**, and a **centre letter** chosen from that word.[^puzzle] Players make words of at least 4 letters that use the centre tile, using each tile once.[^spec-context]

## Centre letter and centre tile are different

`Board.deal` removes **one** instance of the centre letter from the seed, puts it in position 4, and shuffles the rest.[^deal] When the letter occurs twice, the other instance stays on an outer tile. With `nominally` and centre `l`, an `l` remains outside.

So a word using only the outer `l` is rejected, even though it contains the letter: the rule is about the tile.[^outer-tile-test] This is not a rare corner: on the current en-GB asset, 1,520 of the 7,500 puzzles have a centre letter that occurs more than once in the seed (measured on 2026-11-02).[^assets-gb]

## Levels mean word count

A level is how many answers a puzzle has, not how hard its words are.[^levels]

| Level | Label to players | Answers at build time |
| ----- | ---------------- | --------------------- |
| 1, Easy | Up to 30 words | 15 to 30 |
| 2, Medium | 31 to 50 words | 31 to 50 |
| 3, Hard | Over 50 words | 51 to 80 |

The labels come from the spec.[^spec-labels] Note the count can pass the label in play, because an accepted word raises the total: see [Word lists](word-lists.md).

## Puzzles and seeds

- A puzzle is a (seed, centre) pair. All 7,500 pairs are distinct, but only 3,285 distinct seeds exist in en-GB, and a seed can recur up to 8 times with different centres (measured on 2026-11-02).[^assets-gb]
- A puzzle can repeat in play. There is no history, and that is deliberate parity with Nine Tile.[^spec-labels][^pick]
- The variants share 7,085 of their 7,500 puzzles, but not their positions, with only 215 at the same place in the file. So a test written for a position in one variant cannot assume the other: the first Hard puzzle is `souvenirs` in en-GB and `cruelties` in en-US (measured on 2026-11-02).[^assets-gb]

## Test pool

The test pool holds 25 small puzzles of 6 to 14 answers, for checking banners quickly. They carry no level in the file, and parse as level 1.[^puzzle] In test mode, `pick` ignores the level requested.[^pick]

## Shuffle

The centre tile never moves. `shuffle` also empties the entry, because the entry is positions and they would point at different letters afterwards.[^shuffle]

[^puzzle]: `Puzzle` has `centre`, `level` and `seed`; entries in `d` get `level: 1`.
[^spec-context]: "words have at least 4 letters and use the centre tile, and each tile can be used once per word".
[^deal]: `puzzle.seed.split('')..remove(puzzle.centre)`, where `List.remove` removes the first match only.
[^outer-tile-test]: "an outer tile with the centre letter is rejected".
[^assets-gb]: Counted by parsing `p`; en-US has 1,510 such puzzles and 3,266 distinct seeds.
[^levels]: `LEVELS = {1: (15, 30, ...), 2: (31, 50, ...), 3: (51, 80, ...)}`.
[^spec-labels]: "A puzzle can repeat, as there's no play history"; the level labels follow it.
[^pick]: "There's no play history, so a puzzle can repeat."
[^shuffle]: `_picked.clear()` follows the rearrangement. The reason given here is inference; the spec requires the behaviour.
