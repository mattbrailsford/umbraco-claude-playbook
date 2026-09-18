---
name: umb-build-loop
description: >-
  Drives a feature's PLAN.md checklist to completion, task by task — a builder subagent
  implements, a reviewer subagent gates, commit only on pass. Owns BUILD-LOG.md in the
  feature's plan folder. Use once umb-plan has produced an ordered task list and it's time to
  actually write code.
user-invocable: true
argument-hint: [path to the feature's plan folder, optional]
---

# umb-build-loop

> 🎯 **Design for change.** Each task's diff should be small, local, and behind a stable
> seam. The reviewer fails work that couples modules or bloats blast radius — the builder
> should pre-empt that, not rely on the reviewer to catch it.

Execute the task checklist in a feature's plan folder, one task at a time. You are the
orchestrator. You do **not** write feature code or review it yourself — you dispatch to the
`builder` and `reviewer` subagents and gate on their verdicts.

**On the gate granularity:** review runs before every commit, not once at the end. A human
catches their own mistakes as a diff forms in real time; an AI agent building unsupervised
doesn't have that continuous self-check, so the per-task gate closes that gap — a bad task
gets caught before it compounds into the next one. Treat this as the default, not an optional
extra. It doesn't replace a whole-feature PR review (see "Finish") — the two catch different
things.

## Scope

- IN: build each unchecked task, get it through review, commit it.
- OUT: planning, writing the task list, authoring specs — this **consumes** a plan, it
  doesn't author one.

## Preflight

1. Resolve the plan folder: the path given in the argument, else the project's convention
   (see `CLAUDE.md`), else **stop and ask** — do not infer one. Its name is the feature slug
   used below for the branch/worktree.
2. Read `PLAN.md`. It must be a checklist (`- [ ]` / `- [x]`). If it has no checkboxes, stop
   and report — send the user to `umb-plan`.
3. **Resuming or first run?** If any task in `PLAN.md` is already `- [x]`, or `BUILD-LOG.md`
   already has entries, the branch/worktree was already cut by an earlier run — skip to step 5.
   Otherwise this is the first run for this feature; continue to step 4.
4. **Cut the feature's branch/worktree.** This is the one point in the whole pipeline that
   touches git before any feature code exists — see `git-workflow`'s "Branch/worktree per
   feature" section for the full reasoning. In order:
   1. Confirm the working tree is clean *except* for the plan folder itself (expected —
      `umb-explore`/`umb-design`/`umb-plan` never commit it). Any *other* uncommitted change is
      unrelated work; stop and report rather than building on top of it.
   2. Confirm you're on the project's trunk branch (see `CLAUDE.md`'s Feature workflow
      section). If not, stop and ask — don't guess which branch to fork the feature from.
   3. **Ask the user to confirm before running any of this** — it commits to trunk, which the
      "always ask before touching main" rule covers regardless of how small the change is.
   4. Commit the plan folder as-is, on trunk: `git add <plan-folder> && git commit -m "docs:
      add plan folder for <feature-slug>"`.
   5. Create the branch/worktree named after `<feature-slug>`, off that commit. Prefer Claude
      Code's native worktree mechanism (`isolation: "worktree"` on the `Agent` tool, or the
      project's own configured `WorktreeCreate` hook) so the project decides the real branch
      name and location; fall back to a plain `git checkout -b <feature-slug>` off trunk if the
      project has no such hook. Never invent a separate worktree/branch mechanism here.
5. Confirm you're now inside the right branch/worktree — `pwd` and the current branch should
   match `<feature-slug>` (or whatever the project's hook actually named it) — before touching
   any code.

## The loop

For each task still unchecked (`- [ ]`) in `PLAN.md`, in order, top to bottom:

1. **Build.** Dispatch a `builder` subagent (Agent tool, `subagent_type: builder`, model
   sonnet). Give it: the exact task text, the relevant sections of `ARCHITECTURE.md` and
   `SPEC.md`, the files/extension points it owns, and an instruction to invoke the project's
   stack skills (`dotnet-best-practices`, `umbraco-extensibility`, `umbraco-package-
   conventions`, `ef-core-data`, `umbraco-backoffice-conventions`, etc. as relevant) and run
   the existing specs before reporting back. The builder does not commit.

2. **Review.** Dispatch a `reviewer` subagent (Agent tool, `subagent_type: reviewer`, model
   opus — must be ≥ builder). It invokes `security-dotnet`/`security-lit` (whichever the diff
   touches) and the relevant stack skills, reads the builder's diff, and returns `PASS` or
   `FAIL` with specific findings.

3. **Recurse.** If `FAIL`: send the findings back to a fresh `builder` for the same task.
   Repeat build → review until `PASS`. No cap — a task is not done until it passes both code
   and security review. Nothing reaches git history before `PASS`. If a finding is a
   repeatable mistake rather than a one-off slip — the kind of thing a future `builder` would
   plausibly do again on a different task — write it to `.claude/memory/` (type: `gotcha`)
   once it's fixed, so the next dispatch doesn't repeat it.

4. **Smoke the real entry point.** Before commit, actually exercise the deployed artifact.
   Most packages/add-ons generate a throwaway demo site for exactly this — start it and drive
   one real request through the Management API controller, resolve the newly-registered
   service via DI the way Umbraco actually would, or drive the backoffice UI through it
   (Playwright or equivalent). If this project doesn't have a separate demo/site environment —
   you're building something that *is* the host, like Umbraco CMS itself, rather than a
   package installed into one — a thorough integration test that boots the real hosting/DI
   pipeline (not a unit test through an internal seam) is the equivalent gate. Fakes for
   external services are fine either way; the request must travel through the real entry
   point, not an internal function that bypasses it. If the smoke fails, recurse to step 3
   with a finding — a green unit test suite is not enough to ship.

5. **Commit.** On `PASS` + smoke green, have the builder commit *only this task's changes*
   with a message naming the task, following the project's commit conventions (see
   `git-workflow`). One commit per task.

6. **Check the box.** Edit `PLAN.md`: `- [ ]` → `- [x]` for the completed task, and add a
   one-line entry to `BUILD-LOG.md` (commit SHA, what was verified). Commit that change with
   the task commit or immediately after.

7. Next task.

## Finish

When every box is checked: run the full test suite once more, then report a summary (tasks
completed, commits, anything still red). A final architecture/design pass is a separate
step, not part of this loop — re-run `umb-design` if the build surfaced something worth
reconsidering. If this feature is (or completes) a standalone package ready to publish, invoke
`umbraco-marketplace` before tagging a release — it's not part of this loop either.

**The per-task `reviewer` gate and a whole-feature PR review catch different things — run
both.** Open a PR the normal way (`git-workflow`) once the loop finishes. `reviewer` only sees
one task's diff at a time, so it can't catch cross-task issues (a design decision in task 3
that doesn't sit well with task 7, the feature's shape end to end) — a whole-feature review
still needs to happen, by a human or whatever automated review the project has.

If this feature built inside a worktree, don't remove it here — that's a post-merge cleanup
step (the project's own `WorktreeRemove` hook, or `git worktree remove`), outside this loop's
job.

## Rules

- Sequential, dependency-ordered. This is a pipeline, not a parallel team.
- Builder owns code; reviewer owns the gate; this loop owns sequencing, `PLAN.md` checkbox
  state, and `BUILD-LOG.md`. Never collapse these roles.
- If a gate can't pass after repeated attempts and the builder is stuck, stop and report the
  task + findings rather than committing degraded code.
