---
description: "Adding a progress bar for a background import; progress held in one server's memory isn't visible from the server that answers the status request."
tags: [umbraco-extensibility, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.ProductImport`) imports products from a
supplier feed in `ProductImportJob`, a distributed background job. Editors want a progress
bar in the backoffice while an import runs: add a Management API endpoint the dashboard can
poll that returns how many products have been processed out of the total, and whether the
import is still running, and update the job so it reports progress. Sites using the package
are load balanced.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
