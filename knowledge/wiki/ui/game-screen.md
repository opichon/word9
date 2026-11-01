---
type: UI
id: wiki-ui-game-screen
title: Game Screen
description: "The app's one screen: how it rebuilds, the keys tests depend on, why it has no text input, and what a rejected entry actually looks like."
tags: [ui, flutter, widgets]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: screen
    resource: repo://lib/ui/game_screen.dart#L14-L54
    title: GameScreen.build
    last_modified: 2026-11-01
  - id: tile
    resource: repo://lib/ui/game_screen.dart#L74-L93
    title: Tiles
    last_modified: 2026-11-01
  - id: message
    resource: repo://lib/ui/game_screen.dart#L109-L124
    title: The message
    last_modified: 2026-11-01
  - id: entry
    resource: repo://lib/ui/entry_display.dart#L31-L70
    title: EntryDisplay
    last_modified: 2026-11-01
  - id: submit
    resource: repo://lib/state/game_controller.dart#L107-L116
    title: submit clears the entry
    last_modified: 2026-11-01
  - id: driver
    resource: repo://test/support/game_driver.dart#L13-L32
    title: GameDriver looks widgets up by key
    last_modified: 2026-11-01
  - id: shake-test
    resource: repo://test/widgets/game_screen_test.dart#L44-L59
    title: The widget test for the shake
    last_modified: 2026-11-01
  - id: at-2
    resource: repo://integration_test/play_test.dart#L46-L57
    title: AT-2
    last_modified: 2026-11-01
  - id: spec-order
    resource: repo://specs/feature-word9-flutter-app.md#L88-L88
    title: Spec, a rejected entry
    last_modified: 2026-10-31
  - id: ct-9
    resource: repo://test/widgets/game_screen_test.dart#L61-L83
    title: CT-9, no keyboard
    last_modified: 2026-11-01
  - id: step-7
    resource: https://github.com/opichon/word9/commit/416cec1
    title: "feat: play a real puzzle by tapping"
---

[Home](../../index.md) › [UI](index.md) › Game Screen

# Game Screen

The app has one screen, with the title, grid, entry, message, controls and words found in a single `ListView`.[^screen] Its look is provisional until plan steps 17 and 18, so do not treat colours or sizes as design decisions.[^step-7]

## How it rebuilds

A single `ListenableBuilder` at the top rebuilds the whole list on every controller notification.[^screen] There is no per-widget subscription. Only `EntryDisplay` holds state of its own, and that state is only its animation.

## Keys tests depend on

These `ValueKey`s are part of the test contract. `GameDriver` finds them by name, so renaming one breaks every acceptance test rather than one.[^driver]

| Key | Widget |
| --- | ------ |
| `tile-0` to `tile-8` | Each tile[^tile] |
| `entry` | The entry's text[^entry] |
| `entry-shake` | The moving `Transform`[^entry] |
| `message` | The message text[^message] |

Controls have no keys: tests find them by their label, such as `Delete`.

## How tiles show as used

A used tile has `onPressed: null`, so Flutter's disabled style is the "used" look and a second tap cannot reach the controller.[^tile] Tests read `onPressed` to check it.

## No keyboard, by construction

There is no `TextField` or key handler anywhere on the screen. So hardware keys do nothing and no on-screen keyboard can open, and CT-9 proves both.[^ct-9] This is a deliberate spec boundary. See [Nine Tile parity](../domain/nine-tile-parity.md).

## What a rejected entry looks like

`submit` raises `_shakes` and clears the entry **in the same step**, before listeners run.[^submit] So the first frame of the 300 ms shake already has no letters: `EntryDisplay` animates an empty line.[^entry]

The tests cannot see this. The widget test named "a rejected entry visibly shakes" reads only the transform's offset, and AT-2 asserts the entry is empty straight after the tap.[^shake-test][^at-2]

## Open questions

- Is the shake meant to be visible? The spec says a rejection "shows its message, shakes the entry and clears it", which suggests letters should shake and then go.[^spec-order] As written, the player sees the letters vanish and the message appear. Nine Tile's own order was not checked for this page.

[^screen]: `ListenableBuilder` wraps the `ListView`.
[^step-7]: "The look is provisional, and nothing is saved yet."
[^driver]: `find.byKey(ValueKey('tile-$index'))`, `entry`, `message`, `entry-shake`.
[^tile]: `key: ValueKey('tile-$index')`, and `onPressed: board.picked.contains(index) ? null : ...`.
[^entry]: `key: const ValueKey('entry-shake')` and `key: const ValueKey('entry')`; the shake starts in `didUpdateWidget`, and the letters come from the same rebuild.
[^message]: `key: const ValueKey('message')`.
[^ct-9]: `expect(find.byType(EditableText), findsNothing)`.
[^submit]: `_shakes++`, then `board.clearEntry()`, then `notifyListeners()`.
[^shake-test]: `expect(game.shakeOffset, -6)`; it never reads the entry's text.
[^at-2]: `expect(game.entry, isEmpty)` right after `tapControl('Enter')`.
[^spec-order]: "the first failure shows its message, shakes the entry and clears it".
