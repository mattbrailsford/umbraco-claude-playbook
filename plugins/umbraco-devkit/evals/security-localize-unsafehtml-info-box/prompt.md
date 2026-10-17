---
description: "Adding localized lines with markup to an info box; the user and template names are not the developer's to trust. From umbraco/Umbraco-CMS#22731 (GHSA-vr9v-27gg-qgx4)."
tags: [umbraco-security, should-trigger, real-bug]
# covers: ["Backoffice: sanitizing and escaping"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

In my Umbraco 17.6 campaigns extension (`client/`), the campaign Info view
(`client/src/campaigns/workspace/campaign-info.element.ts`) only shows status and
recipients. Under the list, add two lines from the language file: `campaigns_lastEdited`
with who last edited it and the date (formatted for the user's locale), and
`campaigns_createdFrom` with the template name, keeping the bold and italic from the terms.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
