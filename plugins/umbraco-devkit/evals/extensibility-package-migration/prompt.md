---
description: Creating a package's document types and starter content on install should use a PackageMigrationPlan.
tags: [umbraco-extensibility, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Reviews`) needs two document types on the
site: a "Review List" page that allows "Review" children, and "Review" with a title
(textstring), a rating (numeric) and a body (textarea). When the package is installed, create
both, plus one "Reviews" list page at the content root. Later releases will add properties
to Review on sites that already have it.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
