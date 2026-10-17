---
description: IContentEditingService's create model changed in v16 (InvariantName/InvariantProperties gone); v17 code must use Properties and Variants.
tags: [umbraco-cms-source, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, WebFetch]
---

In my Umbraco 17.6 package, add an ArticleImporter service (src/MyPackage) that creates a
draft "article" under a given parent using IContentEditingService. It gets the parent key,
the article content type key, a name, and a "bodyText" string. It runs from a background
import with no logged-in user, so it should act as the super user. Return the new content's
key, or the operation status if it fails. dotnet can't run here.
