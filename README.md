# Umbraco Claude Playbook

A Claude Code plugin for building Umbraco packages and backoffice extensions: C# / .NET backend, EF Core
persistence, Lit + UUI frontend for the backoffice. It gives you a five-step feature pipeline
(`umb-init` → `umb-explore` → `umb-design` → `umb-plan` → `umb-build-loop`), a builder/reviewer
gate that reviews and tests every change before it's committed, and a set of skills teaching
the C#, EF Core, and Lit + UUI idioms Umbraco itself uses.

**This is a foundation, not a finished house.** Drop it into a new package or a fresh add-on,
and build on top of it for whatever that project needs next — see
[Building on top](#building-on-top) below.

## Install

From inside the Umbraco project you want to use this in:

```bash
# 1. This playbook.
claude plugin marketplace add https://github.com/mattbrailsford/umbraco-claude-playbook --scope project
claude plugin install umbraco-claude-playbook@umbraco-claude-playbook --scope project

# 2. The official backoffice extension-point skills (58 skills, Lit/UUI-specific).
claude plugin marketplace add https://github.com/umbraco/Umbraco-CMS-Backoffice-Skills.git#main --scope project
claude plugin install umbraco-cms-backoffice-skills@umbraco-backoffice-marketplace --scope project
```

(Or, from inside Claude Code: `/plugin marketplace add ...` / `/plugin install ...` with the
same arguments.)

Then, optionally, copy [`settings.example.json`](./settings.example.json) → your project's
`.claude/settings.json` (or merge it in) and uncomment the hooks you want — this isn't part of
the installed plugin, since permissions and hooks are a per-project trust decision a plugin
shouldn't make for you.

## Quickstart

```
/umb-init          # once per project — scaffolds the solution (if new) via a real dotnet
                   # template, then CLAUDE.md, .gitignore, README stub
/umb-explore       # talk through what you're building
/umb-design        # decide which extension points, data model, API surface
/umb-plan          # slice into tasks + generate pending specs
/umb-build-loop    # build, review, commit — task by task
```

Or just describe what you want ("I want to add a dashboard that...") — these skills
auto-surface when the description matches, you don't have to invoke them by name. Full
walkthrough: [QUICKSTART.md](./QUICKSTART.md).

Everything writes into one file per feature: `docs/plans/<feature-slug>-plan.md`. Re-run any
phase any time to refine its section; nothing gets clobbered. See
[How it works](#how-it-works) for the section-ownership rules.

## What's included

**Pipeline** — the five skills above, plus a `builder`/`reviewer` subagent pair
`umb-build-loop` dispatches per task. The reviewer is read-only by design (no `Edit`/`Write`
tools): it runs the build and test suite, checks the diff against documented patterns,
traces impact on any public API change, and traces the change to its real entry point before
returning `PASS` or `FAIL`.

**Stack knowledge:**
- `dotnet-best-practices` — nullable reference types, type modeling, async/LINQ/disposal
  discipline — general C#, not Umbraco-specific
- `umbraco-extensibility` — Composers, collection builders, notification handlers,
  attribute-based discovery, async naming, `[Obsolete]`-proxied public API changes
- `typescript-best-practices` — discriminated unions, `{ data, error }` error handling, null
  hygiene, the `toString()`/`toJSON()` rule
- `lit-uui-conventions` — package-level frontend structure the official Backoffice Skills
  plugin doesn't cover: barrel-export entry points, OpenAPI client generation, workspace
  context
- `ef-core-data` — dual SQL Server/SQLite support, product-prefixed migrations, repositories
  internal to their owning service
- `security-dotnet` — Management API authz, EF Core injection, secrets handling, XSS in Lit
  templates
- `solid-principles`, `design-principles`, `gof-patterns` — C# examples throughout

**Process:**
- `bdd-specs-dotnet` — xUnit + Shouldly + Moq, Feature/Scenario/Specification shape
- `user-stories` — Given/When/Then acceptance criteria feeding straight into specs
- `git-workflow` — Conventional Commits, branch-per-CMS-major-version, an
  always-ask-before-touching-main rule for AI agents
- `git-remote` — bootstraps a new GitHub remote: real README, LICENSE, one CONTRIBUTING.md
- `umbraco-marketplace` — gets a finished package listed: the required NuGet tag and Umbraco
  dependency reference, the v14+ compatibility gotcha, the optional `umbraco-marketplace.json`

## How it works

### One plan doc per feature

Each pipeline skill owns a section of one file, by default at
`docs/plans/<feature-slug>-plan.md` (point it at a worktree-relative or monorepo-scoped path
instead if your project needs that — say so once in `CLAUDE.md` and every phase follows it):

| Section | Owned by |
|---|---|
| `## Problem`, `## Non-goals` | `umb-explore` |
| `## Design` | `umb-design` |
| `## Stories & Tasks` | `umb-plan` |
| `## Decision Log` | every phase appends |
| `## Build Log` | `umb-build-loop` |

Rules: **re-entrant** (re-run a phase to refine, never restart), **stop, don't guess** (a
phase missing its input sends you back to the owning phase), **one owner per section**.

### Project memory

Not every decision belongs in the per-feature plan doc or in the root `CLAUDE.md` forever.
`umb-init` scaffolds `.claude/memory/` alongside `CLAUDE.md` for exactly the facts that don't
fit either: standing project-wide decisions (`decision`), corrections learned from a
`reviewer` `FAIL` so the next `builder` dispatch doesn't repeat them (`gotcha`), and pointers
to external systems (`reference`). A convention scoped to one directory still belongs in a
nested `CLAUDE.md` there instead — `reviewer` already reads the nearest one on every task. See
`.claude/memory/README.md` (created by `umb-init`) for the format.

### Docs vs. worktrees

These solve different problems. Worktrees isolate the *filesystem* — two features get two
full checkouts, no risk of one session's edits colliding with another's. The per-feature plan
doc isolates the *decision record* — what was decided, why, what's left. Because the doc's
path is scoped to the feature, the two never collide, with or without worktrees.

## Building on top

The gap between this playbook and a mature product's toolkit is real, and it's meant to be
filled by your project, not guessed at in advance. Once a project's needs grow past what's
here, it typically needs:

- **A real release pipeline** — calendar or semver release branches, changelog generation,
  multi-product manifests — once you have a real release cadence. `git-workflow` here stops
  at "commit and branch well."
- **A worktree-per-feature layer** — merge/cleanup skills and `WorktreeCreate`/
  `WorktreeRemove` hooks, once parallel feature development earns its keep.
- **Project-specific scaffolding and environment automation** — every non-trivial project
  ends up with a few of these.

Don't reach for these on day one; add them when the need actually shows up.

## Repository layout

This repo is both a Claude Code marketplace and the one plugin it lists, the same shape the
official Umbraco Backoffice Skills repo uses:

```
umbraco-claude-playbook/
├── .claude-plugin/
│   └── marketplace.json              # lists the plugin below
├── plugins/umbraco-claude-playbook/
│   ├── .claude-plugin/
│   │   └── plugin.json               # the plugin's own manifest
│   ├── skills/                       # all 19 skills, one folder each
│   └── agents/                       # builder.md, reviewer.md
├── settings.example.json             # optional, copy-paste, not auto-installed
├── README.md
└── QUICKSTART.md
```

## Contributing

Issues and PRs welcome. [`git-remote`](plugins/umbraco-claude-playbook/skills/git-remote/SKILL.md)
and [`git-workflow`](plugins/umbraco-claude-playbook/skills/git-workflow/SKILL.md) describe
the commit/branch conventions this repo itself follows.

## License

[MIT](./LICENSE)

## Credits

Based on [Rob Conery's `claude-playbook`](https://github.com/robconery) starter template,
adapted for Umbraco package and backoffice extension development.
