---
description: Several interchangeable algorithms picked by alias; one class per format resolved through DI, not a growing switch.
tags: [gof-patterns, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

ReportExporter in my Umbraco 17 package only does CSV. Add JSON and XML. The caller passes
the format as a string from the request ("csv", "json", "xml"), and other packages should
be able to add their own formats later without editing ours. Write the code. dotnet can't
run here.
