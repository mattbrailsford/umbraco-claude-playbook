---
description: A new repository should stay internal to its owning service; the controller depends on the service only.
tags: [design-principles, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package needs newsletter subscriptions: an EF Core entity in the existing
MyPackageDbContext, the data access, the business logic (one active subscription per email,
unsubscribe), and a Management API controller to list, add and remove them. Write the code.
dotnet can't run here.
