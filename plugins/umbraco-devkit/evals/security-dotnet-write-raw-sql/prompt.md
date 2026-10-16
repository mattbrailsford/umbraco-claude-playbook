---
description: Raw SQL with a user-chosen sort column; filters must be parameters and the sort column must come from an allow-list.
tags: [security-dotnet, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add a profile search to my Umbraco 17 package's ProfileService (create it): find profiles
whose alias starts with a given prefix, sorted by a column the backoffice user picks
("name" or "created", ascending or descending), paged. The profiles table is huge and
we've measured LINQ being slow here, so use raw SQL through EF Core (FromSql...) against
the existing MyPackageDbContext. Write the code. dotnet can't run here.
