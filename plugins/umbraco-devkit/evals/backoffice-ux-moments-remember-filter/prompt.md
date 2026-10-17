---
description: "Adding a status filter and sort to a list dashboard; does the editor's choice survive coming back?"
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["The five moments"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package's campaigns dashboard (`client/src/campaigns/campaigns-dashboard.element.ts`)
lists every campaign. Editors with hundreds of campaigns want to narrow it down: add a status
filter (All, Draft, Scheduled, Sent) and a sort order (newest first, oldest first, name A–Z).

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
