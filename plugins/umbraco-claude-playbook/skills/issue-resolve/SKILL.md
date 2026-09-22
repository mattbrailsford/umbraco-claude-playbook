---
name: issue-resolve
description: >-
  Routes a triaged tracker issue, plus any notes on how to fix it, into whichever existing fix
  mechanism its size warrants — `quick-fix` for something small, the full `umb-explore` →
  `umb-design` → `umb-plan` → `umb-build-loop` pipeline for anything bigger. Triages the issue
  first if `issue-triage` hasn't already. Drafts, never posts, the tracker resolution once the
  fix lands. Use once you've seen an `issue-triage` report and decided to act on one issue.
user-invocable: true
argument-hint: <issue ID> [notes on how you want it fixed, optional]
---

# issue-resolve

Bridges a triaged issue into an actual fix, using the mechanisms this playbook already has —
it doesn't write the fix itself. `quick-fix` handles something small; the full pipeline
handles anything bigger. Once the fix lands, this closes the loop back on the tracker as a
draft, never a live action.

## Scope

- IN: pull the issue and its triage read, route to the right existing fix mechanism, seed it
  with the issue's content and your notes, draft the tracker resolution once the fix lands.
- OUT: writing the fix itself (that's `quick-fix`'s inline edit, or the pipeline's `builder`),
  reclassifying an issue that's already triaged, posting or closing anything on the tracker
  without your say-so.

## Preflight

1. Resolve the tracker the same way `issue-triage` does — read `CLAUDE.md`'s `## Issue
   tracker` section. If it's missing, nothing's been triaged yet either; send the user to
   `issue-triage` first rather than re-running that interview here.
2. Resolve the issue ID from the argument. If more than one ID is given, stop — this skill
   resolves one issue at a time. A fix touches code and git history, and running several at
   once against the same working tree is exactly the kind of collision worktrees exist to
   prevent; unlike triage, this isn't a fan-out job.
3. Look up the issue in the triage log. If it's there, read its entry (type, likely area,
   security flag, recommended action). If it isn't, dispatch a single `issue-triager` subagent
   for it first, the same as `issue-triage`'s single-issue mode — never move straight to
   fixing an issue nobody's actually read.
4. **A security flag stops everything here.** If the triage — existing or fresh — marked this
   `security: true`, do not proceed with a normal fix. Tell the user and point at the
   responsible-disclosure process instead. A public commit, PR, or comment referencing an
   unpatched vulnerability is a leak, not a fix.
5. Capture any notes given in the argument — how the user wants it fixed, constraints,
   anything the triage didn't know. These get folded into whichever lane runs next; they don't
   replace it.

## Routing

Use the triage's own read of size (`recommended action`, `likely area`) as the starting call,
but the real judgment stays where it already lives:

- **Looks small** — a single concern, the kind `quick-fix`'s own scope section describes →
  invoke `quick-fix` (Skill tool) with a description built from the issue's title/body, the
  triage's likely-area finding, and the user's notes. `quick-fix` still makes its own
  escalation call if the fix turns out bigger once someone's actually in the code; this skill
  doesn't override that.
- **Looks bigger, or `quick-fix` escalates** → write a first-draft `BRIEF.md` before handing
  off to `umb-explore`: a Problem section from the issue's title/body plus the triage's
  findings, the user's notes folded in as constraints or success criteria. `umb-explore`'s own
  preflight finds a `BRIEF.md` already started and refines it rather than interviewing from
  zero. From there the normal pipeline runs: `umb-explore` → `umb-design` → `umb-plan` →
  `umb-build-loop`.

Either way, this skill hands off and waits — it does not write the fix itself.

## Closing the loop

Once the fix is committed — right after commit for `quick-fix`, or once `umb-build-loop`
finishes and the PR is open for the pipeline route:

1. If the tracker is GitHub Issues in the same repo as the code, `git-workflow`'s `Closes
   #123` convention (in the commit/PR body) already closes it on merge — nothing further to
   draft, just confirm the reference actually made it in.
2. Otherwise — a separate tracker, or a different repo than the source — draft a resolution
   comment: what changed, and a link to the commit or PR. Propose a status (resolved/fixed,
   pending release, needs the reporter to confirm) using whatever states that tracker actually
   has; don't invent one it doesn't support.
3. Show the draft to the user. Only post the comment or change the status if they say to —
   same rule as `issue-triage`: a draft is the default output, posting is a separate, explicit
   step.

## Rules

- One issue per run. No fan-out, no subagent batch — this writes code, indirectly, via the
  mechanisms it calls, and that only happens on one working tree at a time.
- Never treat a security-flagged issue as a normal fix.
- Never post a tracker comment or change its status without explicit confirmation.
- Don't re-triage an issue already in the triage log — read its entry, don't redo work
  `issue-triage` already did.

## Hand off

Report which lane it took (`quick-fix` or the pipeline) and why, then whatever that lane's own
hand-off says. Once code is committed, report the draft tracker resolution and wait for
confirmation before posting it.
