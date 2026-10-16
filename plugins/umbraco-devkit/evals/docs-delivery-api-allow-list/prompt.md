---
description: Umbraco 17.2+ added AllowedContentTypeAliases for the Delivery API; memory from before that only knows the disallow list.
tags: [umbraco-docs, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, WebFetch]
---

Our Umbraco 17.6 site (src/MySite) has the Delivery API turned on. Configure it so only the
"article" and "author" document types are exposed, and any document type we add later stays
hidden unless someone adds it on purpose. Make the change in appsettings.json. dotnet can't
run here.
