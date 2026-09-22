{Optional header row — only if you have real links: a ticket, a plan-folder link, a related PR.
Omit the whole line if there's nothing to link.}

[{Ticket ID}]({ticket_url}) | [{Plan folder}]({plan_folder_link}) | ...

## Why the change

{Exactly one sentence: the problem this PR solves and what becomes possible once it ships.}

## Special things to note

- {1-3 bullets: reviewer warnings, migrations, compatibility constraints, deliberate
  omissions, or surprising decisions. Write "- None." if there genuinely aren't any.}

## Change outline

{Use the smallest combination of views from references/diagram-conventions.md that explains
the implementation. Only include a view that actually changed — omit the rest. Order them
however tells the story best; a data structure or contract usually comes before the code that
uses it.}

{...one short sentence introducing the view...}

```diff
{the diagram}
```

{Repeat for each relevant view — file tree, component tree, call chain, table/contract diff,
manifest registration diff, pseudocode. Prefer `diff` for a change to an existing shape; show
the whole block only when most of it is new or a diff would hide ownership or order.}
