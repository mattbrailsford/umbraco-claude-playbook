---
description: Writing a client data source; routine failures (404, validation 400, network) come back as { data, error } instead of throwing.
tags: [typescript-best-practices, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my package's TypeScript client (`client/`), add `client/src/connections/connection.data-source.ts`
with a `ConnectionDataSource` class that loads one connection by id and saves one, using the
functions in `api.ts`. A connection can be missing (404), a save can fail validation (400 with
a ProblemDetails body), and the network can drop. The workspace that calls it will show the
error to the editor. Write the code. npm can't run here.
