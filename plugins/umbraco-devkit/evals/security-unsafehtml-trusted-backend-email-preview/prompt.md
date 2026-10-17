---
description: "Showing a server-rendered email preview built from editor-written templates and member data; it must not render as live markup unsanitized."
tags: [umbraco-security, should-trigger]
# covers: ["Backoffice: sanitizing and escaping"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17.6 member notifications package (`client/`) lets editors write notification
emails. Add the preview pane to `client/src/notifications/email-template-editor.element.ts`:
a member picker for the sample member, a Refresh button, and the email's subject and body
as it would look in an inbox, from `EmailTemplatesService.previewTemplate`.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
