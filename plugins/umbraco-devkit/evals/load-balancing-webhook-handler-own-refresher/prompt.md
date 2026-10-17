---
description: "Notifying an ERP when a price list changes, in a package whose own cache refresher already reacts to every change on every server."
tags: [umbraco-extensibility, should-trigger]
# covers: ["Notification handlers, not raw event subscriptions"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 pricing package (`src/Umbraco.Community.Pricing`) needs to tell the
customer's ERP whenever a price list changes: POST JSON with the price list's key and new
version to `PricingOptions.ErpWebhookUrl`, after the change is saved. The ERP integration
team also wants to be able to hook their own code onto price list changes later. Most
customers run a load-balanced setup with several servers.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
