---
okf_version: "0.2"
---

# Project knowledge Base

Durable knowledge for the project, kept as an [OKF v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) bundle. The code says what the system does; this says why, how we found out, and what to watch for.

Start here, then open only what you need. See [the authoring contract](AGENTS.md) before writing.

## Start here

- [Built versus planned](wiki/architecture/built-versus-planned.md) - which parts of the word9 spec exist on main and which are only planned
- [Nine Tile parity](wiki/domain/nine-tile-parity.md) - the reference that decides what a rule or text should be
- [Entry submission](wiki/architecture/entry-submission.md) - the path of a tap and an Enter through UI, controller and rules
- [Word data flow](wiki/architecture/word-data-flow.md) - how word lists reach the app, and the checks that prove they still match
- [First run](wiki/local/first-run.md) - from clone to a running game and passing tests

### Where to start for a task

| If you are | Start at |
| ---------- | -------- |
| Running it locally | [First run](wiki/local/first-run.md) |
| Adding a plan step or feature | [Built versus planned](wiki/architecture/built-versus-planned.md), then [Spec-driven delivery](wiki/conventions/spec-driven-delivery.md) |
| Changing a game rule | [Game rules](wiki/components/game-rules.md), and check [Nine Tile parity](wiki/domain/nine-tile-parity.md) first |
| Changing the screen or its state | [Game screen](wiki/ui/game-screen.md), [App state](wiki/components/app-state.md) |
| Changing word data or its build | [Rebuild word data](wiki/operations/rebuild-word-data.md) |
| Adding or fixing a test | [Test levels](wiki/testing/test-levels.md), [Test seams and fixtures](wiki/testing/test-seams-and-fixtures.md) |
| Diagnosing a failing check | [Pull request checks](wiki/ci/pull-request-checks.md), [Document workflows](wiki/ci/document-workflows.md) |
| Upgrading Flutter | [Upgrade Flutter](wiki/operations/upgrade-flutter.md) |
| Shipping a build | [Release builds use the debug key](wiki/technical-debt/release-builds-use-debug-key.md): no release path exists yet |

## Knowledge

- [Architecture](wiki/architecture/index.md) - cross-cutting structure, the couplings and orderings no single file makes obvious
- [CI](wiki/ci/index.md) - pipeline configuration, build and test workflows, and when they run
- [Components](wiki/components/index.md) - one concept per app, library, service, or tool
- [Conventions](wiki/conventions/index.md) - the patterns this repo expects you to follow
- [Domain](wiki/domain/index.md) - product and business knowledge: what the code's concepts mean to the business
- [Local](wiki/local/index.md) - getting the project running on a fresh machine, and the known snags
- [Operations](wiki/operations/index.md) - runbooks for setup, services, migrations, and release
- [Reference](wiki/reference/index.md) - standing explanations of concepts, terms, and external systems
- [Security](wiki/security/index.md) - threat model and the controls that address it: secrets, auth, transport, permissions
- [Technical debt](wiki/technical-debt/index.md) - known shortcuts and deferred work: why they exist, what they cost, and the way out
- [Testing](wiki/testing/index.md) - test setup, tooling, and the constraints behind them
- [Troubleshooting](wiki/troubleshooting/index.md) - symptoms, causes, fixes
- [UI](wiki/ui/index.md) - screens, widgets, navigation, and the design system that keeps them consistent

## Operational

These three directories sit outside the default load. They are not alike: `_sources/` holds real concepts to read on demand, `_log/` is history, and `raw/` is not to be read at all.

- [Sources](_sources/index.md) - knowledge ingested from outside the repository, populated by `/repokb:ingest` and `/repokb:ingest-conversation`. Real concepts, cited like any other — read them when a topic calls for them, not by default: [Conversations](_sources/conversations/index.md), [External](_sources/external/index.md)
- Update log, `_log/` - bundle change history, one file per day (`YYYYMMDD.md`)
- Raw, `raw/` - the originals the concepts were distilled from - files, fetched pages, and conversations alike: `images/`, `pdfs/`, `documents/`, `adrs/`, `conversations/`, `others/`

**Agents: `raw/` is strictly for humans. Never open, read, or load in context a file under `raw/`.** Link to it for a human reader and stop there.
