---
description: "An approve-by-email flow: the request, the emailed link and the approval are separate requests that can reach different servers."
tags: [umbraco-extensibility, should-trigger]
# covers: []
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Approvals`) lets an editor ask a manager to
approve a page before it goes live. Add it: a Management API endpoint `RequestApproval`
that takes a document key and a manager's email, and emails the manager (Umbraco's
`IEmailSender`) a link; opening the link shows the page name with Approve and Reject
buttons; Approve publishes the page through `ApprovalPublisher.PublishAsync`. Links should
stop working after 7 days or once used. Our customers' sites are load balanced.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
