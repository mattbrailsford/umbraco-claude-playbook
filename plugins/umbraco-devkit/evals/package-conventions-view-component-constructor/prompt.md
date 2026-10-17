---
description: "Adding a dependency to a shipped view component that sites inherit from; ViewComponents are created by ActivatorUtilities, so the new constructor needs the marker and the old one stays."
tags: [umbraco-package-conventions, should-trigger]
# covers: ["Public API backwards compatibility"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

For the next minor release of my Umbraco 17 package (`src/Umbraco.Community.Reviews`, 2.3.1
on NuGet), the reviews view component should show the product's average rating and review
count above the list. `IReviewSummaryService` already provides them. Update the view
component, its view model and the view.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
