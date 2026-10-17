---
description: Adding a full rebuild to a search sync; the obvious version loads every page through IContentService and looks up data types per property. From umbraco/Umbraco.Cms.Integrations#140.
tags: [umbraco-performance, should-trigger, real-bug]
# covers: ["Read published content from the cache, not the services layer"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/MyPackage.SearchSync`) pushes pages to an external search
service when they're published. Add a full rebuild: a Management API endpoint an
administrator can call that clears the search index and pushes every published page again,
with the same fields as the publish handler sends. Some sites using the package have over
50,000 pages.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
