# Step 9: Docs source

A local clone of `umbraco/UmbracoDocs` lets every phase search the official docs for the
project's major in one fast call, instead of fetching pages one at a time from the live site.
`umbraco-docs` says how it's used. This step finds or creates the clone and records where it
is.

The path is personal: it's different on every machine. It goes in `CLAUDE.local.md`, never in
the shared `CLAUDE.md`.

## Detect

1. `CLAUDE.local.md` already has an `Umbraco docs source:` line whose path is a git repo with
   an `umbraco/UmbracoDocs` remote → done, move on.
2. Otherwise look for an existing clone: a git repo with a remote that points at
   `umbraco/UmbracoDocs`. Check the remote, not the folder name: people who contribute to the
   docs often have a fork, so also accept an `upstream` remote that points there.
   ```bash
   git -C <dir> remote -v   # origin or upstream should contain umbraco/UmbracoDocs
   ```
   Look in the same places as step 8 (`references/cms-source.md`), starting next to the CMS
   clone if step 8 found one.

   One found → confirm it with the user, then record it. More than one → ask which. None
   found → ask whether they already have a clone somewhere else before offering a new one.

## Default if missing

Ask first. Explain that it's a large download (mostly images), kept once per machine and
shared by every project, and that without it lookups still work through the live site, just
slower. Offer the folder next to the CMS clone, or `~/Code/UmbracoDocs`
(`~/source/repos/UmbracoDocs` on Windows), or another path the user names. Never clone inside
this project.

```bash
git clone https://github.com/umbraco/UmbracoDocs.git ~/Code/UmbracoDocs
```

Use a full clone, for the same reason as step 8: a partial clone makes `git grep` fetch each
file one at a time.

On a no, record nothing. A re-run of `umb-init` offers it again.

## Record

1. Add the line to `CLAUDE.local.md` at the repo root, next to step 8's line if there is one,
   creating the file if needed (append if it exists; never rewrite what's there). Write the
   full path with forward slashes, never `~`.
   ```markdown
   - Umbraco docs source: /Users/jane/Code/UmbracoDocs
   ```
   On Windows: `C:/Users/jane/source/repos/UmbracoDocs`.
2. Make sure `.gitignore` lists `CLAUDE.local.md`. Add it if it's missing.
