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
  frontend component boundaries, build-vs-buy, key tradeoffs, which connected systems a change
  of this kind conventionally touches (see "Connected-pattern check" below).
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

## Connected-pattern check

Some changes belong to a *kind* the codebase already has conventions for — a new property on
a content/model type, a new CRUD method on a repository, a new entity type — and that kind
conventionally fans out to systems well outside the file being changed: version history/audit
trail, Deploy import/export connectors, search indexing, cache refreshers, before/after
notification events, permission checks. Missing one of these doesn't fail a build or a test —
it ships a feature that quietly doesn't round-trip through Deploy, or doesn't show up in
version history, and nobody notices until a user does.

Before drafting `ARCHITECTURE.md`, decide if this feature is that kind of addition. If it is:

1. **Check docs first.** If `CLAUDE.md` or another skill already states what a change of this
   kind must touch, that's ground truth — skip straight to step 3.
2. **Otherwise, sample sibling implementations.** Find two or three existing siblings of the
   same kind (properties on similar models, similar entity types, similar CRUD methods) and
   read what each one currently wires up. If they agree, that's the pattern. If they disagree,
   note the split in `ARCHITECTURE.md` and ask which behavior this feature should follow rather
   than picking one.
3. For each system the pattern touches, decide: does this feature need the same treatment?
   Carry the ones that apply into `ARCHITECTURE.md`'s decisions and `SPEC.md`'s scope so
   `umb-plan` slices them into real tasks. Explicitly note the ones that don't apply and why,
   so it reads as a deliberate cut, not an oversight.

This is a different altitude than `reviewer`'s sibling-comparison step: reviewer catches a
missed cross-cutting concern on the *same class* after the code is written; this catches a
missed *subsystem* before a single task is planned. Skipping this step doesn't fail review —
it just means the gap ships, because nothing else in the pipeline looks for it.

## Backoffice UX check (features with a UI)

A backoffice extension has a real user: the editor sitting in front of it. A feature that
technically works but leaves them guessing is still a bug, just one the build/test suite can't
see. If `SPEC.md`'s "Frontend components" section isn't "none," walk through these five spots
before finalizing it and decide, deliberately, whether each needs a line:

1. **First run.** Nothing's been created yet — does the empty state say what goes here and
   offer the first action, or is it a blank table?
2. **The mistake.** The editor picks a bad value or clicks the wrong thing — does the error
   say what happened and what to do next, or just "invalid input"?
3. **The wait.** Something takes more than a second (a save, a fetch, an import) — does the
   editor know it's working?
4. **The finish.** It worked — how do they know, beyond a modal just closing?
5. **The return.** They come back tomorrow — is their last choice (a filter, a tab, a sort
   order) still where they left it?

Most requests describe only the main action and skip the other four. Each spot that applies
becomes one ordinary line in `SPEC.md`, same as any other observable behavior — no new
dependency, no new component, no schema change; `umb-plan` slices it into a task like anything
else. If a spot genuinely doesn't apply, note it as a deliberate skip rather than leaving it
unconsidered, the same way the connected-pattern check above handles a system that doesn't
apply.

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

## Assume, then show

Not every topic below needs a spoken question. Before asking:

1. **Check whether it's a checkable fact** — the codebase's existing conventions, how a
   sibling feature is built, what an extension point actually supports — and go find it
   instead of asking.
2. **If it's a judgment call and a wrong guess is cheap to correct once it's written down**
   (component boundaries, a non-functional target, which pattern to reach for), write it as
   `> ASSUMPTION: ...` under the relevant section of `ARCHITECTURE.md`/`SPEC.md` instead of
   asking, and let the human correct it when they read the design. Correcting a written-down
   guess costs them a sentence; answering a live question costs them a context switch.
3. **Ask directly only when a wrong guess is expensive to undo here** — which extension point
   to hang the feature off (hard to walk back once built against), the data model/migration
   shape, which CMS version(s) to support, or an auth/trust boundary crossing into the
   public-facing site. Everything else defaults to assume-and-show.

This doesn't relax "stop, don't guess" — that rule is about a phase's *required input* being
missing (no `BRIEF.md` to read). This is about which of *this* phase's own questions you put
to the human versus answer yourself and show your work.

## Interview

Up to ~10 questions, adaptive, batched (4 at a time) — only what's left after the filter
above:

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

## Connected systems
<other systems this kind of change conventionally touches — version history, Deploy
connectors, search indexing, notification events, etc. — and whether each applies here and
why, or "none — not this kind of change">

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
