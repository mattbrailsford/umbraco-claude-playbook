---
description: Adding a read-only provider to a read/write interface; split the interface instead of stubbing writes with NotSupportedException.
tags: [solid-principles, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package syncs product data from external providers. Add a provider for a
public RSS feed: it can list and read products, but there's no way to write or delete
anything in an RSS feed. Write the code. dotnet can't run here.
