---
description: "Building a first backoffice element; Lit must come from @umbraco-cms/backoffice/external/lit and @umbraco stays out of the bundle."
tags: [umbraco-backoffice-conventions, should-trigger]
# covers: ["Build output: externalise the backoffice, version every release"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

I'm starting the backoffice client for my Umbraco 17 package in
`src/Umbraco.Community.Greeting/Client`. The manifest is already there. Write the dashboard
element it points at (`src/greeting-dashboard.element.ts`): a Lit element that greets the
editor by a `name` property, defaulting to "editor", in a UUI box. Then add the
`vite.config.ts` that builds it to `../wwwroot/App_Plugins/Greeting/greeting.js`.

npm can't run here; just write the files.
