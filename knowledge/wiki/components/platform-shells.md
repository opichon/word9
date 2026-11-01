---
type: Component
id: wiki-components-platform-shells
title: Platform Shells
description: "android/ and ios/: close to Flutter's template, with the settings that matter for word9 and where the two platforms differ."
tags: [component, android, ios, native]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: gradle
    resource: repo://android/app/build.gradle.kts#L7-L39
    title: Android app build configuration
    last_modified: 2026-11-01
  - id: android-manifest
    resource: repo://android/app/src/main/AndroidManifest.xml
    title: Android main manifest
    last_modified: 2026-11-01
  - id: android-debug-manifest
    resource: repo://android/app/src/debug/AndroidManifest.xml
    title: Android debug manifest
    last_modified: 2026-11-01
  - id: info-plist
    resource: repo://ios/Runner/Info.plist#L9-L18
    title: iOS names
    last_modified: 2026-11-01
  - id: info-plist-orientation
    resource: repo://ios/Runner/Info.plist#L56-L68
    title: iOS orientations
    last_modified: 2026-11-01
  - id: pbxproj
    resource: repo://ios/Runner.xcodeproj/project.pbxproj#L363-L386
    title: iOS deployment target and bundle id
    last_modified: 2026-11-01
  - id: spec-minimum
    resource: repo://specs/feature-word9-flutter-app.md#L71-L73
    title: Spec, platforms
    last_modified: 2026-10-31
  - id: spec-text
    resource: repo://specs/feature-word9-flutter-app.md#L87-L87
    title: Spec, title text
    last_modified: 2026-10-31
  - id: justfile
    resource: repo://justfile#L47-L55
    title: The justfile reads the Gradle file
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Components](index.md) › Platform Shells

# Platform Shells

`android/` and `ios/` carry no app logic and stay close to Flutter's template, with `com.opichon.word9` as the identifier on both.[^gradle][^pbxproj]

## Settings that come from Flutter

The spec makes minimum OS versions Flutter's defaults at build time, so **upgrading Flutter can silently change them**.[^spec-minimum] On Android `minSdk`, `targetSdk` and `compileSdk` all read from `flutter.*`.[^gradle] iOS records its target directly, as 15.0.[^pbxproj]

The Gradle lines are read by a tool as well: `just setup-android` greps for `minSdk = flutter.minSdkVersion` and fails if the line changes.[^justfile] See [First run](../local/first-run.md#android-emulators).

## Where the two platforms differ

| Concern | Android | iOS |
| ------- | ------- | --- |
| Network permission | Absent from the main manifest, present in debug and profile for tooling[^android-manifest][^android-debug-manifest] | Not a permission concept |
| Name on the home screen | `word9`[^android-manifest] | **`Word9`** (`CFBundleDisplayName`)[^info-plist] |
| Portrait lock | Not requested yet | Not requested, and iPhone landscape is listed[^info-plist-orientation] |
| Release signing | Debug key today | Built with `--no-codesign` in CI |

## Open questions

- Is the iOS display name `Word9` deliberate? The spec writes the title as "word9",[^spec-text] and Android matches it. The capital looks like Flutter's project template, but nothing in the history says either way.

## Related pages

- [Network posture](../security/network-posture.md) covers the permission check.
- [Release builds use the debug key](../technical-debt/release-builds-use-debug-key.md) covers signing.

[^gradle]: `namespace` and `applicationId` are `com.opichon.word9`; SDK levels are `flutter.*`.
[^pbxproj]: `IPHONEOS_DEPLOYMENT_TARGET = 15.0`; `PRODUCT_BUNDLE_IDENTIFIER = com.opichon.word9`.
[^spec-minimum]: "The minimum OS versions are Flutter's defaults at build time."
[^justfile]: `grep -q "$1 = flutter.$2" android/app/build.gradle.kts || die ...`.
[^android-manifest]: No `uses-permission` element; `android:label="word9"`.
[^android-debug-manifest]: "The INTERNET permission is required for development."
[^info-plist]: `CFBundleDisplayName` is `Word9`; `CFBundleName` is `word9`.
[^info-plist-orientation]: `UISupportedInterfaceOrientations` includes both landscape values.
[^spec-text]: "the title reads "word9" instead of "NineTile"".
