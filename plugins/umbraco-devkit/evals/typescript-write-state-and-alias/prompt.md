---
description: Modelling a panel's states as a discriminated union, and giving a value object toString/toJSON because it goes into request bodies and logs.
tags: [typescript-best-practices, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my package's TypeScript client (`client/`), add two things to
`client/src/connections/test-panel.ts`:

1. A type for the state of the "Test connection" panel. It's idle until the editor clicks
   Test, then testing, then either passed (with the round-trip time in milliseconds) or
   failed (with the error message), and the editor can test again from either result.
2. A `ProviderAlias` class wrapping a provider's alias string. It's created from user input,
   so it must reject anything that isn't lowercase letters, digits and hyphens. It gets
   passed around the client, put into request bodies that are sent with JSON.stringify,
   and written into log messages in template strings.

Include a small `describeState(state)` function that turns a state into the text the panel
shows. Write the code. npm can't run here.
