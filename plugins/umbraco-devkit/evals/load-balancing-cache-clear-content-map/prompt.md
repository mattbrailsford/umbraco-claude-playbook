---
description: "Keeping an in-memory redirect map built from published content up to date; clearing it from the publishing server alone leaves other servers stale."
tags: [umbraco-extensibility, should-trigger]
# covers: ["4. Cache refresher"]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Redirects`) lets editors manage redirects as
"redirect" documents (see `Models/RedirectDocumentTypes.cs`). Add the part that applies them:
middleware that runs on every front-end request and, when the path matches a redirect's
`fromPath`, redirects to its `toUrl`. Checking the published cache on every request is too
slow, so build a path-to-redirect map once and keep it in memory. When an editor publishes,
changes or unpublishes a redirect, it must apply right away. Customer sites range from a
single server to several load-balanced front-end servers.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
