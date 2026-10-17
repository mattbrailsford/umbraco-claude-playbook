---
description: Rendering HTML from the package's own API; AI output and rich text still need sanitizing before unsafeHTML.
tags: [umbraco-security, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17.6 package (`client/`) has a Management API endpoint that returns an AI-written
summary of a page as HTML, with headings, lists and links. Add a Lit element,
`page-summary-preview`, in `client/src/summary/summary-preview.element.ts`. It takes a
`documentKey`, loads the summary through `PageSummaryDataSource`, and shows it formatted
(not as raw tags), with the "generated at" time underneath. Just the element, no manifest.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
