---
description: "A weekly digest email with links built in a background job; there is no request to take the public host from."
tags: [umbraco-load-balancing, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.ReviewDigest`) has a `ReviewDigestBuilder`
that lists pages waiting for review. Add a weekly job that emails the digest to the address
in `ReviewDigestOptions.To`, through Umbraco's `IEmailSender`, with a link for each page
that opens it in the backoffice. Sites using the package run behind a load balancer.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
