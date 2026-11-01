---
type: Security
id: wiki-security-network-posture
title: Network Posture
description: "word9 makes no network requests and holds no user data: how that is required, what enforces it on each platform, and what the planned links change."
tags: [security, privacy, network, permissions]
status: draft
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-02T00:50:00+07:00
sources:
  - id: spec-offline
    resource: repo://specs/feature-word9-flutter-app.md#L78-L81
    title: Spec, offline and privacy
    last_modified: 2026-10-31
  - id: ci-permission
    resource: repo://.github/workflows/ci.yml#L46-L55
    title: NF-4, the permission check
    last_modified: 2026-11-01
  - id: main-manifest
    resource: repo://android/app/src/main/AndroidManifest.xml
    title: Android main manifest
    last_modified: 2026-11-01
  - id: debug-manifest
    resource: repo://android/app/src/debug/AndroidManifest.xml
    title: Android debug manifest
    last_modified: 2026-11-01
  - id: profile-manifest
    resource: repo://android/app/src/profile/AndroidManifest.xml
    title: Android profile manifest
    last_modified: 2026-11-01
  - id: design-browser
    resource: repo://specs/feature-word9-flutter-app-design.md#L708-L713
    title: Design, opening pages
    last_modified: 2026-11-01
  - id: pubspec
    resource: repo://pubspec.yaml#L10-L12
    title: Run-time dependencies
    last_modified: 2026-11-01
---

[Home](../../index.md) › [Security](index.md) › Network Posture

# Network Posture

The spec's boundary is simple: **the app itself makes no network requests**. No accounts, analytics, ads, crash reporting or purchases. The only network use is a page opened in the browser, for a dictionary entry or the privacy policy.[^spec-offline] So there are no credentials, sessions or user data for the app to protect.

## Controls by platform

| Control | Android | iOS |
| ------- | ------- | --- |
| Release build cannot reach the network | `INTERNET` is absent from the main manifest[^main-manifest] | No equivalent permission |
| Checked on each PR | NF-4: CI dumps the release APK's permissions and fails on `INTERNET`[^ci-permission] | Nothing automatic |
| No networking code | Only Flutter at run time[^pubspec] | Same |

On iOS, the claim rests on the absence of any networking dependency, and on the manual packet capture the plan schedules for step 19 (NF-5), which has not happened.

`INTERNET` stays in the debug and profile manifests because Flutter's tooling needs it.[^debug-manifest][^profile-manifest] So only a release APK proves anything, which is why NF-4 builds one.

## What the planned links change

The design chose the external browser over an in-app tab for dictionary and policy pages, as the plainest fit with "no network requests".[^design-browser] Adding `url_launcher` at step 12 should not need `INTERNET`, though the design notes the Android manifest will need a query for `https` links. NF-4 will catch it if a new dependency brings the permission in.

## Related pages

- [Supply-chain controls](supply-chain-controls.md) covers what enters the build.

[^spec-offline]: "The app itself makes no network requests."
[^main-manifest]: The manifest has no `uses-permission` element.
[^ci-permission]: `aapt2 dump permissions`, then `grep -q 'android.permission.INTERNET'`.
[^debug-manifest]: "The INTERNET permission is required for development."
[^profile-manifest]: The same comment and permission.
[^pubspec]: `dependencies` holds only `flutter`.
[^design-browser]: "External browser app, by the owner: it fits C-6 most plainly".
