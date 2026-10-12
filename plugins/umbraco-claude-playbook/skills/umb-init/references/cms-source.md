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
2. Otherwise look for an existing clone: a git repo with a remote that points at
   `umbraco/Umbraco-CMS`. Check the remote, not the folder name: people who contribute to the
   CMS often have a fork, so also accept an `upstream` remote that points there.
   ```bash
   git -C <dir> remote -v   # origin or upstream should contain umbraco/Umbraco-CMS
   ```
   Look, in this order:
   - Folders next to this repo, and next to its parent folder. People tend to keep related
     repos together.
   - `~/source/repos/`, Visual Studio's default clone folder on Windows.
   - Common home-folder habits: `~/Code/`, `~/src/`, `~/Projects/`, `~/repos/`.

   One found → confirm it with the user, then record it. More than one → ask which. None
   found → ask whether they already have a clone somewhere else before offering a new one.

## Default if missing

Ask first. Explain that it's a large download, kept once per machine and shared by every
project, and that without it lookups still work through `gh`, just slower. Offer
`~/Code/Umbraco-CMS` as the location (`~/source/repos/Umbraco-CMS` on Windows, next to their
other Visual Studio clones), or another path the user names. Never clone inside this project.

```bash
git clone https://github.com/umbraco/Umbraco-CMS.git ~/Code/Umbraco-CMS
```

On Windows, if the clone fails with a "Filename too long" error, turn on long paths and retry:
`git config --global core.longpaths true`.

Use a full clone. A partial clone (`--filter=blob:none`) downloads less up front, but then
`git grep` across a release tag fetches each file one at a time, which makes searches very
slow.

On a no, record nothing. A re-run of `umb-init` offers it again.

## Record

1. Add the line to `CLAUDE.local.md` at the repo root, creating the file if needed (append
   if it exists; never rewrite what's there). Write the full path with forward slashes, never
   `~`: a quoted `"~/..."` isn't expanded, so git can't find the folder. Forward slashes work
   for git on Windows too.
   ```markdown
   # CLAUDE.local.md

   Personal, machine-specific settings. Not committed.

   - Umbraco CMS source: /Users/jane/Code/Umbraco-CMS
   ```
   On Windows: `C:/Users/jane/source/repos/Umbraco-CMS`.
2. Make sure `.gitignore` lists `CLAUDE.local.md`. Add it if it's missing.
