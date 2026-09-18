---
name: quick-fix
description: >-
  Make a small, obvious fix directly on the current branch — no umb-explore, no umb-design, no
  umb-plan, no umb-build-loop. Use for a typo, a reversed condition, a dead try/catch, a
  misnamed variable, a stray import, or a missing null check — single concern, usually under
  ~20 lines, in either C# or Lit/TypeScript. Not a sixth pipeline phase: this is the deliberate
  escape hatch around the pipeline for a fix too small to justify it. Escalates to umb-plan/
  umb-build-loop the moment a fix turns out not to be this small.
user-invocable: true
argument-hint: <describe the fix>
---

# quick-fix

For the trivial stuff: the kind of bug where opening `umb-explore` → `umb-design` → `umb-plan`
→ `umb-build-loop` would be absurd. This skill is deliberately outside the `umb-*` pipeline
naming — it's an escape hatch *around* the pipeline, not a phase in it.

## Scope

- IN: one-spot fixes a competent engineer would commit straight to the default branch without
  ceremony. Single concern, usually under ~20 lines.
- OUT: anything that needs a design call, touches a public method's signature (that's the
  `[Obsolete]`-proxy discipline in `umbraco-package-conventions`/`umbraco-backoffice-
  conventions`, not a quick-fix), renames a backoffice manifest `alias` (a silent breaking
  change per `umbraco-backoffice-conventions`), changes behavior across modules, or needs test
  coverage beyond what already exists. If it smells like any of that, **stop and escalate** —
  suggest `umb-plan` (if a plan folder already covers this area) or `umb-explore` (if it
  doesn't).

## Argument

`$ARGUMENTS` describes the fix in the user's words (e.g. "remove the unneeded try/catch in
GetItemAsync", "fix the typo in the login button label"). If empty, ask one short clarifying
question.

## Loop

1. **Locate.** Find the exact site. If the description is ambiguous or matches multiple
   places, ask before guessing.
2. **Confirm it's actually small.** If reading the surrounding code reveals the fix is
   non-trivial (touches a class/component boundary, changes a public contract, needs new
   branches of test coverage), **stop and escalate** — tell the user this isn't a quick-fix
   and suggest `umb-plan`.
3. **Consult skills selectively.** Only load a skill if the fix genuinely touches its
   territory:
   - `solid-principles` / `design-principles` / `gof-patterns`: only if the fix sits at a
     class/component boundary or changes a control-flow pattern. Skip for typos, comments,
     log strings, dead code removal.
   - `dotnet-best-practices` / `typescript-best-practices`: only if the fix involves types,
     nullability, async behavior, or error shape.
   - **`security-dotnet` / `security-lit`: always, if the fix touches auth, user input, the
     Management API, secrets, or `unsafeHTML`/`unsafeSVG`.** "Quick" doesn't exempt a fix from
     these — they're non-negotiable in this playbook regardless of diff size.
   - No `builder`/`reviewer` dispatch. A quick-fix is single-threaded by definition — sized
     specifically to not need the two-subagent gate `umb-build-loop` uses for everything else.
4. **Apply the edit.** Use `Edit`, not `Write`. Match surrounding style.
5. **Verify.** Run the project's build/test if fast. If slow or absent, run the narrowest
   check that proves the fix (the single related test, or a targeted build of just the
   changed project).
6. **Report and ask before committing.** Show the diff summary and propose a one-line commit
   message, following `git-workflow`'s Conventional Commits format. Do **not** commit unless
   the user says go — committing straight to the default branch is a shared-state action, per
   `git-workflow`'s always-ask-before-touching-main rule for AI agents.

## Hand off

One sentence: what changed, what you verified, awaiting commit confirmation (or confirming
the commit if the user pre-authorized it).
