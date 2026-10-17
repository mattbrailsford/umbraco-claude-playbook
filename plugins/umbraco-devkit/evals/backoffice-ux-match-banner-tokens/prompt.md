---
description: "Adding a banner styled like an existing one that hard-codes colours; the new one should use UUI tokens."
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["Match what's already there"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my Umbraco 17 package, the settings view (`client/src/settings/settings-view.element.ts`)
shows an info banner when the API key is missing. Add a second banner, styled the same
way, that warns when the licence expires in under 30 days (`this._licence.expiresInDays`).

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
