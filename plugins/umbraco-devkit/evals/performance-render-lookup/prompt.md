---
description: Adding a render-time check to a front-end view component; the obvious version reads the database on every page view. From umbraco/Umbraco.Forms.Issues#1283.
tags: [umbraco-performance, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/MyPackage`) renders a signup form on front-end pages through
`SignupFormViewComponent`; most sites put it in the footer of every page. Form steps can now be marked `RequiresConsent`. If any step of
the form requires consent, the form should show a "I agree to the terms" checkbox that must
be ticked. Add that to the view component and its view.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
