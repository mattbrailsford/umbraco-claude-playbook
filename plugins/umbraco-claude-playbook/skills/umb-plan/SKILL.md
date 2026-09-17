---
name: umb-plan
description: >-
  Slices a finished design into an ordered, dependency-aware task checklist. Owns the
  "## Stories & Tasks" section of the feature's plan doc, and delegates to the user-stories
  and bdd-specs-dotnet skills. Use once umb-design has decided how to build the feature
  and it's time to break it into reviewable, committable units of work for umb-build-loop.
user-invocable: true
argument-hint: [scope to plan, optional]
---

# umb-plan

> 🎯 **Design for change.** Slice tasks so each one touches one seam. A task that edits five
> unrelated files, or straddles both a Management API controller and an unrelated UUI
> component, is a coupling smell — re-slice before handing it to `umb-build-loop`.

Turn the design into something `umb-build-loop` can execute. This command **transforms**
`## Design` — it does not re-elicit requirements.

## Where this writes

The same per-feature plan doc. Owns `## Stories & Tasks`. Read `## Problem`, `## Non-goals`,
and `## Design` — this is confirmation and slicing, not a fresh interview.

A checklist of small, dependency-ordered, independently reviewable tasks forces sizing and
sequencing decisions up front and gives `umb-build-loop` something mechanically parseable to
gate against. Keep this discipline (small, ordered, reviewable units) even for a project that
tracks completion via issues instead of an in-doc checklist.

## Scope

- IN: derive user stories from `## Design`, order tasks into a dependency-aware checklist,
  mark what can run concurrently, then generate executable specs via `bdd-specs-dotnet` —
  always, no asking.
- OUT: gathering requirements (`umb-explore`/`umb-design`), building
  (`umb-build-loop`).

## Preflight

1. Read `## Design`. If it's still a stub or full of `TODO`, **stop** — send the user back to
   `umb-design`.
2. Read any existing `## Stories & Tasks`. Re-entrant: reconcile and extend; never silently
   drop or renumber completed (`- [x]`) tasks.

## Stories

Delegate to `user-stories` to produce/refine the story list (Given/When/Then acceptance
criteria per story, formatted so `bdd-specs-dotnet` can consume it directly). Don't
hand-roll the format.

## Specs (always, no asking)

Once stories are finalized and the task list is written, always delegate to
`bdd-specs-dotnet` to generate executable, pending spec files from the stories. This is part
of `umb-plan`'s contract, not optional. The generated specs should fail (or be marked
pending) until `umb-build-loop` turns them green.

## Interview

Light — confirmation, not elicitation. ~3–5 questions, batched:

1. Here's how `## Design` was sliced into stories — anything mis-cut or missing?
2. Priority/sequence right? What's the first shippable slice?
3. Any task marked parallel that actually shares a file or a migration?
4. Hard external dependencies that gate ordering (a CMS API only available from a certain
   version, a package that must ship first)?

## Produce

`## Stories & Tasks`, a checklist `umb-build-loop` can execute:

- Every task is `- [ ]`, top-to-bottom in dependency order.
- Each task line carries: a short id, the story it implements, explicit `depends-on:` ids,
  and a `parallel-group:` tag for tasks with no ordering between them.
- One task = one reviewable, committable unit of work.
- No task references a file, extension point, or decision not already in `## Design`.
- **Wire tasks are first-class.** For every feature that touches a real entry point — a
  Management API controller, a Composer-registered service, a backoffice manifest entry —
  include an explicit `wire: <feature> into <entry point>` task whose acceptance is a real
  request or resolution through the deployed artifact, not just "unit tests pass." A task
  whose only acceptance criterion is unit-test-green is not allowed for anything on that
  path — that's how stubs ship.

Append dated `## Decision Log` entries for non-obvious sequencing decisions (why task X
blocks task Y, why a slice was deferred).

## Hand off

Summarize: N stories, M tasks, S spec files generated, the first parallel group, then:
`Suggested next: umb-build-loop — specs are in place and pending.`
