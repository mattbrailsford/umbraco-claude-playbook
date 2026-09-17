---
name: umb-explore
description: >-
  Problem-space interview for a new Umbraco feature or package — what problem, for whom,
  why, and what's explicitly out of scope. Owns the "## Problem" and "## Non-goals" sections
  of the feature's plan doc. Use when starting a new feature, package, or add-on and nothing
  has been written down yet, or when a feature request is vague and needs shaping before any
  design or code happens.
user-invocable: true
argument-hint: [one-line idea, optional]
---

# umb-explore

Think through an idea before touching the solution space. By the end, the feature's plan doc
says what's being built and for whom, honestly including what isn't known yet.

## Where this writes

The project's per-feature plan doc — see the root `CLAUDE.md` for the path convention (default
`docs/plans/<feature-slug>-plan.md`; a monorepo or worktree-based project may scope it
differently, e.g. `docs/internal/agent/plans/<feature-slug>-plan.md`). If no convention is
written down anywhere, ask once, then propose one and add it to `CLAUDE.md` so the next phase
doesn't have to ask again.

Owns exactly two sections: `## Problem` and `## Non-goals`. Never edit `## Design`,
`## Stories & Tasks`, or `## Build Log` — those belong to later phases.

**Why phase-owned sections:** re-running a phase must never silently overwrite another
phase's decisions — owned sections make that structurally impossible. If a project already
has its own plan-doc convention, match it for consistency, but keep the same discipline
(track which part of the doc each phase owns) rather than going fully freeform.

## Scope

- IN: the problem, the user (an editor? a developer integrating the package? an end site
  visitor?), the why-now, in/out scope, what success looks like, unknowns, light research
  where a fact is needed to proceed.
- OUT: architecture, CMS extension points to use, data model, package structure — all
  `umb-design`. If a solution idea comes up mid-interview, park it under a `> ASSUMPTION:`
  or note in `## Non-goals` rather than deciding it here.

## Preflight

1. If the plan doc already exists, read it. Summarize current state in 1–2 lines
   ("problem defined, no success metric yet"). Re-entrant: refine, don't restart.
2. Read the project's `CLAUDE.md` and any existing architecture docs for prior context —
   don't re-litigate a decision already on record.
3. If this is a package/add-on (not a feature inside an existing product), check whether it's
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

Write/update the plan doc:

```md
## Problem
<what, who, why-now, success criteria, constraints, riskiest unknowns — mark unresolved
items TODO rather than guessing>

## Non-goals
<explicitly out of scope, and why>
```

Append a dated entry to `## Decision Log` for anything decided here worth remembering later
(a scope cut, a killed alternative), one line each with the why. If a decision is project-wide
rather than scoped to this feature (a constraint that will bind every future feature too, not
just this one), write it to `.claude/memory/` instead (type: `decision`) — see
`.claude/memory/README.md` for the format.

## Hand off

State what's still `TODO`, then: `Suggested next: umb-design — or re-run umb-explore
to close open questions first.`
