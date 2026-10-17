---
description: Adding the API behind a settings screen with a password-style field; the masked value must never come back in a response.
tags: [umbraco-security, should-trigger]
# covers: ["Secrets and sensitive configuration"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/MyPackage.Payments`) is getting a backoffice settings screen for
its payment provider: name, merchant ID, and API key. The screen shows the API key in a
password field. Add the Management API controller the screen needs to load and save the
settings, using `IProviderSettingsService`.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
