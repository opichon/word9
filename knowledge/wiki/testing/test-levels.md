---
type: Testing
id: wiki-testing-test-levels
title: Test Levels
description: "The levels of the test suite, what each one runs for real, which command and CI job runs it, and which levels have nothing in them yet."
tags: [testing, flutter, levels]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: strategy
    resource: repo://specs/feature-word9-flutter-app-test-plan.md#L42-L53
    title: Test plan, strategy
    last_modified: 2026-10-31
  - id: at
    resource: repo://integration_test/play_test.dart#L23-L57
    title: AT-1 and AT-2
    last_modified: 2026-11-01
  - id: it-2
    resource: repo://test/integration/word_data_test.dart#L12-L14
    title: IT-2 reads a fixture by relative path
    last_modified: 2026-11-01
  - id: ut-2
    resource: repo://test/unit/solve_parity_test.dart#L11-L15
    title: UT-2 reads the asset from disk
    last_modified: 2026-11-01
  - id: python
    resource: repo://tool/test_check_word_data.py#L2-L2
    title: Python tests
    last_modified: 2026-11-01
  - id: plan-coverage
    resource: repo://specs/feature-word9-flutter-app-plan.md#L553-L605
    title: Plan, coverage table
    last_modified: 2026-10-31
  - id: ci-test
    resource: repo://.github/workflows/ci.yml#L95-L107
    title: The test job
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Testing](index.md) › Test Levels

# Test Levels

Tests are named by their test-plan id, and the prefix gives the level.[^strategy] On 2026-11-02, `flutter test` passed 38 tests and the Python suite 10.

## Levels and how they run

| Prefix | Level | Location | Runs for real | Command |
| ------ | ----- | -------- | ------------- | ------- |
| AT | Acceptance | `integration_test/` | App, real word data | `flutter test integration_test`, on a device |
| IT | Integration | `test/integration/` | Packaged assets | `flutter test` |
| CT | Component | `test/widgets/` | One widget tree, on the small fixture | `flutter test` |
| UT | Unit | `test/unit/` | Rules | `flutter test` |
| none | Contract | `tool/test_check_word_data.py` | The Python check | `python3 -m unittest discover -s tool`[^python] |
| NF | Non-functional | Mixed | See below | Mixed |

**Only NF-4 and NF-7 exist among the non-functional tests**, as the `android-build` and `ios-build` jobs: see [Pull request checks](../ci/pull-request-checks.md). The rest arrive with later steps, and the manual ones with `docs/release-checklist.md`.[^plan-coverage]

## What exists so far

| Written | Not yet |
| ------- | ------- |
| AT-1, AT-2, plus a smoke test[^at] | AT-3 to AT-18 |
| IT-2; IT-1 is the on-demand Python rebuild | IT-3 to IT-7 |
| CT-1, CT-9, and the AT-2 shake detail | The other CTs |
| UT-1 to UT-8 | |

## Constraints behind the setup

- **Tests run from the repository root.** Unit and integration tests open `test/fixtures/...` and `assets/words/...` with `File` and a relative path.[^it-2][^ut-2] CI runs it from the root, as `flutter test` does by default,[^ci-test] and an IDE runner set to another folder will fail on file-not-found.
- **Acceptance tests can only reach what the app bundles.** They run on the device, where `File('test/fixtures/...')` does not exist, so they use `rootBundle` through `controller.load`, not fixtures.[^at]
- **`crypto` is a dev dependency only for IT-2's digest.** Do not import it from `lib/`.

## Related pages

- [Test seams and fixtures](test-seams-and-fixtures.md) covers the shared helpers.
- [Shake not seen on the emulator](../troubleshooting/shake-not-seen-on-emulator.md) explains why AT-2 is split.

[^ci-test]: The `test` job runs `flutter test` with no working directory set.
[^strategy]: The table in section 2 of the test plan.
[^python]: The file's own docstring gives this command.
[^plan-coverage]: The plan's section 9 maps each spec item to its step and tests.
[^at]: `tester.runAsync(controller.load)` loads the real asset.
[^it-2]: `File('test/fixtures/word_data_digests.json')`.
[^ut-2]: `readJson('assets/words/$lang.json')`.
