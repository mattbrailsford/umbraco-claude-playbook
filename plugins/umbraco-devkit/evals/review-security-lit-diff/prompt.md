---
description: A realistic backoffice feature diff hiding three frontend security bugs (unsafeHTML of own-API HTML, DOMPurify letting on* attributes through, a VITE_ API key in the bundle).
tags: [security-lit, reviewer, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, "Bash(git:*)"]
---

This repo is my Umbraco 17 package's backoffice client. I've finished the "AI summary"
workspace view; it's the uncommitted change in the working tree. Git can't run here, so
the full diff is in `CHANGE.diff`. Review it before I commit and tell me PASS or FAIL, with
findings.
