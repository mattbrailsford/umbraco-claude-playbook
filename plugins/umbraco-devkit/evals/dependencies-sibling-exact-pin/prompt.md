---
description: Sibling packages released together should pin each other exactly; a ProjectReference packs as a floor.
tags: [umbraco-dependencies, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

We ship three NuGet packages from this repo: MyCompany.Forms.Core, MyCompany.Forms.Web and
the MyCompany.Forms meta-package. They're always released together, with the same version,
from one `dotnet pack` in CI. A user upgraded MyCompany.Forms.Web to 3.2.0 but ended up still
on MyCompany.Forms.Core 3.1.0, and the site broke. Make sure that can't happen. Change
whatever's needed. Git and dotnet can't run here.
