---
description: "Adding a delete action on a package made from Umbraco's extension template; its hey-api client resolves errors instead of throwing, so tryExecute shows no notification. From umbraco/Umbraco.AI (ff9cb17b4)."
tags: [umbraco-backoffice-conventions, should-trigger, real-bug]
# covers: ["Generating a typed API client from your Management API"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package's stock alerts dashboard is in `Client/`, made from Umbraco's
extension template. Add a Delete button to each alert, using the `deleteAlert` endpoint
that's already in the generated client. After a delete, the list should refresh.

There's no npm or network here, so you can't install packages, regenerate the client or run
the build; just make the code change.
