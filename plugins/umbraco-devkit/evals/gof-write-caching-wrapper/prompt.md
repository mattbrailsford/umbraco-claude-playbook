---
description: Adding caching to a client without changing it or its callers; a sealed decorator over the same interface, wired in DI.
tags: [gof-patterns, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

The PIM API behind IItemClient is slow and rate-limited. Cache GetAsync results for five
minutes in my Umbraco 17 package. ItemSyncService must keep getting fresh data, though,
since its whole job is refreshing. Write the code. dotnet can't run here.
