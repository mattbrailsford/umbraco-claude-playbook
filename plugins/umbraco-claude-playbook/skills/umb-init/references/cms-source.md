# Step 8: CMS source

A local clone of `umbraco/Umbraco-CMS` lets every phase read the CMS's real source at the
project's release tag in one fast call, instead of fetching files one at a time through `gh`.
`umbraco-cms-source` says how it's used. This step finds or creates the clone and records
where it is.

The path is personal: it's different on every machine. It goes in `CLAUDE.local.md`, never in
the shared `CLAUDE.md`.

## Detect

1. `CLAUDE.local.md` already has an `Umbraco CMS source:` line whose path is a git repo with
   an `umbraco/Umbraco-CMS` remote → done, move on.
2. Otherwise look for an existing clone: a git repo whose `origin` remote points at
   `umbraco/Umbraco-CMS`, in the usual places (siblings of this repo, `~/Code/`, `~/src/`,
   `~/Projects/`, `~/repos/`, `~/Documents/`, three levels deep at most). Check the remote, not
   the folder name:
   ```bash
   git -C <dir> remote get-url origin   # should contain umbraco/Umbraco-CMS
   ```
   One found → confirm it with the user, then record it. More than one → ask which.

## Default if missing

Ask first. Explain that it's a large download, kept once per machine and shared by every
project, and that without it lookups still work through `gh`, just slower. Offer
`~/Code/Umbraco-CMS` as the location, or another path the user names. Never clone inside this
project.

```bash
git clone https://github.com/umbraco/Umbraco-CMS.git ~/Code/Umbraco-CMS
```

Use a full clone. A partial clone (`--filter=blob:none`) downloads less up front, but then
`git grep` across a release tag fetches each file one at a time, which makes searches very
slow.

On a no, record nothing. A re-run of `umb-init` offers it again.

## Record

1. Add the line to `CLAUDE.local.md` at the repo root, creating the file if needed (append
   if it exists; never rewrite what's there):
   ```markdown
   # CLAUDE.local.md

   Personal, machine-specific settings. Not committed.

   - Umbraco CMS source: ~/Code/Umbraco-CMS
   ```
2. Make sure `.gitignore` lists `CLAUDE.local.md`. Add it if it's missing.
