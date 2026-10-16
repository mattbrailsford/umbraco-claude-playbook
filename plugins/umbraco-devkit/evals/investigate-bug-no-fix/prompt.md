---
description: investigate-bug proves the cause with evidence and never writes the fix.
tags: [investigate-bug, workflow]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Use the investigate-bug skill. Symptom: the stats dashboard in my Umbraco package shows a
higher "pages" total than the content tree has. On a test site with 3 pages, where one page
has an unpublished draft on top of its published version, the dashboard says 4. Git,
dotnet and the site can't run here; work from the code.
