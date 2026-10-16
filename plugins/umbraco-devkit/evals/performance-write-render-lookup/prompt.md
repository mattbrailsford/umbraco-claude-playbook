---
description: Writing a front-end view component from scratch; the obvious version reads the database on every page view. From umbraco/Umbraco.Forms.Issues#1283.
tags: [umbraco-performance, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/MyPackage`) needs a view component that renders a signup form
on front-end pages, given the form's key: an email field and a submit button posting to
`/umbraco/surface/signup/submit`. If any of the form's steps has
`Settings.RequiresConsent`, the form also shows a "I agree to the terms" checkbox that must
be ticked. Most sites will put the form in the footer of every page. Write the view
component and its view.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
