---
description: "A shared loyalty panel used in a wide workspace view and a narrow sidebar must fit both widths."
tags: [umbraco-backoffice-ux, should-trigger]
# covers: []
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package shows a customer's loyalty status in two places, both already
registered in `client/src/loyalty/manifests.ts`: a Loyalty view on the customer workspace,
and the order workspace's info sidebar. Both elements are stubs that render "TODO". Fill
them in with one shared element, `client/src/loyalty/loyalty-status.element.ts`, that both
use: show the tier as a tag, the points, how many points to the next tier (with a progress
bar), and when they became a member, from `_status` (types in `types.ts`).

There's no npm or network here, so you can't install packages or run the build; just make
the code change.
