---
description: "Queuing a search-engine ping with the page's absolute URL on publish; the queued work runs after the request, and behind a load balancer the request host can be internal."
tags: [umbraco-extensibility, should-trigger]
# covers: []
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.IndexNow`) should tell search engines about
changed pages using IndexNow. When a page is published, send its absolute URL to
`IndexNowClient.SubmitAsync`. Don't slow down publishing: queue the URLs and send them from
a background job every minute, in one batch. Sites using the package run behind a load
balancer, and most have more than one domain.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
