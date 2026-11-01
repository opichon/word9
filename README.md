# word9

A nine-tile word game for Android and iOS, with the same features as the Nine Tile web app. It works offline and needs no account.

Specs, test plan and implementation plan are in [specs/](specs/index.md).

## Development

Uses Flutter 3.47.9, installed with [mise](https://mise.jdx.dev): run `mise install` in this folder.

```sh
flutter pub get
flutter analyze
flutter test                   # unit, component and integration tests
flutter test integration_test  # acceptance tests, on a simulator or emulator
flutter run
```
