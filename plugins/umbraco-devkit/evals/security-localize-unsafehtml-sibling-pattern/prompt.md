---
description: "Adding a second confirmation modal next to one that wraps localize.string in unsafeHTML; asset and folder names are editor input. From umbraco/Umbraco-CMS#22731 (GHSA-vr9v-27gg-qgx4)."
tags: [umbraco-security, should-trigger, real-bug]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17.6 asset library extension (`client/`) has an archive confirmation modal in
`client/src/library/modals/`. Add a move confirmation modal next to it, the same way: a
token, the element in `move-asset-modal.element.ts`, and its manifest entry. It shows the
`assetLibrary_moveHeadline` headline and the `assetLibrary_confirmMove` term with the
asset's name and the target folder's name, both in bold as the term says, then Cancel and
Move buttons. Editors name assets and folders themselves.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
