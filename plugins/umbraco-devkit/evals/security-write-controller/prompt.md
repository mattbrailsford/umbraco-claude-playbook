---
description: Writing a Management API controller; deletes need a stricter, registered policy on top of backoffice access.
tags: [umbraco-security, should-trigger]
# covers: ["Management API controllers"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add a Management API controller to my Umbraco 17 package for connections: list them,
create one, and delete one, using the existing IConnectionService. The backoffice
connections screen will call it. The package's forms and workflows refer to a connection by
its ID.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
