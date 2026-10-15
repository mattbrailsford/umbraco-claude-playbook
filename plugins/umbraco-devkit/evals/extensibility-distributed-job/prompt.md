---
description: A job that must run once on a load-balanced v17 site needs IDistributedBackgroundJob, not ServerRoles.
tags: [umbraco-extensibility, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I'm writing an Umbraco 17 package. It needs a nightly job that emails a digest to editors.
Customer sites run a load-balanced backoffice on three servers. The email must go out once
a night, not once per server. How should I build and register this job? Show the code.
