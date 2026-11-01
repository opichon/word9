---
type: Testing
id: wiki-testing-test-seams-and-fixtures
title: Test Seams and Fixtures
description: "How tests fix the puzzle: the injected random source, the game driver, the three fixtures, and the tests that depend on the first Easy puzzle in the real data."
tags: [testing, fixtures, helpers]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: fixed-random
    resource: repo://test/support/fixed_random.dart
    title: FixedRandom
    last_modified: 2026-11-01
  - id: driver
    resource: repo://test/support/game_driver.dart#L37-L59
    title: GameDriver tap helpers
    last_modified: 2026-11-01
  - id: open-test
    resource: repo://test/widgets/game_screen_test.dart#L20-L26
    title: Opening a game in a widget test
    last_modified: 2026-11-01
  - id: open-at
    resource: repo://integration_test/play_test.dart#L12-L21
    title: Opening a game in an acceptance test
    last_modified: 2026-11-01
  - id: at-1
    resource: repo://integration_test/play_test.dart#L40-L44
    title: AT-1 assertions on the real data
    last_modified: 2026-11-01
  - id: fixture
    resource: repo://test/fixtures/word_data.json
    title: Small word-data fixture
    last_modified: 2026-11-01
  - id: word-rules-fixture
    resource: repo://test/unit/word_rules_test.dart#L9-L17
    title: The test puzzle
    last_modified: 2026-11-01
  - id: parity
    resource: repo://tool/generate_parity_fixture.mjs#L6-L7
    title: Parity fixture sample
    last_modified: 2026-11-01
  - id: pick
    resource: repo://lib/game/puzzles.dart#L47-L50
    title: Choosing from the pool
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Testing](index.md) › Test Seams and Fixtures

# Test Seams and Fixtures

Every test that needs a known puzzle gets it the same way: by injecting a controller with a fixed random source.

## The injection seam

`Word9App(controller:)` accepts a ready controller, and `GameController` takes its `Random` as a constructor argument.[^open-test] Without those, the app makes its own with an unseeded `Random`.

`FixedRandom` implements `Random`, returning `value % max`.[^fixed-random] So `FixedRandom(0)` always takes the first entry from a pool.[^pick]

## The first Easy puzzle is load-bearing

`FixedRandom(0)` at level 1 gives the first Easy puzzle in the file, which is `nominally` with centre `l` in **both** the small fixture and the real en-GB asset.[^open-at][^fixture] So AT-1 asserts "+ LOAM" and "1 of 22" against real data.[^at-1]

The result: any regeneration that changes the order or contents of the Easy puzzles breaks the acceptance tests, even if the word data is otherwise valid.

## GameDriver

`GameDriver` taps tiles the way a player does, shared between widget and acceptance tests. Because the outer tiles are shuffled, tests choose by letter: `tapOuter('o')` finds a free outer tile showing it and returns the position.[^driver] `integration_test/` imports it by relative path from `test/support/`, so moving that folder breaks both.

## Fixtures

| File | Holds | Used by |
| ---- | ----- | ------- |
| `word_data.json` | A tiny valid asset: `nominally`'s 22 answers, plus `main` and the accepted word `moil`[^fixture] | UT, CT, the contract check |
| `word_data_digests.json` | SHA-256 per variant | IT-2, IT-1 |
| `solve_parity.json` | Nine Tile's own `solve` output for 25 test puzzles and 10 per level, per variant[^parity] | UT-2 |

In `word_data.json`, `main` is the word without an `l`: it is there so a solver that ignores the centre letter produces 23 words and fails. The solutions list in `word_rules_test.dart` has 22.[^word-rules-fixture] That purpose is inferred from the data, as nothing states it.

## Adding a test

- For a rule, use a unit test on the small fixture.
- For a widget, use `open` with `FixedRandom(0)` and drive it with `GameDriver`, or use a controlled clock for timing: see [Shake not seen on the emulator](../troubleshooting/shake-not-seen-on-emulator.md).
- Name it with its test-plan id.

[^open-test]: `GameController(lang: 'en-GB', random: FixedRandom(0))..start(data)`.
[^fixed-random]: `nextInt(int max) => value % max`.
[^pick]: `pool[random.nextInt(pool.length)]`.
[^open-at]: "the first Easy puzzle, `nominally` with centre `L`".
[^fixture]: `"p": "nominallyl1 bacterialb2 souvenirse3"`; `"x": "moil"`.
[^at-1]: `expect(find.text('1 of 22'), findsOneWidget)`.
[^driver]: `tapOuter` skips the centre and any picked tile.
[^parity]: "all 25 test-mode puzzles and the first 10 puzzles of each level, for each variant".
[^word-rules-fixture]: "The test puzzle's 22 answers."
