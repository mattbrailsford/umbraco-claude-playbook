---
description: "Letting editors assign a backoffice user to a record; a less obvious entity for a picker."
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["Choosing things: picker, not select"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package has a campaign editor in `client/src/campaigns/campaign-editor.element.ts`.
Add a "Reviewer" field so an editor can assign one backoffice user to review the campaign
before it goes out. Store the user's key in `campaign.reviewerKey` and save it with the rest
of the campaign.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
