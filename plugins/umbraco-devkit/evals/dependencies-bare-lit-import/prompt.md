---
description: "Adding an element to a client that already imports bare lit; the backoffice provides Lit, so a bare import bundles a second copy."
tags: [umbraco-dependencies, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 backoffice extension is in `client/`. Add an `order-status-badge` element in
`client/src/elements/order-status-badge.element.ts`: it takes a `status` property
("pending", "paid", "shipped" or "cancelled") and shows it as a UUI tag in a matching
colour. Export it from `index.ts`.

npm can't run here; just write the code.
