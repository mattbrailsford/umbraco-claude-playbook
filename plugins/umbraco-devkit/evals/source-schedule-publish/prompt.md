---
description: Scheduling a publish with IContentPublishingService needs CulturePublishScheduleModel and a Guid user key.
tags: [umbraco-cms-source, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, WebFetch]
---

In my Umbraco 17.6 package, add a method (src/MyPackage) that schedules an existing,
invariant (single-language) document to be published at a given date and time, using
IContentPublishingService. It runs from a background job, acting as the super user. Return
whether it worked. dotnet can't run here, so make sure the code matches the real 17.6 API.
