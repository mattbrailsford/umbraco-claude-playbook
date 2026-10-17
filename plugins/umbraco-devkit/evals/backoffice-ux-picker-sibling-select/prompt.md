---
description: "Adding a page reference next to a field that already uses a dropdown of pages."
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["Choosing things: picker, not select"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my Umbraco 17 package, the form settings editor (`client/src/forms/form-settings.element.ts`)
already lets editors choose the "Thank you page" a form redirects to. Add a "Privacy policy
page" setting next to it, stored as `settings.privacyPageKey`.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
