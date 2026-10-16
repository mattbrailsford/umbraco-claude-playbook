---
description: project-init in an empty package repo must offer a real dotnet new template, defaulting to opinionated-package-starter, and never hand-write the solution.
tags: [project-init, workflow]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

I'm starting a new Umbraco package, Umbraco.Community.ColorSwatch, a colour swatch property
editor for Umbraco 17. Use project-init to set this repo up. Git and dotnet can't run here.
