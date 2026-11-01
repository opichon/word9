---
name: load
description: "Load the repository knowledge base at knowledge/ into context. Use at the start of a session, before answering questions about how this repo works, or before making changes to an unfamiliar part of it. Reads the OKF index hierarchy first and pulls only the concept documents that are relevant, reporting trust tier and staleness. Trigger: /repokb:load"
---

# /repokb:load

Loads the `knowledge/` knowledge base into the conversation. The wiki is an OKF v0.2 bundle; see `knowledge/AGENTS.md` for the format.

## Usage

```
/repokb:load                      # indexes + orientation set (default)
/repokb:load <topic>              # indexes, then everything relevant to <topic>
/repokb:load --section <name>     # every concept in one section, e.g. --section architecture
/repokb:load --full               # every concept document in the bundle
/repokb:load --audit              # health report only: staleness, trust, index drift, broken links
```

## Why not just read everything

A wiki that outgrows the context window is normal and expected. Loading it wholesale burns the budget you need for the actual work and buries the relevant three documents under thirty irrelevant ones. **Default to progressive disclosure**: the index hierarchy is the map, and it is cheap. Concept documents are the territory, and you fetch the ones you need.

Use `--full` only when the bundle is genuinely small (check first) or the user asks for it.

## Procedure

### 1. Confirm the bundle exists

If `knowledge/index.md` is absent, say so and stop. Do not invent content or silently proceed — offer to scaffold it per `knowledge/AGENTS.md`.

### 2. Load the map

Read, always:

- `knowledge/index.md` — bundle root table of contents
- every `knowledge/**/index.md` — section tables of contents, `_sources/` included. The indexes are cheap and you need them to know what has been ingested; it is the concepts underneath that stay unloaded until a topic calls for them.
- the newest two or three files in `knowledge/_log/` — what changed recently, and whether the bundle is actively maintained. Filenames are `YYYYMMDD.md`, so the last entries of a directory listing are the most recent.

Do **not** read `knowledge/AGENTS.md` unless you are about to write to the wiki. It is the authoring contract, not knowledge.

Prefer one pass over reading files one at a time:

```bash
find knowledge -name 'index.md' | sort
ls knowledge/_log | tail -3
```

### 3. Select concepts

| Invocation         | Select                                                                                                             |
| ------------------ | ------------------------------------------------------------------------------------------------------------------ |
| default            | the documents named under the root index's orientation section — from `wiki/` only                                 |
| `<topic>`          | entries whose title, description, or tags match the topic, plus anything they link to that is clearly load-bearing |
| `--section <name>` | every concept in `knowledge/wiki/<name>/`, or in `knowledge/_sources/<name>/`                                      |
| `--full`           | everything, `_sources/` included                                                                                   |

**`_sources/` is not part of the default load.** Ingested material is second-hand by definition and usually answers a question nobody asked yet, so a bare `/repokb:load` stays inside `wiki/`. A topic match reaches into `_sources/` exactly as it reaches into `wiki/` — if an ingested vendor doc is the best answer to the topic, load and cite it. What you must not do is pull it in by default and spend the context on it.

Index entries carry each concept's `description`, so selection is a judgement over titles and descriptions — not a keyword grep. Match on meaning.

**Use the catalog to find candidates** the indexes do not surface: run `catalog.py knowledge` from the plugin's `scripts/` folder (two levels above this skill's base directory; in this repository `.claude/skills/repokb/scripts/`), then query `knowledge/.catalog.sqlite` with `sqlite3` (schema and examples: `knowledge/AGENTS.md`, Catalog). Full-text `search` for a `<topic>`, `backlinks` for what depends on a page you are about to act on, `tier` and `stale` for the trust report. A hit is a candidate, judged on its title and description like an index entry, and read in full if selected.

When the topic is genuinely absent from the wiki, say so plainly. "The wiki has nothing on the media pipeline" is a useful answer and a prompt to run `/repokb:ingest-conversation` once the work is done.

Fall back to `grep -ril '<term>' knowledge/` when the catalog cannot be built or the indexes look stale and you suspect a document exists that they do not list. Report that drift.

### 4. Read the selected concepts

Read them in full. A concept document is written to be read whole; excerpting frontmatter without the body gets you the claim without the caveats.

### 5. Report trust and freshness — do not skip this

For every document you loaded, evaluate its OKF metadata and surface anything that qualifies what you just read:

- **`status: draft`** — inferred, not confirmed. Say so when you use it.
- **`status: deprecated`** — do not act on it; find what accepted it.
- **`stale_after` in the past** (compare against today's date) — flag it explicitly as possibly out of date.
- **No `verified` key** — Unverified. Agent-authored knowledge nobody has checked.
- **`verified` by non-`human:` actors only** — Machine-confirmed.
- **`verified` by a `human:` actor** — Human-reviewed. The strongest tier available.
- **`generated.at` later than the newest `verified[].at`** — changed since review. The review covered an earlier version, so report the tier as changed since review rather than as reviewed.

Report these as a short block, not per-document prose:

```
Loaded 6 concepts from knowledge/.
  ⚠ knowledge/wiki/components/mobile.md — draft, unverified (derived from makefile only)
  ⚠ knowledge/_sources/external/supertokens-api.md — stale_after 2026-06-01, 77 days past
  ✓ knowledge/wiki/architecture/api-request-lifecycle.md — verified by human:username 2026-08-02
```

**This step is the entire reason the metadata exists.** A knowledge base that presents unverified agent output with the same confidence as human-reviewed fact is worse than no knowledge base, because it launders guesses into authority.

### 6. State what you loaded

One or two sentences: which sections, how many concepts, and the notable gaps you noticed. Then continue with the user's actual task.

## `--audit` mode

Report only, load nothing further. Start by building the catalog (`catalog.py knowledge`, from the plugin's `scripts/` folder (two levels above this skill's base directory; in this repository `.claude/skills/repokb/scripts/`)) and take the counts below from it (`tier`, `changed_since_review`, the `stale`, `gaps` and `orphans` views):

1. **Index drift** — concept files on disk that no `index.md` lists, and index entries pointing at files that do not exist.
2. **Broken cross-links** — links to `knowledge/` paths that do not resolve. OKF explicitly tolerates these, so report them as gaps rather than errors.
3. **Staleness** — every document with `stale_after` in the past.
4. **Trust distribution** — counts by tier, which sections are entirely unverified, and which reviewed documents have changed since review.
5. **Conformance** — any concept missing frontmatter, a `type` or an `id`, and any `index.md` with frontmatter other than `okf_version` in the bundle root's. Only `index.md` files and files inside `raw/` may omit frontmatter.
6. **Breadcrumbs** — any page outside `raw/`, other than the bundle root `index.md`, whose first body line is not a breadcrumb trail, or whose trail does not match where the file sits (`knowledge/AGENTS.md`, Breadcrumbs).
7. **Empty sections** — indexes with no entries, which are commitments nobody has kept.

The audit does not compare the wiki against the code — that needs git history and research. Point at `/repokb:resync --dry-run` for it.

Offer to fix drift, conformance, and breadcrumb problems. Do not fix staleness or trust by editing metadata — those are claims about reality that need a human, and rewriting a `stale_after` date to silence a warning is falsification.

## Interaction with the repo's AGENTS.md

The root `AGENTS.md` imports `REPOKB.md` (and the root `CLAUDE.md` imports `AGENTS.md`), which instructs every session to consult the wiki. That instruction points here. If a session has already run `/repokb:load`, re-running it for a new topic is cheap and correct — load the additional concepts rather than starting over.

## After loading

If the session goes on to discover something the wiki does not know — a constraint, a gotcha, a corrected mental model — offer `/repokb:ingest-conversation` at the end. That round trip is what makes the wiki accumulate instead of decay.
