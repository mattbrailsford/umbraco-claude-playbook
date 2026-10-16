---
description: "Updating one property through IContentEditingService; any property left out of the update is cleared. From umbraco/Umbraco.AI (2db917884, 412edf698)."
tags: [umbraco-cms-source, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Implement `SetStockLevelAsync` in my Umbraco 17 package
(`src/Umbraco.Community.StockSync/Services/ProductDocumentService.cs`). The warehouse feed
calls it for each product when stock changes. Keep using `IContentEditingService` for the
save, and save as the Umbraco super user.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
