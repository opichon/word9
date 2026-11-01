---
name: ingest-conversation
description: "Distill durable knowledge from the current conversation into the knowledge/ knowledge base as OKF v0.2 concept documents — decisions made, constraints discovered, bugs diagnosed, approaches ruled out — routing each into the right section, archiving the conversation itself verbatim in knowledge/raw/conversations/, and updating index.md and the day's file in _log/. Use at the end of a working session or when something worth keeping was figured out. Trigger: /repokb:ingest-conversation"
---

# /repokb:ingest-conversation

Harvests what this session learned and writes it into `knowledge/` so it outlives the chat history, and keeps the chat history itself alongside it. Read `knowledge/AGENTS.md` first — it is the authoring contract this skill conforms to.

## Usage

```
/repokb:ingest-conversation                  # triage the whole session and write what is durable
/repokb:ingest-conversation <focus>          # only what relates to <focus>
/repokb:ingest-conversation --dry-run        # show the triage and proposed routing, write nothing
/repokb:ingest-conversation --session-only   # write only the transcript and session record, skip promoting to concepts
```

`--dry-run` first is a good habit on a long session.

## The failure mode this skill exists to avoid

The obvious implementation — summarise the conversation into a file — produces a chronological transcript summary that nobody ever reads. It grows without bound, duplicates concepts that already exist, and buries the two genuinely valuable sentences inside a wall of "then we tried X".

**The unit of output is a concept, not a session.** Route each piece of knowledge to where someone would go looking for it. The session record is a byproduct, not the product.

## Step 1 — Triage

Go back through the conversation and sort what happened. Be strict; most of a session is not knowledge.

**Durable — write it:**

| Kind                                      | Goes to                                                                       | Example                                                                    |
| ----------------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| A constraint discovered the hard way      | `knowledge/wiki/troubleshooting/` or `knowledge/wiki/architecture/`           | "typecheck reads the libs' `dist/types`, so it lies after a lib edit"      |
| A decision, with alternatives and reasons | whichever section it is about: `architecture/`, `conventions/`, `operations/` | "we kept jobs in-process rather than splitting a worker service, because…" |
| A corrected mental model                  | `knowledge/wiki/architecture/`                                                | "REST and GraphQL are two doors onto one service layer, not two stacks"    |
| A diagnosed bug: symptom → cause → fix    | `knowledge/wiki/troubleshooting/`                                             | anything that cost more than a few minutes to work out                     |
| Product or business meaning               | `knowledge/wiki/domain/`                                                      | what a profile status actually gates                                       |
| A pattern the codebase expects            | `knowledge/wiki/conventions/`                                                 | wiring steps a new model must not skip                                     |
| A constraint behind the test setup        | `knowledge/wiki/testing/`                                                     | "every Vitest config starts its workers without Node's localStorage"       |
| A shortcut taken or work deferred         | `knowledge/wiki/technical-debt/`                                              | "the old validator stays until the last form migrates, because…"           |
| **An approach that failed, and why**      | usually `knowledge/_sources/conversations/`                                   | the highest-value output of most sessions                                  |

**Not durable — leave it out:**

- What the code plainly says. If `grep` answers it, the wiki should not repeat it.
- Anything already in git history, a PR description, or `CLAUDE.md`.
- The narrative of how you searched, which files you opened, what you tried first.
- Task-specific mechanics that will not recur.
- Anything already in the wiki and unchanged — link it instead.

The test: **would this have saved someone time if they had read it before starting?** If not, drop it.

## Step 2 — Attribute honestly

This step is what separates a useful knowledge base from one that launders guesses into authority. For each item, know which it is:

- **The user stated it.** Highest value — this is knowledge that exists nowhere else. Attribute to them.
- **You verified it** by reading code, running a command, or reproducing a failure. Solid; cite what you read or ran.
- **You inferred it** and nobody checked. Mark the document `status: draft` and say which parts are inference.
- **The user corrected you.** Write the corrected version, and if the wrong model was tempting, say why it is wrong — the misconception will recur.

**Never write a `verified` entry with a `human:` actor unless a human in this conversation actually confirmed that specific content.** A user saying "sounds good" to a plan is not verification of the facts in a document you then wrote.

## Step 3 — Update before you create

For each durable item, search the wiki:

```bash
grep -ril '<subject>' knowledge/
```

If a concept already covers it, **extend that document**. A near-duplicate splits knowledge in two and both halves rot. When updating: merge the material in, refresh `generated.at`, and log an `**Update**`.

Create a new concept only when nothing covers the subject. One concept per file — if the title needs "and", it is two documents.

When new knowledge **contradicts** an existing document, do not silently overwrite. Correct it, note what changed and why in today's `knowledge/_log/` file, and tell the user in your report. If the old claim was human-verified and you are contradicting it from inference, say so explicitly and let the user decide.

## Step 4 — Archive the conversation in `raw/conversations/`

The concepts are the distillation; this is the original. Write the session's transcript to:

```
knowledge/raw/conversations/YYYY-MM-DD-<slug>.md
```

Use **the same date and slug as the session record** in Step 5, so the pair is obvious from a directory listing: `raw/conversations/2026-08-17-stale-type-errors.md` beside `_sources/conversations/2026-08-17-stale-type-errors.md`.

**Do not ask** — the archive is the default, and a user who does not want it can delete the file. It is written even under `--session-only`. Under `--dry-run` nothing is written, here as everywhere.

### As verbatim as you can make it

This file exists precisely because the distillation is lossy. It is the one place the exact wording survives, so reproduce the conversation rather than describe it:

- **Every user message, word for word.** Never summarise, tidy, correct, or reorder a user turn. Their phrasing is the highest-value content in the file.
- **Assistant turns in full prose**, as written, in order.
- **Tool calls as a one-line note** — `[tool: Bash — grep -ril 'slonik' knowledge/]` — and their output only where it carried the conclusion (an error message, a failing test, a value that decided something). Full dumps of file reads and directory listings are noise; elide them and say you did.
- **Keep the order.** No thematic regrouping. This file is chronological on purpose — that is what makes it a transcript rather than a second, worse summary.

Head the file with what it is, then label each turn:

```markdown
> Claude Code session, 2026-08-17. Verbatim transcript; tool output elided where noted.

## User

Fix the typecheck errors in the API — they showed up after I touched the auth lib.

## Assistant

...

[tool: Bash — pnpm -F api typecheck]

...
```

No frontmatter — `raw/` files never carry any (`knowledge/AGENTS.md`, file rules). It gets no `index.md` entry either; `raw/` is not indexed.

### Where verbatim yields

Two things override fidelity, and only two:

- **Secrets.** Credentials, tokens, keys, `.env` values, customer data. Replace with `[redacted: <what it was>]` and note the redaction in the header. This applies to a value the _user_ pasted too.
- **Length you cannot carry.** If the session is too long to reproduce, elide the least load-bearing stretches and mark each gap — `[… 20 turns elided: iterating on test fixtures …]` — rather than silently truncating or compressing the whole thing. Never elide a user turn to save room.

An honestly partial transcript is a good record. One that looks complete and is not is a bad one.

### Then never read it again

`knowledge/raw/` is human-only (`knowledge/AGENTS.md`, working rule 6), and a markdown transcript is the most tempting file in it — resist that. A later session answers from the concepts and the session record, not from this file. It is here for the human who wants to know what was actually said.

## Step 5 — Write the session record

Alongside the concepts, write one record to `knowledge/_sources/conversations/YYYY-MM-DD-<slug>.md`:

```yaml
---
type: Session Knowledge
id: sources-conversations-2026-08-17-stale-type-errors
title: Diagnosing stale type errors in the API
description: Why typecheck reported errors that did not exist, and the lib rebuild ordering that fixes it.
tags: [build, libs, typecheck, session]
sources:
  - id: session
    resource: "conversation: Claude Code session, 2026-08-17"
    title: Working session on API type errors
    author: human:username
    last_modified: 2026-08-17
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-17T16:40:00Z
status: stable
---
```

The `id` comes from the page's path (`knowledge/AGENTS.md`, Concept frontmatter), and so does each concept's.

OKF allows `sources[].resource` to be a **scope descriptor** rather than a fetchable artifact (§6.2), which is what a conversation is. Do not invent a URL for it.

Keep the body short and link outward, opening with the breadcrumb trail (`knowledge/AGENTS.md`, Breadcrumbs):

```markdown
[Home](../../index.md) › [Sources](../index.md) › [Conversations](index.md) › Diagnosing stale type errors in the API

# Diagnosing stale type errors in the API

## Question

What the session set out to do.

## Outcome

What was concluded, in two or three lines. Link the concepts this produced.

## Ruled out

What was tried and rejected, and why. This is the part that exists nowhere else.

## Open

What is still unknown, and what would settle it.
```

Link the Step 4 transcript once from the body for the human reader — "the conversation as it happened is at [raw/conversations/…](../../raw/conversations/…)" — with the path relative to the record, and leave it at that. The record must stand on its own without it, since no agent will open it.

**`## Ruled out` is the reason this file exists.** Concepts capture what is true; only the session record captures what looked true and was not. Write that section even when it is the only one with content.

`--session-only` stops here — the transcript and this record, nothing promoted — which is right for an exploratory session that concluded nothing durable yet.

## Step 6 — Update indexes and the log

In the same change:

1. Every directory whose contents changed gets its `index.md` updated — new entries with the concept's `description`, removed entries pruned. An index has no frontmatter (`knowledge/AGENTS.md`, `index.md` format). Every concept you wrote, and any `index.md` or log file you created, opens with its breadcrumb trail (`knowledge/AGENTS.md`, Breadcrumbs).
2. Today's log file, `knowledge/_log/<YYYYMMDD>.md`, gets one entry for this ingest, however many pages it wrote — created if this is the day's first change, with its `id` (`knowledge/AGENTS.md`, `_log/` format) — newest first, using `**Creation**` / `**Update**` / `**Deprecation**`.
3. Cross-link both directions where the relationship is load-bearing.
4. **Rebuild the catalog**: run `catalog.py knowledge` from the plugin's `scripts/` folder (two levels above this skill's base directory; in this repository `.claude/skills/repokb/scripts/`), last, so it holds what you just wrote.

## Step 7 — Report

Tell the user:

- What you wrote and where, as a short list of paths, the transcript in `raw/conversations/` among them.
- Whether the transcript is complete, and what you elided or redacted if it is not.
- What you **deliberately left out** of the concepts, in a line. This is how they catch a bad triage call, and it is the part they can most usefully correct.
- Anything contradicting existing wiki content.
- Which documents are inference (`draft`) and would benefit from their confirmation.

Then offer the one thing you cannot do yourself: ask whether they want to mark any of it human-verified. If they confirm specific documents, add `verified: [{ by: human:<id>, at: <ISO> }]` to those and log a `**Verification**` line. Human-reviewed is the only tier that carries real weight, and it can only come from them.

## Guardrails

- **No secrets** — credentials, tokens, `.env` values, customer data that surfaced in the session. Reference the variable name and where it lives.
- **No transcript dumps in concepts.** If a concept document reads chronologically, it is wrong; rewrite it as a concept. The chronological record belongs in `raw/conversations/` and nowhere else.
- **No inflated confidence.** "Unconfirmed" written down is worth more than a clean-looking assertion that turns out to be wrong, because the next reader can act on the uncertainty.
- **Absolute dates**, always. The reader is in an unknown future.
