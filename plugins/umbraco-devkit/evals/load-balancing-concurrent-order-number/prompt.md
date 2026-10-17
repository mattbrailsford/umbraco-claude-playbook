---
description: "Adding sequential order numbers; read-max-then-insert gives two servers the same number."
tags: [umbraco-load-balancing, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Shop`) saves orders through
`OrderService.CreateAsync`. Finance want every order to get a human-readable number when
it's created: `ORD-` followed by a running number padded to 6 digits (`ORD-000042`), with no
two orders sharing one. Add it, including the migration for the new column. Sites using the
package run on SQL Server or SQLite, and the bigger shops are load balanced.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
