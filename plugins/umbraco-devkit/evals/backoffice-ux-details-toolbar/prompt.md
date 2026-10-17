---
description: "Adding icon-only toolbar actions, one sometimes disabled, in a package that localizes its strings."
tags: [umbraco-backoffice-ux, should-trigger]
# covers: ["Details that get sent back"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package's subscribers list (`client/src/subscribers/subscribers-list.element.ts`)
lets editors tick rows. Add a small toolbar above the table with three icon-only actions:
Refresh (`this.#load()`), Export to CSV (`this.#repo.exportCsv()`), and Unsubscribe
selected (`this.#repo.unsubscribe(this._selection)`). Unsubscribe only works when at least
one row is ticked.

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
