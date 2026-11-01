---
name: ingest
description: "Ingest external knowledge into the knowledge/ knowledge base from a website, PDF, Word document, image, slide deck, video, ADR, or plain text. Extracts the material, distills it into OKF v0.2 concept documents under knowledge/_sources/external/, archives the original — the file itself, or the fetched markdown for a URL — in knowledge/raw/, and updates the affected index.md and the day's file in _log/. Trigger: /repokb:ingest <url-or-path>"
---

# /repokb:ingest

Turns an outside source into durable, structured knowledge in `knowledge/`. Read `knowledge/AGENTS.md` before writing anything — it is the authoring contract this skill conforms to.

## Usage

```
/repokb:ingest <url>                          # web page or online document
/repokb:ingest <path>                         # local file: pdf, docx, image, md, txt, csv
/repokb:ingest <path-or-url> --into <section> # route to a section other than _sources/external
/repokb:ingest <url> --deep                   # follow and ingest linked sub-pages of a doc site
/repokb:ingest <path> --verbatim              # also keep a full extraction alongside the distillation
```

Multiple sources in one invocation are fine — ingest each, then look for what they say about each other.

## What this is for

The wiki exists so knowledge survives outside chat history. Ingestion is the intake path for anything the repository does not already contain: vendor documentation, an RFC, a spec, a design deck, a recorded walkthrough, a support thread that finally explained something.

**Distill, do not dump.** A verbatim copy of a 40-page PDF is not knowledge, it is a slower way to read the PDF. The output should let a future reader act without opening the original, while `sources[].resource` keeps the original one click away.

## Step 1 — Extract

Pick the cheapest route that actually works. Do not shell out when a native tool reads the format directly.

| Source                                | How                                                                                                                                                                           |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Web page                              | `WebFetch` with a prompt naming what you need. It converts to markdown for you. Ask it for the page's full content, not just an answer — Step 2 archives what it returns.     |
| PDF                                   | **`Read` with the `pages` parameter.** Native, handles scanned pages and figures. Max 20 pages per call; `pages` is required past 10 pages. Do not reach for a CLI converter. |
| Image (png, jpg, screenshot, diagram) | **`Read`.** It sees the image. Describe what it shows, do not just OCR the text.                                                                                              |
| `.docx`                               | `textutil -convert txt -stdout <file>` (macOS, available here).                                                                                                               |
| `.md`, `.txt`, `.csv`, source files   | `Read`.                                                                                                                                                                       |
| `.pptx`, `.xlsx`                      | No converter installed. Unzip and read the XML (`unzip -p <file> 'ppt/slides/*.xml'`), or ask the user to export to PDF — usually faster and better.                          |
| Video                                 | See below.                                                                                                                                                                    |
| Paywalled / auth-required             | `WebFetch` fails on these. Ask the user to paste the content or supply a file. Do not guess at what the page says.                                                            |

### Video — be honest about the ladder

Neither `yt-dlp` nor a local transcription model is installed on this machine. `ffmpeg` is. In descending order of quality:

1. **Ask for a transcript.** YouTube and most conferencing tools export one. A transcript is strictly better input than audio.
2. **Fetch a transcript URL** with `WebFetch` if one exists online.
3. **For a local file, extract keyframes and read them.** This genuinely works for screencasts, demos, and slide-based talks, where the information is on screen:
   ```bash
   ffmpeg -i <video> -vf "fps=1/30,scale=1280:-1" -q:v 3 <scratch>/frame_%03d.jpg
   ```
   Then `Read` the frames. Adjust `fps` to the pace of the content.
4. **If none of that applies**, say plainly that you cannot transcribe the audio and ask how the user wants to proceed. Do not ingest a video by guessing from its title and description — that produces a document that looks sourced and is fabricated.

Whatever route you take, record it in the document body under `## Extraction`. A future reader needs to know whether they are reading a transcript, a slide reading, or a summary of a summary.

## Step 2 — Keep the original in `raw/`

Every source you ingest leaves a copy of its original in `knowledge/raw/`, so the material travels with the repository. **Do not ask** — the copy is the default, and a user who does not want it can delete the file themselves.

### A local file — copy it

A file on the user's disk has no home a second reader can reach: a `sources[].resource` pointing at `/Users/someone/Downloads/spec.pdf` resolves for exactly one person. Copy, never move; the user's file stays where it is:

```bash
cp <source> knowledge/raw/<bucket>/<kebab-case-name>.<ext>
```

| Bucket                         | For                                                                           |
| ------------------------------ | ----------------------------------------------------------------------------- |
| `knowledge/raw/images/`        | png, jpg, svg, screenshots, diagrams                                          |
| `knowledge/raw/pdfs/`          | pdf                                                                           |
| `knowledge/raw/documents/`     | docx, pptx, xlsx, md, txt, csv, fetched pages                                 |
| `knowledge/raw/adrs/`          | architecture decision records, verbatim — see Step 4                          |
| `knowledge/raw/conversations/` | conversation transcripts, verbatim — written by `/repokb:ingest-conversation` |
| `knowledge/raw/others/`        | video, audio, archives, anything else                                         |

Then point `sources[].resource` at the committed copy — `knowledge/raw/pdfs/supertokens-passwordless-recipe.pdf` — because the path you were given resolves on one machine only, and record that original path under `## Extraction`.

### A URL — save the fetched markdown

A page can change or disappear, and the reader in an unknown future gets a 404 rather than the thing you read. Write the markdown `WebFetch` already returned in Step 1 to `knowledge/raw/documents/` — no second fetch, and no reformatting of what it gave you:

```
knowledge/raw/documents/<kebab-case-name>.md
```

Head it with the URL and the date you fetched it, so the snapshot says what it is a snapshot of:

```markdown
> Fetched from https://supertokens.com/docs/passwordless/introduction on 2026-08-17, as returned by `WebFetch`.
```

`WebFetch` returns what your prompt asked for, so the snapshot is only as complete as that prompt was. If you asked a narrow question, say so in the snapshot header — an archive that silently omits half the page is a worse record than an honest partial one.

**`sources[].resource` stays the URL** — that is the canonical home, and the snapshot does not replace it. Note the archived path under `## Extraction` instead. With `--deep`, each sub-page you actually fetch gets its own snapshot under the same naming rule.

### Both routes

Name what you keep after the concept document it belongs to, kebab-case, the original extension kept: `supertokens-passwordless-recipe.pdf` in `raw/pdfs/`, or `supertokens-passwordless-recipe.md` for a fetched page, alongside the concept of the same name in `_sources/external/`.

Name what you kept, and a local file's size, in your report (Step 7) — so the user can weigh a 40 MB deck and remove it if they would rather not commit it.

**Keep nothing** in three cases: a file already inside `knowledge/`; material the guardrails at the bottom of this page rule out — secrets, or anything the user has no right to redistribute; and a page you never successfully fetched, since a snapshot of a failed fetch is worse than none. When you skip it, leave `sources[].resource` as the path or URL you were given, and say in `## Extraction` that nothing was kept, so a future reader knows a local path is local to one machine rather than broken.

`knowledge/raw/` is **operational and human-only** (`knowledge/AGENTS.md`, working rule 6) — it sits outside the knowledge base, holding raw material rather than knowledge. You put files in and link them for a human reader; you never read one back out. That holds for a fetched-page snapshot too — it is markdown, and so it is tempting, but the concept document is what you read and cite; the snapshot exists for the human who wants the original wording. Everything an agent needs is what you are about to distil into the concept document — this is the one moment the material passes through you, so do not leave it half-captured on the assumption the file can be re-opened later.

## Step 3 — Check for an existing concept

Before creating anything, search:

```bash
grep -ril '<subject>' knowledge/
```

Also check `sources[].resource` across the bundle for the same URL — re-ingesting a source that is already there should **update** that document, not fork it.

Updating means: merge the new material in, refresh `generated.at`, add the new source entry, and log an `**Update**`. If the source has genuinely changed, note what changed — that delta is often the most valuable part.

## Step 4 — Route it

Default destination is `knowledge/_sources/external/`, one document per source, kebab-case filename naming the subject rather than the format: `supertokens-passwordless-recipe.md`.

Route elsewhere when the content is clearly repo-specific rather than reference material — `--into knowledge/wiki/architecture`, `--into knowledge/wiki/conventions`, `--into knowledge/wiki/domain`. Ask when it is ambiguous; a misfiled document is found by nobody.

### An ADR — always archived verbatim, and only a decided one is written up

An architecture decision record is archived in `knowledge/raw/adrs/` **whatever its status**, and it stays there: the ADR itself never becomes a concept document, in `wiki/` or anywhere else. It is a record the repository already owns, and `raw/` is where records live.

**The archive is verbatim** — the complete file, byte for byte, or the complete text of a pasted or fetched ADR. Not a summary, not a reformatting, not the part `WebFetch` was asked about. This is the one archive the wiki will never re-read, so it has to be whole:

```bash
cp <source> knowledge/raw/adrs/<kebab-case-name>.<ext>
```

Then read its status, which decides everything downstream:

| ADR status                                          | What to do                                                                                                                                                                                                                                                  |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `accepted`, `rejected`, `deprecated`, `accepted`    | Decided. Distil it into `_sources/` as Steps 5 to 7 describe, then update the `wiki/` concepts the decision bears on — the architecture, convention, or component documents that are now true differently — and cross-link them to the new source document. |
| `proposed`, `draft`, under discussion, or no status | **Not decided. Stop after the archive.** No source document, no wiki edit, no index entry. Log the archive, and say in your report that the ADR is parked in `raw/adrs/` until it is decided.                                                               |

A rejected or accepted ADR is still a decision, and often the most useful kind — "we ruled this out, and here is why" is exactly what the wiki exists to keep. An undecided one is a proposal: writing it up would assert as settled something the team has not settled. Archive it so it cannot be lost, leave the wiki alone, and re-run `/repokb:ingest` on it once it is decided — Step 3 will then update rather than fork.

If the status is missing or you cannot tell what it is, treat the ADR as undecided and say so. Ask the user rather than guessing at a decision.

Updating the wiki is the point of a decided ADR, and the easy half to skip. A decision that only ever lands in `_sources/` leaves every wiki concept it contradicts standing as though nothing happened. Search for what the decision touches, update those documents, and if one of them says the opposite of the ADR, surface the contradiction rather than quietly rewriting it.

If the ADR already lives in this repository, keep `sources[].resource` on its in-repo path — the copy in `raw/adrs/` is a snapshot of what you read, not the document's home.

When a source covers several genuinely distinct topics, split it. When it covers one topic across many pages, keep it as one document.

**Large sources get a hub and spokes**: one parent concept summarising the whole, plus child concepts in a subdirectory for each substantial part, cross-linked. Give the subdirectory its own `index.md`, and give it and every spoke a breadcrumb trail that runs through the hub's directory (`knowledge/AGENTS.md`, Breadcrumbs).

## Step 5 — Write the concept document

```yaml
---
type: Reference
id: sources-external-supertokens-passwordless
title: SuperTokens Passwordless Recipe
description: How the passwordless flow is configured and what the API must supply.
resource: https://supertokens.com/docs/passwordless/introduction
tags: [auth, supertokens, vendor-docs]
sources:
  - id: st-docs
    resource: https://supertokens.com/docs/passwordless/introduction
    title: SuperTokens passwordless documentation
    author: SuperTokens
    last_modified: 2026-07-14
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-17T14:22:00Z
status: stable
stale_after: 2027-02-17
---
```

Rules that are not negotiable:

- **`type` and `id` are mandatory.** Without them the bundle is non-conformant. The `id` comes from the page's path (`knowledge/AGENTS.md`, Concept frontmatter); on an update, keep the page's `id`.
- **`generated.by` is you**, in the actor convention: `claude-code/claude-opus-5`.
- **Never write a `verified` entry.** Ingested material is Unverified until a human checks it. That is the honest state and the metadata exists to record it.
- **Set `stale_after`.** External material has a shelf life; six months is a reasonable default, shorter for fast-moving vendor docs, longer for a stable spec.
- **`last_modified`** is when the _source_ changed, not when you read it. Use it if the page states it; omit it if you would be guessing.

Body: open with the breadcrumb trail (`knowledge/AGENTS.md`, Breadcrumbs) — for a document directly in `_sources/external/`, `[Home](../../index.md) › [Sources](../index.md) › [External](index.md) › <title>`. Then the title as the page's only `#` heading, and structural markdown — headings, tables, lists, fenced code. Attribute specific claims with footnotes keyed to `sources[].id`. Include an `## Extraction` section noting the route used and anything it could not reach (paywalled sections, unreadable figures, audio you could not transcribe).

Then the part that makes it worth having: a section on **what this means for this repository**. A vendor doc summary that never touches our code is a bookmark with extra steps. Link to the components and conventions it bears on.

Link what you kept in `knowledge/raw/` once from the body for the human reader — "the original deck is at [raw/pdfs/…](../../raw/pdfs/…)", or "a snapshot as fetched is at [raw/documents/…](../../raw/documents/…)" — with the path relative to the concept document (one more `../` per subdirectory below `_sources/external/`), and leave it at that. The concept document must stand on its own without it.

With `--verbatim`, put the full extraction in a sibling file and link it, rather than inflating the concept.

## Step 6 — Update the indexes and the log

Not optional, and in the same change:

1. Add the entry to the directory's `index.md`, with the concept's `description` as the trailing text. An index has no frontmatter (`knowledge/AGENTS.md`, `index.md` format).
2. Add one `**Creation**` or `**Update**` entry for this ingest to today's log file, `knowledge/_log/<YYYYMMDD>.md`, however many pages it wrote — create the file if this is the day's first change, with its `id` (`knowledge/AGENTS.md`, `_log/` format), newest first within the file.
3. Add cross-links **both ways** — from the new document to what it relates to, and from those documents back, when the relationship is load-bearing.
4. **Rebuild the catalog**: run `catalog.py knowledge` from the plugin's `scripts/` folder (two levels above this skill's base directory; in this repository `.claude/skills/repokb/scripts/`), last, so it holds what you just wrote.

An index that has drifted from its directory is worse than no index, because it is trusted.

## Step 7 — Report

Say what you created or updated, where it landed, and what the extraction could not reach. Name what you kept in `knowledge/raw/` — a copied file **with its size**, `spec-v3.pdf (2.4 MB) → knowledge/raw/pdfs/…`, or a fetched-page snapshot, `knowledge/raw/documents/….md` — since keeping it is the default and deleting it is the user's call. If you kept nothing, say which rule made you skip it. If the material contradicts something already in the wiki, **surface the contradiction rather than quietly overwriting** — the existing document may be right, and the resolution may need the user.

## Guardrails

- **Do not ingest secrets.** Credentials, tokens, private keys, `.env` values. Reference the variable name and where it is configured.
- **Do not ingest material the user has no right to redistribute** into a repository that others will read.
- **Do not present inference as sourced fact.** If you are extrapolating from the material rather than reporting it, mark the document `status: draft` and say which parts are inference.
- **Do not fabricate `last_modified`, `author`, or `usage_count`.** Omit a signal you do not have; a wrong credibility signal is worse than an absent one.
