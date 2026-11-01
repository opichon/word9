---
name: update
description: "Finish a `repokb update`: resolve the conflict markers it left in the knowledge base contract, skills, scripts, hooks and workflows, and port template changes into files it could not merge, keeping this repository's local rules. Use after `repokb update` reports a conflict or a file it did not merge. Trigger: /repokb:update"
---

# /repokb:update

`repokb update` merges repokb's new templates into this install. It stops short where it needs judgement, and this skill finishes the job. Nothing here touches pages: `index.md` files, `wiki/`, `_sources/`, `raw/` and `_log/` belong to this repository.

## Step 1 — Find the work

```bash
git status --short
git grep -n '^<<<<<<< installed'
```

`repokb update` also printed the files it did not merge, marked `NOT MERGED`. If that output is gone, compare each file in `.claude/skills/repokb/`, `knowledge/AGENTS.md`, `knowledge/CLAUDE.md` and `REPOKB.md` with the template in the new `@dzangolab/repokb` package.

## Step 2 — Resolve each conflict

Each conflict has three sides:

- `<<<<<<< installed`: this repository's version.
- `||||||| repokb <from>`: the template both sides started from.
- `>>>>>>> repokb <to>`: the new template.

Compare each side with the middle one to see what each changed, then write the text that keeps both intents:

- A rule specific to this repository stays.
- A general change to repokb's rules, format or tooling comes in.
- Where the local text only restates an older template, take the new text.

If the two genuinely contradict, keep the local rule, leave the markers out, and list it in your report so a person can decide. Never delete a local rule silently.

## Step 3 — Port the files it did not merge

These differ from the template, and the base version has no such file, so there is no record of which differences are local. Read the template and the installed file, and bring in what the template adds without removing local rules.

## Step 4 — Check and report

1. `git grep -n '^<<<<<<< installed'` finds nothing.
2. Rebuild the catalog: run `catalog.py knowledge` from `.claude/skills/repokb/scripts/`.
3. Leave the changes uncommitted, for review, and report each file you changed, each contradiction you left to a person, and anything you could not port.
