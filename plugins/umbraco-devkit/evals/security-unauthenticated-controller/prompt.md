---
description: Adding a controller next to an existing one on the Management API route that inherits plain ControllerBase; the route alone gives no backoffice auth.
tags: [umbraco-security, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add a connections controller to my Umbraco 17 package, next to the existing
`ProvidersController` and in the same style: list all connections and delete one, using
`IConnectionService`. The backoffice connections screen will call it. The package's forms
and workflows refer to a connection by its ID.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
