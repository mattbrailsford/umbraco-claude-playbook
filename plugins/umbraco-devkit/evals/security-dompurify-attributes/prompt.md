---
description: Rendering editor-written HTML that may contain the package's own custom elements; a DOMPurify custom-element config with an open attribute check lets on* handlers through. From Umbraco-CMS advisory GHSA-vrqc-59mw-qqg7.
tags: [umbraco-security, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my Umbraco 17.6 backoffice extension (`client/`), `my-pkg-help-text` currently shows
editors' help text as plain text. Editors write it as HTML, and it can include our own
`my-pkg-tooltip` and `my-pkg-badge` elements with their attributes. Make it render as HTML,
with those two elements and their attributes working.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
