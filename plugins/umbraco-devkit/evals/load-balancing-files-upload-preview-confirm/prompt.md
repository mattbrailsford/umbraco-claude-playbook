---
description: "A two-step backoffice upload (preview, then confirm); a file saved to a folder of the package's own on one server isn't there when the confirm request lands on another."
tags: [umbraco-load-balancing, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Redirects`) manages redirects. Editors want
to bulk-import them from a CSV: in the backoffice they pick the file, the package shows a
preview of the rows it found (and any rows it can't read), and only when they click
Confirm are the redirects saved through `RedirectService.AddAsync`. Add the Management API
endpoints for the upload-and-preview step and the confirm step. CSVs can be tens of
megabytes. Sites using the package are often load balanced.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
