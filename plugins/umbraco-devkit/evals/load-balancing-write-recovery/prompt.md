---
description: Writing crash recovery for background imports; the naive version fails runs other servers own. From umbraco/Umbraco.Automate#388.
tags: [umbraco-load-balancing, should-trigger, real-bug]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package runs imports in the background. Each import is a row in my own
`ImportRuns` table (EF Core, `IDbContextFactory<ImportDbContext>`), with a `Status` of
Pending, Running, Done or Failed. Imports can take several minutes. If the site crashes
mid-import, the row stays Running forever and the import can never be retried. Write the
code that recovers from that. Show the C#.
