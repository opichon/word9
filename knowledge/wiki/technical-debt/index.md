[Home](../../index.md) › Technical debt

# Technical debt

Shortcuts taken knowingly and work deferred: why each one exists, what it costs today, and what paying it down would involve. Deprecate a page once its debt is paid.

## Known debt

- [Release Builds Use the Debug Key](release-builds-use-debug-key.md) - Android release builds on main are signed with the debug key, as Flutter's template leaves them; the fix is on an unmerged branch, partly blocked on the owner.
- [Speed Targets Unmeasured](speed-targets-unmeasured.md) - The spec's start and response targets have never been measured, because the named devices are not available; the JSON word-data choice rests on that measurement.
