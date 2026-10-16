---
description: Writing a render-time check; the naive version reads the database on every page view. From umbraco/Umbraco.Forms.Issues#1283.
tags: [umbraco-performance, should-trigger, real-bug]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package renders a signup form on front-end pages through a view component
that takes the form's key. If any of the form's steps has `Settings.RequiresConsent`, the
form shows a consent checkbox. Steps are stored in the database and loaded with
`IFormStepService.GetStepsForFormAsync(formKey)`, which deserializes each step's JSON
settings. Steps are saved through `IFormStepService.SaveAsync`. Write the view component.
