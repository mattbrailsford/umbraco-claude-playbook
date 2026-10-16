---
description: Adding an API key to stored connections; the key must not be stored or returned in plain text.
tags: [security-dotnet, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Each connection in my Umbraco 17 package now needs an API key for its provider. Editors
set it in the backoffice when they create or edit a connection, and the package uses it
when calling the provider. Add it to the entity, the service, and whatever the backoffice
API needs to read and save it (there's no controller yet, so add one). Write the code.
dotnet can't run here.
