## Start here: the knowledge base

**`knowledge/` is this repository's knowledge base and the first thing to consult in any session.** It holds what the code cannot tell you on its own — why things are the way they are, what broke before, what was decided and rejected, and knowledge ingested from outside sources.

`knowledge/AGENTS.md` is the contract for the bundle: how to read it, what its trust metadata means, which directories are off limits, and the rules for writing. Read it before citing anything out of `knowledge/` or editing anything under it.

**Every page has a semantic heading structure, and every heading means something.** A page has exactly one `#` (h1) heading, its title; its sections are `##` (h2), their sub-sections `###` (h3), and so on, never skipping a level. A heading says what its section holds, so `Pages` or `Contents` will not do. An index lists what its folder holds under a heading naming those things, `## <Things>`, split into several sections where that helps the reader.

**Every page has frontmatter, with a `type` and an `id`.** That includes every `_log/` file. Only `index.md` files, which OKF and AI-XF forbid it (the bundle root's carries `okf_version` alone), and the originals in `raw/` are exempt.
