---
description: Sending a webhook after publish once the content is served; the cache refresher notification that fits fires once per server.
tags: [umbraco-load-balancing, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.PublishHooks`) should POST to the customer's
`PublishHooks:WebhookUrl` whenever a document is published, with the document's key and
culture(s). The customer's system fetches the page from the Delivery API as soon as the
webhook arrives, so the new version must already be in Umbraco's published cache when the
webhook goes out. Some customer sites run on several load-balanced servers. Add it.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
