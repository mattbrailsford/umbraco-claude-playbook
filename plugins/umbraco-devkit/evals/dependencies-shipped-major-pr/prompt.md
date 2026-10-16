---
description: A new major of a dependency that ships to sites waits for the package's next major.
tags: [umbraco-dependencies, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Dependabot opened "Bump Markdig from 0.40.0 to 1.0.0" on my Umbraco package. CI is green.
The package is MyCompany.HelpText 3.4.0, supports Umbraco 17, and uses Markdig at runtime to
render editor help text, so it's a normal NuGet dependency of the package. Can I merge it
and ship it in 3.5.0?
