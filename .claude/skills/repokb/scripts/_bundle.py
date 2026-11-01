"""Shared helpers for the repokb maintenance scripts."""
import os
import re
import sys

SKIP_DIRS = ("raw", "_log")
FRONTMATTER = re.compile(r"\A---\n.*?\n---\n", re.S)


def parse_args(usage):
    args = sys.argv[1:]
    check = "--check" in args
    args = [a for a in args if a != "--check"]
    if len(args) > 1 or any(a.startswith("-") for a in args):
        sys.exit(usage)
    root = os.path.abspath(args[0] if args else "knowledge")
    if not os.path.isfile(os.path.join(root, "index.md")):
        sys.exit(f"{root}/index.md not found: not a repokb bundle")
    return root, check


def pages(root):
    """Every .md page of the bundle, outside raw/ and _log/, except the root CLAUDE.md pointer."""
    for d, dirs, files in os.walk(root):
        rel = os.path.relpath(d, root)
        if rel.split(os.sep)[0] in SKIP_DIRS:
            dirs[:] = []
            continue
        dirs.sort()
        for f in sorted(files):
            if f == "CLAUDE.md" and d == root:
                continue  # one-line @AGENTS.md import: not a page
            if f.endswith(".md"):
                yield os.path.join(d, f)


def split_frontmatter(text):
    m = FRONTMATTER.match(text)
    return (m.group(0), text[m.end():]) if m else ("", text)


# --- Frontmatter: the YAML subset OKF pages use (stdlib only, no PyYAML) ---

LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")


def _plain(s):
    s = s.strip()
    if s[:1] == '"':
        import json

        try:
            return json.loads(s)
        except ValueError:
            return s.strip('"')
    if s[:1] == "'":
        return s[1:-1].replace("''", "'")
    s = re.sub(r"\s+#.*$", "", s)
    return {"true": True, "false": False, "null": None, "~": None, "": None}.get(s, s)


def _flow(s, i=0):
    """Parse a flow value ([…], {…}, quoted or plain scalar) starting at s[i]; return (value, next index)."""
    while i < len(s) and s[i] == " ":
        i += 1
    if i < len(s) and s[i] in "[{":
        close, out = ("]", []) if s[i] == "[" else ("}", {})
        i += 1
        while True:
            while i < len(s) and s[i] in " ,":
                i += 1
            if i >= len(s) or s[i] == close:
                return out, i + 1
            if close == "]":
                v, i = _flow(s, i)
                out.append(v)
            else:
                j = s.index(":", i)
                key = _plain(s[i:j])
                v, i = _flow(s, j + 1)
                out[key] = v
    if i < len(s) and s[i] in "\"'":
        q, j = s[i], i + 1
        while j < len(s) and not (s[j] == q and s[j - 1] != "\\"):
            j += 1
        return _plain(s[i : j + 1]), j + 1
    j = i
    while j < len(s) and s[j] not in ",]}":
        j += 1
    return _plain(s[i:j]), j


def _value(rest):
    rest = rest.strip()
    return _flow(rest)[0] if rest[:1] in "[{" else _plain(rest)


def parse_frontmatter(text):
    """The frontmatter of a page as a dict ({} when it has none)."""
    m = FRONTMATTER.match(text)
    if not m:
        return {}
    lines = m.group(0).split("\n")[1:-2]
    out, i = {}, 0
    while i < len(lines):
        km = re.match(r"^([A-Za-z_][\w-]*):(.*)$", lines[i])
        i += 1
        if not km:
            continue
        key, rest = km.group(1), km.group(2)
        if rest.strip():
            out[key] = _value(rest)
            continue
        block = []
        while i < len(lines) and (lines[i].startswith((" ", "\t")) or not lines[i].strip()):
            if lines[i].strip():
                block.append(lines[i])
            i += 1
        if block and block[0].strip().startswith("- "):
            items, indent = [], None
            for line in block:
                stripped = line.strip()
                if stripped.startswith("- ") and (indent is None or len(line) - len(line.lstrip()) <= indent):
                    indent = len(line) - len(line.lstrip())
                    item = stripped[2:]
                    pair = re.match(r"^([\w-]+):\s(.*)$|^([\w-]+):$", item)
                    if item[:1] in "[{" or not pair:
                        items.append(_value(item))
                    else:
                        items.append({pair.group(1) or pair.group(3): _value(pair.group(2) or "")})
                elif items and isinstance(items[-1], dict):
                    pair = re.match(r"^([\w-]+):(.*)$", stripped)
                    if pair:
                        items[-1][pair.group(1)] = _value(pair.group(2))
            out[key] = items
        else:
            out[key] = {}
            for line in block:
                pair = re.match(r"^\s+([\w-]+):(.*)$", line)
                if pair:
                    out[key][pair.group(1)] = _value(pair.group(2))
    return out


def body_links(path):
    """(target, resolved path) for every relative link in a page's body, code ignored."""
    _, text = split_frontmatter(open(path, encoding="utf-8").read())
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    text = re.sub(r"`[^`\n]*`", "", text)
    here = os.path.dirname(path)
    for target in LINK.findall(text):
        if target.startswith(("http://", "https://", "mailto:", "#")) or re.match(r"^[a-z][a-z0-9+.-]*://", target):
            continue
        yield target, os.path.normpath(os.path.join(here, target.split("#")[0]))


def resource_path(resource, page, root):
    """The file a sources[].resource names inside the repository, or None for a URL or a scope descriptor.

    Accepts repo://<path>, a repository-relative knowledge/… path, and a path relative to the page.
    """
    r = str(resource or "").split("#")[0]
    if r.startswith("repo://"):
        return os.path.normpath(os.path.join(os.path.dirname(root), r[len("repo://"):]))
    if not r or re.match(r"^[a-z][a-z0-9+.-]*:", r) or " " in r:
        return None
    if r.startswith(os.path.basename(root) + "/"):
        return os.path.normpath(os.path.join(os.path.dirname(root), r))
    return os.path.normpath(os.path.join(os.path.dirname(page), r))


def originals(page, root):
    """The files in raw/ a page refers to: by a body link or by a sources[].resource."""
    raw = os.path.join(root, "raw") + os.sep
    fm = parse_frontmatter(open(page, encoding="utf-8").read())
    found = {full for _, full in body_links(page)}
    found |= {resource_path(s.get("resource"), page, root) for s in fm.get("sources") or [] if isinstance(s, dict)}
    return sorted(f for f in found if f and f.startswith(raw) and os.path.isfile(f))
