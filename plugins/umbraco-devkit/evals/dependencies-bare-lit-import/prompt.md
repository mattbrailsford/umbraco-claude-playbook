---
description: A backoffice extension must use the backoffice's Lit, not bundle its own copy.
tags: [umbraco-dependencies, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 backoffice extension is built with Vite and TypeScript. I added `lit` to
`dependencies` in its `package.json`, and my elements do this:

```ts
import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
```

My Vite config's `build.rollupOptions.external` is `[/^@umbraco/]`. Is this set up right?
