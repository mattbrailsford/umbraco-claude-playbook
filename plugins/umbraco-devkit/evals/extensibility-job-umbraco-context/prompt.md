---
description: "Reusing content lookup code from a recurring job; there is no UmbracoContext outside a request. From umbraco/Umbraco.AI (175a9529d)."
tags: [umbraco-extensibility, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.StockSync`) has an `OutOfStockFinder` that the
backoffice report uses. Add a nightly background job that uses it to find out-of-stock
products and emails the list, with each product's absolute URL, to
`StockSyncOptions.ReportEmail` through Umbraco's `IEmailSender`. Products root is
`StockSyncOptions.ProductsRootKey`.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
