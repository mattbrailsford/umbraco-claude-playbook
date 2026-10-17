---
description: Caching settings read on every page; the obvious local cache clear on save leaves other servers on the old value.
tags: [umbraco-extensibility, should-trigger]
# covers: ["4. Cache refresher"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Announcements`) shows an announcement banner
on every page. Some customer sites run on several load-balanced servers.
`AnnouncementSettingsService.Get` hits the database on every page render.
Cache the settings in memory using Umbraco's caching, and make sure a save from the
backoffice shows on the site straight away.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
