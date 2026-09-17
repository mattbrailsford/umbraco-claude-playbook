---
name: umb-init
description: >-
  Scaffolds the working files a fresh Umbraco package or project needs before the pipeline
  skills can run — CLAUDE.md, .gitignore, a README stub, .claude/memory/, and the plan-doc
  path convention. For a brand-new package with no solution yet, offers to generate the
  solution itself from a real dotnet new template rather than hand-rolling one. Use when
  starting a brand-new Umbraco package/add-on/site repo and nothing has been written down yet,
  or when an existing repo is missing CLAUDE.md and wants one.
user-invocable: true
argument-hint: [project name, optional]
---

# umb-init

Stand up the working files so `umb-explore` and the rest of the pipeline have somewhere
to write. For the Claude-Code-specific layer, you **create structure, not content** — stubs
with headings and decisions to make, never invented decisions. For the solution itself, on a
brand-new package, you don't improvise scaffolding by hand — you defer to a real `dotnet new`
template, the same way you'd defer to a formatter instead of hand-fixing whitespace.

## Scope

- IN: for a brand-new package with no solution yet, offering to scaffold the solution itself
  from a real `dotnet new` template (see "Scaffolding a brand-new package" below) — **not**
  hand-rolling a solution/test-site/editorconfig yourself. Once there's a solution (whether
  the template just made one, or one already existed): create/update `CLAUDE.md`,
  `.gitignore`, a `README.md` stub, `.claude/memory/`, and the empty `docs/plans/` folder (or
  whatever path convention the interview settles on).
- OUT: deciding what the project *is* (that's `umb-explore`), architecture
  (`umb-design`), tasks (`umb-plan`). This command does not interview the problem —
  if you're asked "what should this do," stop and point at `umb-explore`. Also out: writing
  solution/project scaffolding by hand — a deterministic template does that job better and
  more consistently than an agent improvising files one at a time.

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
   - Empty dir, and this is a distributable package/add-on (not a single site) → **don't stub
     a solution by hand.** Go to "Scaffolding a brand-new package" below first, then come back
     and seed `CLAUDE.md` from what the template generated, the same way as the
     code-already-present branch above.
   - Empty dir, and this genuinely isn't a package (a full Umbraco site, or the template
     doesn't fit — see below) → `CLAUDE.md` gets a stub with the headings below and `TODO`s,
     as before.

## Scaffolding a brand-new package

Before writing anything else, if there's no `.sln`/project yet and this is a distributable
package: offer `opinionated-package-starter` (Lotte Pitcher's `dotnet new` template) instead of
building the solution by hand. It generates the solution, the package project, a SQLite test
site that references the package locally, `Directory.Packages.props`, an `.editorconfig`, a
tag-triggered NuGet release workflow, and doc templates — all the things this skill used to
have to reconstruct by hand, done consistently by an actual tool instead of improvised per
project.

1. **Confirm the CMS major this template currently targets is right for this project.** As of
   this writing it targets the current Umbraco LTS (17) — that will drift as new LTS versions
   ship, so check the template's own docs rather than trusting this number blindly. If the
   project needs an older major this template doesn't cover, say so and fall back to the
   official `Umbraco.Templates` package (`dotnet new umbraco-package` / `umbraco-extension`)
   for the base project, then hand-scaffold just the pieces that template doesn't include
   (`.editorconfig`, a test site, `Directory.Packages.props`) — don't silently force a CMS
   version the project didn't ask for.
2. **Confirm before running** — this creates a whole solution structure, so show the exact
   commands and get a yes first, the same discipline `git-remote` uses before creating a
   remote:
   ```bash
   dotnet new install Umbraco.Community.Templates.PackageStarter
   dotnet new umbracopackagestarter -n <PackageName> -an "<Author>" -gu "<GitHubUsername>" -gr "<GitHubRepoName>"
   ```
   Sourced from the template's own README as of this writing — a package id, short name, or
   parameter can change upstream; if `dotnet new install` fails or the short name isn't found,
   check https://github.com/LottePitcher/opinionated-package-starter directly rather than
   retrying the command as-is.
3. Run it, then continue below — seed `CLAUDE.md` from what it just generated (same as the
   "code already present" branch), rather than writing a blank stub.

## Interview

Almost none. Ask at most:

1. Project name, if not given and not obvious from the folder/`.sln`/`.csproj`.
2. If this is a brand-new package with no solution yet: use the `opinionated-package-starter`
   template (default yes, if its targeted CMS major fits), and its `-an`/`-gu`/`-gr`
   parameters.
3. The plan-doc path convention (default `docs/plans/<feature-slug>-plan.md`; offer a
   monorepo/worktree-scoped alternative if the repo already uses worktrees or has more than
   one deployable product in it).
4. Only if genuinely ambiguous from the code: which Umbraco CMS major version(s) this targets,
   and whether it ships against SQL Server only or SQL Server + SQLite.

Otherwise stay silent and scaffold.

## Produce

If the `opinionated-package-starter` template just ran, it already produced its own
`.gitignore`, `README.md`, and test site — the re-entrant rule in Preflight means the
templates below won't touch those; they exist for the case where no template was used
(an existing repo, a full site rather than a package, or the template declined/didn't fit).

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

## Project memory

Two places a decision lives, by scope:
- **Scoped to one directory/module** → a nested `CLAUDE.md` in that directory. Claude reads
  the nearest one walking up from whatever it's editing (`reviewer` does this on every task).
- **Project-wide, but not worth permanently bloating this file** → `.claude/memory/` — one
  file per entry, indexed in `.claude/memory/MEMORY.md`. See `.claude/memory/README.md` for
  the format.
```

**`.claude/memory/README.md`** (format spec, create once, re-entrant):

```md
# Project memory

Durable, project-wide facts that don't belong to one directory and would bloat the root
`CLAUDE.md` if written there permanently.

**Use a nested `CLAUDE.md` instead when the fact is scoped to one directory or module** — a
rule only true inside `src/Migrations/`, say. Claude reads the nearest `CLAUDE.md` walking up
from whatever it's editing; a file in here doesn't get picked up that way, so directory-scoped
facts belong there, not here.

## Types

- `decision` — a standing, project-wide call (CMS major version(s) targeted, database
  provider(s) supported, deploy target, an architectural decision from `umb-design` that
  outlives the feature it came from). Written by `umb-explore`/`umb-design` when a decision
  isn't scoped to just the feature being worked on.
- `gotcha` — a correction learned the hard way, usually from a `reviewer` FAIL that revealed a
  rule the `builder` should already have followed. Written by `umb-build-loop` so the next
  task doesn't repeat the same mistake.
- `reference` — a pointer to an external system relevant to this project (issue tracker,
  staging environment, a design doc).

## Format

One file per memory, kebab-case name, plus a one-line entry in `MEMORY.md` (the index):

```md
---
name: kebab-slug
description: one-line, specific enough to judge relevance later
type: decision | gotcha | reference
---

The fact or rule, then:

**Why:** the reasoning or incident that produced it.
**How to apply:** when this should change what an agent does.
```

Don't duplicate what's already in a skill, a stack-convention skill, or a directory's own
`CLAUDE.md` — this folder is for facts specific to *this* project that would otherwise get
re-decided or re-broken every few features.
```

**`.claude/memory/MEMORY.md`** (index, create once, re-entrant):

```md
# Memory index

One line per file in this folder, newest relevant first. See `README.md` for the format.
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
