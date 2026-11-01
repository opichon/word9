---
type: Architecture
id: wiki-architecture-built-versus-planned
title: Built Versus Planned
description: "Which parts of the word9 spec exist on main and which are only planned, so that the specs are not read as a description of the code."
tags: [status, specs, plan, orientation]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: plan-steps
    resource: repo://specs/feature-word9-flutter-app-plan.md#L167-L193
    title: Implementation plan, table of steps
    last_modified: 2026-10-31
  - id: design-components
    resource: repo://specs/feature-word9-flutter-app-design.md#L166-L226
    title: Design, component diagram of the app
    last_modified: 2026-11-01
  - id: step-7
    resource: https://github.com/opichon/word9/commit/416cec1
    title: "feat: play a real puzzle by tapping"
  - id: pr-14
    resource: https://github.com/opichon/word9/pull/14
    title: "Draft PR #14, step 8, signing"
  - id: controller-start
    resource: repo://lib/state/game_controller.dart#L62-L72
    title: GameController.start
    last_modified: 2026-11-01
  - id: app-root
    resource: repo://lib/ui/word9_app.dart#L23-L28
    title: The app root builds its own controller
    last_modified: 2026-11-01
  - id: pubspec
    resource: repo://pubspec.yaml#L10-L20
    title: Dependencies
    last_modified: 2026-11-01
  - id: info-plist
    resource: repo://ios/Runner/Info.plist#L56-L61
    title: iOS supported orientations
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Architecture](index.md) › Built Versus Planned

# Built Versus Planned

`specs/` describes the finished app. The code is well short of it. **Read the specs as the target, and this page as how far the code has got**, as of `main` at `0dca297` on 2026-11-02.

## Plan steps by state

| Steps | State |
| ----- | ----- |
| 1 to 7: shell, word data, rules, parity, a playable puzzle | Merged[^plan-steps] |
| 8: signing | Android half on the unmerged branch `feat/step-8-signing`, Apple half waiting on the owner's account[^pr-14] |
| 9 to 25: Diawi, level picker, banners, reveal, saved games, settings, test mode, theme, stores | Not started[^plan-steps] |

Step 7's own commit says the look is provisional and nothing is saved.[^step-7]

## Behaviour the specs describe that the code does not have

| Spec describes | What the code does today |
| -------------- | ------------------------ |
| Level picker, Medium and Hard | `start` always picks level 1, with test mode off[^controller-start] |
| en-US variant, chosen by locale or in settings | The root hard-codes `en-GB`[^app-root] |
| `SessionController`, `GameStore`, saved state[^design-components] | None of them exists, so a restart loses the game |
| `shared_preferences`, `url_launcher` | Not dependencies. The app has only Flutter at run time[^pubspec] |
| Portrait lock | No orientation request in `lib/`, and iOS still lists both landscape orientations for iPhone[^info-plist] |
| Theme, bundled fonts, 440 pt width, reduced motion, screen-reader labels | Not in `lib/ui/` (steps 17 and 18)[^plan-steps] |
| `docs/` with the privacy policy, release checklist and signing notes | No `docs/` folder on `main` |

## Code that exists with nothing calling it

Plan steps built the rules before the UI that uses them, so these are tested but unreachable in the app:

- `BannerTracker`: banner selection works in unit tests, and no banner ever shows.
- `WordLists.dictionaryAddress` and `WordTally.allWords`: waiting for reveal and dictionary links.
- `PuzzleBook.pick(testMode: true)` and the `d` test pool: waiting for test mode.

Do not delete these as dead code. They are the plan's steps 11, 12 and 16 half delivered: see [Game rules](../components/game-rules.md).

## How to keep this page true

This page goes stale with every merged step. Update it when a plan step lands, or the specs will again read as fact.

## Related pages

- [Spec-driven delivery](../conventions/spec-driven-delivery.md) explains how steps become pull requests.
- [Release builds use the debug key](../technical-debt/release-builds-use-debug-key.md) covers what step 8 leaves open.

[^plan-steps]: The plan numbers the steps; which are merged comes from PRs #7 to #13 and #18.
[^design-components]: The design marks `SessionController`, `GameStore` and Saved state as New relative to `34d58ac`.
[^step-7]: "The look is provisional, and nothing is saved yet."
[^pr-14]: The PR lists the Apple account, registered iPhones, certificate, profile and Diawi token as blocked on the owner.
[^controller-start]: `data.book.pick(level: 1, random: _random, testMode: false)`.
[^app-root]: `GameController(lang: 'en-GB', random: Random())`.
[^pubspec]: `crypto`, `flutter_lints`, `flutter_test` and `integration_test` are all dev dependencies.
[^info-plist]: `UISupportedInterfaceOrientations` lists Portrait, LandscapeLeft and LandscapeRight.
