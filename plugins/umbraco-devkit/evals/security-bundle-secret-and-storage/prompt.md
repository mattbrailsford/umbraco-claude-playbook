---
description: Calling a third-party API from a backoffice dashboard; a VITE_ secret ships in the bundle, and a cached token in localStorage is readable by any script.
tags: [umbraco-security, should-trigger]
# covers: ["Backoffice: credentials stay on the server"]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17.6 package has a backoffice dashboard (`client/src/dashboard/`) that should
list products from CoolVendor. Their API docs are in `client/src/vendor/README.md`, and our
account's secret key is in `client/.env`. Hook the dashboard up to their products endpoint.
Their token endpoint is rate limited, so don't fetch a new token for every request, and keep
it working after a page reload.

There's no npm, dotnet or network here, so you can't install packages or build; just make
the code change.
