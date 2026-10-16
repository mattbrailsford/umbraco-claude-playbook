---
description: project-init on a repo that already has a CLAUDE.md must keep it as is, and show any addition before writing it, one step at a time.
tags: [project-init, workflow]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Run project-init on this repo. Git and dotnet can't run here; we're on `main`.
