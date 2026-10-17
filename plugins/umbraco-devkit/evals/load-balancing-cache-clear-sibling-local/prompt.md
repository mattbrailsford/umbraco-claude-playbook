---
description: "Caching shipping zones the same way as an existing service that clears its cache only on the local server."
tags: [umbraco-extensibility, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 shipping package (`src/Umbraco.Community.Shipping`) reads the shipping zones
from the database on every basket and checkout page. Cache them the same way
`CurrencyRatesService` caches currency rates, so editors' changes to zones still show up
straight away. Some of the shops using it run on several load-balanced servers.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
