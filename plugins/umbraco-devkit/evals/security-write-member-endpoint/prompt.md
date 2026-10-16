---
description: A cookie-authenticated endpoint outside the Management API needs its own antiforgery or origin check.
tags: [umbraco-security, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package needs an endpoint the public website calls when a logged-in member
favourites a page: POST with the page key, saved to a new Favorites table for that member.
Members log in with Umbraco's normal member login (cookie). It's called from front-end
JavaScript with fetch. It's not a backoffice thing, so don't use the Management API. Write
the endpoint and the storage. dotnet can't run here.
