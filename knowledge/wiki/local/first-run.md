---
type: Setup
id: wiki-local-first-run
title: First Run
description: "From clone to a running game and passing tests, with the toolchain, the one-time git setting, Android emulators, and the local snags."
tags: [setup, local, flutter, mise, android]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: readme
    resource: repo://README.md#L9-L29
    title: README, development
    last_modified: 2026-11-01
  - id: mise
    resource: repo://mise.toml
    title: mise tools
    last_modified: 2026-11-02
  - id: hook
    resource: repo://.githooks/pre-commit#L2-L4
    title: Pre-commit hook
    last_modified: 2026-11-02
  - id: just-levels
    resource: repo://justfile#L46-L74
    title: Choosing Android levels
    last_modified: 2026-11-01
  - id: just-avd
    resource: repo://justfile#L87-L100
    title: Creating virtual devices
    last_modified: 2026-11-01
  - id: just-latest
    resource: repo://justfile#L9-L26
    title: The default recipe and flutter-latest
    last_modified: 2026-11-01
  - id: gitignore
    resource: repo://.gitignore#L4-L4
    title: "Ignored: compiled Python"
    last_modified: 2026-11-01
  - id: pyc-commit
    resource: https://github.com/opichon/word9/commit/8b64a32
    title: The commit that added the tracked compiled files
  - id: python-test
    resource: repo://.github/workflows/word-data.yml#L6-L10
    title: Python checks and their version
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Local](index.md) › First Run

# First Run

`flutter analyze`, `flutter test` and the two Python checks were run on macOS on 2026-11-02, with Flutter 3.47.9. A fresh clone, `flutter run`, `flutter test integration_test` and `just setup-android` were not.

## Toolchain

| Tool | Needed for | Comes from |
| ---- | ---------- | ---------- |
| Flutter 3.47.9, Dart 3.13.7 | Everything | `mise install`[^mise] |
| Xcode, Android Studio | Running on a device | Installed by hand |
| Python 3 (3.12 in CI) | Word-data checks only | **Not pinned by mise**[^python-test] |
| just, curl, jq | The two `just` recipes only | Installed by hand[^readme] |
| repokb | Knowledge base maintenance | `mise install`[^mise] |

No environment variables, services, or secrets are needed. There is no database, and no seed step.

## Clone to running

```sh
mise install
git config core.hooksPath .githooks   # once per clone
flutter pub get
flutter analyze                       # no issues on 2026-11-02
flutter test                          # 38 tests pass in seconds
flutter run
```

Acceptance tests need a running simulator or emulator: `flutter test integration_test`.[^readme]

The word-data checks are separate from `flutter test`:

```sh
python3 -B -m unittest discover -s tool                              # 10 tests
python3 -B tool/check_word_data.py assets/words/en-GB.json assets/words/en-US.json
```

## Snags

- **Plain `flutter test` skips the acceptance tests.** Passing locally says nothing about `integration_test/`. CI runs them on both platforms.
- **`git config core.hooksPath` looks optional and is not.** Without it, a commit touching `knowledge/` skips the catalog rebuild, and the `kb-catalog` check fails on the PR.[^hook]
- **Running Python without `-B` can dirty the tree.** Two `.pyc` files in `tool/__pycache__/` are tracked,[^pyc-commit] despite `*.pyc` in `.gitignore`, which does not apply to tracked files.[^gitignore] Hence the `-B` above.
- **`flutter test` must run from the repository root.** Tests read fixtures and assets by relative path: see [Test levels](../testing/test-levels.md).
- **SCOWL is not needed.** The word data is committed; only a rebuild downloads it.

## Android emulators

`just setup-android` installs images and creates a virtual device per API level, named `word9_api<level>`, skipping any that exist.[^just-avd] It takes the levels from three places:[^just-levels]

| Level | Comes from |
| ----- | ---------- |
| Minimum and target | Flutter's own `FlutterExtension.kt`, in the Flutter checkout in use |
| Latest | The newest stable Google APIs image in `sdkmanager` for this Mac's chip |

It needs Android Studio's command-line tools, and stops with instructions if they are missing. Because it reads Flutter's source and the app's Gradle file, a Flutter upgrade can break the parsing. It then says so, and names the justfile variable to pin instead.[^just-levels]

A bare `just` only lists recipes, so that it cannot start those downloads by accident. `just flutter-latest` compares the pin in `pubspec.yaml` with the latest stable release.[^just-latest]

[^mise]: `flutter` and `npm:@dzangolab/repokb`.
[^python-test]: CI sets `python-version: "3.12"`; `mise.toml` has no Python entry.
[^readme]: The README covers `just`, `curl` and `jq`, and the test commands.
[^hook]: "Enable once per clone: git config core.hooksPath .githooks".
[^pyc-commit]: `git log -- tool/__pycache__` shows only this commit.
[^gitignore]: `*.pyc`.
[^just-avd]: `name="word9_api${level%.0}"`; `already exists`.
[^just-levels]: `flutter_level` reads `FlutterExtension.kt`, `latest_level` reads `sdkmanager --list`, and each `die`s naming the variable.
[^just-latest]: `sed -n 's/^  flutter: //p' pubspec.yaml`.
