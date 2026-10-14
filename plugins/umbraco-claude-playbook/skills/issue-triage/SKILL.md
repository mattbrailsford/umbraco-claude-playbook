---
name: issue-triage
description: >-
  Triages one issue, a range, or everything untriaged on the tracker — classifies type and
  likely code area, checks for duplicates, flags anything that looks like a security report,
  and writes a report for human review. Tracks triage state with `state/*` labels on the
  tracker itself and keeps the reporter in the loop with a plain-language comment, both
  applied only once the user approves; keeps no log of its own.
  More than one issue spawns one issue-triager subagent per issue, orchestrated from the main
  thread. Use when there's a backlog to work through, or a specific issue to classify before
  deciding whether to act on it. Proving a bug's cause is `investigate-bug`'s job, not this one.
  Owns the playbook's state labels, its tracker comment format, and its rule for handling
  security reports.
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
  draft a comment for the reporter, and apply the state labels, comments, or closes the user
  approves.
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
   labels` line, ask just the interview's state-labels question and add the line. If the
   mapping has no entry for one of the states, ask about just that state.
5. Resolve which issues this run covers, from the argument:
   - One ID → that issue, whatever its labels. Naming an issue means re-triage it.
   - A range (e.g. `120-135`) → every ID in that range that still exists and is open.
   - No argument → every open issue with no state label, plus:
     - every `state/needs-info` issue the reporter has replied to since the label went on,
       or that has gone quiet for longer than the needs-info timeout;
     - every `state/blocked` issue whose blocker has since closed.

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
- Needs-info timeout: 30 days
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
any dedup-pre-pass hint for that issue, why it's back if it already had a state label (a
reply, the needs-info timeout, or a closed blocker), the "What counts" list from Security reports
below, the "Which state" rules from State labels, and the Tracker comments section. The triager searches the tracker itself, open and closed, for earlier duplicates.

## Aggregating and reporting

1. Collect every subagent's report.
2. Pull anything flagged as a possible security report into its own short list, handled as
   Security reports below says.
3. Build one combined table for everything else: issue, type, likely area, priority/urgency,
   duplicate-of (if any), recommended action, one-line why (written following
   `plain-writing`).
4. Next to each recommended action, show the tracker write it maps to (State labels below):
   the label or close, and the comment the triager drafted.
5. Present the table and the security list (if non-empty) to the user. Nothing gets written
   back to the tracker until the user says which recommendations to apply. Then apply exactly
   those, and report what was written.

## State labels

The tracker holds triage state, so there's no separate log to commit or keep in sync. An open
issue with no state label is untriaged.

| Label | Means | Set by |
|---|---|---|
| `state/needs-investigation` | Looks real, but nobody has proven it yet | `issue-triage` |
| `state/needs-info` | Waiting on the reporter for detail only they can give | `issue-triage`, `investigate-bug` |
| `state/needs-decision` | Clear, but waiting on a maintainer to agree to it | `issue-triage` |
| `state/blocked` | Can't be fixed here until something outside the project changes | `issue-triage`, `investigate-bug` |
| `state/ready` | Verified and ready to fix | `issue-triage`, `investigate-bug` |
| `state/in-progress` | A fix lane has started | `issue-resolve` |

**Which state.** Pick the first that fits:

1. `state/needs-info` only when the missing piece is something only the reporter can give:
   their steps, versions, setup, data, or what they expected. Don't use it for anything that
   reading the code or trying a repro could answer. That's investigation work, not the
   reporter's.
2. `state/blocked` when the fix can't happen in this project until something outside it
   changes: a CMS bug with no package workaround planned, or a dependency's release. Link
   what it's waiting on. If a workaround in the package is planned, it isn't blocked.
3. `state/needs-decision` for a feature request, or a change to how something is meant to
   work, that's clear enough to plan but that nobody has agreed to do. Triage doesn't make
   that call. The user can make it while approving the report: yes means `state/ready`, no
   means a close as not planned. The label is for when they don't decide yet.
4. `state/ready` only when there's nothing left to prove or decide. A bug is ready once
   `investigate-bug` has proven its cause, or when the report and the code together leave no
   doubt (a wrong label, a broken link, an error message pointing at the exact line). A
   feature request is ready once it's been agreed and has enough detail to plan.
5. `state/needs-investigation` for any other real-looking bug. When in doubt between this and
   `state/ready`, pick this. `investigate-bug` moves it on: to `state/ready` once the cause
   is proven, to `state/needs-info` if only the reporter can fill a gap, or to a close if it
   isn't a bug.

- An issue carries one state label at a time. Setting one removes the others.
- Duplicates and issues to close don't get a label. Close them with the tracker's own reason
  (duplicate, not planned) where it has one, plus a comment naming the duplicate or the why.
- Every label change and close gets a drafted comment, as Tracker comments below says.
- A `state/needs-info` issue with no reply from the reporter for longer than the
  `Needs-info timeout` in `## Issue tracker` (30 days if it isn't set) gets a drafted close
  as not planned.
- A fixed issue leaves the label set through closing. The close is the record.
- Use the label names recorded in `## Issue tracker` when the project maps these onto its own.
  Never invent a label the tracker doesn't have; create one only with the user's yes.

## Tracker comments

This section is the playbook's one statement of how to write to an issue. `issue-triager`,
`investigate-bug`, and `issue-resolve` all point here.

Triage is also how the reporter hears back. Every label change or close gets one comment,
drafted for the user to approve, with up to two parts, in this order:

1. **For the reporter.** Always present. Written following `plain-writing`, for someone who
   uses the package but has never seen its source. No file paths, class names, or stack
   frames unless the reporter used them first. Say what was understood, what happens next,
   and what's needed from them, if anything. Thank them where it fits. Never promise a fix
   date or a release.
2. **Notes for the fix.** Only when there's something technical worth keeping: the likely
   code area, the repro, the proven cause, related issues. Fold it away where the tracker
   can, so the reporter sees one line they can skip: on GitHub, a `<details>` block with
   `<summary>Notes for the fix</summary>` and a blank line after it, so the Markdown inside
   still renders. Where the tracker has no collapsible block, use a `Notes for the fix`
   heading. This is what whoever picks the issue up reads first; without it, the findings
   are lost when the chat ends.

What the reporter part says, by outcome:

- `state/needs-info`: exactly what's missing and why it's needed, asked as questions they can
  answer without the code (steps, versions, a screenshot, a log message and where to find
  it).
- `state/needs-investigation`: it's been read and will be looked into, but isn't confirmed as a
  bug yet.
- `state/needs-decision`: the request is understood and waiting on a maintainer's decision.
  Don't hint at the answer here; the suggestion goes in the notes.
- `state/blocked`: what it's waiting on, with a link, and that it moves once that's fixed.
- `state/ready`: it's confirmed, what was found in plain terms, and that it's queued for a fix.
- Duplicate: a link to the earlier issue to follow instead.
- Close: why, kindly. For a support question, answer it or point to the docs or forum.
- Needs-info timeout close: there was no reply, so it's closed for now, and replying with
  the detail will reopen it.
- `state/in-progress` and the fix landing: drafted by `issue-resolve`, in the same two parts.

For `state/needs-decision`, the second part is titled `Notes for the decision` instead, and
holds what a maintainer needs to say yes or no:

- **Need:** what the reporter is trying to do, which may differ from the feature they asked
  for.
- **Demand:** linked duplicates and related issues, and their reaction counts.
- **Today:** any workaround, setting, or extension point that already gets close.
- **Already covered:** whether the CMS or another package does this.
- **Size:** small, medium, or large, with the code area it would touch, backed by a search
  of the code.
- **Risks:** a breaking change, new public API to maintain, work on each supported CMS
  major, a performance cost.
- **Other ways:** a smaller or different way to meet the need, such as an extension point.
- **Questions first:** anything to settle before it could be planned.
- **Suggestion:** do it, do another way, or don't, with the one or two reasons that weigh
  most. Label it as a suggestion; the maintainer decides. Word a "don't" kindly, since the
  reporter can read it.

The notes are public even when folded, so leave out roadmap, commercial, or customer detail.

A security report never gets a comment (Security reports below).

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
picks `quick-fix` or the pipeline, and drafts the tracker reply once the fix lands. A
`state/needs-investigation` issue can go to `investigate-bug` first instead, to prove it
before anyone commits to a fix. This skill stops at "here's what I'd do," it doesn't start
building.
