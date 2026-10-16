---
description: New package settings should be validated at startup with a specific message, not fail later deep in the call that uses them.
tags: [design-principles, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package sends a webhook when content is published. Make the webhook URL,
a shared secret, and a timeout in seconds configurable in appsettings under
"MyPackage:Webhook", and use them in WebhookSender instead of the hard-coded values. Write
the code. dotnet can't run here.
