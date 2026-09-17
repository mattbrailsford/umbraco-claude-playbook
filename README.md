# Umbraco Claude Playbook

A `.claude/` starting point for solid Umbraco development: C# / .NET backend, EF Core
persistence, Lit + UUI frontend for the backoffice. Adapted from
[Rob Conery's `claude-playbook`](https://github.com/robconery) starter template, with the
parts that assumed a small solo web app replaced by patterns that hold up on a real,
multi-year, multi-version Umbraco product.

**This is a foundation, not a finished house.** It's meant to be shareable with the wider
Umbraco community as-is — drop it into a new package, a client site, a fresh add-on — and
then built on top of for whatever that specific project needs next. `Umbraco.AI` is both
where this was validated and a live example of "built on top of it": its own
`release-management`, `changelog-management`, `post-release-cleanup`, and worktree-workflow
skills are *not* part of this playbook. They're monorepo-specific, multi-version-specific
tooling that Umbraco.AI layered on once its needs outgrew the generic base. Your project
will likely grow its own equivalents; this just gives you somewhere solid to grow them from.

## What changed from the original, and why

The original template targets one small app, one repo, one developer, greenfield. Four
deliberate departures, generalized from what actually works on a real Umbraco codebase —
not Umbraco.AI's specific internals, but the shape of good practice it demonstrates:

| Original | Here | Why |
|---|---|---|
| Slash commands for the phase pipeline (`/explore`, `/design`, `/plan`, `/build-loop`) | **Skills** (`umb-explore`, `umb-design`, `umb-plan`, `umb-build-loop`) | Umbraco.AI's own toolkit runs entirely on skills, including pipeline-shaped ones (`release-management` orchestrates a multi-step process the same way `/build-loop` does). Skills auto-surface by description *and* can be called by name, so nothing is lost by not also having commands — just one mechanism to learn instead of two. |
| One project = one repo = one set of root `docs/*.md` files (`PROJECT.md`, `ARCHITECTURE.md`, `SPEC.md`, `STORIES.md`, `PLAN.md`, `MEMORY.md`) | **One file per feature** (`docs/plans/<feature-slug>-plan.md`), with each phase owning a *section* instead of a whole file | Real Umbraco projects are rarely "one project" for long — packages spawn add-ons, sites grow features in parallel, and more than one person ends up working on more than one thing at once. A feature-scoped doc travels with a feature (and, if you use git worktrees, with its worktree) instead of contending for one shared root file. |
| TypeScript / Postgres / SQLite / Next.js skill set | **C# / EF Core / Lit + UUI** skill set, teaching the extension-point idioms Umbraco itself uses (Composers, collection builders, notification handlers, property editors) | The original's skills are real and good, just for a different stack. These teach the equivalent muscle memory for building *on* Umbraco rather than *with* a generic web framework. |
| No frontend extension-point knowledge shipped (you write your own) | **Defers to the official [Umbraco Backoffice Skills](https://docs.umbraco.com/umbraco-in-ai/agent-skills/backoffice-skills) plugin** (58 skills covering dashboards, trees, property editors, modals) | Umbraco already publishes and maintains this. This playbook's own `lit-uui-conventions` skill only covers what that plugin doesn't: package-level frontend structure (barrel-export entry points, OpenAPI client generation from your Management API). |

## Install

```bash
# 1. The official backoffice extension-point skills (58 skills, Lit/UUI-specific).
claude plugin marketplace add https://github.com/umbraco/Umbraco-CMS-Backoffice-Skills.git#main --scope project
claude plugin install umbraco-cms-backoffice-skills@umbraco-backoffice-marketplace --scope project

# 2. This playbook.
cp -r umbraco-claude-playbook/.claude /path/to/your/umbraco-project/
```

Then, optionally, copy `.claude/settings.example.json` → your project's `.claude/settings.json`
(or merge it in) and uncomment the hooks you want.

## The pipeline

```
umb-init ──▶ umb-explore ──▶ umb-design ──▶ umb-plan ──▶ umb-build-loop
(scaffold)    (problem)       (solution)     (tasks)      (code)
```

`umb-init` is a one-time, re-entrant setup step for a repo that doesn't have a
`CLAUDE.md` yet — it scaffolds `CLAUDE.md`, `.gitignore`, a `README.md` stub, and settles the
plan-doc path convention so every later phase agrees on where to write. It creates structure,
never decisions — run it once per project, not once per feature.

Each is a skill, invoked by name or auto-surfaced when you describe wanting to
start/plan/build a feature. None of them owns a whole file — they own **sections of one
file per feature**, by default at:

`docs/plans/<feature-slug>-plan.md`

(Working in a bigger repo where features live in isolated worktrees, like Umbraco.AI does?
Point this at a worktree-relative or monorepo-scoped path instead — e.g.
`docs/internal/agent/plans/<feature-slug>-plan.md`. The pipeline skills don't hardcode the
path; they just need to agree on one per project. Say so once in your project's `CLAUDE.md`
and every phase will follow it.)

| Section | Owned by |
|---|---|
| `## Problem`, `## Non-goals` | `umb-explore` |
| `## Design` (data model / migrations, Management API surface, frontend components, decisions + rejected alternatives) | `umb-design` |
| `## Stories & Tasks` | `umb-plan` |
| `## Decision Log` | every phase appends, nobody owns it exclusively |
| `## Build Log` | `umb-build-loop` |

Same rules as the original: **re-entrant** (re-run a phase to refine, never restart),
**stop, don't guess** (a phase missing its input sends you back to the owning phase), and
**one owner per section** so nothing gets silently overwritten.

## Docs vs. worktrees — how this handles two features at once

These solve two different problems, not the same one.

- **Worktrees** isolate the *filesystem* — two features get two full checkouts, two
  branches, no risk of one session's edits colliding with another's. (Umbraco.AI makes
  this mandatory for non-trivial work; smaller projects may not need it at all.)
- **The per-feature plan doc** isolates the *decision record* — what was decided, why, and
  what's left, for one feature.

Because the plan doc's path is scoped to the feature, two features never contend for the
same file, with or without worktrees. When a feature merges, its plan file merges with it
and becomes part of the repo's permanent record.

## The builder / reviewer gate

`umb-build-loop` dispatches two subagents per task:

- **`builder`** (sonnet) — implements one task from the plan's `## Stories & Tasks`
  section, runs the tests, reports back. Never commits unless told.
- **`reviewer`** (opus) — read-only. **Has no `Edit`/`Write` tools by design.** Runs the
  build and test suite itself, checks the diff against documented patterns before falling
  back to sibling-code comparison, traces impact on consumers for any public API change,
  traces the change to its real entry point (a Management API controller action, a
  Composer-registered service, a Lit component actually wired into a barrel export), and
  returns `PASS` or `FAIL` with findings tiered Critical/Important/Suggestion — only
  Critical/Important block a pass. A reviewer that can fix its own findings isn't a gate.

  The docs-first validation, sibling-comparison fallback, and consumer-impact-analysis
  techniques are adapted from `Umbraco.Cms`'s own `umb-review` skill — a mature, production
  PR-review gate wired into that repo's CI. Deliberately **not** carried over: its
  CMS-core-specific architecture-layer checks (Core/Infrastructure/Web/API dependency
  direction), its CI wiring, and its multi-file reference-doc system — a package repo
  doesn't have CMS-core's internal layering, and a `reviewer` subagent invoked from
  `umb-build-loop` doesn't need a separate non-interactive automation harness.

Full detail: `.claude/agents/builder.md`, `.claude/agents/reviewer.md`, and the orchestration
in `.claude/skills/umb-build-loop/SKILL.md`.

## Skills

### Pipeline (this playbook's core)
- `umb-init` — one-time scaffold: `CLAUDE.md`, `.gitignore`, README stub, plan-doc path
- `umb-explore` — problem-space interview → `## Problem` / `## Non-goals`
- `umb-design` — solution-space interview → `## Design`
- `umb-plan` — slice into tasks → `## Stories & Tasks`
- `umb-build-loop` — orchestrates builder → reviewer → commit, task by task

### Stack knowledge
- `dotnet-conventions` — building on Umbraco's own extensibility idioms: Composers,
  collection builders, notification handlers, attribute-based discovery, the
  `[Action][Entity]Async` naming habit, public-API back-compat via `[Obsolete]` proxying
- `typescript-best-practices` — strict TS discipline for the frontend: discriminated unions
  over optional-field soup, `Result`-shaped error handling, null hygiene, the
  `toString()`/`toJSON()` rule. Language discipline, not package structure — see
  `lit-uui-conventions` for that half
- `lit-uui-conventions` — package-level frontend structure the official Backoffice Skills
  plugin doesn't cover: barrel-export entry points, OpenAPI client generation from your
  Management API, workspace context patterns
- `ef-core-data` — shipping an EF Core-backed package inside Umbraco: dual SQL
  Server/SQLite support, product-prefixed migrations so they don't collide in Umbraco's
  shared database, keeping repositories internal to their owning service
- `security-dotnet` — ASP.NET Core / Management API authz, EF Core injection, secrets
  handling, XSS in Lit templates
- `solid-principles`, `design-principles`, `gof-patterns` — carried over from the original,
  examples retargeted to C#

### Process
- `bdd-specs-dotnet` — xUnit + Shouldly + Moq, Feature/Scenario/Specification shape over
  Arrange-Act-Assert, with builder/fake/fixture test-data conventions
- `user-stories` — carried over near-verbatim; writes into the feature's `## Stories &
  Tasks` section instead of a root `STORIES.md`
- `git-workflow` — Conventional Commits, trunk-vs-branch by change size, the versioning
  question every Umbraco package eventually hits (tracking CMS majors, supporting more than
  one at once), and a rule adapted from `Umbraco.Commerce`'s `CLAUDE.md`: an AI agent always
  asks before committing or merging to the default or a support branch, however trivial the
  change looks. Deliberately stops short of a release pipeline — see below.
- `git-remote` — bootstraps a new GitHub remote for a package: real README, LICENSE, one
  CONTRIBUTING.md. Deliberately lighter than a generic open-source checklist — no
  `SECURITY.md`, no second issue template, matching what real Umbraco product repos actually
  ship rather than a template's idea of "professional."

## Building on top

The gap between "this playbook" and "a mature product's toolkit" is real, and it's meant to
be filled by your project, not by this playbook guessing your needs in advance. Umbraco.AI's
own `.claude/skills/` is the reference for what that looks like once a project needs it:

- `release-management`, `release-manifest-management`, `changelog-management`,
  `post-release-cleanup` — a full release pipeline, once you have one product (let alone
  twenty) and a real release cadence. `git-workflow` here stops at "commit and branch well";
  it doesn't assume you need calendar-based release branches or multi-product manifests.
- `worktree-merge`, `worktree-cleanup`, the `WorktreeCreate`/`WorktreeRemove` hooks — the
  parallel-feature-development layer, once one worktree per feature earns its keep.
- `add-provider`, `demo-site-management`, `demo-site-automation` — project-specific scaffolding
  and environment automation. Every non-trivial project ends up with a few of these; they're
  what "built on top of" means in practice.

Don't copy these wholesale into a new project on day one — they exist because Umbraco.AI's
needs grew into them. Build your own version when your project's needs do the same.

## What this deliberately does not include

- A `you/` personal-context skill. Personal style belongs in a developer's own
  `~/.claude/CLAUDE.md` (outside any repo); project-specific working rules belong in the
  checked-in `CLAUDE.md` plus each developer's own `CLAUDE.local.md`. A shared, shareable
  playbook shouldn't own "who you are."
- `postgres-dba` / `sqlite-dev` as separate skills — merged into one `ef-core-data` skill,
  since Umbraco packages routinely need to support both SQL Server and SQLite from the same
  EF Core model, which the original's single-database-per-project split doesn't anticipate.
- Any Lit/UUI extension-point reference material the official Backoffice Skills plugin
  already owns — see the install step above.
- Any release/versioning pipeline — see "Building on top."

## Open follow-ups (flagged, not decided here)

- `bdd-specs-dotnet` assumes tests are written **before** implementation, matching the
  original's TDD stance. Confirm that's the stance you want before `umb-build-loop` sees
  real use — some teams will prefer tests-alongside-implementation with the same rigor
  applied after, and the skill should say which up front rather than let it drift per-task.
- No `umbraco-quick-fix` or `umbraco-document` equivalent has been built yet (the original's
  `/quick-fix` and `/document`). Add them the same way if their absence turns out to be felt
  in practice.
- No `git-merge` equivalent (a full, careful "merge this branch into main safely" flow with
  dirty-tree/diverged-remote checks and a confirmed strategy). Real Umbraco repos checked
  (`Umbraco.Cms`, `Umbraco.Commerce`, `Umbraco.Automate`) don't merge straight to main by
  hand at all — code lands via PR merge (CMS/Automate) or via `release`/`hotfix` branches in
  a GitFlow-style model (Commerce). `git-workflow`'s new "always ask before touching main"
  rule covers the actual risk; a dedicated merge-orchestration skill would be solving a
  problem none of the three real repos checked actually have. `git-remote` was built — see
  above.
- No `agent-teams` equivalent (the original's skill for running several parallel Claude Code
  sessions on independent workstreams). `umb-build-loop` is a sequential pipeline, not
  that — worth adding if a project's tasks are independent enough to parallelize.
- `bdd-specs-dotnet` and `user-stories` aren't `user-invocable` — they only run when
  `umb-plan` delegates to them, unlike the original's standalone `/spec`. Add the
  frontmatter if you want to re-run either on its own.
