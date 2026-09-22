---
name: umb-explore
description: >-
  Problem-space interview for a new Umbraco feature or package — what problem, for whom,
  why, and what's explicitly out of scope. Owns BRIEF.md in the feature's plan folder. Use
  when starting a new feature, package, or add-on and nothing has been written down yet, or
  when a feature request is vague and needs shaping before any design or code happens.
user-invocable: true
argument-hint: [one-line idea, optional]
---

# umb-explore

Think through an idea before touching the solution space. By the end, the feature's `BRIEF.md`
says what's being built and for whom, honestly including what isn't known yet.

## Where this writes

The project's per-feature plan folder — see the root `CLAUDE.md` for the path convention
(default `docs/plans/<feature-slug>/`; a monorepo or worktree-based project may scope it
differently). If no convention is written down anywhere, ask once, then propose one and add it
to `CLAUDE.md` so the next phase doesn't have to ask again.

Owns exactly one file: `BRIEF.md`. Never edit `ARCHITECTURE.md`, `SPEC.md`, `STORIES.md`,
`PLAN.md`, or `BUILD-LOG.md` — those belong to later phases.

**Stays uncommitted, stays on trunk.** `umb-explore` never runs `git commit`, never creates a
branch. The plan folder is just plain files on disk until `umb-build-loop` decides the feature
is actually being built — see "Branch/worktree per feature" in `git-workflow` for why. If the
feature never gets built, nothing ever touched git history.

**Why one file per phase, not one shared doc:** re-running a phase must never silently
overwrite another phase's decisions, and two files can't collide the way two sections in one
shared file can — a phase editing its own file is safe to run concurrently with another phase
(or another session) touching a different one. If a project already has its own plan-folder
convention, match it for consistency, but keep the same discipline (one owner per file) rather
than going fully freeform.

## Scope

- IN: the problem, the user (an editor? a developer integrating the package? an end site
  visitor?), the why-now, in/out scope, what success looks like, unknowns, light research
  where a fact is needed to proceed.
- OUT: architecture, CMS extension points to use, data model, package structure — all
  `umb-design`. If a solution idea comes up mid-interview, park it under a `> ASSUMPTION:`
  or note in the non-goals section rather than deciding it here.

## Preflight

1. Resolve which feature this run is for. If more than one plan folder exists, prefer a match
   between the current branch/worktree name and a folder name (see `CLAUDE.md`'s "Finding the
   current feature's plan folder" rule) — this is the normal case for a refinement run once
   `umb-build-loop` has started. If nothing matches and only one plan folder exists, or the
   argument names a brand-new idea, use that instead; ask only if it's still ambiguous. If
   `BRIEF.md` already exists in the resolved folder, read it. Summarize current state in 1–2
   lines ("problem defined, no success metric yet"). Re-entrant: refine, don't restart. **Skip
   step 2 below** when refining an existing `BRIEF.md`.
2. **Only for a brand-new feature (no `BRIEF.md` yet):** confirm the current branch is the
   project's trunk branch (see `CLAUDE.md`'s Feature workflow section; default the repo's
   default branch). If it isn't, stop and tell the user — starting a new plan folder from an
   unrelated branch is how plan folders end up scattered across branches they don't belong to.
   Let them override if they confirm it's intentional (e.g. planning a sub-feature inside a
   monorepo product's own long-lived line).
3. Read the project's `CLAUDE.md` and any existing architecture docs for prior context —
   don't re-litigate a decision already on record.
4. If this is a package/add-on (not a feature inside an existing product), check whether it's
   extending an existing Umbraco extension point (property editor, dashboard, content app,
   notification handler) or introducing a new one — that framing shapes several of the
   interview questions below.

## Interview

Up to ~10 questions, adaptive — only ask what's missing. Batch them (4 at a time,
2–3 rounds, not an interrogation):

1. What problem, concretely? What does an editor/developer do today without it?
2. Who is it for? Backoffice editors, developers consuming the package, front-end site
   visitors, or some mix? Who is explicitly *not* the audience?
3. Why now?
4. What's explicitly **out** of scope?
5. What does success look like — observable, ideally measurable?
6. Hard constraints: which Umbraco CMS version(s) must this support? Any locked
   dependencies?
7. What's the riskiest unknown — a CMS API that might not do what's assumed, a UUI
   component that might not exist yet, a performance ceiling?
8. What's the smallest version that's still worth shipping?
9. Is this replacing or extending something that already exists in Umbraco core or another
   package?
10. What would make you kill this?

Do targeted research only when an answer hinges on a checkable fact (e.g. does Umbraco core
already expose the extension point this needs).

## Produce

When revising an existing `BRIEF.md`, rewrite the affected sections to reflect the current
understanding only — don't leave the old answer in place alongside a note about what
changed. This file is a snapshot of the current problem definition, not a changelog. Past
answers and why they changed belong in `DECISION-LOG.md`.

Write/update `BRIEF.md`:

```md
# Brief

## Problem
<what, who, why-now, success criteria, constraints, riskiest unknowns — mark unresolved
items TODO rather than guessing>

## Non-goals
<explicitly out of scope, and why>
```

Append a dated entry to `DECISION-LOG.md` for anything decided here worth remembering later
(a scope cut, a killed alternative), one line each with the why. If a decision is project-wide
rather than scoped to this feature (a constraint that will bind every future feature too, not
just this one), write it to `.claude/memory/` instead (type: `decision`) — see
`.claude/memory/README.md` for the format.

## Hand off

State what's still `TODO`, then: `Suggested next: umb-design — or re-run umb-explore
to close open questions first.`
