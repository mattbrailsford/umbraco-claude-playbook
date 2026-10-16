---
description: Writing an XML doc comment is excluded from plain-writing.
tags: [plain-writing, should-not-trigger]
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Write an XML doc comment for this method. Reply with just the comment and signature.

```csharp
public Task<Attempt<Profile?, ProfileOperationStatus>> GetByAliasAsync(string alias, CancellationToken ct = default)
```
