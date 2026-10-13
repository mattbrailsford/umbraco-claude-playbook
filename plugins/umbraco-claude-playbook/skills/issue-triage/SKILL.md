---
name: issue-triage
description: >-
  Triages one issue, a range, or everything untriaged on the tracker — classifies type and
  likely code area, checks for duplicates, flags anything that looks like a security report,
  and writes a report for human review. Tracks triage state with `state/*` labels on the
  tracker itself, applied only once the user approves; keeps no log of its own.
  More than one issue spawns one issue-triager subagent per issue, orchestrated from the main
  thread. Use when there's a backlog to work through, or a specific issue to classify before
  deciding whether to act on it. Proving a bug's cause is `investigate-bug`'s job, not this one.
  Owns the playbook's state labels and its rule for handling security reports.
user-invocable: true
argument-hint: [issue ID | ID range | leave blank for whole tracker]
---

# issue-triage

Read the room on a bug tracker before anyone commits to fixing anything. Classifies, checks
for duplicates, points at the likely code, and flags anything that smells like a security
report — then hands back a report. The tracker is the only record of what's been triaged,
and nothing is written to it until the user says so.

## Scope

- IN: fetch, classify, find the likely code area, duplicate-check, security-flag, report,
  and apply the state labels, comments, or closes the user approves.
- OUT: any tracker write the user hasn't approved, proving a bug's cause, writing fixes,
  planning a feature. Once a triaged issue turns into real work, hand off to `issue-resolve`.

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
4. Resolve the state label names: the defaults in State labels below, or the mapping
   `CLAUDE.md` records under `## Issue tracker`. If that section exists but has no `State
   labels` line, ask just the interview's state-labels question and add the line.
5. Resolve which issues this run covers, from the argument:
   - One ID → that issue, whatever its labels. Naming an issue means re-triage it.
   - A range (e.g. `120-135`) → every ID in that range that still exists and is open.
   - No argument → every open issue with no state label, plus every `state/needs-info` issue
     the reporter has replied to since the label went on.

### Interview (only if `## Issue tracker` is missing from `CLAUDE.md`)

Ask in one batch:
1. **Tracker type** — GitHub Issues, Jira, Azure DevOps Boards, or other (name it).
2. **Location** — the repo/project/org identifier, and whether it's the same repo as the
   source code or a separate one.
3. **Access** — is there an MCP server already connected for it, or should this use the CLI or
   a token from the environment?
4. **State labels** — does the tracker already have labels or tags for triage state? If so,
   map them onto the states in State labels below. If not, may this create the default
   `state/*` ones? Creating them is a tracker write, so it waits for a yes.

Append the answers to `CLAUDE.md`:
```markdown
## Issue tracker
- Type: <type>
- Location: <repo/project/org — note explicitly if separate from the source repo>
- Access: <MCP server name | CLI command | REST endpoint>
- State labels: default   <!-- or a mapping, e.g. ready → status/accepted -->
```

## The dedup pre-pass (only when more than one issue is in scope)

Parallel subagents in the same batch can't see each other's output, so run one cheap,
deterministic check first, before spawning anything: pull just the title (and error
text/stack trace, if the tracker's list view shows one) for every issue in scope, and
exact- or near-exact-match them against each other.
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
any dedup-pre-pass hint for that issue, and the "What counts" list from Security reports
below. The triager searches the tracker itself, open and closed, for earlier duplicates.

## Aggregating and reporting

1. Collect every subagent's report.
2. Pull anything flagged as a possible security report into its own short list, handled as
   Security reports below says.
3. Build one combined table for everything else: issue, type, likely area, priority/urgency,
   duplicate-of (if any), recommended action, one-line why (written following
   `plain-writing`).
4. Next to each recommended action, show the tracker write it maps to (State labels below):
   the label, any drafted comment, or a close.
5. Present the table and the security list (if non-empty) to the user. Nothing gets written
   back to the tracker until the user says which recommendations to apply. Then apply exactly
   those, and report what was written.

## State labels

The tracker holds triage state, so there's no separate log to commit or keep in sync. An open
issue with no state label is untriaged.

| Label | Means | Set by |
|---|---|---|
| `state/ready` | Triaged and worth fixing, with enough detail to start | `issue-triage` |
| `state/needs-info` | Waiting on the reporter for a repro or detail | `issue-triage` |
| `state/in-progress` | A fix lane has started | `issue-resolve` |

- An issue carries one state label at a time. Setting one removes the others.
- Duplicates and issues to close don't get a label. Close them with the tracker's own reason
  (duplicate, not planned) where it has one, plus a comment naming the duplicate or the why.
- A `state/needs-info` issue also gets a drafted comment asking for exactly what's missing.
- A fixed issue leaves the label set through closing. The close is the record.
- Use the label names recorded in `## Issue tracker` when the project maps these onto its own.
  Never invent a label the tracker doesn't have; create one only with the user's yes.

## Security reports

This section is the playbook's one statement of this rule. `issue-triager`, `issue-resolve`,
and `investigate-bug` all point here.

**What counts.** An issue or symptom that reads like a real vulnerability: auth bypass, an
action allowed without permission, data shown to someone who shouldn't see it, injection or
injected script running, secret or credential exposure, remote code execution, a CVE
reference, or similar.

**What to do.**

- Stop. Don't triage, investigate, or fix it as normal work.
- Tell the user, naming the issue but not detailing it, and point them at the
  responsible-disclosure process.
- Never put it in a public commit, PR, comment, or issue, and never draft a public response
  to it. A public reference to an unpatched vulnerability is a leak, not a fix.
- Never quote exploit detail into a report, log, or plan file.
- Never label it, in this tracker or any other public place, and never record it in a file.
  The chat is the only place it appears. With no label, it stays untriaged and gets flagged
  again on the next run, which is the reminder that it's still open.

## Rules

- Read-only against the codebase. The only file this skill writes is, on first run only, the
  `## Issue tracker` section of `CLAUDE.md`. The tracker is written to only as the next rule
  allows.
- Never post a comment, apply a label, or close an issue without the user picking that action
  explicitly — issue by issue, or as a stated "apply all." A draft is the default output, not
  an action.
- If the tracker is unreachable (auth, network, wrong location), stop and say so. Don't triage
  a stale cached copy or guess at an issue's content.

## Hand off

A triaged issue that turns into real work goes to `issue-resolve` next, with its ID. That
picks `quick-fix` or the pipeline, and drafts the tracker reply once the fix lands. This skill
stops at "here's what I'd do," it doesn't start building.
