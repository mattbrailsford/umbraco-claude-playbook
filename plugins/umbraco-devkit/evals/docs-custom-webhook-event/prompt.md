---
description: A custom webhook event follows Umbraco's documented WebhookEventBase pattern and registration.
tags: [umbraco-docs, should-trigger]
# covers: ["Read, search, list"]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, WebFetch]
---

My Umbraco 17.6 package publishes OrderSavedNotification (src/MyPackage/Orders). Site owners
want to pick "Order Saved" as an event when they set up a webhook in the backoffice. Add the
webhook event and register it in MyPackageComposer. dotnet can't
run here.
