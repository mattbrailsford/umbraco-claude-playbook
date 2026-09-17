---
name: umb-init
description: >-
  Scaffolds the working files a fresh Umbraco package or project needs before the pipeline
  skills can run — CLAUDE.md, .gitignore, a README stub, and the plan-doc path convention.
  Use when starting a brand-new Umbraco package/add-on/site repo and nothing has been written
  down yet, or when an existing repo is missing CLAUDE.md and wants one.
user-invocable: true
argument-hint: [project name, optional]
---

# umb-init

Stand up the working files so `umb-explore` and the rest of the pipeline have somewhere
to write. You **create structure, not content** — stubs with headings and decisions to make,
never invented decisions.

## Scope

- IN: create/update `CLAUDE.md`, `.gitignore`, a `README.md` stub, and the empty
  `docs/plans/` folder (or whatever path convention the interview settles on).
- OUT: deciding what the project *is* (that's `umb-explore`), architecture
  (`umb-design`), tasks (`umb-plan`). This command does not interview the problem —
  if you're asked "what should this do," stop and point at `umb-explore`.

## Preflight

1. **Re-entrant: if a file already exists, leave it alone.** Report what was already there
   vs. what you created. Never clobber an existing `CLAUDE.md` — if it's missing a section
   this skill would normally add (the plan-doc convention, the pipeline skill list), offer to
   append just that section, and show the diff before writing it.
2. Detect the ground:
   - Code already present → seed `CLAUDE.md` from what's actually there: the CMS version(s)
     targeted (check `Directory.Packages.props` / `.csproj` for an `Umbraco.Cms.Core` package
     reference), the solution/project layout, whether a `Client/` frontend folder exists, the
     test project(s) and their framework. Be factual, no guessing — if something can't be
     detected, leave it `TODO` rather than assuming.
   - Empty dir → `CLAUDE.md` gets a stub with the headings below and `TODO`s.

## Interview

Almost none. Ask at most:

1. Project name, if not given and not obvious from the folder/`.sln`/`.csproj`.
2. The plan-doc path convention (default `docs/plans/<feature-slug>-plan.md`; offer a
   monorepo/worktree-scoped alternative if the repo already uses worktrees or has more than
   one deployable product in it).
3. Only if genuinely ambiguous from the code: which Umbraco CMS major version(s) this targets,
   and whether it ships against SQL Server only or SQL Server + SQLite.

Otherwise stay silent and scaffold.

## Produce

**`CLAUDE.md`** (root, owned here — re-entrant, append missing sections rather than rewrite):

```md
# CLAUDE.md

[One-line project summary — ask if there isn't one already, or infer from an existing
README/package description.]

## Stack

- Umbraco CMS: [version(s) targeted — TODO if undetected]
- Database: [SQL Server only | SQL Server + SQLite — TODO if undetected]
- Frontend: [Lit + UUI, if a Client/ folder exists — otherwise omit this section]

## Build & test

```bash
dotnet build <solution>.sln
dotnet test <solution>.sln
```
[Fill in the real commands once detected; TODO otherwise. Add npm build/test lines only if
a frontend project exists.]

## Feature workflow

This project uses the Umbraco Claude Playbook. Feature plan docs live at:
`[the path convention settled on in the interview]`

Pipeline: `/umb-explore` → `/umb-design` → `/umb-plan` → `/umb-build-loop`.
Each owns a section of the feature's plan doc, not a whole file — see the playbook's README
for the section-ownership table.

## Conventions

[TODO — filled in as umb-explore/umb-design surface real decisions worth recording
here permanently, e.g. folder structure rules, naming conventions specific to this project.]
```

**`.gitignore`** — .NET + (if a frontend exists) Node hybrid. This is the shape real Umbraco
product repos actually use — the classic Visual Studio bracket-cased patterns, not a
hand-picked shortlist:

```gitignore
# .NET (Visual Studio default patterns — catches case variants like Bin/ and BIN/ too)
[Dd]ebug/
[Rr]elease/
[Bb]in/
[Oo]bj/
.vs/
*.user
*.suo

# NuGet — this is a package repo; don't accidentally commit pack output
*.nupkg
*.snupkg
packages/

# Node / frontend
node_modules/
dist/

# Editors
.idea/
.vscode/

# Secrets — never commit these
appsettings.Local.json
appsettings.Development.json
.env
.env.*

# Generated demo site, if this project uses one for manual testing (a demo-site-management-
# style skill pattern more than one real Umbraco product uses) — the whole tree is generated
# per-developer and never committed
demos/
```

Trim the frontend section if this repo doesn't have one. **Don't** add Umbraco runtime
folders like `App_Data/` or `umbraco/Logs/` by default — a package repo doesn't run Umbraco
directly, a generated demo site does (already covered by `demos/` above). Only add them if
this repo genuinely *is* a full Umbraco site, not a package.

**If this repo is a meta/aggregator repo** (a monorepo of pointers to separately-versioned
sub-projects — some real Umbraco products are structured this way), use an allowlist-style
`.gitignore` (`*` at the top, then `!path/to/each/real/thing`) instead of the denylist
template above.

**`README.md`** — one-line stub only, owned by a future `umbraco-document`-equivalent once
one exists; don't write a full README here, that's not this skill's job. Just:

```md
# [Project name]

[One-line description — TODO]
```

**`docs/plans/`** (or the agreed path) — create the empty folder with a `.gitkeep` if the
convention is a fresh folder, so the path exists before the first feature needs it.

## Hand off

End with the file list (created vs. skipped vs. appended-to), the plan-doc path convention
settled on, then:
`Suggested next: umb-explore — to define the first feature.`
