---
description: "Telling an external indexer about published pages, next to an existing cache refresher handler that runs on every server."
tags: [umbraco-extensibility, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.SiteSearch`) should tell the customer's
search indexer (`SiteSearchOptions.IndexerUrl`) whenever a page is published or
unpublished: POST JSON with the page's key, the culture(s) and "publish" or "unpublish".
The indexer then reads the page from the Delivery API, so the new version has to be in
Umbraco's published cache by the time the POST arrives. Sites using the package run on
anything from one server to a load-balanced cluster.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
