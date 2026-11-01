---
type: Architecture
id: wiki-architecture-app-startup
title: App Startup
description: "How a launch gets from main() to a playable grid: what runs off the UI thread, what does not, and what happens if the asset cannot load."
tags: [startup, flutter, state, word-data]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: app-root
    resource: repo://lib/ui/word9_app.dart#L19-L34
    title: Word9App state and controller ownership
    last_modified: 2026-11-01
  - id: controller-load
    resource: repo://lib/state/game_controller.dart#L50-L72
    title: GameController.load and start
    last_modified: 2026-11-01
  - id: word-data-load
    resource: repo://lib/state/word_data.dart#L22-L29
    title: loadWordData
    last_modified: 2026-11-01
  - id: solve
    resource: repo://lib/game/word_lists.dart#L35-L41
    title: WordLists.solve
    last_modified: 2026-11-01
  - id: screen-spinner
    resource: repo://lib/ui/game_screen.dart#L20-L28
    title: GameScreen shows a spinner until the board exists
    last_modified: 2026-11-01
  - id: adr
    resource: repo://specs/adr/adr-word-data-pipeline.md#L57-L62
    title: "ADR: word-data pipeline, consequences"
    last_modified: 2026-10-31
  - id: shell-test
    resource: repo://test/widgets/word9_app_test.dart#L5-L9
    title: The app shell test
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Architecture](index.md) › App Startup

# App Startup

There is no splash, no storage read and no routing: one asset load stands between launch and a puzzle.

## Startup sequence

1. `main()` runs `Word9App`. Its state creates a `GameController` for `en-GB` with an unseeded `Random`, and calls `load()` without awaiting it.[^app-root]
2. The first frame renders immediately. With `board == null`, `GameScreen` shows the title and a spinner.[^screen-spinner]
3. `loadWordData` reads `assets/words/en-GB.json`, then decodes it with `compute`. Decoding includes splitting the strings and building the sets, so that work is off the UI thread too.[^word-data-load]
4. Back on the UI thread, `start` picks a puzzle, deals the board and **solves it there, scanning every answer in the variant**.[^solve]
5. `notifyListeners` replaces the spinner with the board.[^controller-load]

Step 4 sets `_board` and `_tally` before notifying. `tally` is `late`, and the screen reads it only when the board is non-null, so that order is what keeps it safe.[^controller-load]

## Who owns the controller

`Word9App` takes an optional controller. When it is given one, as tests do, it neither loads nor disposes it; the caller owns both.[^app-root] This is the seam every test uses to fix the random source: see [Test seams and fixtures](../testing/test-seams-and-fixtures.md).

`load` checks `_disposed` before calling `start`, because the asset can finish after the widget has gone. The shell test relies on this: it pumps the app, never waits for the load, and tears down.[^shell-test]

## Failure behaviour

**A failed asset load leaves the spinner up for good.** Nothing catches an error from `load()`, which is called fire-and-forget, and there is no error state on the screen.[^controller-load] The assets ship inside the app package, so this needs a broken build rather than bad luck, and no spec item covers it.

## Speed

Only the active variant's asset is loaded, by design, because each holds about 70,000 words.[^adr] The spec's 3 s cold-start target has not been measured: see [Speed targets unmeasured](../technical-debt/speed-targets-unmeasured.md).

## Inference on this page

The claim that a load failure needs a broken build is inference from the assets being packaged. Nothing tests it.

[^app-root]: `widget.controller ?? (GameController(lang: 'en-GB', random: Random())..load())`; `dispose` only runs when `widget.controller == null`.
[^screen-spinner]: `if (board == null) const Center(child: CircularProgressIndicator())`.
[^word-data-load]: `compute(_decode, source)`, where `_decode` calls `WordData.fromJson`.
[^solve]: `answers.where(...)`, with no index.
[^controller-load]: `load` awaits `loadWordData` with no `try`; `start` assigns `_board`, then `_tally`, then notifies.
[^adr]: "Only the active variant's asset is loaded, off the UI thread."
[^shell-test]: The test expects the title and finishes.
