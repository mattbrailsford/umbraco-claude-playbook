---
description: Building a backoffice dashboard that lists items and links each to a content page; picker not select, empty state, loading state, UUI tokens.
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["Choosing things: picker, not select", "The five moments"]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Build the dashboard element for my Umbraco 17 backoffice extension at
`client/src/connections/connections-dashboard.element.ts`. It lists the package's
connections (name, provider, and the content page each one links to) and lets an editor
add a connection: a name, a provider (one of "mailchimp", "brevo", "klaviyo") and the
content page it links to. Use the repository in `client/src/connections/repository.ts`.
Don't register a manifest; just the element.
