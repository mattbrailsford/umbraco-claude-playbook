---
description: Drafting a reply to an issue reporter should load plain-writing.
tags: [plain-writing, should-trigger]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

Draft a reply to the person who opened issue #212 on my Umbraco package ("Stats dashboard
shows wrong totals"). The cause: the dashboard counted unpublished nodes twice when a page
had both a draft and a published version. It's fixed in 4.1.0, released today; they need to
update the NuGet package and restart the site. Reply with the comment text.
