---
name: investigate-bug
description: >-
  Finds the cause of a bug whose cause isn't known yet, in an Umbraco package or backoffice
  extension (C# and/or Lit). Pins down the symptom, reproduces it through the real entry
  point, gathers evidence from logs, the Management API, and the browser, narrows it by layer
  and by history, then tests one hypothesis at a time until the cause is proven. Reports the
  cause with its evidence and routes the fix to `quick-fix` or the `umb-*` pipeline; it never
  writes the fix itself. Given an issue ID, also drafts the issue's next state label and a
  comment for the reporter. Use for "why is this broken", "this stopped working", "find out
  what's causing X", a failing test nobody understands, or an issue triaged as needing
  investigation.
user-invocable: true
argument-hint: <what's going wrong, or an issue ID>
---

# investigate-bug

A fix aimed at a guessed cause often moves the bug instead of removing it. This skill finds
the cause first and proves it, so the fix lane (`quick-fix` or the pipeline) starts from a
known cause and a repro, not a theory.

## Scope

- IN: reproduce, gather evidence, narrow, prove the cause, find other places with the same
  cause, write the report, update the issue on the user's yes, route the fix.
- OUT: the fix itself, and any lasting change to the project's code. Scratch work (a
  throwaway test, a script, temporary logging) is allowed, but it's removed before the
  hand-off. Investigation leaves `git status` as it found it.

## Argument

`$ARGUMENTS` is the symptom in the user's words, or an issue ID. For an issue ID, read the
issue, and use this session's `issue-triage` report for it if there is one.

## 1. Pin down the symptom

Before reading code, get these. Ask for what's missing, one question at a time:

- **Steps.** What the user did, in order, and where (backoffice screen, front-end page, API
  call, background job).
- **Expected and actual.** What should have happened, and what did instead, word for word
  for any error.
- **Where it runs.** CMS version, package version, database provider, browser if it's
  backoffice, single server or load-balanced.
- **When it started.** Always, or since an upgrade, a deploy, or a config change.

A vague symptom ("saving is broken") gets one round of questions, not a guess.

**Security check.** If the symptom matches what `issue-triage`'s Security reports section
counts as a vulnerability, stop and follow that section.

## 2. Reproduce it

Reproduce through the real entry point, in the first way the project supports, using the
same order as `umb-build-loop`'s "Smoke the real entry point" step: an e2e test, the demo
site (drive the backoffice, or send the real Management API request), or an integration test
that boots Umbraco.

- Write the repro down as exact steps or a scratch test. It goes in the report.
- **Can't reproduce?** Check the "Where it runs" details against your setup and change one
  thing at a time toward theirs (database provider, version, config, data). If it still
  won't reproduce, stop and report what you tried and what you'd need from the reporter. An
  unreproduced bug doesn't get a fix.

## 3. Gather evidence

Look before theorising. Collect what the failure leaves behind:

- **Server log.** `umbraco/Logs/UmbracoTraceLog.<machine>.<date>.json` in the site folder,
  one JSON object per line (Serilog's compact format). Search it for errors and warnings
  around the repro, and for the package's own `SourceContext`. The backoffice shows the same
  log under Settings › Log Viewer.
- **The API response.** For a backoffice bug, the Management API request behind the screen:
  status code and body (a `ProblemDetails` body names the error). Read it from the browser's
  network panel or send it yourself.
- **The browser.** Console errors and failed network requests, read with Playwright or the
  browser tools. A backoffice extension that never loads usually shows here first.
- **The data.** If the symptom is wrong data, read the rows themselves on the database the
  user runs.

Quote what you find (log line, status and body, console message) in the report.

## 4. Narrow it down

Cut the search space before reading code in depth. Use whichever of these splits fits:

- **Backend or frontend.** Does the Management API return the right thing? If yes, the bug
  is in the client. If no, it's on the server.
- **Package or CMS.** Does it happen without the package, on a plain Umbraco site at the same
  version? If yes, read the CMS at that tag (`umbraco-cms-source`) and search its issues
  (`gh search issues --repo umbraco/Umbraco-CMS "<error text>"`). A CMS bug gets reported
  upstream and worked around in the package, not patched inside the package.
- **Which change.** If it used to work, find the change that broke it. Read `git log` for the
  area first. If that doesn't find it and the repro can run as a command, use `git bisect
  run` with it. Bisect checks out old commits, so it needs a clean working tree: **ask the
  user before starting**, and always end with `git bisect reset`.
- **Which data or config.** If it only happens for some content, users, or settings, compare
  one that fails with one that works and change one difference at a time.

`references/umbraco-suspects.md` lists where Umbraco bugs often hide. Check it once the
search space is small, not before.

## 5. Prove the cause

Work one hypothesis at a time:

1. State it as a cause that would explain every piece of evidence so far.
2. Name a check that would prove it wrong: a log line that should or shouldn't appear, a
   value read in the debugger, a scratch test, a one-line temporary change.
3. Run the check and record the result, whichever way it goes.

A cause is proven when changing it changes the symptom: the scratch test fails with the
cause in place and passes with it removed, or the repro stops failing. "This code looks
wrong" isn't proof. If the evidence contradicts every hypothesis, go back to step 3 for more
evidence rather than inventing a fourth.

Then name the cause, not just the line (a missing permission check, a scope that's never
completed, an alias two extensions share), and grep for other places with the same cause.

Remove every scratch change, end any bisect, and check `git status` matches the start.

## 6. Report and route

Write the report in chat:

```markdown
**Symptom:** <one line>
**Repro:** <exact steps, or the scratch test's code>
**Cause:** <the cause, at file:line> (<CMS tag or commit, if relevant>)
**Evidence:** <the check that proved it, and its result>
**Same cause elsewhere:** <file:line per place, or "none found">
**Suggested fix:** <one or two lines, and the test that should guard it>
**Route:** <quick-fix | umb-explore | upstream CMS issue>, because <one line>
```

**If the argument was an issue ID**, draft the issue's update, following `issue-triage`'s
State labels and Tracker comments sections:

- Cause proven → `state/ready`. The reporter part says it's confirmed and queued; `Notes for
  the fix` carries the repro, cause, and same-cause places from the report.
- Can't reproduce, and only the reporter can close the gap → `state/needs-info`, asking for
  what step 2 found missing.
- Not a bug (works as designed, or a usage mistake) → a close, saying why.
- Cause is in the CMS and no package workaround is planned → `state/blocked`, linking the
  upstream issue once the user has posted it.

Show the label and comment to the user and apply them only on their yes.

Then route it. **If `issue-resolve` called this skill and the cause is proven**, skip the
update above and this list: hand the report back and let `issue-resolve` pick and start the
lane. It posts one comment covering both the findings and the start of the fix. With no
proven cause, draft the update above as normal and hand the report back.
**If the argument was an issue ID** and nothing called this skill, offer `issue-resolve` with
that ID and the report, so the fix gets tracked on the issue. Otherwise:

- **Small fix** (one concern, the size `quick-fix` describes): offer `quick-fix`, passing it
  the cause, the repro, and the places with the same cause.
- **Bigger fix**, or a shared fix across several places: offer `umb-explore`, with the
  report as its starting material.
- **CMS bug:** draft an issue for `umbraco/Umbraco-CMS` with the minimal repro on a plain
  site. Show it to the user; never post it yourself. Route any package workaround as above.

If the cause is a mistake a future `builder` would likely repeat, offer to save it to
`.claude/memory/` as a `gotcha` (see `.claude/memory/README.md` for the format).

## Rules

- No fix before a proven cause. A guessed fix gets reported as a guess, not shipped.
- One bug per run.
- Evidence beats memory. Quote the log line, response, or source line behind every claim.
- Never commit from this skill. The only tracker write is the label and comment from step
  6, and only on the user's yes.

## Hand off

The report from step 6. Called from `issue-resolve`: stop there. Otherwise: the route you'd
take and a one-line question asking whether to start it.
