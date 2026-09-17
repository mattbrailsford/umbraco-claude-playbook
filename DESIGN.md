# Design notes

## Where this came from

Adapted from [Rob Conery's `claude-playbook`](https://github.com/robconery) starter
template, which targets one small app, one repo, one developer, greenfield. Four deliberate
departures, generalized from what actually works on a real Umbraco codebase, not any single
product's private internals:

| Original | Here | Why |
|---|---|---|
| Slash commands for the phase pipeline (`/explore`, `/design`, `/plan`, `/build-loop`) | **Skills** (`umb-explore`, `umb-design`, `umb-plan`, `umb-build-loop`) | Skills auto-surface by description *and* can be called by name, so nothing is lost by not also having commands — just one mechanism to learn instead of two. |
| One project = one repo = one set of root `docs/*.md` files (`PROJECT.md`, `ARCHITECTURE.md`, `SPEC.md`, `STORIES.md`, `PLAN.md`, `MEMORY.md`) | **One file per feature** (`docs/plans/<feature-slug>-plan.md`), with each phase owning a *section* instead of a whole file | Real Umbraco projects are rarely "one project" for long — packages spawn add-ons, sites grow features in parallel, and more than one person ends up working on more than one thing at once. A feature-scoped doc travels with a feature (and, if you use git worktrees, with its worktree) instead of contending for one shared root file. |
| TypeScript / Postgres / SQLite / Next.js skill set | **C# / EF Core / Lit + UUI** skill set, teaching the extension-point idioms Umbraco itself uses (Composers, collection builders, notification handlers, property editors) | The original's skills are real and good, just for a different stack. These teach the equivalent muscle memory for building *on* Umbraco rather than *with* a generic web framework. |
| No frontend extension-point knowledge shipped (you write your own) | **Defers to the official [Umbraco Backoffice Skills](https://docs.umbraco.com/umbraco-in-ai/agent-skills/backoffice-skills) plugin** (58 skills covering dashboards, trees, property editors, modals) | Umbraco already publishes and maintains this. This playbook's own `lit-uui-conventions` skill only covers what that plugin doesn't: package-level frontend structure (barrel-export entry points, OpenAPI client generation from your Management API). |

## How it was validated

Every convention in the skills is checked against real, production Umbraco codebases —
Umbraco CMS core itself, and several real multi-version Umbraco products, not invented from
first principles. Where real projects genuinely disagree on a practice, the skills say so and
give a default rather than pretending there's one universal answer. Where a skill recommends
something *better* than common current practice (stricter build-review gating for
AI-driven work, Conventional Commits, structured plan docs), it says so honestly instead of
dressing up a new discipline as if it were already standard.

The `reviewer` agent's docs-first validation, sibling-comparison fallback, and
consumer-impact-analysis techniques are adapted from Umbraco CMS's own production PR-review
tooling. Deliberately not carried over: CMS-core-specific architecture-layer checks
(Core/Infrastructure/Web/API dependency direction), CI wiring, and a multi-file reference-doc
system — a package repo doesn't have CMS-core's internal layering, and a `reviewer` subagent
invoked from `umb-build-loop` doesn't need a separate automation harness.

## What this deliberately does not include

- A `you/` personal-context skill. Personal style belongs in a developer's own
  `~/.claude/CLAUDE.md` (outside any repo); project-specific working rules belong in the
  checked-in `CLAUDE.md` plus each developer's own `CLAUDE.local.md`. A shared, shareable
  playbook shouldn't own "who you are."
- `postgres-dba` / `sqlite-dev` as separate skills — merged into one `ef-core-data` skill,
  since Umbraco packages routinely need to support both SQL Server and SQLite from the same
  EF Core model, which the original's single-database-per-project split doesn't anticipate.
- Any Lit/UUI extension-point reference material the official Backoffice Skills plugin
  already owns.
- Any release/versioning pipeline — see the README's "Building on top" section.

## Open follow-ups (flagged, not decided)

- `bdd-specs-dotnet` assumes tests are written **before** implementation, matching the
  original's TDD stance. Confirm that's the stance you want before `umb-build-loop` sees
  real use — some teams will prefer tests-alongside-implementation with the same rigor
  applied after, and the skill should say which up front rather than let it drift per-task.
- No `umb-quick-fix` or `umb-document` equivalent has been built yet (the original's
  `/quick-fix` and `/document`). Add them the same way if their absence turns out to be felt
  in practice.
- No `git-merge` equivalent (a full "merge this branch into main safely" flow with
  dirty-tree/diverged-remote checks). Real Umbraco repos checked land code via PR merge or
  via `release`/`hotfix` branches, not a hand-run merge script — `git-workflow`'s "always ask
  before touching main" rule covers the actual risk that pattern would guard against.
- No `agent-teams` equivalent (running several parallel Claude Code sessions on independent
  workstreams). `umb-build-loop` is a sequential pipeline, not that — worth adding if a
  project's tasks are independent enough to parallelize.
- `bdd-specs-dotnet` and `user-stories` aren't `user-invocable` — they only run when
  `umb-plan` delegates to them, unlike the original's standalone `/spec`. Add the
  frontmatter if you want to re-run either on its own.
