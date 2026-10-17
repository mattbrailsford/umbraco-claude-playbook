---
description: "Formatting dates in a backoffice element with a library the backoffice already ships (luxon); importing it from npm bundles a second copy."
tags: [umbraco-backoffice-conventions, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

The job runs table in my Umbraco 17 package's backoffice client
(`src/Umbraco.Community.JobBoard/Client/src/runs/job-runs-table.element.ts`) shows raw ISO
timestamps. Make the Started column show a relative time ("3 hours ago") with the full date
and time in the editor's local time zone as a tooltip, and the Duration column show a short
duration ("4m 12s"), or "running" while there's no finish time. I've added luxon to
package.json for the date handling.

npm can't run here; just make the code change.
