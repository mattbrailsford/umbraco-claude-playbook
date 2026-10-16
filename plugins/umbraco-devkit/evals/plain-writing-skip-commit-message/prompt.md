---
description: Writing a commit message is excluded from plain-writing.
tags: [plain-writing, should-not-trigger]
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Write a Conventional Commits message for this change: the stats dashboard counted
unpublished nodes twice when a page had both a draft and a published version; I changed the
query to group by node key. Reply with just the message.
