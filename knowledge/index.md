---
okf_version: "0.2"
---

# Project knowledge Base

Durable knowledge for the project, kept as an [OKF v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) bundle. The code says what the system does; this says why, how we found out, and what to watch for.

Start here, then open only what you need. See [the authoring contract](AGENTS.md) before writing.

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
