---
name: describe-pr
description: >-
  Writes the pull request description — the one skill git-workflow always delegates to for
  this, never done by hand. Produces a diagram-based outline (file trees, before/after code
  diffs, call chains, EF Core/SQL table changes, Lit component trees, manifest registration
  changes) when the feature's `docs/plans/<feature-slug>/` folder exists, or a plain
  summary/why/verify/risk write-up when it doesn't. Use whenever a PR is being opened or
  updated.
user-invocable: true
argument-hint: [PR number | leave blank for the current branch]
---

# Describe a pull request

`git-workflow` never writes a PR body by hand — it always runs this skill instead, for every
PR. This skill decides, every time, which of its two styles fits: a diagram-based outline for a
feature-sized change, or a plain summary for everything else.

This skill only composes the description. Branch/push/PR-creation mechanics, force-push and
secret-scanning sanity rules, and the always-ask-before-touching-main rule all stay owned by
`git-workflow` — read that skill's "Pull requests" and "Sanity rules" sections and follow them
as-is; don't restate them here.

## Workflow

1. **Check for a plan folder.** Does `docs/plans/<feature-slug>/` exist for the current branch
   (the umb-* pipeline ran for this feature)? This decides which style you write in step 3 — a
   `quick-fix` or trunk-based commit won't have one, and that's expected, not an error.

2. **Gather context.**
   - Plan folder found: read `BRIEF.md`, `ARCHITECTURE.md`/`SPEC.md`, and `PLAN.md` for the
     "why." Then invoke `umb-decision-review` (via the Skill tool) — always, not only if it
     happens to have already run — and use its ranked output as-is for step 4's "Special
     things to note." The PR is the one checkpoint a fully autonomous run is guaranteed to get
     a human look at, so this step never skips it: don't fall back to reading `DECISION-LOG.md`
     by hand and don't re-derive the list yourself.
   - No plan folder: read the branch's commit messages instead — there's no separate plan
     artifact to draw on, and `umb-decision-review` needs a plan folder to run against.
   - Either way, read the full diff against the base branch (`git diff <base>...HEAD`, or
     `gh pr diff <number>` if a PR already exists) — enough of it, and enough surrounding code,
     to explain behavior and ownership, not just line counts.

3. **Find or create the PR.**
   - `gh pr view --json url,number,title,state,baseRefName,headRefName` on the current branch.
   - No PR yet: follow `git-workflow`'s "Pull requests" section to push and open one. Don't
     duplicate those steps here — this skill picks up once a PR exists (or is about to).

4. **Write the description**, in the style step 1 decided:
   - **Plan folder found** — use `templates/pr-description.md`:
     - **Why the change** — exactly one sentence.
     - **Special things to note** — 1-3 bullets, led by whatever `umb-decision-review` flagged
       in step 2 (an assumption, a spec deviation, a workaround), plus migrations, compatibility
       constraints, or other deliberate omissions it wouldn't have caught. Write `- None.` if
       there aren't any — don't pad it out.
     - **Change outline** — the smallest set of diagrams that explains the implementation. See
       `references/diagram-conventions.md` for which shape fits which kind of change and how to
       draw it. Only include a view that actually changed; skip the rest. Order them the way a
       reader would want the story told (a data structure or contract usually comes before the
       code that uses it), not in a fixed sequence.
     - Prefer a `diff` block for a change to an existing shape; show the whole thing only when
       most of it is new or the diff notation would obscure ownership or order.
   - **No plan folder** — use `templates/pr-plain.md`: Summary, Why, How to verify, Risk /
     rollback. A diagram-heavy outline on a five-line fix is noise, not help.
   - Either way, write it as one person explaining a change to another — plain language, no
     jargon that isn't already in the codebase.

5. **Save and publish.**
   - Plan folder found: save the draft to `docs/plans/<feature-slug>/PR-DESCRIPTION.md` first —
     this skill owns that file, the same way `umb-build-loop` owns `BUILD-LOG.md`. Then
     `gh pr edit <number> --body-file docs/plans/<feature-slug>/PR-DESCRIPTION.md`.
   - No plan folder: nothing to save alongside — pass the description straight through with
     `gh pr edit <number> --body "$(cat <<'EOF' ... EOF)"` (or `gh pr create` if step 3 is
     opening the PR for the first time).
   - Confirm the update succeeded.

6. **Report back**, briefly: the PR URL, the saved description's path (if any), and a short
   list of changed files. Nothing else — the PR itself carries the full description.

## Sanity rules

Inherited from `git-workflow`, not restated: no force-push, no `--no-verify`, re-check the diff
for secrets before it goes anywhere, and stop to ask before running `git commit`/`git merge`
straight against the default branch or a `support/*` branch.
