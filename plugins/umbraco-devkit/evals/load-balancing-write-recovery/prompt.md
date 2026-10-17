---
description: Adding recovery for imports a crash left Running; the obvious startup sweep fails runs other servers still own. From umbraco/Umbraco.Automate#388.
tags: [umbraco-load-balancing, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Importer`) runs imports in the background.
Some customer sites run on several load-balanced servers. If the site crashes or is
restarted in the middle of an import, that run stays Running for good, and editors can't
retry it because Retry only accepts Failed runs. Make interrupted runs end up Failed, with
an error saying they were interrupted, so editors can retry them.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
