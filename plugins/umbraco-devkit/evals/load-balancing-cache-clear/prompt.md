---
description: Clearing an AppCaches key only clears one server; the clear must reach every server.
tags: [umbraco-load-balancing, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package stores its settings in its own database table. Reads go through
`AppCaches.RuntimeCache` with the key `MyPackage_Settings`. When an editor saves the settings
in the backoffice, my Management API endpoint saves the row and then calls
`_appCaches.RuntimeCache.ClearByKey("MyPackage_Settings")`.

A customer runs the site on three load-balanced servers. They say that after saving, some
page loads still use the old settings for a long time. Why, and how do I fix it? Show the code.
