---
description: Writing a Management API controller; deletes need a stricter, registered policy on top of backoffice access.
tags: [security-dotnet, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add a Management API controller to my Umbraco 17 package for connections: list them,
create one, and delete one, using the existing IConnectionService. Connections hold the
settings the package uses to call external providers, so deleting one breaks whatever
uses it. Write the code. dotnet can't run here.
