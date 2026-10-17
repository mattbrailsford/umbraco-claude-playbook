---
description: "An OAuth connect flow spans a redirect and a callback that can land on different servers."
tags: [umbraco-load-balancing, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Mailchimp`) needs a "Connect to Mailchimp"
button in its settings. Add the two backend endpoints: `Connect` redirects the backoffice
user to Mailchimp's authorize URL with a `state` value (and a PKCE code challenge), and
`Callback` checks the state, exchanges the code for a token with the verifier, and saves
the token through `MailchimpTokenStore`. The client id and secret are in
`MailchimpOptions`. Several customer sites are load balanced.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
