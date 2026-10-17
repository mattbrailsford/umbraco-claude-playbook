---
description: Building a delete confirmation from a localized term with markup; wrapping localize.string in unsafeHTML inserts the item name unescaped. From umbraco/Umbraco-CMS#22731 (GHSA-vr9v-27gg-qgx4).
tags: [umbraco-security, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my Umbraco 17.6 backoffice extension (`client/`), finish the delete confirmation modal
in `client/src/items/modals/delete-item-modal.element.ts`. Show the
`myPackage_confirmDelete` term with the item's name, with the name in bold as the term
says, a Cancel button that rejects the modal, and a red Delete button that submits it.
Item names are typed in by editors.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
