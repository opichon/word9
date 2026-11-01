---
type: Instructions
id: agents
title: Wiki Authoring Contract
description: How to read, write, and extend the knowledge base as an AI-XF bundle.
tags: [meta, okf, authoring]
status: stable
---

[Home](index.md) › Wiki Authoring Contract

# Wiki Authoring Contract

This directory is an **[Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) (OKF) v0.2 bundle**. It is the durable memory for this repository: what the code cannot tell you on its own — why things are the way they are, what broke before, what was decided, what was learned from outside sources.

Read this file before citing anything out of `knowledge/` or writing anything into it. **Reading the bundle** below is the part that applies to every session, including one that only ever reads.

## The one rule that matters

**The code is the source of truth for _what_ the system does. The wiki is the source of truth for _why_, _how we learned it_, and _what to watch out for_.**

Do not write documents that restate what a reader could get by opening the file. `api.ts` registers plugins in a given order — that is discoverable. _That the order matters because `migrationPlugin` must run after slonik and last of all_ is knowledge. Write the second kind.

## Reading the bundle

`/repokb:load` is the entry point; the bundle root `index.md` is the fallback when the skill is unavailable. Either way, **load the index hierarchy first and pull concept documents only as a topic calls for them** — this bundle is built for progressive disclosure, not wholesale loading.

**Search the catalog, not the folders.** `python3 .claude/skills/repokb/scripts/catalog.py knowledge` builds `knowledge/.catalog.sqlite` from the bundle in about a second; query it with `sqlite3` to find pages by words (`search`, full text), tag, type, trust tier, staleness or inbound links, then read the pages it names. See [Catalog](#catalog).

**Respect the trust metadata on everything you read.** Every concept carries OKF provenance and lifecycle fields: a missing `verified` key means unverified agent output, `status: draft` means inferred rather than confirmed, and a past `stale_after` means possibly out of date. Qualify what you say accordingly instead of presenting all of it as equally established fact. The tiers are defined under [Trust](#trust--generated-and-verified).

## Layout

```
knowledge/
  index.md              # bundle root — table of contents, carries okf_version
  manifest.ai-xf.yaml   # declares the AI-XF bundle and its conformance level, carries repokb_version
  .catalog.sqlite       # SQLite catalog built from the pages by catalog.py — derived, committed, never edited
  _log/                 # bundle-level change history, one file per day
    20260817.md         #   YYYYMMDD.md
  _sources/             # ingested external material (OKF §6.3) — real concepts, not loaded by default
    external/           #   websites, PDFs, docs, videos
    conversations/      #   knowledge distilled from LLM sessions
  AGENTS.md             # this file — the authoring contract
  CLAUDE.md             # imports AGENTS.md, so Claude Code loads it automatically
  raw/                  # originals behind ingested material: files, pages as fetched, conversations — human-only, see rule 6
    images/ pdfs/ documents/ adrs/ conversations/ others/
  wiki/                 # what this repository knows about itself
    architecture/       #   cross-cutting structure and dataflow
    components/         #   one concept per app / lib / service / tool
    domain/             #   product and business knowledge
    conventions/        #   how we write code and run the process here
    ui/                 #   screens, widgets, navigation, design system
    security/           #   threat model, secrets, auth, transport, permissions
    local/              #   getting it running on a fresh machine
    ci/                 #   pipelines, builds, checks
    operations/         #   runbooks: deploy, env, migrations, incident response
    testing/            #   test setup and the constraints behind it
    troubleshooting/    #   symptom → cause → fix
    technical-debt/     #   known shortcuts, what they cost, the way out
    reference/          #   standing explanations of concepts and external systems
```

Every directory under `wiki/` and `_sources/` has an `index.md`. `_log/` and `raw/` hold bookkeeping and raw files rather than concepts, and are not indexed.

**Three directories are operational: they sit outside the default load.** `_log/` and `_sources/` carry the `_` prefix, `raw/` does not — but all three are excluded, and they are not governed by the same rule. What they hold differs, so what you may do with them differs:

| Directory   | Holds                                   | Indexed | How you treat it                                                    |
| ----------- | --------------------------------------- | ------- | ------------------------------------------------------------------- |
| `_log/`     | The bundle's own change history         | no      | Read for history and recency; never cite as a fact about the system |
| `raw/`      | Originals behind ingested material      | no      | Never read at all — see rule 6                                      |
| `_sources/` | Ingested external material, as concepts | **yes** | Read and cite like any concept, but only when a topic calls for it  |

`_log/` and `raw/` carry no `index.md`. `raw/` files carry no frontmatter, because they are originals; a `_log/` file carries the short frontmatter under [File rules](#file-rules). `_sources/` is different in kind: its files are ordinary concept documents with full frontmatter, its directories are indexed, and its contents are citable — it is operational only in the sense that it is not part of the default load. It is the intake, not the destination: what proves durable and repo-specific gets promoted into `wiki/`.

## File rules

| File                   | Frontmatter                                          | Purpose                             |
| ---------------------- | ---------------------------------------------------- | ----------------------------------- |
| `index.md`             | **none**                                             | Table of contents for its directory |
| bundle root `index.md` | `okf_version` only                                   | Table of contents for the bundle    |
| `_log/<YYYYMMDD>.md`   | **required**: `type: Log`, `id`, `title`, `description` | One day of change history        |
| `raw/<bucket>/<file>`  | **none**                                             | An ingested original — human-only   |
| everything else        | **required**, must contain `type` and `id`           | A concept document                  |

`CLAUDE.md` is a concept like any other — `type: Instructions` — whose only job is to import this file for Claude Code. Edit the contract here, never there.

**Every concept has frontmatter, and every frontmatter has a `type`.** That includes every `_log/` file. The only `.md` files without it are `index.md` files, which are not concepts, and those in `raw/`, which are originals rather than pages. A concept without a `type` breaks this contract.

**An `index.md` has no frontmatter**, as OKF v0.2 §8 and AI-XF §10.1 require. The one exception is `okf_version` in the bundle root `index.md`. Its title is its `#` heading, and what it covers goes in the paragraph under that heading. okf-validate checks indexes with `spec: okf`, because AI-XF's validator skips them, and everything else with `spec: ai-xf`.

`manifest.ai-xf.yaml` at the bundle root declares the bundle as [AI-XF](https://github.com/DavidROliverBA/ai-xf-format), OKF's superset, at conformance level 1, and CI validates every page outside `raw/` against it. It also carries `repokb_version`, the repokb release that scaffolded or last resynced the bundle, which the CLI writes. It is not a concept: leave it alone.

## Concept frontmatter

Required, on every page but an `index.md`:

```yaml
type: <one of the vocabulary below>
id: <stable identifier, see below>
```

**`id` names the page for good.** Derive it from the page's path relative to the bundle root when you create the page: drop `.md`, lowercase it, and turn each run of other characters into a single `-`, trimming any at the ends. `wiki/components/api.md` is `wiki-components-api`, and `_log/20260817.md` is `log-20260817`. It must be unique in the bundle, so if another page already holds it, usually one that moved away, add `-2`. **Never change an `id`**, even when the page moves or is renamed.

Always include these too, because retrieval depends on them:

```yaml
title: <human-readable name>
description: <one sentence; this is what shows up in index.md and in search>
tags: [<tag>, <tag>]
```

Then the families below, as they apply.

### Provenance — `sources`

Where the knowledge came from. Required for anything ingested from outside the repo.

```yaml
sources:
  - id: api-composition-root # stable key, used for per-claim footnotes
    resource: apps/api/src/api.ts
    title: API composition root
    author: human:username # optional credibility signal
    last_modified: 2026-08-17 # when the *source* changed
```

Attribute individual claims with markdown footnotes keyed to `sources[].id`:

```markdown
Migrations run automatically at boot.[^api-composition-root]

[^api-composition-root]: `migrationPlugin` is registered last in `API()`.
```

### Trust — `generated` and `verified`

```yaml
generated:
  by: claude-code/claude-opus-5 # who wrote it
  at: 2026-08-17T10:30:00Z # last meaningful content change
verified:
  - { by: human:jhon, at: 2026-08-17T11:00:00Z }
```

**Never write a `verified` entry on your own behalf, and never add a `human:` actor to `verified` unless a human in the conversation actually confirmed that document's content.** The trust tier is derived from this field and it is the only defense against a wiki that confidently repeats its own guesses:

| State                             | Tier              |
| --------------------------------- | ----------------- |
| no `verified` key                 | Unverified        |
| `verified` by non-`human:` actors | Machine-confirmed |
| `verified` by a `human:` actor    | Human-reviewed    |

Agent-authored documents start Unverified. That is correct and expected — say so rather than inflating it.

A `verified` entry covers the document as it was at its `at`. When `generated.at` is later than the newest one, the content changed after the review: keep the entries as the record of a review that happened, and treat the document as changed since review rather than as reviewed.

### Lifecycle — `status` and `stale_after`

```yaml
status: draft | stable | deprecated # absent means stable
stale_after: 2027-02-17 # absolute date, never a relative TTL
```

Set `stale_after` on anything pinned to a moving target — dependency versions, external docs, infra endpoints. Six months is a reasonable default for external material; omit it for durable repository knowledge.

### Actor convention (OKF §7)

- Agents: `<producer>/<version>` → `claude-code/claude-opus-5`
- People: `human:<id>` → `human:john`
- Automated processes: `process:<id>` → `process:gitlab-ci`

The `human:` prefix is load-bearing. Use it only for people.

## Type vocabulary

OKF has no central type registry; these are this bundle's conventions. Consumers must tolerate types outside this list, so add one if nothing fits — but check first.

| `type`                 | Use for                                                        | Lives in                             |
| ---------------------- | -------------------------------------------------------------- | ------------------------------------ |
| `Component`            | An app, lib, service, or tool in the repo                      | `wiki/components/`                   |
| `Architecture`         | Cross-cutting structure, dataflow, boundaries                  | `wiki/architecture/`                 |
| `Domain Concept`       | Product/business meaning: matching, profile review, moderation | `wiki/domain/`                       |
| `Convention`           | A rule we follow: code style, model layout, commit format      | `wiki/conventions/`                  |
| `UI`                   | A screen, widget, navigation structure, or design-system rule  | `wiki/ui/`                           |
| `Security`             | A threat and the control that addresses it                     | `wiki/security/`                     |
| `Setup`                | Getting the project running on a fresh machine                 | `wiki/local/`                        |
| `CI`                   | Pipeline configuration, build and test workflows               | `wiki/ci/`                           |
| `Runbook`              | A procedure a person executes                                  | `wiki/operations/`                   |
| `Testing`              | Test setup, tooling, and the constraints behind them           | `wiki/testing/`                      |
| `Troubleshooting`      | A symptom, its cause, and its fix                              | `wiki/troubleshooting/`              |
| `Technical Debt`       | A known shortcut or deferred fix, its cost, and the way out    | `wiki/technical-debt/`               |
| `Explainer`            | A standing explanation of a concept, term, or external system  | `wiki/reference/`                    |
| `Reference`            | Material ingested from outside the repo                        | `_sources/external/`                 |
| `Session Knowledge`    | Knowledge distilled from an LLM conversation                   | `_sources/conversations/`            |
| `Attested Computation` | A sanctioned command or query others must run verbatim         | anywhere; usually `wiki/operations/` |
| `Log`                  | One day of the bundle's change history                         | `_log/`                              |

## Linking

A link asserts _a relationship_; the prose says what kind. Link generously — broken links are explicitly tolerated by OKF and a link to a document that does not exist yet is a useful marker of a gap, not an error.

**Every link points to a file, never to a directory.** To link a directory, link its `index.md`: `[Components](wiki/components/index.md)`, not `[Components](wiki/components/)`. Many markdown readers (Marked 2, MarkView, and others) do nothing when a link to a directory is clicked. A directory without an `index.md` — `_log/` and `raw/` and their buckets — has nothing to link to: name it as a code path (`` `raw/pdfs/` ``) instead.

**Every link is relative to the file it is written in.** From `_sources/external/foo.md`, the components index is `../../wiki/components/index.md`. Never start a link with `/`: readers that open the file from disk resolve `/wiki/…` against the filesystem root, not the bundle root, and the link goes nowhere.

## Breadcrumbs

**Every page opens with a breadcrumb trail**, so a reader can step back to the page above it or jump to the top. Concepts, `index.md` files, `_log/` files, and this file all carry one. The exceptions are the bundle root `index.md`, which is the top, and files in `raw/`, which are originals rather than pages.

The trail is the first line of the body — directly after the frontmatter's closing `---`, or the first line of an `index.md` — followed by a blank line, then the `#` heading:

```markdown
[Home](../../index.md) › [Components](index.md) › Request Lifecycle
```

- It starts at `[Home]`, the bundle root `index.md`, and adds one crumb for each directory between the root and the page, linking that directory's `index.md`. A directory with no `index.md` — `wiki/` itself — gets no crumb.
- Each crumb's label is the name the index one level up lists it under: `Components`, `Sources`, `External`.
- The last crumb is the page itself, as plain text rather than a link: the `title` of a concept, the section name of an `index.md`, the ISO date of a `_log/` file.
- Crumbs are separated by ` › `, and their links follow the rules above — relative, and to files.

The trail is derived from where the file sits, so it moves with the file: moving a document means rewriting its trail, and moving or renaming a directory means rewriting the trail of everything beneath it.

## Headings

**Every page is semantically correct: one title, then a strict hierarchy, with every heading meaningful.**

- **Exactly one `#` (h1) heading, the page's title**, directly after the breadcrumb. On a concept it is the same text as the frontmatter `title`.
- **Sections are `##` (h2), their sub-sections `###` (h3), and so on.** A level is never skipped.
- **Every heading conveys meaning.** It says what its section holds and still makes sense read alone in a table of contents. `Pages`, `Contents`, `Details` or `Other` say nothing: name the thing instead.

## Body structure

Favour structure over prose — headings, tables, lists, fenced code. Both humans and retrieval do better with it.

Conventional headings, used when they apply:

- `## Schema` — structured description of fields or columns
- `## Examples` — concrete usage
- `## Computation` — the sanctioned computation, for `Attested Computation` documents

For `Attested Computation`, `runtime` is required (`bash`, `postgres`, `psql`, `python`), and an agent **may only fill in declared `parameters` — it must never edit the computation itself**. That constraint is the whole point of the type: it turns "did you run the right thing?" into a mechanical comparison.

## `index.md` format

No frontmatter: its [breadcrumb trail](#breadcrumbs), then its title, then a paragraph saying what the directory covers; sections group entries under headings. Each entry links a concept and repeats its `description`.

**An index lists what its folder holds under a heading naming those things.** A folder usually holds a collection of similar things, so its main section is `## <Things>`: `## Runbooks` in Operations, `## Symptoms` in Troubleshooting. Split it into several sections when that helps the reader, by kind or by owner, with the folder's main subject first. Never list entries under a generic heading such as `## Pages` or `## Contents`, which says only that they are files. A folder with nothing in it yet has no such section; add it with the first page.

```markdown
[Home](../../index.md) › Operations

# Operations

Runbooks for setup, services, migrations, and release.

## Runbooks

- [Title](path.md) - description copied from the concept's frontmatter
- [Subdirectory](subdir/index.md) - what the group covers
```

The bundle root `index.md` also carries `okf_version: "0.2"` as its only frontmatter.

**Whenever you add, move, or delete a concept, update the `index.md` of its directory in the same change.** An index that has drifted from its directory is worse than no index.

## `_log/` format

One file per day, named for that day with no separators — `20260817.md` for 2026-08-17. The filename is the date, so a plain directory listing sorts the history chronologically and the newest entries are the last file.

Frontmatter with `type: Log`, `id`, `title` (the ISO date) and `description`, then its [breadcrumb trail](#breadcrumbs). The ISO date is the heading, and entries are newest first, each with a bold convention word.

**One entry per operation, not one per page.** An operation is one ingest, resync, init, or working session, however many pages it touched. In one line, say what happened and why, linking the page to start from. Don't list the other pages or give them entries of their own: the log is committed, so `git log` already holds them.


```markdown
---
type: Log
id: log-20260817
title: 2026-08-17
description: Changes to the knowledge base on 2026-08-17.
---

[Home](../index.md) › 2026-08-17

# 2026-08-17

- **Creation**: Documented the API, in 4 new pages. Start at [API component](../wiki/components/api.md).
- **Update**: Corrected the plugin order after the auth rewrite; 3 pages changed. See [request lifecycle](../wiki/architecture/api-request-lifecycle.md).
```

Use `**Creation**`, `**Update**`, `**Deprecation**`, `**Verification**`, `**Initialization**`, `**Resync**`.

Append to today's file, creating it if this is the day's first change. Never rewrite a past day's file — the log is a record, not a summary.

Commit the log with the pages it describes. Parallel branches can add to the same day's file, and GitHub reports that as a conflict because it ignores the union merge `.gitattributes` sets for log files. Run `git merge main` locally and push: git keeps the entries from both sides, with nothing to edit.

Log at the bundle root for anything structural. A directory may keep its own `_log/` once its history gets busy enough to be worth separating.

## Catalog

The folder hierarchy is how a person browses the bundle; it stops working as a way to _find_ things once the bundle holds hundreds of pages. `catalog.py` (in `.claude/skills/repokb/scripts/`) indexes every page outside `raw/` and `_log/` into SQLite, from its frontmatter and body. The catalog is **derived and disposable**: the pages are the source of truth, it is committed alongside them (rebuild it in the same commit as the pages it reflects), and it is rebuilt rather than edited or migrated (`meta.schema_version` changes when its shape does). It records a digest of its inputs (`meta.inputs_digest`: page contents, the bundle's file paths outside `_log/` and dotfiles, and the catalog scripts), so:

- `catalog.py --check knowledge` tells reliably, after a clone too, whether the catalog matches the working tree; `--check --staged` whether it matches the index.
- `catalog.py knowledge` rebuilds it, and leaves it untouched when nothing changed. Run it before querying. When the pages match HEAD again (an edit reverted), HEAD's catalog is restored, so no catalog diff is left behind.
- The `pre-commit` hook in `.githooks/` runs `catalog.py --staged knowledge` on every commit that changes `knowledge/` or the scripts, and stages the result: the committed catalog matches the committed pages, whatever is still unstaged. Nothing rebuilds it on each edit. Enable it once per clone with `git config core.hooksPath .githooks`; a repository that already has a hooks manager, such as husky, calls `.githooks/pre-commit` from its own `pre-commit` instead.
- The `kb-catalog` Action checks the pull request merged into `main` (`refs/pull/<n>/merge`), and fails when its catalog does not match its pages: a commit made with `--no-verify`, without the hook, replayed by a rebase, or a conflict resolved by keeping the wrong side. Its job summary lists the pages the catalog adds, changes and removes against `main`, which is what the binary diff holds. Where `okf-approve` is set up, its workflow rebuilds the catalog after its merge commit.
- GitHub cannot resolve a conflict on the catalog: merge or rebase on `main` locally, run `catalog.py knowledge` and `git add` it, never pick a side by hand. `kb-catalog` runs once the conflict is gone and confirms the result.

| Table or view | Holds |
| ------------- | ----- |
| `pages` | One row per page: `path`, `type`, `title`, `description`, `section`, `status`, `tier`, `changed_since_review`, `generated_by`, `generated_at`, `reviewed_at`, `stale_after`, `body`. Indexes have a NULL `type`, `description` and `tier` |
| `search` | Full-text index over `title`, `description`, `tags` and `body` |
| `tags`, `sources`, `reviews`, `originals` | A page's tags, `sources` entries, `verified` entries, and the files in `raw/` it refers to |
| `links` | Every link in a page's body: `src`, `target`, `dst`, `kind` (`page`, `index`, `raw`, `missing`, `outside` or `url`) |
| `backlinks` | Inbound links per page: what needs a look when it changes |
| `gaps`, `orphans`, `stale`, `unbacked` | Links to pages not written yet; concepts nothing links to; pages past `stale_after`; `_sources/` concepts with no original in `raw/` |

```bash
sqlite3 knowledge/.catalog.sqlite "SELECT path, tier FROM search JOIN pages USING (path) WHERE search MATCH 'retry OR timeout' ORDER BY rank LIMIT 10"
sqlite3 knowledge/.catalog.sqlite "SELECT path, title FROM pages WHERE section = 'wiki/troubleshooting' AND tier = 'unverified'"
sqlite3 knowledge/.catalog.sqlite "SELECT src FROM backlinks WHERE path = 'wiki/architecture/api-request-lifecycle.md'"
```

A catalog hit is a pointer, not knowledge: read the page it names, in full, with its trust metadata, before citing it.

## Working rules

1. **Update before you create.** Search the wiki first. A new document that overlaps an existing one splits the knowledge in two and both halves rot. Extend the existing concept instead.
2. **One concept per file.** If a document needs "and" in its title, it is two documents.
3. **Never delete knowledge to make room.** Mark it `status: deprecated` and say what accepted it. Links and history depend on it.
4. **Dates are absolute.** `2026-08-17`, never "last week". The reader is in an unknown future.
5. **Do not paste secrets, tokens, credentials, or `.env` values.** Reference the variable name and where it is configured.
6. **`raw/` is human-only. Never open, read, or cite a file in it.** It holds the original images, PDFs, documents, and ADRs, markdown snapshots of ingested web pages, and verbatim transcripts of ingested conversations, that a human reader may want to see for themselves — raw material the bundle keeps, not knowledge the bundle asserts. Agents work from the concept documents instead: if something in a raw file matters, it was distilled into a concept at ingest time, and that concept - not the file - is what you read and cite. A link into `raw/` is for the human; treat the file itself as out of bounds.
7. **Every concept change lands with its bookkeeping.** Adding, moving, or deprecating a document updates its directory's `index.md` and is covered by the operation's entry in today's `_log/` file, in the same edit — never as a follow-up. A new or moved document gets its [breadcrumb trail](#breadcrumbs) in that same edit too.
8. **Format what you write the way the repository formats it.** This bundle lives inside a repository whose formatters, linters, and commit hooks it cannot know in advance, and a file they reject blocks the commit. Before you finish, find the repository's own formatting setup — `package.json` scripts, `lint-staged`, `.husky/`, `.pre-commit-config.yaml`, `.prettierrc`, `.markdownlint*`, `.editorconfig` — and run it over every file you created or changed, accepting its rewrites. Run it on those files only; never reformat files you did not touch. When the scaffolded files have never been through it (the first session to write into the bundle), include them: the bundle and the repository-root `REPOKB.md`, `AGENTS.md`, and `CLAUDE.md`. If the repository has no formatter, or excludes this directory from it, there is nothing to do. Never bypass a hook to get a commit through.
