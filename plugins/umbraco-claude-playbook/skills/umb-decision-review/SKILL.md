---
name: umb-decision-review
description: >-
  Digests a finished build into the handful of things the human should actually look at —
  assumptions the builder made, spec deviations, workarounds, judgment calls on ambiguous plan
  wording. Read-only, never gates or fixes anything. describe-pr invokes this automatically
  while writing every PR, so it doesn't normally need to be run by hand — but it's
  user-invocable for an earlier look once umb-build-loop finishes a feature, before a PR exists.
user-invocable: true
argument-hint: [path to the feature's plan folder, optional]
---

# umb-decision-review

`umb-build-loop` runs unsupervised across many tasks. Each `builder` dispatch reports back
"any decision the plan left implicit that it had to make," and the loop logs those to
`DECISION-LOG.md` (see that skill's step 6). In a fully autonomous run, the PR is the one
checkpoint guaranteed to get a human look, so `describe-pr` always invokes this skill while
writing that PR — nobody has to remember to trigger a separate review step. This skill doesn't
decide anything itself; it decides what's worth *the user's* attention and hands back a short,
ranked list.

## Scope

- IN: read `DECISION-LOG.md`, `BUILD-LOG.md`, and the feature's diff since it branched from
  trunk; surface the subset worth a human's eyes; rank them.
- OUT: fixing anything (no `Edit`/`Write` needed — this is a report), gating a commit (that's
  `reviewer`'s job, already done per task inside the loop), writing the PR description (that's
  `describe-pr` — hand this skill's output to its "Special things to note" section instead of
  duplicating the digest in a second file).

## Preflight

1. Resolve the plan folder: the path given in the argument; else match the current
   branch/worktree name against a plan folder the way `umb-build-loop` does (see the project's
   `CLAUDE.md`); else stop and ask.
2. Confirm `BUILD-LOG.md` has at least one entry. If it's empty or missing, nothing has been
   built yet — say so and stop rather than reviewing an empty diff.

## What counts as worth surfacing

Flag something only if a different, equally reasonable choice existed and the outcome could
plausibly matter to the person who owns the feature. Four categories:

- **Assumption** — filled a gap the plan or spec left open, without asking.
- **Deviation** — the implementation does something other than what `SPEC.md` or
  `ARCHITECTURE.md` says it does.
- **Workaround** — routed around a bug, a missing dependency, a CMS-version gap, or a flaky
  test, instead of a clean fix. (A weakened or skipped spec is already an automatic `reviewer`
  `FAIL` inside the loop, so a surviving one here means it slipped through — call that out
  as the top-priority item, not just another workaround.)
- **Judgment call** — ambiguous plan wording resolved one way among several defensible ones.

Skip pure implementation mechanics — variable names, which loop construct, formatting, file
layout inside an already-agreed extension point. Nobody needs to sign off on those.

## Workflow

1. Read `DECISION-LOG.md` end to end. Keep only entries timestamped from this feature's build
   phase (from when `umb-build-loop` cut the branch onward). Earlier entries belong to
   `umb-explore`/`umb-design`/`umb-plan` — the user already weighed in during those phases'
   interviews; don't re-surface settled ground.
2. Read `BUILD-LOG.md` for what each task claimed to verify, as context for the entries above.
3. Read the full diff since the branch point (`git diff <base>...HEAD`), with enough
   surrounding code to judge each flagged item in context, not just the changed lines.
4. Cross-check the diff against `SPEC.md`/`ARCHITECTURE.md` for anything that reads as a
   deviation but was never logged — the builder is supposed to report these, but this step
   catches what leaked through rather than trusting the log is complete.
5. For each surviving item, write one line: `file:line`, category tag, what happened, why it
   matters, and a recommended action — `Looks fine as documented` / `Needs a decision from
   you` / `Consider reverting`.
6. Sort most consequential first — anything touching user-facing behavior or a public API
   above an internal implementation choice; an unmitigated FAIL-worthy workaround above either.

## Report

Print the list directly in the reply — don't create a new file in the plan folder. If nothing
survives steps 1–4, say plainly "nothing needs your review" and stop; don't pad an empty
result with the search process.

## Hand off

Suggested next: `describe-pr` — fold anything real from this list into its "Special things to
note" section, then open the PR per `git-workflow`.
