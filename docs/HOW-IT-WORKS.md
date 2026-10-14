# How it works

The ideas behind the playbook, for when you want more than the
[README](../README.md) and [QUICKSTART](../QUICKSTART.md) give you.

## Three flows

Work gets built in one of three flows:

- **The pipeline**, `umb-explore` → `umb-design` → `umb-plan` → `umb-build-loop`, for a
  feature or any fix too big to do in one go.
- **`quick-fix`**, for a small fix of one concern. It hands over to the pipeline if the fix
  turns out bigger.
- **`major-upgrade`**, for moving to a new Umbraco major.

These helpers come before a flow, never instead of one. None of them writes code:

- `investigate-bug` proves a bug's cause, then says which flow should fix it.
- `issue-triage` reads tracker issues and recommends what to act on.
- `issue-backlog` works the open issues through triage, decisions, and investigation, then
  starts fixes one issue at a time through `issue-resolve`.
- `issue-resolve` sends one triaged issue to `quick-fix` or the pipeline.

You don't have to pick. Describe what you want and Claude picks the skill from its
description.

## One plan folder per feature

Each pipeline step owns one file in a per-feature folder, by default
`docs/plans/<feature-slug>/`. To use a different path (worktree-relative, or scoped to a
monorepo package), say so once in your project's `CLAUDE.md` and every step follows it.

| File | Owned by |
|---|---|
| `README.md` | `umb-explore` creates it; every step updates its own line |
| `BRIEF.md` | `umb-explore` |
| `ARCHITECTURE.md`, `SPEC.md`, `mockups/` | `umb-design` |
| `STORIES.md`, `PLAN.md` | `umb-plan` (`umb-build-loop` only ticks `PLAN.md`'s task checkboxes) |
| `DECISION-LOG.md` | every step appends |
| `BUILD-LOG.md`, `screenshots/` | `umb-build-loop` |
| `PR-DESCRIPTION.md` | `describe-pr` |

Three rules make this work:

- **Re-entrant.** Re-run a step to refine its file. It never starts over.
- **One owner per file.** Two steps, or two sessions, never edit the same file, so there's
  nothing to merge-conflict over.
- **Stop, don't guess.** A step missing its input sends you back to the step that owns it.

Outside the feature folders, `umb-design` also owns `docs/mockups/starters/`: mockup
starters for a product's own screens (a Copilot sidebar, a flow editor) that the general
starters can't draw. One is saved only when a screen is both distinct and something features
keep landing on.

## The builder/reviewer gate

`umb-build-loop` hands each task in `PLAN.md` to a `builder` agent, then a `reviewer` agent
checks the change. The reviewer has no edit tools on purpose: it can only read, run the build
and tests, and return `PASS` or `FAIL`. A reviewer that could patch its own findings would
stop being a gate. Once every task is built, one more review covers the whole branch, to
catch problems that build up across tasks.

`quick-fix` uses the same reviewer for small fixes. `major-upgrade` uses the whole gate for
a move to a new Umbraco major: it lists the breaking changes that hit the project in
`docs/upgrades/v<major>.md`, then builds that list task by task, green at every commit.

## Project memory

Some facts don't belong in a feature's plan folder or in `CLAUDE.md` forever. `umb-init`
sets up `.claude/memory/` for those:

- **`decision`**: a standing project-wide decision.
- **`gotcha`**: a lesson from a reviewer `FAIL`, so the next build doesn't repeat it.
- **`reference`**: a pointer to an outside system.

A convention for one folder still goes in a `CLAUDE.md` in that folder. The reviewer reads
the nearest one on every task. `.claude/memory/README.md`, created by `umb-init`, explains the
format.

## Plan folders, branches, and worktrees

These solve different problems. A worktree keeps two features' *files* apart. A plan folder
keeps a feature's *decisions* together. Because each plan folder has its own path, they never
collide, with or without worktrees.

`umb-explore`, `umb-design`, and `umb-plan` never touch git. A feature you explore and then
drop costs nothing. `umb-build-loop` is where git comes in: on the first build, it asks
before committing the plan folder to your trunk branch, then cuts a branch or worktree named
after the feature. The plan ends up in the feature branch's history because it was committed
just before the branch was cut. `git-workflow`'s "Branch/worktree per feature" section has
the full reasoning.

## Building on top

The playbook stops where most projects start to differ. As a project grows, it usually
needs:

- **A release pipeline.** Release branches, changelogs, multi-product manifests. Each
  project's release steps live in that project, not here.
- **Branch cleanup automation.** `umb-build-loop` already cuts a branch per feature. A project
  can add its own `WorktreeCreate`/`WorktreeRemove` hooks for naming, copying local files,
  and cleaning up after merge.
- **Project-specific scaffolding.** Every non-trivial project ends up with a few of these.

Add them when the need shows up, not on day one.

## This repo's layout

The repo is both a Claude Code marketplace and the one plugin it lists:

```
umbraco-claude-playbook/
├── .claude-plugin/marketplace.json       # lists the plugin below
├── plugins/umbraco-claude-playbook/
│   ├── .claude-plugin/plugin.json        # the plugin's own manifest
│   ├── skills/                           # one folder per skill
│   └── agents/                           # builder, reviewer, issue-triager
├── settings.example.json                 # optional, copy by hand, not installed
├── scripts/                              # repo checks, not shipped
└── docs/                                 # this file, PR example images
```
