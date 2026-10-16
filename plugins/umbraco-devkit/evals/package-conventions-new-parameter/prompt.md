---
description: A new parameter on a shipped public method needs an obsolete proxy overload with a removal version.
tags: [umbraco-package-conventions, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my Umbraco package (`src/Umbraco.Community.Items`), let callers of
`ItemService.GetItemAsync` pass the new `ItemOptions`, so they can include archived items
or skip loading tags. `ItemOptions.Default` should behave like today. Other packages call
`GetItemAsync`. Make the change on this branch; I'll port it to the v18 branch after.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
