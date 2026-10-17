---
description: "Adding a per-member submission limit; a counter in one server's memory lets members past the limit on every other server."
tags: [umbraco-extensibility, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Feedback`) has a feedback form that members
post to `FeedbackController.Submit`. We're getting spammed. Limit each member to 5
submissions per hour; past that, return 429. The package is used on load-balanced sites.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
