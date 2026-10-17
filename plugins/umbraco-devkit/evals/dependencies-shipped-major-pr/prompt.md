---
description: "Taking Dependabot's Markdig major into a minor release; a major of a shipped dependency waits for the package's own next major."
tags: [umbraco-dependencies, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Get MyCompany.HelpText 3.5.0 ready. It's a small release: pull in Dependabot's open PR
"Bump Markdig from 0.40.0 to 1.0.0" (CI is green on it), bump the version, and add the
changelog entry.

Git and dotnet can't run here.
