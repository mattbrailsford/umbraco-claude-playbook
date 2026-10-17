---
description: "Adding a Markdown preview to a property editor UI with marked and DOMPurify, both of which the backoffice already ships; npm imports bundle second copies."
tags: [umbraco-backoffice-conventions, should-trigger]
# covers: ["Build output: externalise the backoffice, version every release"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package's release notes property editor (`client/`) is a plain textarea where
editors write Markdown. Add an Edit / Preview toggle: Preview shows the Markdown rendered
as HTML, sanitized so a pasted script can't run. Use marked and DOMPurify; they're already
in package.json.

npm can't run here; just make the code change.
