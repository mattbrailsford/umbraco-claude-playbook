---
description: Writing a backoffice element; Lit must come from the backoffice's external path, not a bare import that bundles a second copy.
tags: [umbraco-dependencies, should-trigger]
# covers: ["Locked to the CMS"]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Add a Lit element to my backoffice client at `src/MyPackage/Client/src/tag-list.element.ts`.
It takes a `tags: string[]` property and renders them as a list with `repeat`, giving the
first tag a `first` class with `classMap`. Register nothing yet, just the element.
