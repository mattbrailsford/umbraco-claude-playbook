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
/umb-decision-review  # digest what the build decided on its own, before the PR opens
```

Or just describe what you want ("I want to add a dashboard that...") — these skills
auto-surface when the description matches, you don't have to invoke them by name. Full
walkthrough: [QUICKSTART.md](./QUICKSTART.md).

Everything writes into one folder per feature: `docs/plans/<feature-slug>/`. Re-run any
phase any time to refine its file; nothing gets clobbered. See
[How it works](#how-it-works) for the file-ownership rules.

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
  attribute-based discovery
- `umbraco-package-conventions` — async naming, repository visibility,
  `[Obsolete]`-proxied public API changes
- `typescript-best-practices` — discriminated unions, `{ data, error }` error handling, null
  hygiene, the `toString()`/`toJSON()` rule — general TypeScript, not Umbraco-specific
- `umbraco-backoffice-conventions` — package-level frontend structure the official Backoffice
  Skills plugin doesn't cover: required compiler setup, barrel-export entry points, OpenAPI
  client generation, observable-subscription lifecycle, monorepo build order
- `ef-core-data` — dual SQL Server/SQLite support, product-prefixed migrations, repositories
  internal to their owning service
- `security-dotnet` — Management API authz, EF Core injection, secrets handling
- `security-lit` — XSS in Lit templates, secrets in a client bundle, browser storage, npm
  supply chain
- `solid-principles`, `design-principles` — both C# and Lit/TypeScript examples throughout
- `gof-patterns` — all 23 patterns in C#, plus Lit/TypeScript examples for the ones that
  come up often in backoffice component work (State, Strategy, Command, Composite)

**Process:**
- `bdd-specs` — Feature/Scenario/Specification shape for both backend (xUnit + Shouldly + Moq)
  and frontend (Web Test Runner + `@open-wc/testing`)
- `user-stories` — Given/When/Then acceptance criteria feeding straight into specs
- `git-workflow` — Conventional Commits, branch-per-CMS-major-version, an
  always-ask-before-touching-main rule for AI agents
- `umb-decision-review` — once `umb-build-loop` finishes, digests `DECISION-LOG.md`,
  `BUILD-LOG.md`, and the feature diff into a short list of assumptions, spec deviations, and
  workarounds worth the user's attention before the PR opens. Read-only, never gates or fixes
  anything.
- `describe-pr` — `git-workflow` always delegates the PR description to this skill; it writes a
  diagram-based outline (file trees, before/after diffs, call chains, table/manifest diffs) for
  a feature-sized change, or a plain summary otherwise
- `git-remote` — bootstraps a new GitHub remote: real README, LICENSE, one CONTRIBUTING.md
- `umbraco-marketplace` — gets a finished package listed: the required NuGet tag and Umbraco
  dependency reference, the v14+ compatibility gotcha, the optional `umbraco-marketplace.json`
- `quick-fix` — the escape hatch around the five-step pipeline for a fix too small to justify
  it (a typo, a dead try/catch); escalates to `umb-plan`/`umb-explore` the moment it isn't
- `issue-triage` — classifies, duplicate-checks, and security-flags issues from a tracker that
  may live outside the source repo; one issue runs inline, a range or the whole backlog fans
  out to one `issue-triager` subagent each. Report only — never labels, comments, or closes
  anything itself.
- `issue-resolve` — takes one triaged issue and routes it into `quick-fix` or the full pipeline
  depending on size, then drafts (never posts) the tracker resolution once the fix lands.

## How it works

### One plan folder per feature

Each pipeline phase owns one file in a per-feature folder, by default at
`docs/plans/<feature-slug>/` (point it at a worktree-relative or monorepo-scoped path instead
if your project needs that — say so once in `CLAUDE.md` and every phase follows it):

| File | Owned by |
|---|---|
| `BRIEF.md` | `umb-explore` |
| `ARCHITECTURE.md`, `SPEC.md` | `umb-design` |
| `STORIES.md`, `PLAN.md` | `umb-plan` |
| `DECISION-LOG.md` | every phase appends |
| `BUILD-LOG.md` | `umb-build-loop` |
| `PR-DESCRIPTION.md` | `describe-pr` (only when the plan folder exists — otherwise the description goes straight into the PR, not to disk) |

One file per owner, not one section per owner in a shared doc — two phases (or two sessions)
never touch the same file, so there's nothing to merge-conflict over. Rules: **re-entrant**
(re-run a phase to refine its file, never restart), **stop, don't guess** (a phase missing its
input sends you back to the owning phase), **one owner per file**.

### Project memory

Not every decision belongs in a per-feature plan file or in the root `CLAUDE.md` forever.
`umb-init` scaffolds `.claude/memory/` alongside `CLAUDE.md` for exactly the facts that don't
fit either: standing project-wide decisions (`decision`), corrections learned from a
`reviewer` `FAIL` so the next `builder` dispatch doesn't repeat them (`gotcha`), and pointers
to external systems (`reference`). A convention scoped to one directory still belongs in a
nested `CLAUDE.md` there instead — `reviewer` already reads the nearest one on every task. See
`.claude/memory/README.md` (created by `umb-init`) for the format.

### Docs vs. worktrees

These solve different problems. Worktrees isolate the *filesystem* — two features get two
full checkouts, no risk of one session's edits colliding with another's. The per-feature plan
folder isolates the *decision record* — what was decided, why, what's left. Because the
folder's path is scoped to the feature, the two never collide, with or without worktrees.

They're also linked at one specific moment, not throughout. `umb-explore`/`umb-design`/
`umb-plan` never touch git — the plan folder is just files on disk, so a feature explored then
dropped never cost a branch. `umb-build-loop` is what connects the two: at the start of the
first build, it commits the plan folder to trunk, then cuts a branch or worktree named after
the plan folder (using Claude Code's native `WorktreeCreate` hook if the project has one
configured, otherwise a plain branch). The docs end up in the feature branch's history because
they were committed just before it was cut, not because of any special copying step. See
`git-workflow`'s "Branch/worktree per feature" section for the full reasoning.

## Building on top

The gap between this playbook and a mature product's toolkit is real, and it's meant to be
filled by your project, not guessed at in advance. Once a project's needs grow past what's
here, it typically needs:

- **A real release pipeline** — calendar or semver release branches, changelog generation,
  multi-product manifests — once you have a real release cadence. `git-workflow` here stops
  at "commit and branch well."
- **Merge/cleanup automation on top of branch-per-feature** — `umb-build-loop` already cuts a
  branch/worktree per feature (see "Docs vs. worktrees" above); a project can add its own
  `WorktreeCreate`/`WorktreeRemove` hooks for custom naming, local-file copying, and
  post-merge cleanup once parallel feature development earns that investment.
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
│   ├── skills/                       # all 26 skills, one folder each
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
