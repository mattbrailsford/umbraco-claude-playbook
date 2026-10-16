---
description: Adding a dependency to a shipped public controller keeps the old constructor and marks the new one for ActivatorUtilities.
tags: [umbraco-package-conventions, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Items`) is on NuGet at 3.1.0. For 3.2.0,
`ItemController.Delete` should ask the new `IItemPermissionChecker` whether the current
backoffice user may delete the item, and return 403 if not. Some customer sites subclass
`ItemController`.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
