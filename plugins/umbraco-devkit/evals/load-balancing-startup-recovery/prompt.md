---
description: Making interrupted imports resume after a restart; the obvious startup requeue re-runs imports other servers are still running. From umbraco/Umbraco.Automate#388 and umbraco/Umbraco.AI#445.
tags: [umbraco-load-balancing, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.Importer`) runs imports in the background.
Some customer sites run on several load-balanced servers. When the site restarts in the middle of an import (a deploy, an app pool recycle), that run
is left Running and never finishes. Make those imports start again by themselves after the
restart, so nobody has to notice and re-queue them.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
