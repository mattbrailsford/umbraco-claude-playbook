---
description: Opening a fixed list of PDF sections to other packages should use an ordered collection builder and offer notifications.
tags: [umbraco-extensibility, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/Umbraco.Community.PagePdf`) turns a content page into a PDF
from a fixed list of sections in `PdfGenerator`. Other packages want to add their own
sections, and put them in a specific place among mine (for example a "Related products"
section just before the footer). Make that possible.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
