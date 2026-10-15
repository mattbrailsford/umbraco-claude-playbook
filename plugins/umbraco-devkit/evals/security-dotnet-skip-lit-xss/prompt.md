---
description: A frontend-only Lit XSS question belongs to security-lit, not security-dotnet.
tags: [security-dotnet, should-not-trigger]
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

In my Umbraco backoffice Lit element, is ``html`<p>${this.userComment}</p>` `` safe against
XSS if userComment is text a member typed in? Keep it short.
