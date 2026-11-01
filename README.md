# word9

A nine-tile word game for Android and iOS, with the same features as the Nine Tile web app. It works offline and needs no account.

Specs, test plan and implementation plan are in [specs/](specs/index.md).

## Development

Uses Flutter 3.47.4.

```sh
flutter pub get
flutter analyze
flutter test                   # unit, component and integration tests
flutter test integration_test  # acceptance tests, on a simulator or emulator
flutter run
```

To compare the project's Flutter version with the latest stable release, run `just flutter-latest`, which needs `curl` and `jq`.

### Android emulators

With Android Studio and [just](https://just.systems) installed, this installs the images and creates a virtual device for each API level:

```sh
just setup-android
```

It works out the levels to use: `minSdk` and `targetSdk` from the Flutter version in use, and the newest stable image from the Android SDK. The variables at the top of the [justfile](justfile) pin a level or add others.
