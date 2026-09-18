---
name: umb-init
description: >-
  Scaffolds the working files a fresh Umbraco package or project needs before the pipeline
  skills can run — CLAUDE.md, .gitignore, a README stub, .claude/memory/, and the plan-folder
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
   this skill would normally add (the plan-folder convention, the pipeline skill list), offer to
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
   - Regardless of the branch above: detect the trunk branch (`git symbolic-ref
     refs/remotes/origin/HEAD`, falling back to whichever of `main`/`master` exists) and check
     `.claude/settings.json` (project and user level) for an already-configured
     `WorktreeCreate` hook. Both facts go into `CLAUDE.md`'s Feature workflow section — don't
     ask for either unless detection is genuinely ambiguous (e.g. both a default branch and a
     separate long-lived `vN/dev` line exist and it's unclear which one new features should
     branch from).

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
3. The plan-folder path convention (default `docs/plans/<feature-slug>/`, holding `BRIEF.md`,
   `ARCHITECTURE.md`, `SPEC.md`, `STORIES.md`, `PLAN.md`, `DECISION-LOG.md`, `BUILD-LOG.md` —
   one file per pipeline phase; offer a monorepo/worktree-scoped alternative if the repo
   already uses worktrees or has more than one deployable product in it).
4. Only if trunk-branch detection above was ambiguous: which branch new features should start
   from and be cut against (see `git-workflow`'s "Branch/worktree per feature" section — this
   is where `umb-build-loop` commits the plan folder and cuts the feature branch/worktree).
5. Only if genuinely ambiguous from the code: which Umbraco CMS major version(s) this targets,
   and whether it ships against SQL Server only or SQL Server + SQLite.

Otherwise stay silent and scaffold.

## Produce

If the `opinionated-package-starter` template just ran, it already produced its own
`.gitignore`, `README.md`, and test site — the re-entrant rule in Preflight means the
templates below won't touch those; they exist for the case where no template was used
(an existing repo, a full site rather than a package, or the template declined/didn't fit).

Copy each template below and fill in its bracketed placeholders from what was detected or
asked in the interview — don't hand-write these from scratch, and don't copy a placeholder
through unfilled:

- **`templates/CLAUDE.md`** → repo root (owned here — re-entrant, append missing sections
  rather than rewrite an existing one).
- **`templates/memory-readme.md`** → `.claude/memory/README.md` (format spec, create once,
  re-entrant).
- **`templates/memory-index.md`** → `.claude/memory/MEMORY.md` (index, create once,
  re-entrant).
- **`templates/project.gitignore`** → `.gitignore`. .NET + (if a frontend exists) Node
  hybrid — the shape real Umbraco product repos actually use, not a hand-picked shortlist.
  Trim the frontend section if this repo doesn't have one. **Don't** add Umbraco runtime
  folders like `App_Data/` or `umbraco/Logs/` by default — a package repo doesn't run Umbraco
  directly, a generated demo site does (already covered by `demos/` in the template). Only add
  them if this repo genuinely *is* a full Umbraco site, not a package. **If this repo is a
  meta/aggregator repo** (a monorepo of pointers to separately-versioned sub-projects), use an
  allowlist-style `.gitignore` (`*` at the top, then `!path/to/each/real/thing`) instead of
  this denylist template.
- **`templates/README.md`** → repo root `README.md` — one-line stub only, owned by a future
  `umbraco-document`-equivalent once one exists; don't write a full README here, that's not
  this skill's job.

**`docs/plans/`** (or the agreed path) — create the empty folder with a `.gitkeep` if the
convention is a fresh folder, so the path exists before the first feature needs it. Don't
pre-create a per-feature subfolder or any of its seven files — `umb-explore` creates
`docs/plans/<feature-slug>/` and its own `BRIEF.md` when the first real feature starts.

## Hand off

End with the file list (created vs. skipped vs. appended-to), the plan-folder path convention
settled on, then:
`Suggested next: umb-explore — to define the first feature.`
