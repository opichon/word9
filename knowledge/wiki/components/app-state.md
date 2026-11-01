---
type: Component
id: wiki-components-app-state
title: App State
description: "lib/state/: GameController and the word-data loader, what they own, why state is a ChangeNotifier, and what the design adds on top."
tags: [component, state, flutter]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: plan-state
    resource: repo://specs/feature-word9-flutter-app-plan.md#L78-L87
    title: Plan, app state decision
    last_modified: 2026-10-31
  - id: controller
    resource: repo://lib/state/game_controller.dart#L22-L72
    title: GameController fields, load and start
    last_modified: 2026-11-01
  - id: design-decisions
    resource: repo://specs/feature-word9-flutter-app-design.md#L708-L718
    title: Design decisions
    last_modified: 2026-11-01
  - id: design-notes
    resource: repo://specs/feature-word9-flutter-app-design.md#L222-L224
    title: Design notes on the component diagram
    last_modified: 2026-11-01
  - id: shakes
    resource: repo://lib/state/game_controller.dart#L43-L44
    title: The shake counter
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Components](index.md) › App State

# App State

`lib/state/` sits between the widgets and the rules. It holds one `GameController`, a `ChangeNotifier`, and `loadWordData`. The owner chose `ChangeNotifier` over Riverpod and Bloc as built in and enough for this state, and recorded that it is easy to change behind `app-state`.[^plan-state]

## What GameController owns

| State | Lifetime |
| ----- | -------- |
| `lang`, `_random` | The controller's whole life, fixed at construction |
| `_data`, `_board`, `_tally` | Set by `start`, and replaced whole by the next `start`[^controller] |
| `_message` | Until the next tile tap, submission or `start` |
| `_shakes` | Only ever rises |

`_board` is nullable and doubles as the "still loading" signal. `_data` and `_tally` are `late`, so reading `tally` before `start` throws: the widgets avoid it by checking `board` first.[^controller]

`_shakes` is a counter rather than a flag so that two rejections in a row each trigger a shake: a widget compares the old and new values.[^shakes]

## The design's intended shape

The design keeps `GameController` as **one game for one variant and mode**, and adds a `SessionController` above it that replaces the controller on a switch, so that a switch cannot leak state from the previous game.[^design-decisions] So do not add variant switching or test mode by resetting fields here.

The design also puts state above the widgets so that a rotation keeps the entry and message.[^design-notes] Neither `SessionController` nor `GameStore` exists yet: see [Built versus planned](../architecture/built-versus-planned.md).

## Related pages

- [App startup](../architecture/app-startup.md) follows `load` and `start`.
- [Entry submission](../architecture/entry-submission.md) follows the input methods.

[^plan-state]: "Decision: `ChangeNotifier`, by the owner. ADR: Not needed: local, and easy to change behind `app-state`."
[^controller]: `Board? _board`, `late WordData _data`, `late WordTally _tally`.
[^shakes]: "How many times the entry has been rejected. Each rise shakes the entry."
[^design-decisions]: The "Owner of variant and test mode" row.
[^design-notes]: "State lives in the controllers, above the widgets, so a rotation rebuilds the layout and keeps the letters and message (EC-16)."
