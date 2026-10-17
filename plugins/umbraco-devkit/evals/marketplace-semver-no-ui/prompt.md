---
description: "Announcing v14-17 support without a release; a 10.0.0 floor with no maximum lists as v10-13 unless umbraco-marketplace.json sets SemVer mode."
tags: [umbraco-marketplace, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

We've now tested Slug Rules on Umbraco 14, 15, 16 and 17 and it works on all of them. Update
the repo so the README, CI and the Umbraco Marketplace listing all show support for Umbraco
10 to 17. I don't want to cut a new NuGet release just for this.

Git, dotnet and the network can't run here.
