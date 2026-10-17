---
description: "Linking incoming orders to a customer record found or created by email; check-then-insert creates duplicates when two servers take orders for the same customer at once."
tags: [umbraco-extensibility, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Shop`) takes orders through
`OrderService.CreateAsync`, which only stores the customer's email on the order. We want a
customer list in the backoffice, so add a `Customer` entity (email, first and last order
date, order count) and link each order to one: when an order comes in, use the customer
with that email if there is one, otherwise create them. Include the migration. Shops send
a lot of orders at sale times, and the bigger ones are load balanced.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
