---
description: Adding a dependency to a shipped public controller keeps the old constructor and marks the new one for ActivatorUtilities.
tags: [umbraco-package-conventions, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package ships a public Management API controller. Some sites subclass it, so
they call its constructor themselves:

```csharp
public class ItemController : ManagementApiControllerBase
{
    private readonly IItemService _itemService;

    public ItemController(IItemService itemService)
        => _itemService = itemService;
}
```

The next minor release needs an `IItemPermissionChecker` in this controller too. How should I
change the constructor without breaking anyone? Show the code.
