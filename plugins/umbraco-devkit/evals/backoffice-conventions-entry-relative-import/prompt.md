---
description: "Adding a wait to a dashboard; from 17.6/18.1 a relative import of the entry file loads it twice. From umbraco/Umbraco.AI#324."
tags: [umbraco-backoffice-conventions, should-trigger, real-bug]
# covers: ["Local vs. global components"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 18.1 package has a backoffice dashboard in `client/`. When an editor opens the
Content section right after logging in, the status dashboard sometimes shows "Status request
failed: 401". Its first request goes out before the entry point has configured the API
client. `entry.ts` already has a `clientReady` promise for this. Fix the dashboard so it
waits for the client before its first request.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
