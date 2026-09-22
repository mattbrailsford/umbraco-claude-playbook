---
name: issue-triage
description: >-
  Triages one issue, a range, or everything untriaged on the tracker — classifies type and
  likely code area, checks for duplicates, flags anything that looks like a security report,
  and writes a report for human review. Never labels, comments, or closes anything itself.
  More than one issue spawns one issue-triager subagent per issue, orchestrated from the main
  thread. Use when there's a backlog to work through, or a specific issue to understand before
  fixing it.
user-invocable: true
argument-hint: [issue ID | ID range | leave blank for whole tracker]
---

# issue-triage

Read the room on a bug tracker before anyone commits to fixing anything. Classifies, checks
for duplicates, points at the likely code, and flags anything that smells like a security
report — then hands back a report. It never writes back to the tracker on its own.

## Scope

- IN: fetch, classify, find the likely code area, duplicate-check, security-flag, report.
- OUT: applying labels/comments/closing issues, writing fixes, planning a feature. Once a
  triaged issue turns into real work, hand off to `umb-explore` (or `quick-fix` if it's small
  enough to skip the pipeline).

## Preflight

1. **Resolve the tracker.** Read `CLAUDE.md` for an `## Issue tracker` section (type,
   location, access method). If it's missing, run the interview below and append the section —
   don't guess a tracker or invent an API to call.
2. Note whether the tracker lives in this repo or elsewhere (a separate GitHub repo, a Jira
   project, an Azure DevOps org) — the `Location` line answers that. Every fetch uses it
   explicitly; never assume the tracker is wherever `origin` points.
3. Resolve the access method, in order of preference: an already-connected MCP server for that
   tracker type, else its CLI (`gh` for GitHub, `jira` CLI, `az boards`), else a documented
   REST call. Record whichever one actually worked in `## Issue tracker` so the next run skips
   this detection step.
4. Resolve the triage log path: `docs/triage/TRIAGE-LOG.md` by default, or whatever
   `CLAUDE.md` says under `## Issue tracker`. Read it if it exists — every issue ID already
   listed there counts as "already triaged" (whole-tracker mode skips it), and its
   title/summary lines are the history the duplicate check further down compares against.
5. Resolve which issues this run covers, from the argument:
   - One ID → that issue.
   - A range (e.g. `120-135`) → every ID in that range that still exists and is open.
   - No argument → every open issue not already in the triage log.

### Interview (only if `## Issue tracker` is missing from `CLAUDE.md`)

Ask in one batch:
1. **Tracker type** — GitHub Issues, Jira, Azure DevOps Boards, or other (name it).
2. **Location** — the repo/project/org identifier, and whether it's the same repo as the
   source code or a separate one.
3. **Access** — is there an MCP server already connected for it, or should this use the CLI or
   a token from the environment?

Append the answers to `CLAUDE.md`:
```markdown
## Issue tracker
- Type: <type>
- Location: <repo/project/org — note explicitly if separate from the source repo>
- Access: <MCP server name | CLI command | REST endpoint>
- Triage log: docs/triage/TRIAGE-LOG.md   <!-- only if the user wants a non-default path -->
```

## The dedup pre-pass (only when more than one issue is in scope)

Parallel subagents in the same batch can't see each other's output, so run one cheap,
deterministic check first, before spawning anything: pull just the title (and error
text/stack trace, if the tracker's list view shows one) for every issue in scope, and
exact- or near-exact-match them against each other and against the triage log's history.
This is a literal text comparison, not a judgment call — flag pairs, don't resolve them.
Attach the flag ("possibly a duplicate of #N") to whichever subagent prompt(s) it applies to;
the subagent still investigates and makes the final call, since a matching title or stack
trace is a hint, not a fact.

## Dispatch

**One issue in scope:** dispatch a single `issue-triager` subagent (Agent tool,
`subagent_type: issue-triager`) and wait for its report.

**More than one:** the main thread is the orchestrator. It does not fetch, classify, or judge
any issue itself — it dispatches one `issue-triager` subagent per issue and only aggregates.
Batch the dispatches (parallel Agent tool calls in one message); cap concurrency around 8–10
at a time rather than firing the whole scope at once. For a large whole-tracker run, tell the
user the issue count and the batch plan before starting — a few hundred open issues means a
few hundred subagent calls, and that's worth flagging before it runs.

Every dispatch gets: the issue ID, the tracker's type/location/access method, the repo path,
any dedup-pre-pass hint for that issue, and the relevant slice of the triage log (titles only,
not full history, to keep the prompt small).

## Aggregating and reporting

1. Collect every subagent's report.
2. Pull anything flagged as a possible security report into its own short list, named but not
   detailed in the main output — point the user at responsible disclosure instead of normal
   triage for those. Never draft a public response to one.
3. Build one combined table for everything else: issue, type, likely area, priority/urgency,
   duplicate-of (if any), recommended action, one-line why.
4. Append every triaged issue to the triage log (id, title, type, date, outcome) — this is
   what makes whole-tracker mode incremental on the next run.
5. Present the table and the security list (if non-empty) to the user. Nothing gets written
   back to the tracker — no label, comment, or close — until the user says which
   recommendations to apply.

## Rules

- Read-only against the tracker and the codebase. The only files this skill writes are the
  triage log, and, on first run only, the `## Issue tracker` section of `CLAUDE.md`.
- Never post a comment, apply a label, or close an issue without the user picking that action
  explicitly — issue by issue, or as a stated "apply all." A draft is the default output, not
  an action.
- A security-looking issue never gets the normal report treatment — flag it, name it, stop.
  Don't quote exploit detail into a shared report; route it to responsible disclosure instead.
- If the tracker is unreachable (auth, network, wrong location), stop and say so. Don't triage
  a stale cached copy or guess at an issue's content.

## Hand off

A triaged issue that turns into real work goes to `umb-explore` next (or `quick-fix` for
anything small enough to skip the pipeline) — this skill stops at "here's what I'd do," it
doesn't start building.
