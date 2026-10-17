---
description: Adding a slow action button to a backoffice screen; waiting state, finish feedback, and an error that says what to do next.
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["The five moments"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add a "Sync now" button to my Umbraco 17 backoffice dashboard in
`client/src/sync/sync-dashboard.element.ts`. It calls `repository.syncAll()`, which takes
10 to 30 seconds and returns `{ data, error }`. Update the element.
