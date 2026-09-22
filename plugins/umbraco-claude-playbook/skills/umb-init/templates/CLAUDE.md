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

This project uses the Umbraco Claude Playbook. Feature plan folders live at:
`[the path convention settled on in the interview]`

Pipeline: `/umb-explore` → `/umb-design` → `/umb-plan` → `/umb-build-loop`.
Each phase owns its own file in the feature's plan folder (`BRIEF.md`, `ARCHITECTURE.md` +
`SPEC.md`, `STORIES.md` + `PLAN.md`, `BUILD-LOG.md`) — see the playbook's README for the
file-ownership table.

**Branch/worktree per feature:** new features start from `[trunk branch — the repo's default
branch, or a long-lived vN/dev line for a branch-per-major project]`. Plan-folder files stay
uncommitted through `umb-explore`/`umb-design`/`umb-plan`. `umb-build-loop` commits the plan
folder to trunk and cuts the feature's branch/worktree — named after the plan folder — the
moment building actually starts, not before (see `git-workflow`'s "Branch/worktree per
feature" section). [If a `WorktreeCreate` hook is configured for this project, name it here —
it decides the real branch name and location. Otherwise `umb-build-loop` falls back to a plain
`git checkout -b <feature-slug>` off trunk.]

**Finding the current feature's plan folder:** once a branch/worktree exists for a feature,
its name already carries the feature slug — strip a leading `vN/` and/or `<type>/` prefix (see
`git-workflow`'s branch-naming table) and check whether the plan-folder path above has a
matching `<remainder>/` folder. If it does, that's the current feature — no need to ask which
one. Only fall back to asking when nothing matches (still on trunk, or the branch/worktree name
doesn't correspond to any plan folder).

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
