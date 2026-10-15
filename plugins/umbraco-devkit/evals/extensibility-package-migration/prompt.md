---
description: Installing and evolving package content/schema should use a PackageMigrationPlan.
tags: [umbraco-extensibility, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package needs to create a document type and some starter content when it is
installed. In version 2 of the package I'll need to add a new property to that document type
on sites that already have version 1. How should I do this? Show the code and how it's
registered.
