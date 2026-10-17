---
description: "Package migration that grants the admin group a section; the admin group's int id isn't 1 on every site. From umbraco/Umbraco.AI (0ffaf8db2)."
tags: [umbraco-extensibility, should-trigger, real-bug]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.StockSync`) adds a backoffice section,
`StockSync.Section`. Right now nobody can see it until someone ticks it on a user group by
hand. Add a step to the package's migration plan that gives the Administrators group access
to the section when the package installs or upgrades.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
