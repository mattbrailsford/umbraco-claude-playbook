---
description: A new parameter on a shipped public method needs an obsolete proxy overload with a removal version.
tags: [umbraco-package-conventions, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco package supports Umbraco 17 and 18, on one branch per major. It ships this public
class, and other packages call it:

```csharp
public class ItemService
{
    public Task<Item?> GetItemAsync(Guid id) { /* ... */ }
}
```

I want callers to be able to pass an `ItemOptions` (it has a sensible `ItemOptions.Default`).
How should I add it? Show the code.
