---
name: umb-design
description: >-
  Solution-space interview for an Umbraco feature — which extension points, data model,
  Management API surface, and frontend components to use. Owns ARCHITECTURE.md and SPEC.md in
  the feature's plan folder. Use once umb-explore has defined the problem and it's time to
  decide how to build it: which CMS extension point fits, whether it needs persistence, what
  the package/project structure should look like.
user-invocable: true
argument-hint: [area to focus, optional]
---

# umb-design

> 🎯 **Design for change.** Every decision here is judged by one question: when this
> changes, how big is the diff? Pick the Umbraco extension points, seams, and data shapes
> that make the *next* change small and local — not the ones that are merely first to mind.

Decide *how* to build what `umb-explore` defined. Output: which parts of Umbraco you're
extending, the data model (if any), the Management API surface (if any), and the frontend
component shape (if any).

## Where this writes

The same per-feature plan folder `umb-explore` started. Owns two files:

- **`ARCHITECTURE.md`** — the internal structural decisions: which extension point(s), the
  data model, key decisions with their rationale and the rejected alternative. This answers
  "how is it built, and why."
- **`SPEC.md`** — the externally observable contract: the Management API surface and the
  frontend components' expected behavior, in concrete, testable terms. This answers "what must
  it do," and is what `umb-plan` slices into stories — keep it testable, not vague.

Read `BRIEF.md` — design must serve it, not redefine it. As with `umb-explore`: if the project
has its own plan-folder convention, fold this content into that shape, but keep the discipline
of touching only these two files; that's the point, not the specific file names.

## Scope

- IN: which Umbraco extension point(s) to use (property editor, dashboard, content app,
  section, notification handler, middleware, tree, workspace, etc.), data model & persistence
  (EF Core entities/migrations, or none), Management API surface (controllers, DTOs, routes),
  frontend component boundaries, build-vs-buy, key tradeoffs.
- OUT: the problem/why (`umb-explore` — read it, don't redo it), task breakdown
  (`umb-plan`), actual code (`umb-build-loop`).

## Preflight

1. Resolve which feature this run is for. If more than one plan folder exists, prefer a match
   between the current branch/worktree name and a folder name (see `CLAUDE.md`'s "Finding the
   current feature's plan folder" rule) — this is the normal case once `umb-build-loop` has
   started. If nothing matches, fall back to the one plan folder present, or ask if more than
   one is ambiguous.
2. Read `BRIEF.md` in the resolved folder. If it's still `TODO` or missing, surface that and
   offer to bounce back to `umb-explore` — designing against an undefined problem is wasted
   work.
3. Read the project's `CLAUDE.md` for existing architectural conventions (folder structure,
   namespace rules, extension patterns already in use) — a new feature should extend the
   grain of the codebase, not fight it.

## Skills to pull in

- Extension-point idioms, DI registration patterns → `umbraco-extensibility`.
- Async naming, repository visibility, public-API compatibility → `umbraco-package-conventions`.
- General C# type/error-handling shape for a new service or model → `dotnet-best-practices`.
- Persistence needed → `ef-core-data`.
- Backoffice UI needed → the official Umbraco Backoffice Skills plugin for the specific
  extension point (dashboard, property editor, tree, etc.), plus
  `umbraco-backoffice-conventions` for package-level frontend structure.
- Module/class boundaries → `solid-principles`, `design-principles`. Pattern choice →
  `gof-patterns`.
- Anything touching auth, user input, or the Management API → `security-dotnet`, now, not
  at review time.
- Rendering externally-sourced/AI-generated content in the frontend, or a design that would
  expose a secret to the client → `security-lit`, now, not at review time.

## Interview

Up to ~10 questions, adaptive, batched (4 at a time):

1. Which Umbraco extension point(s) does this hang off? (property editor, dashboard,
   content app, notification handler, middleware, custom section, tree...)
2. Does it need its own persistence, or does it read/write existing Umbraco data
   (content, media, members)?
3. If persistence: core entities, relationships, and — SQL Server only, or SQL Server *and*
   SQLite (most packages need both, since sites run either)?
4. Does this need a Management API surface of its own, or is it purely a backoffice UI
   against existing APIs?
5. Component boundaries — what's a service, what's a repository, what's UI-only?
6. Which CMS major version(s) does this need to run on? Any API used only in one?
7. Auth & trust boundaries — is this backoffice-only, or does anything cross into the
   public-facing site?
8. Hardest technical risk, and the fallback if the assumed extension point doesn't behave as
   expected?
9. What are we explicitly **not** building for now (YAGNI)?
10. Non-functionals that bite: content-tree scale, request latency, cold-start on a busy
    site?

## Produce

When revising an existing `ARCHITECTURE.md`/`SPEC.md`, rewrite the affected sections to
reflect the current approach only — don't leave the old approach in place alongside a note
about what changed. These files are a snapshot of the current design, not a changelog. Past
approaches and why they were rejected belong in `DECISION-LOG.md`.

`ARCHITECTURE.md`:

```md
# Architecture

## Extension points
<which Umbraco extension point(s), and why this one over an alternative>

## Data model & persistence
<entities, relationships, SQL Server + SQLite considerations, or "none — reads/writes
existing Umbraco data via <service>">

## Key decisions
<each decision, its rationale, and the alternative rejected>
```

`SPEC.md`:

```md
# Spec

## Management API surface
<routes, request/response shapes, and the observable behavior each one guarantees — or
"none">

## Frontend components
<component boundaries, which package/library they live in, and what each must observably
do/render/emit — or "none">
```

Append dated entries to `DECISION-LOG.md` for each architectural call made here. If a call is
a standing, project-wide decision rather than one scoped to this feature (the CMS major
version(s) targeted, the database provider(s) supported, a pattern every future feature must
follow), write it to `.claude/memory/` instead (type: `decision`) — see
`.claude/memory/README.md` for the format.

## Hand off

Note any `TODO` in `ARCHITECTURE.md`/`SPEC.md`, then: `Suggested next: umb-plan.`
