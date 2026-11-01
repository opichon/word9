#!/usr/bin/env python3
"""Build the SQLite catalog of a repokb bundle.

Usage: catalog.py [--check] [--staged] [KNOWLEDGE_DIR]   (default: ./knowledge)

Writes KNOWLEDGE_DIR/.catalog.sqlite: every page outside raw/ and _log/, its
frontmatter, its tags, sources, reviews and links, and a full-text index over
title, description, tags and body (knowledge/AGENTS.md, "Catalog"). The
catalog is derived but committed with the pages: the markdown is the source of
truth, and the catalog is rebuilt from it in about a second, never edited. Query it with
`sqlite3 knowledge/.catalog.sqlite`; the schema is in SCHEMA below.

The catalog records a digest of its inputs (meta.inputs_digest): the content
of every page, the path of every other file in the bundle outside _log/, dotfiles
aside (link kinds and originals depend on which files exist), and the source of this
script and _bundle.py. A run whose digest matches the catalog's leaves the
file untouched, so a rebuild with nothing changed adds no diff. With --check,
nothing is written; the exit code is 1 when the catalog is missing or its
digest differs. File times play no part, so the check holds after a clone.

When the new digest equals that of the catalog committed at HEAD, HEAD's copy
is written back instead of a fresh build: edits that are reverted leave no
catalog diff (a fresh build differs by meta.built_at).

With --staged, the bundle and these scripts are taken from the git index
instead of the working tree, so the catalog matches exactly what the next
commit holds (unstaged edits and untracked files left out). The pre-commit
hook in .githooks/ runs it; --check --staged checks the staged catalog.
"""
import datetime
import hashlib
import os
import re
import shutil
import sqlite3
import subprocess
import sys
import tempfile

import _bundle
from _bundle import LINK, originals, pages, parse_args, parse_frontmatter, split_frontmatter

SCHEMA_VERSION = "1"
SCHEMA = """
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);
CREATE TABLE pages (
  path TEXT PRIMARY KEY,          -- relative to the bundle root
  type TEXT,                      -- NULL for indexes
  title TEXT,                     -- frontmatter title, or an index's first heading
  description TEXT,
  section TEXT,                   -- first two path parts: wiki/components, _sources/external, …
  status TEXT,                    -- draft | stable | deprecated; NULL means stable
  tier TEXT,                      -- unverified | machine-confirmed | human-reviewed
  changed_since_review INTEGER,   -- 1 when generated.at is later than the newest review
  generated_by TEXT,
  generated_at TEXT,
  reviewed_at TEXT,               -- newest verified[].at
  stale_after TEXT,
  body TEXT                       -- markdown after the frontmatter
);
CREATE TABLE tags (path TEXT REFERENCES pages, tag TEXT, PRIMARY KEY (path, tag));
CREATE TABLE sources (
  path TEXT REFERENCES pages, source_id TEXT, resource TEXT, title TEXT, author TEXT, last_modified TEXT
);
CREATE TABLE reviews (path TEXT REFERENCES pages, by TEXT, at TEXT);
-- The originals in raw/ a page refers to, by a body link or a sources[].resource.
CREATE TABLE originals (path TEXT REFERENCES pages, original TEXT, PRIMARY KEY (path, original));
CREATE TABLE links (
  src TEXT REFERENCES pages,      -- linking page
  target TEXT,                    -- the link as written
  dst TEXT,                       -- resolved path relative to the bundle root; NULL for a URL
  kind TEXT                       -- page | index | raw | missing | outside | url
);
CREATE INDEX links_dst ON links (dst);
CREATE INDEX links_src ON links (src);
CREATE VIRTUAL TABLE search USING fts5 (path UNINDEXED, title, description, tags, body, tokenize = 'porter unicode61');

-- Inbound links per page: what breaks or needs a look when it changes.
CREATE VIEW backlinks AS
  SELECT DISTINCT l.dst AS path, l.src, p.title AS src_title FROM links l JOIN pages p ON p.path = l.src
  WHERE l.kind IN ('page', 'index');
-- Pages with stale_after in the past.
CREATE VIEW stale AS
  SELECT path, title, stale_after FROM pages WHERE stale_after < date('now');
-- Concept pages nothing links to, not even their index.
CREATE VIEW orphans AS
  SELECT path, title FROM pages WHERE type IS NOT NULL AND path NOT IN (SELECT dst FROM links WHERE dst IS NOT NULL);
-- _sources/ concepts that refer to no original in raw/.
CREATE VIEW unbacked AS
  SELECT path, title FROM pages WHERE section LIKE '_sources/%' AND type IS NOT NULL
  AND path NOT IN (SELECT path FROM originals);
-- Links to pages not written yet.
CREATE VIEW gaps AS
  SELECT src, target FROM links WHERE kind = 'missing';
"""


def tier(reviews):
    if any(str(r.get("by", "")).startswith("human:") for r in reviews):
        return "human-reviewed"
    return "machine-confirmed" if reviews else "unverified"


def inputs_digest(root):
    """Hash of everything the catalog is built from; see the module docstring."""
    h = hashlib.sha256()
    for script in (__file__, _bundle.__file__):
        h.update(open(script, "rb").read())
    for d, dirs, files in os.walk(root):
        rel = os.path.relpath(d, root)
        if rel.split(os.sep)[0] == "_log":
            dirs[:] = []
            continue
        dirs.sort()
        for f in sorted(files):
            if f.startswith("."):
                continue  # .DS_Store and the catalog itself
            path = os.path.join(d, f)
            name = os.path.relpath(path, root)
            h.update(name.encode() + b"\0")
            if f.endswith(".md") and rel.split(os.sep)[0] != "raw":
                h.update(open(path, "rb").read() + b"\0")
    return h.hexdigest()


def stored_digest(out):
    if not os.path.exists(out):
        return None
    try:
        db = sqlite3.connect(f"file:{out}?mode=ro", uri=True)
        row = db.execute("SELECT value FROM meta WHERE key = 'inputs_digest'").fetchone()
        db.close()
    except sqlite3.Error:
        return None
    return row[0] if row else None


def git_env():
    """The environment for git, with an exported GIT_DIR and work tree made absolute.

    In a linked worktree, or with --git-dir, git exports GIT_DIR to hooks with no GIT_WORK_TREE
    or a relative one. Either way the top of the work tree then depends on the current directory,
    so `git -C knowledge` would take knowledge/ for it. Pin it to where this script started, the
    top in a hook. GIT_INDEX_FILE stays: `git commit -a` and `git commit <path>` hand the hook a
    temporary index, which is what the commit will hold.
    """
    env = dict(os.environ)
    if "GIT_DIR" in env:
        env["GIT_DIR"] = os.path.abspath(env["GIT_DIR"])
        env["GIT_WORK_TREE"] = os.path.abspath(env.get("GIT_WORK_TREE", "."))
    return env


def git(cwd, *args, stdin=None):
    return subprocess.run(["git", "-C", cwd, *args], input=stdin, capture_output=True, check=True, env=git_env()).stdout


def head_catalog(root, tmp):
    """HEAD's committed catalog written to tmp, or None outside git or when HEAD has none."""
    try:
        blob = git(root, "show", "HEAD:./.catalog.sqlite")
    except (OSError, subprocess.CalledProcessError):
        return None
    with open(tmp, "wb") as f:
        f.write(blob)
    return tmp


def install(root, out, candidate):
    """Write candidate to out, or HEAD's catalog when it records the same digest."""
    with tempfile.TemporaryDirectory() as tmp:
        head = head_catalog(root, os.path.join(tmp, "head.sqlite"))
        digest = stored_digest(candidate)
        src = head if head and digest and stored_digest(head) == digest else candidate
        if os.path.abspath(src) != os.path.abspath(out):
            shutil.copyfile(src, out)
    return src == head


def staged(root, check):
    """Run the index's copy of this script on the index's copy of the bundle."""
    top = git(root, "rev-parse", "--show-toplevel").decode().strip()
    scripts = os.path.relpath(os.path.dirname(os.path.abspath(__file__)), top)
    bundle = os.path.relpath(root, top)
    # The copy below is in no repository, so its run must not inherit this one's.
    outside = {k: v for k, v in os.environ.items() if k not in ("GIT_DIR", "GIT_INDEX_FILE", "GIT_WORK_TREE")}
    with tempfile.TemporaryDirectory() as tmp:
        files = git(top, "ls-files", "-z", "--", bundle, scripts)
        git(top, "checkout-index", "-z", "--stdin", f"--prefix={tmp}/", stdin=files)
        copy = os.path.join(tmp, bundle)
        run = subprocess.run(
            [sys.executable, os.path.join(tmp, scripts, "catalog.py"), *(["--check"] if check else []), copy],
            capture_output=True, text=True, env=outside,
        )
        if check or run.returncode:
            sys.stdout.write(run.stdout.replace(tmp + os.sep, ""))
            sys.stderr.write(run.stderr)
            sys.exit(run.returncode)
        out = os.path.join(root, ".catalog.sqlite")
        reused = install(root, out, os.path.join(copy, ".catalog.sqlite"))
        print(f"{os.path.relpath(out)} {'restored from HEAD' if reused else 'built'} from the staged pages")


def build(root, out, digest):
    tmp = out + ".tmp"
    if os.path.exists(tmp):
        os.remove(tmp)
    db = sqlite3.connect(tmp)
    db.executescript(SCHEMA)
    all_pages = list(pages(root))
    fms = {}
    for page in all_pages:
        text = open(page, encoding="utf-8").read()
        fms[page] = (parse_frontmatter(text), split_frontmatter(text)[1])

    for page, (fm, body) in fms.items():
        rel = os.path.relpath(page, root)
        is_index = os.path.basename(page) == "index.md"
        heading = re.search(r"^# (.+)$", body, re.M)
        title = fm.get("title") or (heading.group(1).strip() if heading else rel)
        generated = fm.get("generated") if isinstance(fm.get("generated"), dict) else {}
        reviews = [r for r in fm.get("verified") or [] if isinstance(r, dict)]
        reviewed = max((str(r.get("at")) for r in reviews), default=None)
        tags = [str(t) for t in fm.get("tags") or []] if isinstance(fm.get("tags"), list) else []
        at = str(generated.get("at")) if generated.get("at") else None
        db.execute(
            "INSERT INTO pages VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (
                rel, None if is_index else fm.get("type"), title, fm.get("description"),
                "/".join(rel.split(os.sep)[:2]) if os.sep in rel else "", fm.get("status"),
                None if is_index else tier(reviews), int(bool(reviewed and at and at > reviewed)),
                generated.get("by"), at, reviewed, str(fm["stale_after"]) if fm.get("stale_after") else None, body,
            ),
        )
        db.executemany("INSERT OR IGNORE INTO tags VALUES (?,?)", [(rel, t) for t in tags])
        db.executemany(
            "INSERT INTO sources VALUES (?,?,?,?,?,?)",
            [(rel, s.get("id"), s.get("resource"), s.get("title"), s.get("author"), str(s.get("last_modified") or "") or None)
             for s in fm.get("sources") or [] if isinstance(s, dict)],
        )
        db.executemany("INSERT INTO originals VALUES (?,?)", [(rel, os.path.relpath(f, root)) for f in originals(page, root)])
        db.executemany("INSERT INTO reviews VALUES (?,?,?)", [(rel, r.get("by"), str(r.get("at"))) for r in reviews])
        db.execute("INSERT INTO search VALUES (?,?,?,?,?)", (rel, title, fm.get("description"), " ".join(tags), body))

        here = os.path.dirname(page)
        code_free = re.sub(r"`[^`\n]*`", "", re.sub(r"```.*?```", "", body, flags=re.S))
        for target in LINK.findall(code_free):
            if target.startswith("#") or target.startswith("mailto:"):
                continue
            if re.match(r"^[a-z][a-z0-9+.-]*://", target):
                db.execute("INSERT INTO links VALUES (?,?,?,?)", (rel, target, None, "url"))
                continue
            full = os.path.normpath(os.path.join(here, target.split("#")[0]))
            if not full.startswith(root + os.sep):
                kind = "outside"
            elif not os.path.exists(full):
                kind = "missing"
            elif full.startswith(os.path.join(root, "raw") + os.sep):
                kind = "raw"
            else:
                kind = "index" if os.path.basename(full) == "index.md" else "page"
            db.execute("INSERT INTO links VALUES (?,?,?,?)", (rel, target, os.path.relpath(full, root), kind))

    root_fm = parse_frontmatter(open(os.path.join(root, "index.md"), encoding="utf-8").read())
    db.executemany(
        "INSERT INTO meta VALUES (?,?)",
        [
            ("built_at", datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")),
            ("inputs_digest", digest),
            ("okf_version", str(root_fm.get("okf_version") or "")),
            ("schema_version", SCHEMA_VERSION),
        ],
    )
    db.commit()
    db.close()
    os.replace(tmp, out)
    return len(all_pages)


def main():
    from_index = "--staged" in sys.argv
    sys.argv = [a for a in sys.argv if a != "--staged"]
    root, check = parse_args(__doc__)
    if from_index:
        return staged(root, check)
    out = os.path.join(root, ".catalog.sqlite")
    digest, stored = inputs_digest(root), stored_digest(out)
    if check:
        print("catalog up to date" if stored == digest else "catalog missing" if stored is None and not os.path.exists(out) else "catalog out of date")
        sys.exit(0 if stored == digest else 1)
    if stored == digest:
        print(f"{os.path.relpath(out)} up to date")
        return
    with tempfile.TemporaryDirectory() as tmp:
        head = head_catalog(root, os.path.join(tmp, "head.sqlite"))
        if head and stored_digest(head) == digest:
            shutil.copyfile(head, out)
            print(f"{os.path.relpath(out)} restored from HEAD")
            return
    print(f"{build(root, out, digest)} page(s) catalogued in {os.path.relpath(out)}")


if __name__ == "__main__":
    main()
