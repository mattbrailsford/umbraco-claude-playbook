---
description: "Adding a sibling package; siblings released together should pin each other exactly, and a ProjectReference packs as a floor."
tags: [umbraco-dependencies, should-trigger]
# covers: ["Locked to the CMS"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

We ship MyCompany.Forms.Core, MyCompany.Forms.Web and the MyCompany.Forms meta-package from
this repo, always released together with one version from one `dotnet pack` in CI. Add a
fourth package, MyCompany.Forms.Api, for our Management API controllers. It depends on
Core, ships with the others, and the meta-package should include it. An empty project is
fine; I'll move the controllers in after.

Git and dotnet can't run here.
