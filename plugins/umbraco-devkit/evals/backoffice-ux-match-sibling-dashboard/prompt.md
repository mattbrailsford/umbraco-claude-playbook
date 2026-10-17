---
description: "Adding a dashboard next to an existing one; it should follow the sibling's box, table and header-action pattern."
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["Match what's already there"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package has an orders dashboard in `client/src/orders/`. Add a customers
dashboard in `client/src/customers/customers-dashboard.element.ts` that lists customers
(name, email, number of orders) from `CustomersRepository.requestAll()` and has an
"Export" action that calls `exportCsv()`. Register it next to the orders dashboard in
`client/src/manifests.ts`.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
