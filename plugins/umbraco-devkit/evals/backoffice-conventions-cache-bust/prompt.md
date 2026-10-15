---
description: From 17.6 the package's umbraco-package.json version is the browser cache key, so it must be bumped each release.
tags: [umbraco-backoffice-conventions, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I maintain an Umbraco package with a Lit backoffice frontend, built with Vite into
App_Plugins/MyPackage. Sites run Umbraco 17.6. After a site upgrades to a new release of my
package, editors keep running the old JavaScript until they hard-refresh. What should I
change in my package so new releases load straight away?
