---
description: "Building a details panel next to a card that already renders server-rendered rich text with raw unsafeHTML; editor rich text needs sanitizing even from the package's own API."
tags: [umbraco-security, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17.6 product picker extension (`client/`) has a hover preview card for
products. Add a fuller details panel, `product-picker-details-panel`, in
`client/src/products/product-details-panel.element.ts`, for when an editor clicks a product:
name, SKU and price, then the description and the shipping notes, both formatted like on
the card. Use `ProductDetailsDataSource`. Just the element, no manifest.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
