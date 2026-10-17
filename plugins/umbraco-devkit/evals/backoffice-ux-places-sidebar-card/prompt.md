---
description: "Building a figures card that renders both in a wide workspace view and a narrow sidebar."
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["Every place it appears"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package shows a product's stock figures in two places, already registered in
`client/src/stock/manifests.ts`: a full workspace view, and the info sidebar of the product
workspace. Both render `<shop-stock-summary>`. Build that element in
`client/src/stock/stock-summary.element.ts`: it shows four figures side by side (in stock,
reserved, on order, sold this month) from its `summary` property, each with a label.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
