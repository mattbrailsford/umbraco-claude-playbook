---
description: Routine failures (not found, invalid input) returned as a result or Attempt shape, not thrown and caught.
tags: [dotnet-best-practices, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add an UpdateBaseUrlAsync method to my Umbraco 17 package's ConnectionService. It should
reject a base URL that isn't an absolute https URL, and a connection id that doesn't exist.
Then add a Management API controller action that calls it and returns 400 or 404 for those
cases. Write the code. dotnet can't run here.
