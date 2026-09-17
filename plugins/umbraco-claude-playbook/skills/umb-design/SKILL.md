---
name: umb-design
description: >-
  Solution-space interview for an Umbraco feature — which extension points, data model,
  Management API surface, and frontend components to use. Owns the "## Design" section of the
  feature's plan doc. Use once umb-explore has defined the problem and it's time to decide
  how to build it: which CMS extension point fits, whether it needs persistence, what the
  package/project structure should look like.
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

The same per-feature plan doc `umb-explore` started. Owns exactly one section:
`## Design`. Read `## Problem` and `## Non-goals` — design must serve them, not redefine them.

As with `umb-explore`: if the project has its own plan-doc convention (numbered sub-phases, a
`## Migration` section, whatever shape it already uses), fold this content into that shape —
but keep the discipline of touching only this phase's own part of the doc; that's the point,
not the specific heading names.

## Scope

- IN: which Umbraco extension point(s) to use (property editor, dashboard, content app,
  section, notification handler, middleware, tree, workspace, etc.), data model & persistence
  (EF Core entities/migrations, or none), Management API surface (controllers, DTOs, routes),
  frontend component boundaries, build-vs-buy, key tradeoffs.
- OUT: the problem/why (`umb-explore` — read it, don't redo it), task breakdown
  (`umb-plan`), actual code (`umb-build-loop`).

## Preflight

1. Read the plan doc's `## Problem` and `## Non-goals`. If they're still `TODO` or missing,
   surface that and offer to bounce back to `umb-explore` — designing against an
   undefined problem is wasted work.
2. Read the project's `CLAUDE.md` for existing architectural conventions (folder structure,
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

```md
## Design

### Extension points
<which Umbraco extension point(s), and why this one over an alternative>

### Data model & persistence
<entities, relationships, SQL Server + SQLite considerations, or "none — reads/writes
existing Umbraco data via <service>">

### Management API surface
<routes, request/response shapes, or "none">

### Frontend components
<component boundaries, which package/library they live in>

### Key decisions
<each decision, its rationale, and the alternative rejected>
```

Append dated entries to `## Decision Log` for each architectural call made here. If a call is
a standing, project-wide decision rather than one scoped to this feature (the CMS major
version(s) targeted, the database provider(s) supported, a pattern every future feature must
follow), write it to `.claude/memory/` instead (type: `decision`) — see
`.claude/memory/README.md` for the format.

## Hand off

Note any `TODO` in `## Design`, then: `Suggested next: umb-plan.`
