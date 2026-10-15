---
description: A backend EF Core raw SQL question belongs to security-dotnet, not security-lit.
tags: [security-lit, should-not-trigger]
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

Is this EF Core call in my Umbraco package safe? Keep it short.

```csharp
var rows = await db.Profiles
    .FromSqlRaw($"SELECT * FROM MyPackage_Profile WHERE Alias = '{alias}'")
    .ToListAsync();
```
