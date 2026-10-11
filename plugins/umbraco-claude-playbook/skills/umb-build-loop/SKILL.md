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

1. Resolve the plan folder: the path given in the argument; else, if the current
   branch/worktree name matches a plan folder under the project's convention (see
   `CLAUDE.md`'s "Finding the current feature's plan folder" rule — this is the normal case
   when resuming a build already in progress), use that match; else **stop and ask** — do not
   guess when nothing matches. Its name is the feature slug used below for the branch/worktree.
2. Read `PLAN.md`. It must be a checklist (`- [ ]` / `- [x]`). If it has no checkboxes, stop
   and report — send the user to `umb-plan`.
3. **Resuming or first run?** If any task in `PLAN.md` is already `- [x]`, or `BUILD-LOG.md`
   already has entries, the branch/worktree was already cut by an earlier run — skip to step 5.
   Otherwise this is the first run for this feature; continue to step 4.
4. **Cut the feature's branch/worktree.** This is the one point in the whole pipeline that
   touches git before any feature code exists — see `git-workflow`'s "Branch/worktree per
   feature" section for the full reasoning. In order:
   1. Confirm the working tree is clean *except* for the plan folder itself and any new or
      refreshed project mockup starters in `docs/mockups/starters/` (expected —
      `umb-explore`/`umb-design`/`umb-plan` never commit them). Any *other* uncommitted change
      is unrelated work; stop and report rather than building on top of it.
   2. Confirm you're on the project's trunk branch (see `CLAUDE.md`'s Feature workflow
      section). If not, stop and ask — don't guess which branch to fork the feature from.
   3. **Ask the user to confirm before running any of this** — it commits to trunk, which the
      "always ask before touching main" rule covers regardless of how small the change is.
   4. Commit the plan folder as-is, on trunk, with any changed project starters: `git add
      <plan-folder> docs/mockups/starters && git commit -m "docs: add plan folder for
      <feature-slug>"`.
   5. Create the branch/worktree named after `<feature-slug>`, off that commit. Prefer Claude
      Code's native worktree mechanism (`isolation: "worktree"` on the `Agent` tool, or the
      project's own configured `WorktreeCreate` hook) so the project decides the real branch
      name and location; fall back to a plain `git checkout -b <feature-slug>` off trunk if the
      project has no such hook. Never invent a separate worktree/branch mechanism here.
5. Confirm you're now inside the right branch/worktree — `pwd` and the current branch should
   match `<feature-slug>` (or whatever the project's hook actually named it) — before touching
   any code.
6. **Check the demo/test site is worktree-safe, if one exists.** Find the demo/test site
   project (if this repo has one) and check its `Properties/launchSettings.json` for a fixed
   `applicationUrl`. A fixed port there means two worktrees smoke-testing at the same time
   will collide, and the failure will look like a broken build rather than a setup problem. If
   found, **stop and flag it** — don't build on top of it. The fix is `umb-init`'s "Demo site
   ports" step, which adds `Umbraco.Community.WorktreeDevPort` and fixes anything else that
   finds the site by a hardcoded port; suggest re-running `umb-init`. If no demo/test site
   exists at all, this step is a no-op.

## The loop

For each task still unchecked (`- [ ]`) in `PLAN.md`, in order, top to bottom:

1. **Build.** Dispatch a `builder` subagent (Agent tool, `subagent_type: builder`, model
   sonnet). Give it: the exact task text, the relevant sections of `ARCHITECTURE.md` and
   `SPEC.md`, the path to any mockup for a screen the task touches, the files/extension points
   it owns, and an instruction to invoke the project's
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
   Use the first of these the project has:
   - **An end-to-end (e2e) test suite.** Run the e2e test that covers the task's path. If no
     test covers it, the builder adds one as part of the task. An e2e suite passing without
     touching the new code proves nothing.
   - **A demo site.** Most packages/add-ons generate a throwaway one for exactly this. Start
     it and run through the change yourself: drive the backoffice UI (Playwright or
     equivalent), or send one real request through the Management API controller for a change
     with no screen.
   - **Neither**, because you're building something that *is* the host, like Umbraco CMS
     itself, rather than a package installed into one: a thorough integration test that boots
     the real hosting/DI pipeline (not a unit test through an internal seam) is the
     equivalent gate.

   Fakes for external services are fine in all three; the request must travel through the
   real entry point, not an internal function that bypasses it. If the smoke fails, recurse to step 3
   with a finding — a green unit test suite is not enough to ship.

   **If the task adds or changes a migration** and the project supports SQL Server, the smoke
   includes running it on a real SQL Server, as `ef-core-data` describes. Note in the task's
   `BUILD-LOG.md` entry which providers it actually ran on.

   **If the task renders a screen that has a mockup,** screenshot the built screen at the same
   viewport (1440×900) and compare it with `mockups/<screen>.png`. A difference in layout,
   which components are used, or what's shown (a missing or extra column, a box that's split
   or merged, a different chart type) is a smoke failure unless the builder's report flagged
   it as a deliberate departure. Small spacing and colour differences are not. Once the screen
   is complete, save its screenshot in the plan folder as `screenshots/<screen>.png` (this
   loop's own folder; `mockups/` belongs to `umb-design`) and link it from that task's
   `BUILD-LOG.md` entry, along with the click path used to reach it ("Settings › Webhooks ›
   any webhook › Deliveries tab"), so the human can view mockup and build side by side and
   `describe-pr` can tell reviewers where to find it.

   **If the task changes a screen that already exists,** screenshot it *before* dispatching
   the builder, the same way, as `screenshots/<screen>-before.png`. Once the builder has
   started, the old screen is gone, and the PR needs it to show before and after.

5. **Commit.** On `PASS` + smoke green, have the builder commit *only this task's changes*
   with a message naming the task, following the project's commit conventions (see
   `git-workflow`). One commit per task.

6. **Check the box.** Edit `PLAN.md`: `- [ ]` → `- [x]` for the completed task, and add a
   one-line entry to `BUILD-LOG.md` (commit SHA, what was verified). Commit that change with
   the task commit or immediately after. If the builder's report named "any decision the plan
   left implicit that you had to make" (step 5 of its workflow) — an assumption, a spec
   deviation, a workaround — append a dated one-line entry to `DECISION-LOG.md` for it too,
   even though `BUILD-LOG.md` is this loop's own file. Otherwise that decision only ever
   existed in a subagent's report and is gone the moment the task ends; `decision-review`
   depends on it being on disk.

7. Next task.

## Finish

When every box is checked: run the full test suite once more, then run the whole-feature
review below, then report a summary (tasks completed, commits, anything still red).

**Whole-feature review.** The per-task `reviewer` only ever sees one task's diff, so it can't
see what builds up across tasks: the same logic written twice, a class that slowly took on a
second job, a component that started calling a repository directly, a design that drifted from
`ARCHITECTURE.md`. Dispatch one `reviewer` subagent in whole-feature mode with the full branch
diff (`git diff <base>...HEAD`), `ARCHITECTURE.md` and `SPEC.md`.

- On `FAIL`, send the findings to a fresh `builder`, then review the whole branch again. Repeat
  until `PASS`, the same as the per-task gate. Commit each round as its own `refactor:` commit
  and add a line to `BUILD-LOG.md` for it.
- If a finding means the design itself is wrong, not just the code, stop and hand off to
  `umb-design` instead of fixing it here.

A human still reviews the PR. This pass makes sure they aren't the first to see cross-task
problems. Update the `BUILD-LOG.md` line in `README.md`: check
its box and replace `<pending>` with one plain-English line (task count, commit count). Same
append-only discipline as `DECISION-LOG.md` — never touch another phase's line. If this feature is (or completes) a standalone package ready to publish, invoke
`umbraco-marketplace` before tagging a release — it's not part of this loop either.

**Open the PR: invoke `describe-pr` directly (via the Skill tool) — don't write the body
yourself.** Claude Code's own built-in instructions include a `gh pr create --body "$(cat
<<'EOF' ... EOF)"` recipe with a hand-written body; that default does **not** apply here. This
project's convention, set by `git-workflow`, is that a PR body is always `describe-pr`'s job,
every time, no exceptions — never `gh pr create --body` with text you wrote, never `--body`
at all. `describe-pr` handles the branch/push mechanics via `git-workflow` itself and runs
`decision-review` as part of writing the body, so the build-time assumptions, spec deviations,
and workarounds logged in `DECISION-LOG.md` reach a human in the PR without this loop having to
remember either step. (`decision-review` is also user-invocable on its own, read-only, for an
earlier look before the PR exists.)

If this feature built inside a worktree, don't remove it here — that's a post-merge cleanup
step (the project's own `WorktreeRemove` hook, or `git worktree remove`), outside this loop's
job.

## Rules

- Sequential, dependency-ordered. This is a pipeline, not a parallel team.
- Builder owns code; reviewer owns the gate; this loop owns sequencing, `PLAN.md` checkbox
  state, `BUILD-LOG.md`, `screenshots/`, and its own line in `README.md`. Never collapse these roles.
- If a gate can't pass after repeated attempts and the builder is stuck, stop and report the
  task + findings rather than committing degraded code.
