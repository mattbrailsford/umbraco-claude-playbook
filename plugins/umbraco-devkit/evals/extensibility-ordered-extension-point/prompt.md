---
description: Making a feature extensible should use an ordered collection builder and propose notifications.
tags: [umbraco-extensibility, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I'm building an Umbraco package that turns a content page into a PDF. Other packages should
be able to add their own sections to the PDF, and choose where they appear relative to my
built-in sections. How should I design that extension point? Show the C#.
