---
description: A realistic uncommitted feature diff hiding three real Umbraco bugs (startup sweep, per-render DB read, unsafeHTML around a localized name). Tests the review gate, not one skill.
tags: [reviewer, should-trigger, real-bug]
# covers: []
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, "Bash(git:*)"]
---

This repo is my Umbraco 17 package. I've finished the "signup imports" feature; it's the
uncommitted change in the working tree. Git can't run here, so the full diff is in
`CHANGE.diff`. Some types it uses (`ImportWorker`, `MyPackageDbContext`, `FormStep`) live in
files I haven't included. Review it before I commit and tell me PASS or FAIL, with findings.
