---
description: A realistic feature diff hiding three multi-server bugs (direct cache clear, logo on local disk, weekly email job relying on default ServerRoles).
tags: [umbraco-load-balancing, reviewer, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, "Bash(git:*)"]
---

This repo is my Umbraco 17 package. I've finished the "branding and weekly report"
feature; it's the uncommitted change in the working tree. Git can't run here, so the full
diff is in `CHANGE.diff`. Some types it uses (`MyPackageDbContext`, `ReportBuilder`) live
in files I haven't included. Review it before I commit and tell me PASS or FAIL, with
findings.
