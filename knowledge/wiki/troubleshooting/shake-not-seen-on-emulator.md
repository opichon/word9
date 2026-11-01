---
type: Troubleshooting
id: wiki-troubleshooting-shake-not-seen-on-emulator
title: Shake Not Seen on the Emulator
description: "An acceptance test cannot sample a 300 ms animation on a slow emulator: why AT-2 was split, and the rule that follows for timing in acceptance tests."
tags: [troubleshooting, testing, animation, emulator]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: sample-commit
    resource: https://github.com/opichon/word9/commit/f2717cb
    title: "test: sample the shake across real frames in AT-2"
  - id: clock-commit
    resource: https://github.com/opichon/word9/commit/aa63132
    title: "test: prove the shake with a controlled clock"
  - id: widget-commit
    resource: https://github.com/opichon/word9/commit/0b17d85
    title: "test: add the widget test for the shake's movement"
  - id: at-2
    resource: repo://integration_test/play_test.dart#L53-L55
    title: The comment in AT-2
    last_modified: 2026-11-01
  - id: widget-test
    resource: repo://test/widgets/game_screen_test.dart#L44-L59
    title: Widget test with a controlled clock
    last_modified: 2026-11-01
  - id: entry
    resource: repo://lib/ui/entry_display.dart#L18-L21
    title: The shake's duration
    last_modified: 2026-11-01
  - id: plan-step-11
    resource: repo://specs/feature-word9-flutter-app-plan.md#L380-L385
    title: Plan, step 11
    last_modified: 2026-10-31
---

[Home](../../index.md) › [Troubleshooting](index.md) › Shake Not Seen on the Emulator

# Shake Not Seen on the Emulator

## Symptom

An acceptance test that samples an animation's position across real frames fails on an emulator, though the animation works.

## Cause

The emulator's frames can be slower than the 300 ms shake,[^entry] so a test can miss the whole movement. This history is a sequence: first AT-2 sampled the shake across real frames,[^sample-commit] then the approach was replaced with a controlled clock,[^clock-commit] and then the movement check became a widget test.[^widget-commit]

## Fix in place

The check is split in two:[^at-2]

| Test | Checks | Clock |
| ---- | ------ | ----- |
| AT-2, on a device | The shake is triggered: `controller.shakes` is 1 | Real |
| Widget test, in `test/widgets/` | The offset is -6, then 6, then 0 at 75, 225 and 300 ms[^widget-test] | Controlled by `tester.pump` |

## Rule that follows

Do not assert timing in `integration_test/`. Test that a thing was triggered there, and test how it moves in a widget test. Banner timing (CT-2) is planned this way too, as a component test with a replaceable clock.[^plan-step-11]

## Limit of this split

Neither test looks at whether letters are on screen during the shake: see [Game screen](../ui/game-screen.md#what-a-rejected-entry-looks-like).

[^plan-step-11]: "shelf and banner widgets in `lib/ui/`, with a replaceable clock", and tests including CT-2.
[^entry]: `Duration(milliseconds: 300)`.
[^sample-commit]: Changes `integration_test/play_test.dart` only.
[^clock-commit]: "The emulator's frames can be slower than the shake, so AT-2 checks that it is triggered, and a widget test checks the movement."
[^widget-commit]: Adds the test to `test/widgets/game_screen_test.dart`.
[^at-2]: "The emulator's frames can be slower than the 300 ms shake, so check here that it's triggered. The game screen's widget test checks the movement."
[^widget-test]: Pumps of 75, 150 and 75 ms, and offsets -6, 6 and 0.
