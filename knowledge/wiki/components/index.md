[Home](../../index.md) › Components

# Components

One concept per app, library, service, or tool in the project.

## Components

- [App State](app-state.md) - lib/state/: GameController and the word-data loader, what they own, why state is a ChangeNotifier, and what the design adds on top.
- [Game Rules](game-rules.md) - lib/game/: the Flutter-free rules of a puzzle, how its pieces divide the work, and which of them the app does not call yet.
- [Platform Shells](platform-shells.md) - android/ and ios/: close to Flutter's template, with the settings that matter for word9 and where the two platforms differ.
- [Word-data Tool](word-data-tool.md) - tool/: the Python build and checks for word data, the rules that decide which words and puzzles exist, and the details the exact match depends on.
