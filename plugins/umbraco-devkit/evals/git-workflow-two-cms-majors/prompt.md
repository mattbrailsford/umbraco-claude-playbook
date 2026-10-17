---
description: "A first release supporting two CMS majors: package versions track the CMS major (13.x, 17.x) by default."
tags: [git-workflow, should-trigger]
# covers: ["Umbraco packages and version tracking"]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Tag Cloud works on Umbraco 13 and hasn't had a real release yet. I want the first release to
support both 13 and 17, and I'll keep fixing bugs on 13 for a while because plenty of sites will
stay there. How should I set up the branches and the version numbers? Write the plan into
`docs/versioning.md`. Git can't run here.
