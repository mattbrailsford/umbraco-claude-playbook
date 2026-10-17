---
description: "Adding a large CSV export that the editor downloads once it's ready; a file on one server's disk isn't there on the next request."
tags: [umbraco-extensibility, should-trigger]
# covers: []
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.FormEntries`) stores form entries in its own
table. Add a CSV export for the backoffice: one Management API endpoint starts the export
for a form and returns an id, the export runs in the background because big forms have
hundreds of thousands of entries, a second endpoint says whether it's finished, and a third
lets the editor download the file. Our larger customers run their sites load balanced.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
