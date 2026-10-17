---
description: Adding a nightly digest email job on a load-balanced v17 site; it needs IDistributedBackgroundJob, not ServerRoles.
tags: [umbraco-extensibility, should-trigger]
# covers: ["10. Recurring background job"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.EditorDigest`) builds a digest of the last
24 hours of content changes with `DigestBuilder`. Add a nightly job that emails it to
`EditorDigestOptions.Recipient` through Umbraco's `IEmailSender`, and register it. Customer
sites run a load-balanced backoffice on three servers.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
