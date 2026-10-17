---
description: "Speeding up an endpoint with Task.WhenAll; Umbraco scopes are tracked per async flow, so parallel scoped work crashes. From umbraco/Umbraco.AI (07f2a9d0b)."
tags: [umbraco-performance, should-trigger, real-bug]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

The review summary panel in my Umbraco 17 package (`src/Umbraco.Community.ReviewNotes`)
takes about 600 ms to load. `ReviewSummaryService.GetAsync` makes four calls one after
another, and none of them depends on another's result except the null check on the
document. Make it faster by running the independent calls at the same time.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
